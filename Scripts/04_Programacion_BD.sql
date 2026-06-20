-- ============================================================
-- sección 1: función auxiliar
-- calcular_dias_retraso(id_prestamo)
-- retorna los días de retraso de un préstamo dado su id.
-- devuelve 0 si no hay retraso o -1 si el préstamo no existe.
-- ============================================================
create or replace function calcular_dias_retraso(p_id_prestamo int)
returns int
language plpgsql
as $$
declare
    v_fecha_limite  date;
    v_dias          int;
begin
    -- Obtener la fecha límite del préstamo
    select fecha_limite
    into   v_fecha_limite
    from   prestamo
    where  id_prestamo = p_id_prestamo;

    -- Si no existe el préstamo, retornar -1 como indicador de error
    if not found then
        return -1;
    end if;

    -- Calcular días de retraso respecto a la fecha actual
    v_dias := greatest(0, (current_date - v_fecha_limite)::int);

    return v_dias;
end;
$$;

-- Ejemplo de uso:
select calcular_dias_retraso(7);

-- ============================================================
-- sección 2: función auxiliar
-- socio_tiene_multas_pendientes(id_socio)
-- retorna true si el socio tiene al menos una multa pendiente.
-- ============================================================
create or replace function socio_tiene_multas_pendientes(p_id_socio int)
returns boolean
language plpgsql
as $$
declare
    v_cantidad int;
begin
    select count(*)
    into   v_cantidad
    from   multa
    where  id_socio = p_id_socio
      and  estado   = 'PENDIENTE'; -- Corregido a MAYÚSCULAS

    return v_cantidad > 0;
end;
$$;


-- Ejemplo de uso:
select socio_tiene_multas_pendientes(6);


-- ============================================================
-- sección 3: función auxiliar
-- prestamos_activos_socio(id_socio)
-- retorna la cantidad de préstamos activos del socio.
-- ============================================================
create or replace function prestamos_activos_socio(p_id_socio int)
returns int
language plpgsql
as $$
declare
    v_cantidad int;
begin
    select count(*)
    into   v_cantidad
    from   prestamo
    where  id_socio = p_id_socio
      and  estado   = 'ACTIVO'; 

    return v_cantidad;
end;
$$;

-- Ejemplo de uso:
select prestamos_activos_socio(1);



-- ============================================================
-- sección 4: trigger lógico
-- trg_generar_multa_por_retraso
--
-- se activa after insert en la tabla devolución.
-- calcula el retraso, inserta la multa si aplica, cambia el
-- estado del préstamo a 'DEVUELTO' y el ejemplar a 'DISPONIBLE'.
-- ============================================================

-- 4.1 Función que ejecuta la lógica del trigger
create or replace function fn_generar_multa_por_retraso()
returns trigger
language plpgsql
as $$
declare
    v_fecha_limite  date;
    v_id_socio      int;
    v_dias_retraso  int;
    v_monto_dia     numeric(6,2) := 0.50;   -- Tarifa estándar por día de retraso
    v_monto_total   numeric(10,2);
begin
    -- Obtener datos del préstamo relacionado con la devolución recién insertada
    select p.fecha_limite, p.id_socio
    into   v_fecha_limite, v_id_socio
    from   prestamo p
    where  p.id_prestamo = new.id_prestamo;

    -- Calcular días de retraso exactos basándose en la fecha de devolución registrada
    v_dias_retraso := (new.fecha_devolucion - v_fecha_limite)::int;

    -- Solo actuar si existe retraso físico
    if v_dias_retraso > 0 then
        v_monto_total := v_dias_retraso * v_monto_dia;

        -- Insertar la multa correspondiente de forma segura
        insert into multa (
            id_prestamo,
            id_socio,
            dias_retraso,
            monto_por_dia,
            monto_total,
            estado,
            fecha_generacion
        )
        values (
            new.id_prestamo,
            v_id_socio,
            v_dias_retraso,
            v_monto_dia,
            v_monto_total,
            'PENDIENTE', 
            current_date
        )
        on conflict (id_prestamo) do nothing;

        raise notice 'Multa generada de manera automática: % días de retraso, monto total: $%',
            v_dias_retraso, v_monto_total;
    end if;

    -- Actualizar el estado del préstamo a DEVUELTO (Garantiza consistencia del negocio)
    update prestamo
    set    estado = 'DEVUELTO' -- Corregido a MAYÚSCULAS
    where  id_prestamo = new.id_prestamo;

    -- Liberar el ejemplar asignado de forma automática cambiándolo a DISPONIBLE
    update ejemplar
    set    estado = 'DISPONIBLE' -- Corregido a MAYÚSCULAS
    where  id_ejemplar = (
        select pr.id_ejemplar 
        from   prestamo pr 
        where  pr.id_prestamo = new.id_prestamo
    );

    return new;
end;
$$;

-- 4.2 Definición formal del disparador en la tabla
create or replace trigger trg_generar_multa_por_retraso
    after insert on devolucion
    for each row
    execute function fn_generar_multa_por_retraso();


