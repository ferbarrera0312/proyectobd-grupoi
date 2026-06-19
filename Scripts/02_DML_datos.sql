-- ============================================================
--  PROYECTO FINAL — BASES DE DATOS
--  Escenario C: Sistema de Gestión de Biblioteca Pública
--  Archivo: 02_DML_datos.sql
--  Descripción: Carga inicial de datos representativos
--  Motor: PostgreSQL 17+
-- ============================================================

SET search_path TO biblioteca;

-- ------------------------------------------------------------
-- 1. EDITORIALES
-- ------------------------------------------------------------
INSERT INTO editorial (nombre, pais, telefono, correo) VALUES
('Alfaguara',          'España',    '+34-91-744-9060', 'info@alfaguara.com'),
('Planeta',            'España',    '+34-93-496-7000', 'info@planeta.es'),
('Anagrama',           'España',    '+34-93-339-9620', 'info@anagrama-ed.es'),
('Fondo de Cultura',   'México',    '+52-55-5227-4672','fce@fondodec.com'),
('Norma',              'Colombia',  '+57-1-221-9900',  'info@norma.com'),
('Santillana',         'España',    '+34-91-744-9060', 'info@santillana.com');

-- ------------------------------------------------------------
-- 2. CATEGORÍAS
-- ------------------------------------------------------------
INSERT INTO categoria (nombre, descripcion) VALUES
('Novela',             'Obras de ficción narrativa larga'),
('Ciencia Ficción',    'Ficción basada en ciencia y tecnología futura'),
('Historia',           'Obras sobre eventos y períodos históricos'),
('Filosofía',          'Obras de pensamiento y reflexión filosófica'),
('Programación',       'Libros técnicos de desarrollo de software'),
('Infantil',           'Literatura dirigida a niños y jóvenes'),
('Poesía',             'Obras en verso'),
('Derecho',            'Legislación, jurisprudencia y teoría jurídica');

-- ------------------------------------------------------------
-- 3. AUTORES
-- ------------------------------------------------------------
INSERT INTO autor (nombre, apellido, nacionalidad, fecha_nac) VALUES
('Gabriel',   'García Márquez', 'Colombiano',  '1927-03-06'),
('Isabel',    'Allende',        'Chilena',     '1942-08-02'),
('Mario',     'Vargas Llosa',   'Peruano',     '1936-03-28'),
('Jorge Luis','Borges',         'Argentino',   '1899-08-24'),
('Octavio',   'Paz',            'Mexicano',    '1914-03-31'),
('Julio',     'Cortázar',       'Argentino',   '1914-08-26'),
('George',    'Orwell',         'Británico',   '1903-06-25'),
('Isaac',     'Asimov',         'Estadounidense','1920-01-02'),
('Robert',    'Martin',         'Estadounidense','1952-12-05'),
('Donald',    'Knuth',          'Estadounidense','1938-01-10'),
('Laura',     'Méndez',         'Salvadoreña', '1985-06-15'),
('Carlos',    'Fuentes',        'Mexicano',    '1928-11-11');

-- ------------------------------------------------------------
-- 4. LIBROS
-- ------------------------------------------------------------
INSERT INTO libro (isbn, titulo, anio_publicacion, id_editorial, id_categoria, descripcion) VALUES
('978-84-204-8864-0','Cien años de soledad',        1967, 1, 1, 'Obra maestra del realismo mágico latinoamericano'),
('978-84-408-0240-5','La casa de los espíritus',    1982, 2, 1, 'Saga familiar en un país latinoamericano imaginario'),
('978-84-204-6421-0','La ciudad y los perros',      1963, 1, 1, 'Primera novela de Vargas Llosa sobre una academia militar'),
('978-84-204-4108-1','Ficciones',                   1944, 1, 1, 'Colección de cuentos filosóficos y fantásticos de Borges'),
('978-84-204-9901-1','El laberinto de la soledad',  1950, 4, 4, 'Ensayo sobre la identidad mexicana'),
('978-84-376-0494-1','Rayuela',                     1963, 3, 1, 'Novela experimental de Cortázar'),
('978-84-350-0001-2','1984',                        1949, 2, 2, 'Distopía política del totalitarismo'),
('978-84-350-0002-9','Fundación',                   1951, 2, 2, 'Primer volumen de la saga de la Fundación de Asimov'),
('978-84-350-0003-6','Código Limpio',               2008, 2, 5, 'Guía de buenas prácticas en programación'),
('978-84-350-0004-3','El Arte de la Programación',  1968, 2, 5, 'Obra de referencia fundamental de Knuth'),
('978-84-350-0005-0','El principito',               1943, 6, 6, 'Clásico de la literatura infantil universal'),
('978-84-350-0006-7','Pedro Páramo',                1955, 4, 1, 'Novela de Juan Rulfo sobre un pueblo fantasma');

