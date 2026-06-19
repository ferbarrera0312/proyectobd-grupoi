-- ============================================================
--  PROYECTO FINAL — BASES DE DATOS
--  Escenario C: Sistema de Gestión de Biblioteca Pública
--  Archivo: 01_DDL.sql
--  Descripción: Creación de la base de datos, tablas y restricciones
--  Motor: PostgreSQL 17+
-- ============================================================

-- ------------------------------------------------------------
-- 1. CREAR BASE DE DATOS Y ESQUEMA
-- ------------------------------------------------------------
-- CREATE DATABASE biblioteca_db;
-- \c biblioteca_db

-- Crear esquema principal
CREATE SCHEMA IF NOT EXISTS biblioteca;

-- Establecer el esquema de búsqueda por defecto
SET search_path TO biblioteca;

-- ------------------------------------------------------------
-- 2. TABLAS DE CATÁLOGO / MAESTRAS
-- ------------------------------------------------------------

-- Editorial: empresa que publica los libros
CREATE TABLE editorial (
    id_editorial    SERIAL          PRIMARY KEY,
    nombre          VARCHAR(150)    NOT NULL,
    pais            VARCHAR(100),
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    CONSTRAINT uq_editorial_nombre UNIQUE (nombre)
);

-- Categoría: género o área temática del libro
CREATE TABLE categoria (
    id_categoria    SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    descripcion     TEXT,
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

-- Autor
CREATE TABLE autor (
    id_autor        SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    nacionalidad    VARCHAR(80),
    fecha_nac       DATE,
    CONSTRAINT uq_autor_nombre UNIQUE (nombre, apellido)
);

-- ------------------------------------------------------------
-- 3. LIBRO Y RELACIONES N:M
-- ------------------------------------------------------------

-- Libro: registro bibliográfico (no el ejemplar físico)
CREATE TABLE libro (
    id_libro        SERIAL          PRIMARY KEY,
    isbn            VARCHAR(20)     NOT NULL,
    titulo          VARCHAR(300)    NOT NULL,
    anio_publicacion SMALLINT       CHECK (anio_publicacion BETWEEN 1400 AND 2100),
    id_editorial    INT             NOT NULL,
    id_categoria    INT             NOT NULL,
    descripcion     TEXT,
    CONSTRAINT uq_libro_isbn    UNIQUE (isbn),
    CONSTRAINT fk_libro_editorial
        FOREIGN KEY (id_editorial) REFERENCES editorial(id_editorial)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_libro_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Libro_Autor: relación N:M entre Libro y Autor
CREATE TABLE libro_autor (
    id_libro        INT     NOT NULL,
    id_autor        INT     NOT NULL,
    rol             VARCHAR(50) DEFAULT 'Principal',   -- Principal, Coautor, Editor, etc.
    CONSTRAINT pk_libro_autor   PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_la_libro
        FOREIGN KEY (id_libro)  REFERENCES libro(id_libro)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_la_autor
        FOREIGN KEY (id_autor)  REFERENCES autor(id_autor)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Ejemplar: copia física de un libro
CREATE TABLE ejemplar (
    id_ejemplar     SERIAL          PRIMARY KEY,
    id_libro        INT             NOT NULL,
    codigo_barras   VARCHAR(50)     NOT NULL,
    estado          VARCHAR(20)     NOT NULL DEFAULT 'Disponible'
                        CHECK (estado IN ('Disponible','Prestado','Reservado','Dañado','Baja')),
    fecha_adquisicion DATE          DEFAULT CURRENT_DATE,
    CONSTRAINT uq_ejemplar_codigo UNIQUE (codigo_barras),
    CONSTRAINT fk_ejemplar_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 4. EMPLEADO
-- ------------------------------------------------------------

CREATE TABLE empleado (
    id_empleado     SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    dui             CHAR(10)        NOT NULL,           -- Documento único de identidad
    cargo           VARCHAR(80)     NOT NULL DEFAULT 'Bibliotecario',
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    fecha_ingreso   DATE            NOT NULL DEFAULT CURRENT_DATE,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_empleado_dui   UNIQUE (dui),
    CONSTRAINT uq_empleado_correo UNIQUE (correo)
);

-- ------------------------------------------------------------
-- 5. SOCIO
-- ------------------------------------------------------------

CREATE TABLE socio (
    id_socio        SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    dui             CHAR(10)        NOT NULL,
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    direccion       TEXT,
    fecha_registro  DATE            NOT NULL DEFAULT CURRENT_DATE,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_socio_dui    UNIQUE (dui),
    CONSTRAINT uq_socio_correo UNIQUE (correo)
);

-- ------------------------------------------------------------
-- 6. PRÉSTAMO Y DEVOLUCIÓN
-- ------------------------------------------------------------

-- Préstamo: registro de cada préstamo realizado
CREATE TABLE prestamo (
    id_prestamo     SERIAL          PRIMARY KEY,
    id_socio        INT             NOT NULL,
    id_ejemplar     INT             NOT NULL,
    id_empleado     INT             NOT NULL,           -- empleado que procesa el préstamo
    fecha_prestamo  DATE            NOT NULL DEFAULT CURRENT_DATE,
    fecha_limite    DATE            NOT NULL,           -- fecha máxima de devolución (15 días)
    estado          VARCHAR(20)     NOT NULL DEFAULT 'Activo'
                        CHECK (estado IN ('Activo','Devuelto','Vencido')),
    CONSTRAINT fk_prestamo_socio
        FOREIGN KEY (id_socio)    REFERENCES socio(id_socio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_ejemplar
        FOREIGN KEY (id_ejemplar) REFERENCES ejemplar(id_ejemplar)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- La fecha límite debe ser mayor que la fecha de préstamo
    CONSTRAINT chk_fechas_prestamo CHECK (fecha_limite > fecha_prestamo)
);

-- Devolución: registro de la entrega del ejemplar
CREATE TABLE devolucion (
    id_devolucion   SERIAL          PRIMARY KEY,
    id_prestamo     INT             NOT NULL,
    id_empleado     INT             NOT NULL,           -- empleado que recibe la devolución
    fecha_devolucion DATE           NOT NULL DEFAULT CURRENT_DATE,
    observacion     TEXT,
    CONSTRAINT uq_devolucion_prestamo UNIQUE (id_prestamo),  -- un préstamo solo se devuelve una vez
    CONSTRAINT fk_dev_prestamo
        FOREIGN KEY (id_prestamo)  REFERENCES prestamo(id_prestamo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_dev_empleado
        FOREIGN KEY (id_empleado)  REFERENCES empleado(id_empleado)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 7. MULTA
-- ------------------------------------------------------------

-- Multa: generada automáticamente por el trigger de devolución tardía
CREATE TABLE multa (
    id_multa        SERIAL          PRIMARY KEY,
    id_prestamo     INT             NOT NULL,
    id_socio        INT             NOT NULL,
    dias_retraso    INT             NOT NULL CHECK (dias_retraso > 0),
    monto_por_dia   NUMERIC(6,2)    NOT NULL DEFAULT 0.50,  -- $0.50 por día
    monto_total     NUMERIC(10,2)   NOT NULL,
    estado          VARCHAR(20)     NOT NULL DEFAULT 'Pendiente'
                        CHECK (estado IN ('Pendiente','Pagada','Condonada')),
    fecha_generacion DATE           NOT NULL DEFAULT CURRENT_DATE,
    fecha_pago      DATE,
    CONSTRAINT uq_multa_prestamo UNIQUE (id_prestamo),     -- una multa por préstamo
    CONSTRAINT fk_multa_prestamo
        FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_multa_socio
        FOREIGN KEY (id_socio)    REFERENCES socio(id_socio)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 8. RESERVA
-- ------------------------------------------------------------

-- Reserva: permite apartar un ejemplar que está prestado
CREATE TABLE reserva (
    id_reserva      SERIAL          PRIMARY KEY,
    id_socio        INT             NOT NULL,
    id_libro        INT             NOT NULL,           -- se reserva el libro, no el ejemplar específico
    fecha_reserva   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(20)     NOT NULL DEFAULT 'Activa'
                        CHECK (estado IN ('Activa','Cumplida','Cancelada')),
    CONSTRAINT fk_reserva_socio
        FOREIGN KEY (id_socio) REFERENCES socio(id_socio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 9. ÍNDICES ADICIONALES (mejora de rendimiento)
-- ------------------------------------------------------------

CREATE INDEX idx_prestamo_socio    ON prestamo(id_socio);
CREATE INDEX idx_prestamo_estado   ON prestamo(estado);
CREATE INDEX idx_prestamo_fecha    ON prestamo(fecha_prestamo);
CREATE INDEX idx_ejemplar_libro    ON ejemplar(id_libro);
CREATE INDEX idx_ejemplar_estado   ON ejemplar(estado);
CREATE INDEX idx_multa_estado      ON multa(estado);
CREATE INDEX idx_reserva_libro     ON reserva(id_libro);
CREATE INDEX idx_libro_autor_autor ON libro_autor(id_autor);

-- ============================================================
-- FIN DEL SCRIPT DDL
-- ============================================================
