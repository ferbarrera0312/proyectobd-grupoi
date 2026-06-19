-- ============================================================
--  PROYECTO FINAL — BASES DE DATOS
--  Escenario C: Sistema de Gestión de Biblioteca Pública
--  Archivo: 03_Consultas.sql
--  Descripción: Consultas SQL requeridas por el escenario
--  Motor: PostgreSQL 17+
-- ============================================================

SET search_path TO biblioteca;

-- ============================================================
-- CONSULTA 1
-- Libros más prestados en los últimos 3 meses
-- Muestra el título, ISBN, y cantidad de préstamos recientes
-- ============================================================
SELECT
    l.titulo,
    l.isbn,
    COUNT(p.id_prestamo)  AS total_prestamos
FROM prestamo p
JOIN ejemplar  e ON e.id_ejemplar = p.id_ejemplar
JOIN libro     l ON l.id_libro    = e.id_libro
WHERE p.fecha_prestamo >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY l.id_libro, l.titulo, l.isbn
ORDER BY total_prestamos DESC;

-- ============================================================
-- CONSULTA 2
-- Socios con multas pendientes
-- Muestra nombre completo, DUI, monto total adeudado y
-- cantidad de multas sin pagar
-- ============================================================
SELECT
    s.id_socio,
    s.nombre || ' ' || s.apellido   AS socio,
    s.dui,
    COUNT(m.id_multa)               AS multas_pendientes,
    SUM(m.monto_total)              AS monto_total_adeudado
FROM socio   s
JOIN multa   m ON m.id_socio = s.id_socio
WHERE m.estado = 'Pendiente'
GROUP BY s.id_socio, s.nombre, s.apellido, s.dui
ORDER BY monto_total_adeudado DESC;

-- ============================================================
-- CONSULTA 3
-- Autores con mayor número de títulos en el catálogo
-- Incluye nombre completo y cantidad de libros
-- ============================================================
SELECT
    a.nombre || ' ' || a.apellido   AS autor,
    a.nacionalidad,
    COUNT(la.id_libro)              AS total_titulos
FROM autor      a
JOIN libro_autor la ON la.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre, a.apellido, a.nacionalidad
ORDER BY total_titulos DESC;

-- ============================================================
-- CONSULTA 4
-- Ejemplares que NUNCA han sido prestados
-- Útil para detectar material sin rotación
-- ============================================================
SELECT
    e.id_ejemplar,
    e.codigo_barras,
    l.titulo,
    l.isbn,
    e.fecha_adquisicion,
    e.estado
FROM ejemplar e
JOIN libro    l ON l.id_libro = e.id_libro
WHERE NOT EXISTS (
    SELECT 1
    FROM   prestamo p
    WHERE  p.id_ejemplar = e.id_ejemplar
)
ORDER BY e.fecha_adquisicion;

-- ============================================================
-- CONSULTA 5
-- Empleado que ha procesado más préstamos en el mes actual
-- ============================================================
SELECT
    em.id_empleado,
    em.nombre || ' ' || em.apellido AS empleado,
    em.cargo,
    COUNT(p.id_prestamo)            AS prestamos_del_mes
FROM empleado em
JOIN prestamo p ON p.id_empleado = em.id_empleado
WHERE DATE_TRUNC('month', p.fecha_prestamo) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY em.id_empleado, em.nombre, em.apellido, em.cargo
ORDER BY prestamos_del_mes DESC
LIMIT 1;

-- ============================================================
-- CONSULTAS ADICIONALES DE APOYO
-- ============================================================

-- A. Verificar disponibilidad de ejemplares de un libro dado su título
SELECT
    l.titulo,
    e.id_ejemplar,
    e.codigo_barras,
    e.estado
FROM libro    l
JOIN ejemplar e ON e.id_libro = l.id_libro
WHERE l.titulo ILIKE '%Cien años%'
ORDER BY e.estado;

-- B. Historial completo de préstamos de un socio
SELECT
    p.id_prestamo,
    l.titulo,
    p.fecha_prestamo,
    p.fecha_limite,
    p.estado                                    AS estado_prestamo,
    d.fecha_devolucion,
    CASE
        WHEN d.fecha_devolucion IS NULL THEN 'No devuelto aún'
        WHEN d.fecha_devolucion > p.fecha_limite THEN 'Devuelto tarde'
        ELSE 'A tiempo'
    END                                         AS resultado,
    m.monto_total                               AS multa
FROM prestamo  p
JOIN ejemplar  e ON e.id_ejemplar = p.id_ejemplar
JOIN libro     l ON l.id_libro    = e.id_libro
LEFT JOIN devolucion d ON d.id_prestamo = p.id_prestamo
LEFT JOIN multa      m ON m.id_prestamo = p.id_prestamo
WHERE p.id_socio = 1                            -- reemplazar con el ID deseado
ORDER BY p.fecha_prestamo DESC;

-- C. Ocupación por categoría (libros, ejemplares y préstamos activos)
SELECT
    c.nombre                         AS categoria,
    COUNT(DISTINCT l.id_libro)       AS total_libros,
    COUNT(DISTINCT e.id_ejemplar)    AS total_ejemplares,
    COUNT(DISTINCT p.id_prestamo)    AS prestamos_activos
FROM categoria c
JOIN libro     l ON l.id_categoria = c.id_categoria
JOIN ejemplar  e ON e.id_libro     = l.id_libro
LEFT JOIN prestamo p ON p.id_ejemplar = e.id_ejemplar AND p.estado = 'Activo'
GROUP BY c.id_categoria, c.nombre
ORDER BY total_prestamos DESC;

-- D. Préstamos próximos a vencer (en los próximos 3 días)
SELECT
    p.id_prestamo,
    s.nombre || ' ' || s.apellido   AS socio,
    s.telefono,
    l.titulo,
    p.fecha_limite,
    p.fecha_limite - CURRENT_DATE   AS dias_restantes
FROM prestamo  p
JOIN socio     s ON s.id_socio    = p.id_socio
JOIN ejemplar  e ON e.id_ejemplar = p.id_ejemplar
JOIN libro     l ON l.id_libro    = e.id_libro
WHERE p.estado = 'Activo'
  AND p.fecha_limite BETWEEN CURRENT_DATE AND CURRENT_DATE + 3
ORDER BY p.fecha_limite;

-- ============================================================
-- FIN DEL SCRIPT DE CONSULTAS
-- ============================================================