-- Relación Libro–Autor
INSERT INTO libro_autor (id_libro, id_autor, rol) VALUES
(1,  1, 'Principal'),
(2,  2, 'Principal'),
(3,  3, 'Principal'),
(4,  4, 'Principal'),
(5,  5, 'Principal'),
(6,  6, 'Principal'),
(7,  7, 'Principal'),
(8,  8, 'Principal'),
(9,  9, 'Principal'),
(10, 10,'Principal'),
(11, 11,'Traductor'),   -- autor original Antoine de Saint-Exupéry; aquí usamos a Méndez como traductor ficticio
(12, 12,'Principal');

-- ------------------------------------------------------------
-- 5. EJEMPLARES (3–5 copias por libro popular)
-- ------------------------------------------------------------
INSERT INTO ejemplar (id_libro, codigo_barras, estado, fecha_adquisicion) VALUES
-- Cien años de soledad
(1, 'EJ-001-A', 'Disponible',  '2020-01-10'),
(1, 'EJ-001-B', 'Disponible',  '2020-01-10'),
(1, 'EJ-001-C', 'Prestado',    '2020-01-10'),
-- La casa de los espíritus
(2, 'EJ-002-A', 'Disponible',  '2020-02-15'),
(2, 'EJ-002-B', 'Prestado',    '2020-02-15'),
-- La ciudad y los perros
(3, 'EJ-003-A', 'Disponible',  '2021-03-20'),
(3, 'EJ-003-B', 'Dañado',      '2021-03-20'),
-- Ficciones
(4, 'EJ-004-A', 'Disponible',  '2019-06-01'),
(4, 'EJ-004-B', 'Disponible',  '2019-06-01'),
-- El laberinto de la soledad
(5, 'EJ-005-A', 'Disponible',  '2021-07-12'),
-- Rayuela
(6, 'EJ-006-A', 'Disponible',  '2018-09-05'),
(6, 'EJ-006-B', 'Prestado',    '2018-09-05'),
-- 1984
(7, 'EJ-007-A', 'Disponible',  '2019-11-20'),
(7, 'EJ-007-B', 'Disponible',  '2022-01-08'),
-- Fundación
(8, 'EJ-008-A', 'Disponible',  '2022-03-14'),
-- Código Limpio
(9, 'EJ-009-A', 'Disponible',  '2023-01-10'),
(9, 'EJ-009-B', 'Prestado',    '2023-01-10'),
-- Arte de la Programación
(10,'EJ-010-A', 'Disponible',  '2021-05-22'),
-- El principito (nunca prestado — útil para la consulta)
(11,'EJ-011-A', 'Disponible',  '2024-08-01'),
-- Pedro Páramo
(12,'EJ-012-A', 'Disponible',  '2020-10-15'),
(12,'EJ-012-B', 'Disponible',  '2020-10-15');