-- ============================================================
-- sección 5: procedimiento almacenado (transaccional)
-- sp_procesar_prestamo
--
-- valida las reglas de negocio de la biblioteca de forma atómica.
-- si cumple, inserta el préstamo y pasa el ejemplar a 'PRESTADO'.
-- ============================================================
create or replace procedure sp_procesar_prestamo(
    in  p_id_socio      int,
    in  p_id_ejemplar   int,
    in  p_id_empleado   int,
    out p_id_prestamo   int,
    out p_mensaje       text,
    in  p_dias_prestamo int     default 15
)
language plpgsql
as $$
declare
    v_estado_ejemplar   varchar(20);
    v_socio_active      boolean;
    v_prestamos_activos int;
    v_tiene_multas      boolean;
begin
    -- -------------------------------------------------------
    -- VALIDACIÓN 1: El ejemplar debe existir y estar DISPONIBLE
    -- -------------------------------------------------------
    select estado
    into   v_estado_ejemplar
    from   ejemplar
    where  id_ejemplar = p_id_ejemplar;

    if not found then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El ejemplar con ID ' || p_id_ejemplar || ' no existe en el catálogo.';
        return;
    end if;

    if v_estado_ejemplar <> 'DISPONIBLE' then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El ejemplar no está disponible para préstamo. Estado actual: ' || v_estado_ejemplar;
        return;
    end if;

    -- -------------------------------------------------------
    -- VALIDACIÓN 2: El socio debe existir y estar activo
    -- -------------------------------------------------------
    select activo
    into   v_socio_active
    from   socio
    where  id_socio = p_id_socio;

    if not found then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El socio con ID ' || p_id_socio || ' no existe.';
        return;
    end if;

    if not v_socio_active then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El socio se encuentra INACTIVO dentro de la institución.';
        return;
    end if;

    -- -------------------------------------------------------
    -- VALIDACIÓN 3: El socio no debe tener multas pendientes
    -- -------------------------------------------------------
    v_tiene_multas := socio_tiene_multas_pendientes(p_id_socio);

    if v_tiene_multas then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El socio registra multas PENDIENTES. Debe solventar su saldo.';
        return;
    end if;

    -- -------------------------------------------------------
    -- VALIDACIÓN 4: Límite operacional (Máximo 3 préstamos activos)
    -- -------------------------------------------------------
    v_prestamos_activos := prestamos_activos_socio(p_id_socio);

    if v_prestamos_activos >= 3 then
        p_id_prestamo := null;
        p_mensaje     := 'ERROR: El socio excede el límite permitido de préstamos activos (Límite: 3, Actuales: ' || v_prestamos_activos || ').';
        return;
    end if;

    -- -------------------------------------------------------
    -- EJECUCIÓN DEL PROCESO (Escritura en Tablas)
    -- -------------------------------------------------------
    insert into prestamo (
        id_socio,
        id_ejemplar,
        id_empleado,
        fecha_prestamo,
        fecha_limite,
        estado
    )
    values (
        p_id_socio,
        p_id_ejemplar,
        p_id_empleado,
        current_date,
        current_date + p_dias_prestamo,
        'ACTIVO'
    )
    returning id_prestamo into p_id_prestamo;

    -- Modificar el estado del ejemplar a PRESTADO
    update ejemplar
    set    estado = 'PRESTADO'
    where  id_ejemplar = p_id_ejemplar;

    p_mensaje := 'OK: Préstamo asentado con éxito. ID Asignado: '
                 || p_id_prestamo
                 || '. Fecha límite establecida de retorno: '
                 || (current_date + p_dias_prestamo)::text;

    -- Commit eliminado El bloque se confirma automáticamente al finalizar exitosamente.

exception
    when others then
        -- En caso de error inesperado, el motor ya abortó la subtransacción.
        -- Simplemente capturamos el mensaje para no romper la app cliente.
        p_id_prestamo := null;
        p_mensaje     := 'ERROR transaccional inesperado: ' || sqlerrm;
end;
$$;


-- Ejemplo de uso
do $$
	declare
		v_id int;

v_msg text;

begin
-- Al terminar en v_msg, el sistema aplica el DEFAULT 15 automáticamente
	call sp_procesar_prestamo(1, 2, 2, v_id, v_msg);

raise notice '%',
v_msg;
end $$;


-- ============================================================
-- sección 6: función tabular
-- fn_historial_socio(id_socio)
-- retorna el historial dinámico de préstamos de un usuario.
-- ============================================================
create or replace function fn_historial_socio(p_id_socio int)
returns table (
    id_prestamo         int,
    titulo              varchar(300),
    codigo_barras       varchar(50),
    fecha_prestamo      date,
    fecha_limite        date,
    estado_prestamo     varchar(20),
    fecha_devolucion    date,
    dias_retraso        int,
    monto_multa         numeric(10,2)
)
language plpgsql
as $$
begin
    return query
    select
        p.id_prestamo,
        l.titulo,
        e.codigo_barras,
        p.fecha_prestamo,
        p.fecha_limite,
        p.estado,
        d.fecha_devolucion,
        coalesce(m.dias_retraso, 0)     dias_retraso,
        coalesce(m.monto_total,  0.00)  monto_multa 
    from  prestamo p
    join  ejemplar e on e.id_ejemplar = p.id_ejemplar
    join  libro l on l.id_libro = e.id_libro
    left join devolucion d on d.id_prestamo = p.id_prestamo
    left join multa m on m.id_prestamo = p.id_prestamo
    where p.id_socio = p_id_socio
    order by p.fecha_prestamo desc;
end;
$$;

-- Ejemplo de uso:
select * from fn_historial_socio(1);