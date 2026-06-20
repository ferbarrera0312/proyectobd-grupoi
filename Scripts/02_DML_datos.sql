-- ------------------------------------------------------------
-- 1. editoriales
-- ------------------------------------------------------------
insert into editorial (nombre, pais, telefono, correo) values
('Alfaguara',          'España',    '+34-91-744-9060', 'info@alfaguara.com'),
('Planeta',            'España',    '+34-93-496-7000', 'info@planeta.es'),
('Anagrama',           'España',    '+34-93-339-9620', 'info@anagrama-ed.es'),
('Fondo de Cultura',   'México',    '+52-55-5227-4672', 'fce@fondodec.com'),
('Norma',              'Colombia',  '+57-1-221-9900',   'info@norma.com'),
('Santillana',         'España',    '+34-91-744-9060', 'info@santillana.com');

select * from editorial;

-- ------------------------------------------------------------
-- 2. categorías
-- ------------------------------------------------------------
insert into categoria (nombre, descripcion) values
('Novela',             'Obras de ficción narrativa larga'),
('Ciencia Ficción',    'Ficción basada en ciencia y tecnología futura'),
('Historia',           'Obras sobre eventos y períodos históricos'),
('Filosofía',          'Obras de pensamiento y reflexión filosófica'),
('Programación',       'Libros técnicos de desarrollo de software'),
('Infantil',           'Literatura dirigida a niños y jóvenes'),
('Poesía',             'Obras en verso'),
('Derecho',            'Legislación, jurisprudencia y teoría jurídica');

-- ------------------------------------------------------------
-- 3. autores
-- ------------------------------------------------------------
insert into autor (nombre, apellido, nacionalidad, fecha_nac) values
('Gabriel',   'García Márquez', 'Colombiano',     '1927-03-06'),
('Isabel',    'Allende',        'Chilena',        '1942-08-02'),
('Mario',     'Vargas Llosa',   'Peruano',        '1936-03-28'),
('Jorge Luis', 'Borges',         'Argentino',      '1899-08-24'),
('Octavio',   'Paz',            'Mexicano',       '1914-03-31'),
('Julio',     'Cortázar',       'Argentino',      '1914-08-26'),
('George',    'Orwell',         'Británico',      '1903-06-25'),
('Isaac',     'Asimov',         'Estadounidense', '1920-01-02'),
('Robert',    'Martin',         'Estadounidense', '1952-12-05'),
('Donald',    'Knuth',          'Estadounidense', '1938-01-10'),
('Laura',     'Méndez',         'Salvadoreña',    '1985-06-15'),
('Carlos',    'Fuentes',        'Mexicano',       '1928-11-11');

-- ------------------------------------------------------------
-- 4. libros
-- ------------------------------------------------------------
insert into libro (isbn, titulo, anio_publicacion, id_editorial, id_categoria, descripcion) values
('978-84-204-8864-0', 'Cien años de soledad',       1967, 1, 1, 'Obra maestra del realismo mágico latinoamericano'),
('978-84-408-0240-5', 'La casa de los espíritus',   1982, 2, 1, 'Saga familiar en un país latinoamericano imaginario'),
('978-84-204-6421-0', 'La ciudad y los perros',     1963, 1, 1, 'Primera novela de Vargas Llosa sobre una academia militar'),
('978-84-204-4108-1', 'Ficciones',                  1944, 1, 1, 'Colección de cuentos filosóficos y fantásticos de Borges'),
('978-84-204-9901-1', 'El laberinto de la soledad', 1950, 4, 4, 'Ensayo sobre la identidad mexicana'),
('978-84-376-0494-1', 'Rayuela',                    1963, 3, 1, 'Novela experimental de Cortázar'),
('978-84-350-0001-2', '1984',                       1949, 2, 2, 'Distopía política del totalitarismo'),
('978-84-350-0002-9', 'Fundación',                  1951, 2, 2, 'Primer volumen de la saga de la Fundación de Asimov'),
('978-84-350-0003-6', 'Código Limpio',              2008, 2, 5, 'Guía de buenas prácticas en programación'),
('978-84-350-0004-3', 'El arte de la programación', 1968, 2, 5, 'Obra de referencia fundamental de Knuth'),
('978-84-350-0005-0', 'El principito',              1943, 6, 6, 'Clásico de la literatura infantil universal'),
('978-84-350-0006-7', 'Pedro Páramo',               1955, 4, 1, 'Novela de Juan Rulfo sobre un pueblo fantasma');