-- ------------------------------------------------------------
-- 6. EMPLEADOS
-- ------------------------------------------------------------
INSERT INTO empleado (nombre, apellido, dui, cargo, telefono, correo, fecha_ingreso) VALUES
('Ana',      'García',   '00000001-0', 'Jefe de Biblioteca',   '7600-0001', 'ana.garcia@biblioteca.gob.sv',   '2015-03-01'),
('Roberto',  'Morales',  '00000002-0', 'Bibliotecario',        '7600-0002', 'roberto.m@biblioteca.gob.sv',    '2018-06-15'),
('Sofía',    'Hernández','00000003-0', 'Bibliotecario',        '7600-0003', 'sofia.h@biblioteca.gob.sv',      '2019-01-20'),
('Marcos',   'López',    '00000004-0', 'Auxiliar',             '7600-0004', 'marcos.l@biblioteca.gob.sv',     '2021-07-01'),
('Carmen',   'Vásquez',  '00000005-0', 'Auxiliar',             '7600-0005', 'carmen.v@biblioteca.gob.sv',     '2022-02-14');

-- ------------------------------------------------------------
-- 7. SOCIOS
-- ------------------------------------------------------------
INSERT INTO socio (nombre, apellido, dui, telefono, correo, direccion, fecha_registro) VALUES
('Luis',      'Martínez',  '10000001-0', '7700-1001', 'luis.m@mail.com',    'Calle 1, Col. San Benito, SS',        '2022-01-10'),
('María',     'Torres',    '10000002-0', '7700-1002', 'maria.t@mail.com',   'Av. Independencia 45, Santa Ana',     '2022-03-22'),
('Juan',      'Rodríguez', '10000003-0', '7700-1003', 'juan.r@mail.com',    'Reparto Miramonte, SS',               '2021-11-05'),
('Valentina', 'Cruz',      '10000004-0', '7700-1004', 'vale.c@mail.com',    'Col. Escalón, SS',                    '2023-02-14'),
('Diego',     'Reyes',     '10000005-0', '7700-1005', 'diego.r@mail.com',   'Pasaje Las Flores, Soyapango',        '2022-08-30'),
('Patricia',  'Lima',      '10000006-0', '7700-1006', 'patri.l@mail.com',   'Col. Guadalupe, San Miguel',          '2023-05-10'),
('Fernando',  'Aguilar',   '10000007-0', '7700-1007', 'fernando.a@mail.com','Bo. San Jacinto, SS',                 '2024-01-18'),
('Gabriela',  'Montes',    '10000008-0', '7700-1008', 'gaby.m@mail.com',    'Urb. California, Antiguo Cuscatlán', '2024-03-07');

-- ------------------------------------------------------------
-- 8. PRÉSTAMOS (mezcla de activos, vencidos y devueltos)
-- ------------------------------------------------------------
INSERT INTO prestamo (id_socio, id_ejemplar, id_empleado, fecha_prestamo, fecha_limite, estado) VALUES
-- Préstamos activos (aún en curso)
(1, 3,  2, CURRENT_DATE - 5,  CURRENT_DATE + 10, 'Activo'),   -- Luis tiene EJ-001-C
(2, 5,  2, CURRENT_DATE - 3,  CURRENT_DATE + 12, 'Activo'),   -- María tiene EJ-002-B
(3, 12, 3, CURRENT_DATE - 8,  CURRENT_DATE + 7,  'Activo'),   -- Juan tiene EJ-006-B
-- Préstamos ya devueltos (histórico)
(4, 17, 2, CURRENT_DATE - 40, CURRENT_DATE - 25, 'Devuelto'), -- Valentina devolvió EJ-009-B
(5, 7,  3, CURRENT_DATE - 60, CURRENT_DATE - 45, 'Devuelto'), -- Diego devolvió EJ-007-A
(1, 8,  2, CURRENT_DATE - 90, CURRENT_DATE - 75, 'Devuelto'), -- Luis devolvió EJ-004-A (antiguo)
-- Préstamos vencidos (para generar multas)
(6, 18, 4, CURRENT_DATE - 30, CURRENT_DATE - 15, 'Vencido'),  -- Patricia: 15 días vencido
(7, 20, 4, CURRENT_DATE - 25, CURRENT_DATE - 10, 'Vencido'),  -- Fernando: 10 días vencido
-- Préstamos adicionales para el último mes (para consultas de ranking)
(2, 9,  3, CURRENT_DATE - 20, CURRENT_DATE - 5,  'Devuelto'),
(3, 13, 2, CURRENT_DATE - 15, CURRENT_DATE,      'Devuelto'),
(4, 1,  3, CURRENT_DATE - 10, CURRENT_DATE + 5,  'Devuelto'),
(5, 14, 2, CURRENT_DATE - 55, CURRENT_DATE - 40, 'Devuelto');

