-- =============================================================================
-- proyecto: sistema de biblioteca (ddl + integridad referencial)
-- =============================================================================
-- 1. preparación del entorno
create database proyecto_biblioteca;

-- tablas independientes (entidades fuertes)
-- tabla: editorial
create table editorial (
    id_editorial    int             generated always as identity,
    nombre          varchar(150)    not null,
    pais            varchar(100),
    telefono        varchar(20),
    correo          varchar(150),
    constraint pk_editorial primary key (id_editorial),
    constraint uq_editorial_nombre unique (nombre),
    constraint ck_editorial_correo check (correo is null or correo ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- tabla: categoria
create table categoria (
    id_categoria    int             generated always as identity,
    nombre          varchar(100)    not null,
    descripcion     varchar(250),
    constraint pk_categoria primary key (id_categoria),
    constraint uq_categoria_nombre unique (nombre)
);

-- tabla: autor
create table autor (
    id_autor        int             generated always as identity,
    nombre          varchar(100)    not null,
    apellido        varchar(100)    not null,
    nacionalidad    varchar(80),
    fecha_nac       date,
    constraint pk_autor primary key (id_autor),
    constraint uq_autor_nombre unique (nombre, apellido)
);

-- tabla: empleado
create table empleado (
    id_empleado     int             generated always as identity,
    nombre          varchar(100)    not null,
    apellido        varchar(100)    not null,
    dui             char(10)        not null,
    cargo           varchar(80)     not null default 'bibliotecario',
    telefono        varchar(20),
    correo          varchar(150),
    fecha_ingreso   date            not null default current_date,
    activo          boolean         not null default true,
    constraint pk_empleado primary key (id_empleado),
    constraint uq_empleado_dui unique (dui),
    constraint uq_empleado_correo unique (correo),
    constraint ck_empleado_dui_formato check (dui ~ '^[0-9]{8}-[0-9]{1}$'),
    constraint ck_empleado_correo_formato check (correo is null or correo ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- tabla: socio
create table socio (
    id_socio        int             generated always as identity,
    nombre          varchar(100)    not null,
    apellido        varchar(100)    not null,
    dui             char(10)        not null,
    telefono        varchar(20),
    correo          varchar(150),
    direccion       text,
    fecha_registro  date            not null default current_date,
    activo          boolean         not null default true,
    constraint pk_socio primary key (id_socio),
    constraint uq_socio_dui unique (dui),
    constraint uq_socio_correo unique (correo),
    constraint ck_socio_dui_formato check (dui ~ '^[0-9]{8}-[0-9]{1}$'),
    constraint ck_socio_correo_formato check (correo is null or correo ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- =============================================================================
-- tablas dependientes (entidades de primer nivel)
-- =============================================================================

-- tabla: libro
create table libro (
    id_libro        int             generated always as identity,
    isbn            varchar(20)     not null,
    titulo          varchar(300)    not null,
    anio_publicacion int            not null,
    id_editorial    int             not null,
    id_categoria    int             not null,
    descripcion     text,
    constraint pk_libro primary key (id_libro),
    constraint uq_libro_isbn unique (isbn),
    constraint ck_libro_anio check (anio_publicacion between 1400 and 2100),
    constraint fk_libro_editorial foreign key (id_editorial) 
        references editorial(id_editorial) on delete restrict on update cascade,
    constraint fk_libro_categoria foreign key (id_categoria) 
        references categoria(id_categoria) on delete restrict on update cascade
);

-- tabla: ejemplar
create table ejemplar (
    id_ejemplar     int             generated always as identity,
    id_libro        int             not null,
    codigo_barras   varchar(50)     not null,
    estado          varchar(20)     not null default 'DISPONIBLE',
    fecha_adquisicion date          not null default current_date,
    constraint pk_ejemplar primary key (id_ejemplar),
    constraint uq_ejemplar_codigo unique (codigo_barras),
    constraint ck_ejemplar_estado check (estado in ('DISPONIBLE','PRESTADO','RESERVADO','DAÑADO','BAJA')),
    constraint fk_ejemplar_libro foreign key (id_libro) 
        references libro(id_libro) on delete restrict on update cascade
);

-- tabla: reserva
create table reserva (
    id_reserva      int             generated always as identity,
    id_socio        int             not null,
    id_libro        int             not null,
    fecha_reserva   timestamp       not null default current_timestamp,
    estado          varchar(20)     not null default 'ACTIVA',
    constraint pk_reserva primary key (id_reserva),
    constraint ck_reserva_estado check (estado in ('ACTIVA','CUMPLIDA','CANCELADA')),
    constraint fk_reserva_socio foreign key (id_socio) 
        references socio(id_socio) on delete restrict on update cascade,
    constraint fk_reserva_libro foreign key (id_libro) 
        references libro(id_libro) on delete restrict on update cascade
);

-- =============================================================================
-- tablas dependientes de segundo nivel y relaciones n:m
-- =============================================================================

-- tabla: libro_autor (relación n:m)
create table libro_autor (
    id_libro        int             not null,
    id_autor        int             not null,
    rol             varchar(50)     default 'principal',
    constraint pk_libro_autor primary key (id_libro, id_autor),
    constraint fk_la_libro foreign key (id_libro) 
        references libro(id_libro) on delete cascade on update cascade,
    constraint fk_la_autor foreign key (id_autor) 
        references autor(id_autor) on delete restrict on update cascade
);

-- tabla: prestamo
create table prestamo (
    id_prestamo     int             generated always as identity,
    id_socio        int             not null,
    id_ejemplar     int             not null,
    id_empleado     int             not null,
    fecha_prestamo  date            not null default current_date,
    fecha_limite    date            not null,
    estado          varchar(20)     not null default 'ACTIVO',
    constraint pk_prestamo primary key (id_prestamo),
    constraint ck_prestamo_estado check (estado in ('ACTIVO','DEVUELTO','VENCIDO')),
    constraint ck_fechas_prestamo check (fecha_limite >= fecha_prestamo),
    constraint fk_prestamo_socio foreign key (id_socio) 
        references socio(id_socio) on delete restrict on update cascade,
    constraint fk_prestamo_ejemplar foreign key (id_ejemplar) 
        references ejemplar(id_ejemplar) on delete restrict on update cascade,
    constraint fk_prestamo_empleado foreign key (id_empleado) 
        references empleado(id_empleado) on delete restrict on update cascade
);

-- tabla: devolucion
create table devolucion (
    id_devolucion   int             generated always as identity,
    id_prestamo     int             not null,
    id_empleado     int             not null,
    fecha_devolucion date           not null default current_date,
    observacion     text,
    constraint pk_devolucion primary key (id_devolucion),
    constraint uq_devolucion_prestamo unique (id_prestamo),
    constraint fk_dev_prestamo foreign key (id_prestamo) 
        references prestamo(id_prestamo) on delete restrict on update cascade,
    constraint fk_dev_empleado foreign key (id_empleado) 
        references empleado(id_empleado) on delete restrict on update cascade
);

-- tabla: multa
create table multa (
    id_multa        int             generated always as identity,
    id_prestamo     int             not null,
    id_socio        int             not null,
    dias_retraso    int             not null,
    monto_por_dia   numeric(6,2)    not null default 0.50,
    monto_total     numeric(10,2)   not null,
    estado          varchar(20)     not null default 'PENDIENTE',
    fecha_generacion date           not null default current_date,
    fecha_pago      date,
    constraint pk_multa primary key (id_multa),
    constraint uq_multa_prestamo unique (id_prestamo),
    constraint ck_multa_dias check (dias_retraso > 0),
    constraint ck_multa_estado check (estado in ('PENDIENTE','PAGADA','CONDONADA')),
    constraint ck_multa_monto_calc check (monto_total = (dias_retraso * monto_por_dia)),
    constraint fk_multa_prestamo foreign key (id_prestamo) 
        references prestamo(id_prestamo) on delete restrict on update cascade,
    constraint fk_multa_socio foreign key (id_socio) 
        references socio(id_socio) on delete restrict on update cascade
);