-- relación libro–autor
insert into libro_autor (id_libro, id_autor, rol) values
(1,  1,  'PRINCIPAL'),
(2,  2,  'PRINCIPAL'),
(3,  3,  'PRINCIPAL'),
(4,  4,  'PRINCIPAL'),
(5,  5,  'PRINCIPAL'),
(6,  6,  'PRINCIPAL'),
(7,  7,  'PRINCIPAL'),
(8,  8,  'PRINCIPAL'),
(9,  9,  'PRINCIPAL'),
(10, 10, 'PRINCIPAL'),
(11, 11, 'TRADUCTOR'),
(12, 12, 'PRINCIPAL');

-- ------------------------------------------------------------
-- 5. ejemplares
-- ------------------------------------------------------------
insert into ejemplar (id_libro, codigo_barras, estado, fecha_adquisicion) values
-- Cien años de soledad
(1, 'EJ-001-A', 'DISPONIBLE', '2020-01-10'),
(1, 'EJ-001-B', 'DISPONIBLE', '2020-01-10'),
(1, 'EJ-001-C', 'PRESTADO',   '2020-01-10'),
-- La casa de los espíritus
(2, 'EJ-002-A', 'DISPONIBLE', '2020-02-15'),
(2, 'EJ-002-B', 'PRESTADO',   '2020-02-15'),
-- La ciudad y los perros
(3, 'EJ-003-A', 'DISPONIBLE', '2021-03-20'),
(3, 'EJ-003-B', 'DAÑADO',     '2021-03-20'),
-- Ficciones
(4, 'EJ-004-A', 'DISPONIBLE', '2019-06-01'),
(4, 'EJ-004-B', 'DISPONIBLE', '2019-06-01'),
-- El laberinto de la soledad
(5, 'EJ-005-A', 'DISPONIBLE', '2021-07-12'),
-- Rayuela
(6, 'EJ-006-A', 'DISPONIBLE', '2018-09-05'),
(6, 'EJ-006-B', 'PRESTADO',   '2018-09-05'),
-- 1984
(7, 'EJ-007-A', 'DISPONIBLE', '2019-11-20'),
(7, 'EJ-007-B', 'DISPONIBLE', '2022-01-08'),
-- Fundación
(8, 'EJ-008-A', 'DISPONIBLE', '2022-03-14'),
-- Código Limpio
(9, 'EJ-009-A', 'DISPONIBLE', '2023-01-10'),
(9, 'EJ-009-B', 'PRESTADO',   '2023-01-10'),
-- El arte de la programación
(10, 'EJ-010-A', 'DISPONIBLE', '2021-05-22'),
-- El principito
(11, 'EJ-011-A', 'DISPONIBLE', '2024-08-01'),
-- Pedro Páramo
(12, 'EJ-012-A', 'DISPONIBLE', '2020-10-15'),
(12, 'EJ-012-B', 'DISPONIBLE', '2020-10-15');

-- ------------------------------------------------------------
-- 6. empleados
-- ------------------------------------------------------------
insert into empleado (nombre, apellido, dui, cargo, telefono, correo, fecha_ingreso) values
('Ana',     'García',    '00000001-0', 'Jefe de Biblioteca', '7600-0001', 'ana.garcia@biblioteca.gob.sv',  '2015-03-01'),
('Roberto', 'Morales',   '00000002-0', 'Bibliotecario',      '7600-0002', 'roberto.m@biblioteca.gob.sv',   '2018-06-15'),
('Sofía',   'Hernández', '00000003-0', 'Bibliotecario',      '7600-0003', 'sofia.h@biblioteca.gob.sv',     '2019-01-20'),
('Marcos',  'López',     '00000004-0', 'Auxiliar',           '7600-0004', 'marcos.l@biblioteca.gob.sv',    '2021-07-01'),
('Carmen',  'Vásquez',   '00000005-0', 'Auxiliar',           '7600-0005', 'carmen.v@biblioteca.gob.sv',    '2022-02-14');

-- ------------------------------------------------------------
-- 7. socios
-- ------------------------------------------------------------
insert into socio (nombre, apellido, dui, telefono, correo, direccion, fecha_registro) values
('Luis',      'Martínez',  '10000001-0', '7700-1001', 'luis.m@mail.com',     'Calle 1, Col. San Benito, SS',       '2022-01-10'),
('María',     'Torres',    '10000002-0', '7700-1002', 'maria.t@mail.com',    'Av. Independencia 45, Santa Ana',    '2022-03-22'),
('Juan',      'Rodríguez', '10000003-0', '7700-1003', 'juan.r@mail.com',     'Reparto Miramonte, SS',              '2021-11-05'),
('Valentina', 'Cruz',      '10000004-0', '7700-1004', 'vale.c@mail.com',     'Col. Escalón, SS',                   '2023-02-14'),
('Diego',     'Reyes',     '10000005-0', '7700-1005', 'diego.r@mail.com',    'Pasaje Las Flores, Soyapango',       '2022-08-30'),
('Patricia',  'Lima',      '10000006-0', '7700-1006', 'patri.l@mail.com',    'Col. Guadalupe, San Miguel',         '2023-05-10'),
('Fernando',  'Aguilar',   '10000007-0', '7700-1007', 'fernando.a@mail.com', 'Bo. San Jacinto, SS',                '2024-01-18'),
('Gabriela',  'Montes',    '10000008-0', '7700-1008', 'gaby.m@mail.com',     'Urb. California, Antiguo Cuscatlán','2024-03-07');