-- ------------------------------------------------------------
-- 9. DEVOLUCIONES
-- ------------------------------------------------------------
-- Devolución normal (a tiempo)
INSERT INTO devolucion (id_prestamo, id_empleado, fecha_devolucion, observacion) VALUES
(4,  3, CURRENT_DATE - 25, 'Devolución en buen estado'),
(5,  2, CURRENT_DATE - 45, 'Sin novedades'),
(6,  2, CURRENT_DATE - 75, 'Devolución en buen estado'),
(9,  3, CURRENT_DATE - 4,  'Sin novedades'),
(10, 2, CURRENT_DATE - 1,  'Sin novedades'),
(11, 3, CURRENT_DATE - 1,  'Sin novedades'),
(12, 2, CURRENT_DATE - 40, 'Sin novedades');

-- Actualizar estado de ejemplares devueltos a 'Disponible'
UPDATE ejemplar SET estado = 'Disponible' WHERE id_ejemplar IN (17, 7, 8, 9, 13, 1, 14);

-- Devoluciones tardías (generarán multas via trigger, o se insertan manualmente si el trigger no existe aún)
INSERT INTO devolucion (id_prestamo, id_empleado, fecha_devolucion, observacion) VALUES
(7,  4, CURRENT_DATE, 'Devolución tardía — 15 días de retraso'),
(8,  4, CURRENT_DATE, 'Devolución tardía — 10 días de retraso');

-- Actualizar estado de préstamos devueltos tardíamente
UPDATE prestamo SET estado = 'Devuelto' WHERE id_prestamo IN (7, 8);
UPDATE ejemplar  SET estado = 'Disponible' WHERE id_ejemplar IN (18, 20);

-- ------------------------------------------------------------
-- 10. MULTAS (generadas manualmente; el trigger también las genera)
-- ------------------------------------------------------------
-- Nota: el trigger de devolución inserla las multas automáticamente.
-- Si los registros anteriores se insertaron antes del trigger, se agregan aquí:
INSERT INTO multa (id_prestamo, id_socio, dias_retraso, monto_por_dia, monto_total, estado, fecha_generacion)
SELECT
    p.id_prestamo,
    p.id_socio,
    (CURRENT_DATE - p.fecha_limite)::INT   AS dias_retraso,
    0.50                                   AS monto_por_dia,
    (CURRENT_DATE - p.fecha_limite) * 0.50 AS monto_total,
    'Pendiente',
    CURRENT_DATE
FROM prestamo p
WHERE p.id_prestamo IN (7, 8)
  AND NOT EXISTS (
        SELECT 1 FROM multa m WHERE m.id_prestamo = p.id_prestamo
  );

-- ------------------------------------------------------------
-- 11. RESERVAS
-- ------------------------------------------------------------
INSERT INTO reserva (id_socio, id_libro, estado) VALUES
(8, 1, 'Activa'),   -- Gabriela reservó "Cien años de soledad" (tiene un ejemplar prestado)
(6, 2, 'Activa'),   -- Patricia reservó "La casa de los espíritus"
(3, 6, 'Cancelada'),-- Juan canceló su reserva de Rayuela
(1, 9, 'Cumplida'); -- Luis ya recibió Código Limpio

-- ============================================================
-- FIN DEL SCRIPT DML
-- ============================================================
