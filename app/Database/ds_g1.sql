-- ============================================================
-- INTRASEV MOTORS - Esquema y datos de la base de datos (ds_g1)
-- Motor compatible: MySQL / MariaDB (XAMPP)
-- Creado con CodeIgniter 4 (PHP 8.2, MySQLi)
--
-- Cómo usarlo en local (XAMPP):
--   mysql -u root < app/Database/ds_g1.sql
--
-- NOTA: Este script re-crea las tablas (DROP + CREATE) y
--       reinserta los datos de ejemplo. Perfecto para resetear.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ds_g1
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE ds_g1;

-- ============================================================
-- LIMPIEZA (orden por dependencias)
-- ============================================================
DROP TABLE IF EXISTS tDetallePedidos;
DROP TABLE IF EXISTS tCarritoCompras;
DROP TABLE IF EXISTS tPedidos;
DROP TABLE IF EXISTS tUsuarios;
DROP TABLE IF EXISTS tProductos;
DROP TABLE IF EXISTS tAutos;
DROP TABLE IF EXISTS tRoles;

-- ============================================================
-- TABLA: tRoles
-- ============================================================
CREATE TABLE tRoles (
    id_rol      INT AUTO_INCREMENT NOT NULL,
    nombre_rol  VARCHAR(50)  NOT NULL,
    descripcion VARCHAR(255) NULL,
    PRIMARY KEY (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tUsuarios
--   Relación: tUsuarios.id_rol -> tRoles.id_rol (N:1)
-- ============================================================
CREATE TABLE tUsuarios (
    id_usuario         INT AUTO_INCREMENT NOT NULL,
    id_rol             INT NOT NULL,
    usuario            VARCHAR(50)  NOT NULL,
    nombre_completo    VARCHAR(150) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL,
    contrasena_hash    VARCHAR(255) NOT NULL,
    telefono           VARCHAR(20)  NULL,
    fecha_creacion     DATETIME     NULL,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uq_usuario (usuario),
    UNIQUE KEY uq_correo (correo_electronico),
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (id_rol) REFERENCES tRoles (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tProductos
-- ============================================================
CREATE TABLE tProductos (
    id_producto   INT AUTO_INCREMENT NOT NULL,
    nombre        VARCHAR(150) NOT NULL,
    descripcion   TEXT NULL,
    precio        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    imagen        VARCHAR(255) NULL,
    stock         INT NOT NULL DEFAULT 0,
    estado_activo TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tAutos
-- ============================================================
CREATE TABLE tAutos (
    id_auto     INT AUTO_INCREMENT NOT NULL,
    modelo      VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    url_imagen  VARCHAR(255) NULL,
    PRIMARY KEY (id_auto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tPedidos
--   Relación: tPedidos.id_usuario -> tUsuarios.id_usuario (N:1)
-- ============================================================
CREATE TABLE tPedidos (
    id_pedido     INT AUTO_INCREMENT NOT NULL,
    id_usuario    INT NOT NULL,
    fecha_pedido  DATETIME NOT NULL,
    estado_pedido VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    monto_total   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedidos_usuario FOREIGN KEY (id_usuario) REFERENCES tUsuarios (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tDetallePedidos
--   Relaciones:
--     tDetallePedidos.id_pedido   -> tPedidos.id_pedido   (N:1)
--     tDetallePedidos.id_producto -> tProductos.id_producto (N:1)
-- ============================================================
CREATE TABLE tDetallePedidos (
    id_detalle               INT AUTO_INCREMENT NOT NULL,
    id_pedido                INT NOT NULL,
    id_producto              INT NOT NULL,
    cantidad                 INT NOT NULL DEFAULT 1,
    precio_unitario_historico DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id_detalle),
    CONSTRAINT fk_detalle_pedido   FOREIGN KEY (id_pedido)   REFERENCES tPedidos (id_pedido),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES tProductos (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA: tCarritoCompras
--   Relaciones:
--     tCarritoCompras.id_usuario  -> tUsuarios.id_usuario   (N:1)
--     tCarritoCompras.id_producto -> tProductos.id_producto (N:1)
-- ============================================================
CREATE TABLE tCarritoCompras (
    id_carrito     INT AUTO_INCREMENT NOT NULL,
    id_usuario     INT NOT NULL,
    id_producto    INT NOT NULL,
    cantidad       INT NOT NULL DEFAULT 1,
    fecha_agregado DATETIME NULL,
    PRIMARY KEY (id_carrito),
    CONSTRAINT fk_carrito_usuario  FOREIGN KEY (id_usuario)  REFERENCES tUsuarios (id_usuario),
    CONSTRAINT fk_carrito_producto FOREIGN KEY (id_producto) REFERENCES tProductos (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DATOS DE EJEMPLO (SEED)
-- ============================================================
INSERT INTO tRoles (id_rol, nombre_rol, descripcion) VALUES
(1, 'Administrador', 'Acceso total al panel de administración'),
(2, 'Cliente',       'Puede comprar en la tienda'),
(3, 'Ventas',        'Usuario de ventas sin acceso al panel de administración');

-- Admin de ejemplo -> login: admin / admin123
INSERT INTO tUsuarios (id_rol, usuario, nombre_completo, correo_electronico, contrasena_hash, telefono, fecha_creacion) VALUES
(1, 'admin', 'Administrador Principal', 'admin@intrasev.com', 'admin123', '999888777', NOW());

-- Cliente de ejemplo -> login: cliente / cliente123
INSERT INTO tUsuarios (id_rol, usuario, nombre_completo, correo_electronico, contrasena_hash, telefono, fecha_creacion) VALUES
(2, 'cliente', 'Cliente Demo', 'cliente@intrasev.com', 'cliente123', '987654321', NOW());

-- Admin adicional -> login: richard / 123456
INSERT INTO tUsuarios (id_rol, usuario, nombre_completo, correo_electronico, contrasena_hash, telefono, fecha_creacion) VALUES
(1, 'richard', 'Richard', 'richard@intrasev.com', '123456', '999000111', NOW());

-- Usuario de Ventas -> login: heral / 123456 (sin permisos de admin)
INSERT INTO tUsuarios (id_rol, usuario, nombre_completo, correo_electronico, contrasena_hash, telefono, fecha_creacion) VALUES
(3, 'heral', 'Heral Ose', 'heral@intrasev.com', '123456', '888777666', NOW());

INSERT INTO tProductos (nombre, descripcion, precio, imagen, stock, estado_activo) VALUES
('Kit de Frenos Cerámicos', 'Kit de pastillas y discos de competición.', 450.00, NULL, 25, 1),
('Intercooler Frontal', 'Intercooler de mayor capacidad para turbo.', 680.00, NULL, 12, 1),
('Escape Deportivo Acero', 'Sistema de escape completo en acero inoxidable.', 890.00, NULL, 8, 1),
('Filtro de Aire Deportivo', 'Filtro de alto flujo reutilizable.', 120.00, NULL, 40, 1);

INSERT INTO tAutos (modelo, descripcion, url_imagen) VALUES
('Honda Civic 1998', 'Proyecto JDM con motor VTEC.', NULL),
('VW Golf MK3', 'Reprogramación Stage1 y suspensión coilover.', NULL),
('Subaru Impreza 98', 'AWD reforzado con turbo y rally setup.', NULL);