select * from socio;

-- Limpiar todas las tablas en orden (respetando FK)
truncate table multa, devolucion, prestamo, reserva, 
              libro_autor, ejemplar, libro, 
              socio, empleado, autor, categoria, editorial
restart identity cascade;

-- ------------------------------------------------------------
-- 8. préstamos
-- ------------------------------------------------------------
insert into prestamo (id_socio, id_ejemplar, id_empleado, fecha_prestamo, fecha_limite, estado) values
-- Préstamos activos
(1, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-001-C'), 2, current_date - 5,  current_date + 10, 'ACTIVO'),
(2, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-002-B'), 2, current_date - 3,  current_date + 12, 'ACTIVO'),
(3, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-006-B'), 3, current_date - 8,  current_date + 7,  'ACTIVO'),
-- Préstamos ya devueltos (histórico)
(4, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-009-B'), 2, current_date - 40, current_date - 25, 'DEVUELTO'),
(5, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-007-A'), 3, current_date - 60, current_date - 45, 'DEVUELTO'),
(1, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-004-A'), 2, current_date - 90, current_date - 75, 'DEVUELTO'),
-- Préstamos vencidos
(6, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-010-A'), 4, current_date - 30, current_date - 15, 'VENCIDO'),
(7, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-012-A'), 4, current_date - 25, current_date - 10, 'VENCIDO'),
-- Préstamos adicionales para métricas mensuales
(2, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-005-A'), 3, current_date - 20, current_date - 5,  'DEVUELTO'),
(3, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-007-B'), 2, current_date - 15, current_date,      'DEVUELTO'),
(4, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-001-A'), 3, current_date - 10, current_date + 5,  'DEVUELTO'),
(5, (select id_ejemplar from ejemplar where codigo_barras = 'EJ-008-A'), 2, current_date - 55, current_date - 40, 'DEVUELTO');

-- ------------------------------------------------------------
-- 9. devoluciones
-- ------------------------------------------------------------
insert into devolucion (id_prestamo, id_empleado, fecha_devolucion, observacion) values
(4,  3, current_date - 25, 'Devolución en buen estado'),
(5,  2, current_date - 45, 'Sin novedades'),
(6,  2, current_date - 75, 'Devolución en buen estado'),
(9,  3, current_date - 4,  'Sin novedades'),
(10, 2, current_date - 1,  'Sin novedades'),
(11, 3, current_date - 1,  'Sin novedades'),
(12, 2, current_date - 40, 'Sin novedades');

-- Sincronizar estados de ejemplares devueltos
update ejemplar set estado = 'DISPONIBLE'
where codigo_barras in ('EJ-009-B','EJ-007-A','EJ-004-A','EJ-005-A','EJ-007-B','EJ-001-A','EJ-008-A');

-- Devoluciones tardías
insert into devolucion (id_prestamo, id_empleado, fecha_devolucion, observacion) values
(7, 4, current_date, 'Devolución tardía — 15 días de retraso'),
(8, 4, current_date, 'Devolución tardía — 10 días de retraso');

-- Actualizar estado de préstamos y ejemplares asociados a las devoluciones tardías
update prestamo  set estado = 'DEVUELTO'   where id_prestamo in (7, 8);
update ejemplar  set estado = 'DISPONIBLE' where codigo_barras in ('EJ-010-A', 'EJ-012-A');

-- ------------------------------------------------------------
-- 10. multas
-- ------------------------------------------------------------
insert into multa (id_prestamo, id_socio, dias_retraso, monto_por_dia, monto_total, estado, fecha_generacion)
select
    p.id_prestamo,
    p.id_socio,
    (current_date - p.fecha_limite)::int    as dias_retraso,
    0.50                                    as monto_por_dia,
    (current_date - p.fecha_limite) * 0.50  as monto_total,
    'PENDIENTE',
    current_date
from prestamo p
where p.id_prestamo in (7, 8)
  and not exists (
        select 1 from multa m where m.id_prestamo = p.id_prestamo
  );

-- ------------------------------------------------------------
-- 11. reservas
-- ------------------------------------------------------------
insert into reserva (id_socio, id_libro, estado) values
(8, 1, 'ACTIVA'),
(6, 2, 'ACTIVA'),
(3, 6, 'CANCELADA'),
(1, 9, 'CUMPLIDA');