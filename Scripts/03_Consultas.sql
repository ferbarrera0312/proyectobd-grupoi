-- Consulta 1
-- Libros más prestados en los últimos 3 meses
-- muestra el título, isbn, y cantidad de préstamos recientes
select
    l.titulo,
    l.isbn,
    count(p.id_prestamo) total_prestamos
from prestamo p
join ejemplar e on e.id_ejemplar = p.id_ejemplar
join libro l on l.id_libro = e.id_libro
where p.fecha_prestamo >= current_date - interval '3 months'
group by l.id_libro, l.titulo, l.isbn
order by total_prestamos desc;

-- Consulta 2
-- Socios con multas pendientes
-- muestra nombre completo, dui, monto total adeudado y
-- cantidad de multas sin pagar
select
    s.id_socio,
    s.nombre || ' ' || s.apellido socio,
    s.dui,
    count(m.id_multa) multas_pendientes,
    sum(m.monto_total) monto_total_adeudado
from socio s
join multa m on m.id_socio = s.id_socio
where m.estado = 'PENDIENTE'
group by s.id_socio, s.nombre, s.apellido, s.dui
order by monto_total_adeudado desc;

-- Consulta 3
-- Autores con mayor número de títulos en el catálogo
-- incluye nombre completo, nacionalidad y cantidad de libros
select
    a.nombre || ' ' || a.apellido autor,
    a.nacionalidad,
    count(la.id_libro) total_titulos
from autor a
join libro_autor la on la.id_autor = a.id_autor
group by a.id_autor, a.nombre, a.apellido, a.nacionalidad
order by total_titulos desc;

-- Consulta 4
-- Ejemplares que nunca han sido prestados
-- útil para detectar material sin rotación en el inventario
select
    e.id_ejemplar,
    e.codigo_barras,
    l.titulo,
    l.isbn,
    e.fecha_adquisicion,
    e.estado
from ejemplar e
join libro l on l.id_libro = e.id_libro
where not exists (
    select 1
    from prestamo p
    where p.id_ejemplar = e.id_ejemplar
)
order by e.fecha_adquisicion asc;

-- Consulta 5
-- Empleado que ha procesado más préstamos en el mes actual
select
    em.id_empleado,
    em.nombre || ' ' || em.apellido empleado,
    em.cargo,
    count(p.id_prestamo) prestamos_del_mes
from empleado em
join prestamo p on p.id_empleado = em.id_empleado
where date_trunc('month', p.fecha_prestamo) = date_trunc('month', current_date)
group by em.id_empleado, em.nombre, em.apellido, em.cargo
order by prestamos_del_mes desc
limit 1;


-- ============================================================
-- Consultas adicionales de apoyo y monitoreo
-- ============================================================

-- ------------------------------------------------------------
-- A. Verificar disponibilidad de ejemplares dado un título
-- ------------------------------------------------------------
select
    l.titulo,
    e.id_ejemplar,
    e.codigo_barras,
    e.estado
from libro l
join ejemplar e on e.id_libro = l.id_libro
where l.titulo ilike '%Cien años%'
order by e.estado asc;

-- ------------------------------------------------------------
-- B. Historial completo de préstamos de un socio específico
-- ------------------------------------------------------------
select
    p.id_prestamo,
    l.titulo,
    p.fecha_prestamo,
    p.fecha_limite,
    p.estado estado_prestamo,
    d.fecha_devolucion,
    case
        when d.fecha_devolucion is null then 'No devuelto aún'
        when d.fecha_devolucion > p.fecha_limite then 'Devuelto tarde'
        else 'A tiempo'
    end resultado,
    coalesce(m.monto_total, 0.00) multa
from prestamo p
join ejemplar e on e.id_ejemplar = p.id_ejemplar
join libro l on l.id_libro = e.id_libro
left join devolucion d on d.id_prestamo = p.id_prestamo
left join multa m on m.id_prestamo = p.id_prestamo
where p.id_socio = 1
order by p.fecha_prestamo desc;

-- ------------------------------------------------------------
-- c. ocupación por categoría (libros, ejemplares y préstamos activos)
-- ------------------------------------------------------------
select
    c.nombre categoria,
    count(distinct l.id_libro) total_libros,
    count(distinct e.id_ejemplar) total_ejemplares,
    count(distinct p.id_prestamo) prestamos_activos
from categoria c
left join libro l on l.id_categoria = c.id_categoria
left join ejemplar e on e.id_libro = l.id_libro
left join prestamo p on p.id_ejemplar = e.id_ejemplar and p.estado = 'ACTIVO'
group by c.id_categoria, c.nombre
order by total_libros desc;

-- ------------------------------------------------------------
-- d. préstamos próximos a vencer (en los próximos 3 días)
-- ------------------------------------------------------------
select
    p.id_prestamo,
    s.nombre || ' ' || s.apellido socio,
    s.telefono,
    l.titulo,
    p.fecha_limite,
    p.fecha_limite - current_date dias_restantes
from prestamo p
join socio s on s.id_socio = p.id_socio
join ejemplar e on e.id_ejemplar = p.id_ejemplar
join libro l on l.id_libro = e.id_libro
where p.estado = 'ACTIVO'
  and p.fecha_limite between current_date and current_date + 3
order by p.fecha_limite asc;