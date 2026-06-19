-- ============================================================
--  PROYECTO FINAL — BASES DE DATOS
--  Escenario C: Sistema de Gestión de Biblioteca Pública
--  Archivo: 04_Programacion_BD.sql
--  Descripción: Trigger, Procedimiento Almacenado y Funciones
--  Motor: PostgreSQL 17+
-- ============================================================

SET search_path TO biblioteca;

-- ============================================================
-- SECCIÓN 1: FUNCIÓN AUXILIAR
-- calcular_dias_retraso(id_prestamo)
-- Retorna los días de retraso de un préstamo dado su ID.
-- Devuelve 0 si no hay retraso.
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_dias_retraso(p_id_prestamo INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_limite  DATE;
    v_dias          INT;
BEGIN
    -- Obtener la fecha límite del préstamo
    SELECT fecha_limite
    INTO   v_fecha_limite
    FROM   prestamo
    WHERE  id_prestamo = p_id_prestamo;

    -- Si no existe el préstamo, retornar -1 como indicador de error
    IF NOT FOUND THEN
        RETURN -1;
    END IF;

    -- Calcular días de retraso respecto a la fecha actual
    v_dias := GREATEST(0, (CURRENT_DATE - v_fecha_limite)::INT);

    RETURN v_dias;
END;
$$;

-- Ejemplo de uso:
-- SELECT calcular_dias_retraso(7);


-- ============================================================
-- SECCIÓN 2: FUNCIÓN AUXILIAR
-- socio_tiene_multas_pendientes(id_socio)
-- Retorna TRUE si el socio tiene al menos una multa pendiente.
-- ============================================================
CREATE OR REPLACE FUNCTION socio_tiene_multas_pendientes(p_id_socio INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_cantidad INT;
BEGIN
    SELECT COUNT(*)
    INTO   v_cantidad
    FROM   multa
    WHERE  id_socio = p_id_socio
      AND  estado   = 'Pendiente';

    RETURN v_cantidad > 0;
END;
$$;

-- Ejemplo de uso:
-- SELECT socio_tiene_multas_pendientes(6);


-- ============================================================
-- SECCIÓN 3: FUNCIÓN AUXILIAR
-- prestamos_activos_socio(id_socio)
-- Retorna la cantidad de préstamos activos del socio.
-- ============================================================
CREATE OR REPLACE FUNCTION prestamos_activos_socio(p_id_socio INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cantidad INT;
BEGIN
    SELECT COUNT(*)
    INTO   v_cantidad
    FROM   prestamo
    WHERE  id_socio = p_id_socio
      AND  estado   = 'Activo';

    RETURN v_cantidad;
END;
$$;

-- Ejemplo de uso:
-- SELECT prestamos_activos_socio(1);


-- ============================================================
-- SECCIÓN 4: TRIGGER
-- trg_generar_multa_por_retraso
--
-- Se activa AFTER INSERT en la tabla devolución.
-- Si la devolución ocurre después de la fecha_límite del
-- préstamo, inserta automáticamente un registro en la tabla
-- multa y actualiza el estado del préstamo a 'Devuelto'.
-- ============================================================

-- 4.1 Función que ejecuta el trigger
CREATE OR REPLACE FUNCTION fn_generar_multa_por_retraso()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_limite  DATE;
    v_id_socio      INT;
    v_dias_retraso  INT;
    v_monto_dia     NUMERIC(6,2) := 0.50;   -- $0.50 por día de retraso
    v_monto_total   NUMERIC(10,2);
BEGIN
    -- Obtener datos del préstamo relacionado con la devolución recién insertada
    SELECT p.fecha_limite, p.id_socio
    INTO   v_fecha_limite, v_id_socio
    FROM   prestamo p
    WHERE  p.id_prestamo = NEW.id_prestamo;

    -- Calcular días de retraso
    v_dias_retraso := (NEW.fecha_devolucion - v_fecha_limite)::INT;

    -- Solo actuar si existe retraso
    IF v_dias_retraso > 0 THEN

        v_monto_total := v_dias_retraso * v_monto_dia;

        -- Insertar la multa (verificar que no exista ya una para este préstamo)
        INSERT INTO multa (
            id_prestamo,
            id_socio,
            dias_retraso,
            monto_por_dia,
            monto_total,
            estado,
            fecha_generacion
        )
        VALUES (
            NEW.id_prestamo,
            v_id_socio,
            v_dias_retraso,
            v_monto_dia,
            v_monto_total,
            'Pendiente',
            CURRENT_DATE
        )
        ON CONFLICT (id_prestamo) DO NOTHING;   -- evitar duplicado si ya existe

        RAISE NOTICE 'Multa generada: % días de retraso, monto $%',
            v_dias_retraso, v_monto_total;
    END IF;

    -- Actualizar el estado del préstamo a Devuelto
    UPDATE prestamo
    SET    estado = 'Devuelto'
    WHERE  id_prestamo = NEW.id_prestamo;

    -- Liberar el ejemplar (volver a Disponible)
    UPDATE ejemplar
    SET    estado = 'Disponible'
    WHERE  id_ejemplar = (
        SELECT id_ejemplar FROM prestamo WHERE id_prestamo = NEW.id_prestamo
    );

    RETURN NEW;
END;
$$;

-- 4.2 Crear el trigger sobre la tabla devolucion
CREATE OR REPLACE TRIGGER trg_generar_multa_por_retraso
    AFTER INSERT ON devolucion
    FOR EACH ROW
    EXECUTE FUNCTION fn_generar_multa_por_retraso();


-- ============================================================
-- SECCIÓN 5: PROCEDIMIENTO ALMACENADO
-- sp_procesar_prestamo
--
-- Procesa el préstamo de un ejemplar realizando las siguientes
-- validaciones antes de registrar:
--   1. Verificar que el ejemplar exista y esté disponible.
--   2. Verificar que el socio esté activo.
--   3. Verificar que el socio NO tenga multas pendientes.
--   4. Verificar que el socio NO supere el límite de 3 préstamos activos.
-- Si todo es válido, registra el préstamo, actualiza el estado
-- del ejemplar y retorna el ID del préstamo generado.
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_procesar_prestamo(
    IN  p_id_socio      INT,
    IN  p_id_ejemplar   INT,
    IN  p_id_empleado   INT,
    IN  p_dias_prestamo INT   DEFAULT 15,   -- plazo en días (por defecto 15)
    OUT p_id_prestamo   INT,
    OUT p_mensaje       TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_ejemplar   VARCHAR(20);
    v_socio_activo      BOOLEAN;
    v_prestamos_activos INT;
    v_tiene_multas      BOOLEAN;
BEGIN
    -- -------------------------------------------------------
    -- VALIDACIÓN 1: El ejemplar debe existir y estar Disponible
    -- -------------------------------------------------------
    SELECT estado
    INTO   v_estado_ejemplar
    FROM   ejemplar
    WHERE  id_ejemplar = p_id_ejemplar;

    IF NOT FOUND THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El ejemplar con ID ' || p_id_ejemplar || ' no existe.';
        RETURN;
    END IF;

    IF v_estado_ejemplar <> 'Disponible' THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El ejemplar no está disponible. Estado actual: ' || v_estado_ejemplar;
        RETURN;
    END IF;

    -- -------------------------------------------------------
    -- VALIDACIÓN 2: El socio debe existir y estar activo
    -- -------------------------------------------------------
    SELECT activo
    INTO   v_socio_activo
    FROM   socio
    WHERE  id_socio = p_id_socio;

    IF NOT FOUND THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El socio con ID ' || p_id_socio || ' no existe.';
        RETURN;
    END IF;

    IF NOT v_socio_activo THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El socio está inactivo y no puede realizar préstamos.';
        RETURN;
    END IF;

    -- -------------------------------------------------------
    -- VALIDACIÓN 3: El socio no debe tener multas pendientes
    -- -------------------------------------------------------
    v_tiene_multas := socio_tiene_multas_pendientes(p_id_socio);

    IF v_tiene_multas THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El socio tiene multas pendientes. Debe cancelarlas antes de solicitar un préstamo.';
        RETURN;
    END IF;

    -- -------------------------------------------------------
    -- VALIDACIÓN 4: El socio no debe superar 3 préstamos activos
    -- -------------------------------------------------------
    v_prestamos_activos := prestamos_activos_socio(p_id_socio);

    IF v_prestamos_activos >= 3 THEN
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR: El socio ya tiene ' || v_prestamos_activos
                         || ' préstamos activos. El límite permitido es 3.';
        RETURN;
    END IF;

    -- -------------------------------------------------------
    -- REGISTRAR EL PRÉSTAMO
    -- -------------------------------------------------------
    INSERT INTO prestamo (
        id_socio,
        id_ejemplar,
        id_empleado,
        fecha_prestamo,
        fecha_limite,
        estado
    )
    VALUES (
        p_id_socio,
        p_id_ejemplar,
        p_id_empleado,
        CURRENT_DATE,
        CURRENT_DATE + p_dias_prestamo,
        'Activo'
    )
    RETURNING id_prestamo INTO p_id_prestamo;

    -- Actualizar el estado del ejemplar a Prestado
    UPDATE ejemplar
    SET    estado = 'Prestado'
    WHERE  id_ejemplar = p_id_ejemplar;

    p_mensaje := 'OK: Préstamo registrado exitosamente. ID de préstamo: '
                 || p_id_prestamo
                 || '. Fecha límite: '
                 || (CURRENT_DATE + p_dias_prestamo)::TEXT;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_id_prestamo := NULL;
        p_mensaje     := 'ERROR inesperado: ' || SQLERRM;
END;
$$;

-- Ejemplo de uso:
-- DO $$
-- DECLARE
--     v_id   INT;
--     v_msg  TEXT;
-- BEGIN
--     CALL sp_procesar_prestamo(
--         p_id_socio    => 1,
--         p_id_ejemplar => 2,
--         p_id_empleado => 2,
--         p_id_prestamo => v_id,
--         p_mensaje     => v_msg
--     );
--     RAISE NOTICE '%', v_msg;
-- END;
-- $$;


-- ============================================================
-- SECCIÓN 6: FUNCIÓN TABULAR — HISTORIAL CLÍNICO
-- fn_historial_socio(id_socio)
-- Retorna el historial completo de préstamos de un socio.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_historial_socio(p_id_socio INT)
RETURNS TABLE (
    id_prestamo         INT,
    titulo              VARCHAR(300),
    codigo_barras       VARCHAR(50),
    fecha_prestamo      DATE,
    fecha_limite        DATE,
    estado_prestamo     VARCHAR(20),
    fecha_devolucion    DATE,
    dias_retraso        INT,
    monto_multa         NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_prestamo,
        l.titulo,
        e.codigo_barras,
        p.fecha_prestamo,
        p.fecha_limite,
        p.estado,
        d.fecha_devolucion,
        COALESCE(m.dias_retraso, 0)     AS dias_retraso,
        COALESCE(m.monto_total,  0.00)  AS monto_multa
    FROM  prestamo   p
    JOIN  ejemplar   e  ON  e.id_ejemplar = p.id_ejemplar
    JOIN  libro      l  ON  l.id_libro    = e.id_libro
    LEFT JOIN devolucion d ON d.id_prestamo = p.id_prestamo
    LEFT JOIN multa      m ON m.id_prestamo = p.id_prestamo
    WHERE p.id_socio = p_id_socio
    ORDER BY p.fecha_prestamo DESC;
END;
$$;

-- Ejemplo de uso:
-- SELECT * FROM fn_historial_socio(1);

-- ============================================================
-- FIN DEL SCRIPT DE PROGRAMACIÓN EN LA BASE DE DATOS
-- ============================================================
