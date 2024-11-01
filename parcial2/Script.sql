-- DATOS PRUEBA

INSERT INTO usuarios (id, nombre, direccion, email, fecha_registro, estado) VALUES
('1', 'Juan Pérez', 'Calle 123', 'juan@example.com', '2023-01-15', 'Activo'),
('2', 'María López', 'Avenida 456', 'maria@example.com', '2023-02-20', 'Activo'),
('3', 'Pedro González', 'Boulevard 789', 'pedro@example.com', '2023-03-10', 'Inactivo');

INSERT INTO tarjetas (num_tarjeta, fecha_expiracion, cvv, tipo) VALUES
('1234567', '2025-12-31', '123', 'Visa'),         
('12345678', '2024-06-30', '456', 'Mastercard'),    
('123456789', '2025-08-15', '789', 'Visa');          

INSERT INTO productos (codigo_producto, nombre, porcentaje_impuesto_precio, tipo) VALUES
('P001', 'Samsung', 0.18, 'Celular'),
('P002', 'Televisión LED', 0.15, 'Televisor'),
('P003', 'Apple', 0.12, 'Celular');

INSERT INTO pagos (codigo_pago, fecha, estado, monto, producto_id, tarjeta_id, usuario_id) VALUES
('PAY001', '2024-01-01', 'Exitoso', 1500, 16, 16, '1'),
('PAY002', '2024-02-15', 'Fallido', 900, 17, 17, '2'),
('PAY003', '2024-03-10', 'Exitoso', 2000, 18, 16, '1'),
('PAY004', '2024-04-22', 'Exitoso', 750, 16, 18, '3');

select * from tarjetas;
select * from productos;


-- PREGUNTA 1
CREATE type estado as enum('Activo', 'Inactivo');
create type tipo_tarjeta as enum('Visa', 'Mastercard');
create type tipo_producto as enum('Celular', 'Televisor');
create type tipo_estado as enum('Exitoso', 'Fallido');


CREATE TABLE usuarios(
	id varchar PRIMARY KEY,
	nombre varchar,
	direccion varchar,
	email varchar,
	fecha_registro date,
	estado estado
);

CREATE TABLE tarjetas(
	id serial primary key,
	num_tarjeta varchar unique not null,
	fecha_expiracion date not null,
	cvv varchar not null,
	tipo tipo_tarjeta not null
);

create table productos(
	id serial primary key,
	codigo_producto varchar unique not null,
	nombre varchar not null,
	porcentaje_impuesto_precio numeric not null,
	tipo tipo_producto not null
);

create table pagos(
	id serial primary key,
	codigo_pago varchar unique not null,
	fecha date,
	estado tipo_estado not null,
	monto numeric not null,
	producto_id integer, 
	tarjeta_id integer,
	usuario_id varchar,
    foreign key (usuario_id) REFERENCES usuarios(id),
    foreign key (tarjeta_id) references tarjetas(id),
    foreign key (producto_id) references productos(id)

);

create table comprobantes_pago_xml(
	id serial primary key,
	detalle_xml xml
);

create table comprobantes_pago_json(
	id serial primary key,
	detalle_json JSONB
);


CREATE OR REPLACE FUNCTION obtener_pagos_usuario(
    p_usuario_id VARCHAR,
    p_fecha DATE
)
RETURNS TABLE (
    codigo_pago VARCHAR,
    nombre_producto VARCHAR,
    monto NUMERIC,
    estado tipo_estado
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pagos.codigo_pago,
        productos.nombre AS nombre_producto,
        pagos.monto,
        pagos.estado
    FROM 
        pagos
    JOIN 
        productos ON pagos.producto_id = productos.id
    WHERE 
        pagos.usuario_id = p_usuario_id 
        AND pagos.fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_tarjetas_usuario(
    p_usuario_id VARCHAR
)
RETURNS TABLE (
    nombre_usuario VARCHAR,
    email VARCHAR,
    numero_tarjeta VARCHAR,
    cvv VARCHAR,
    tipo_tarjeta tipo_tarjeta
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.nombre AS nombre_usuario,
        u.email,
        t.num_tarjeta AS numero_tarjeta,
        t.cvv,
        t.tipo AS tipo_tarjeta
    FROM 
        usuarios u
    JOIN 
        pagos p ON u.id = p.usuario_id
    JOIN 
        tarjetas t ON p.tarjeta_id = t.id
    WHERE 
        u.id = p_usuario_id
        AND p.monto > 1000;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM obtener_pagos_usuario('1', '2024-01-01');
SELECT * FROM obtener_tarjetas_usuario('1');


-- PREGUNTA 2

CREATE OR REPLACE FUNCTION obtener_tarjeta_detalle_usuario(
    p_usuario_id VARCHAR
)
RETURNS VARCHAR AS $$
DECLARE
    tarjeta_cursor CURSOR FOR 
        SELECT num_tarjeta, fecha_expiracion FROM tarjetas;
    usuario_cursor CURSOR FOR 
        SELECT nombre, email FROM usuarios WHERE id = p_usuario_id;

    tarjeta_record RECORD;
    usuario_record RECORD;
    resultado VARCHAR := '';
BEGIN
    OPEN usuario_cursor;
    FETCH usuario_cursor INTO usuario_record;

    IF FOUND THEN
        OPEN tarjeta_cursor;
        LOOP
            FETCH tarjeta_cursor INTO tarjeta_record;
            EXIT WHEN NOT FOUND;

            resultado := resultado || 
                         'Numero Tarjeta: ' || tarjeta_record.num_tarjeta || ', ' ||
                         'Fecha Expiracion: ' || tarjeta_record.fecha_expiracion || ', ' ||
                         'Nombre: ' || usuario_record.nombre || ', ' ||
                         'Email: ' || usuario_record.email || '; ';
        END LOOP;
        CLOSE tarjeta_cursor;
    END IF;

    CLOSE usuario_cursor;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION obtener_pagos_menor_1000_fecha(
    p_fecha DATE
)
RETURNS VARCHAR AS $$
DECLARE
    pago_cursor CURSOR FOR 
        SELECT monto, estado, producto_id, usuario_id FROM pagos WHERE fecha = p_fecha AND monto < 1000;
    producto_cursor CURSOR FOR 
        SELECT id, nombre, porcentaje_impuesto_precio FROM productos;
    usuario_cursor CURSOR FOR 
        SELECT id, direccion, email FROM usuarios;

    pago_record RECORD;
    producto_record RECORD;
    usuario_record RECORD;
    resultado VARCHAR := '';
BEGIN
    OPEN pago_cursor;
    LOOP
        FETCH pago_cursor INTO pago_record;
        EXIT WHEN NOT FOUND;

        OPEN producto_cursor;
        LOOP
            FETCH producto_cursor INTO producto_record;
            EXIT WHEN NOT FOUND;
            IF producto_record.id = pago_record.producto_id THEN
                resultado := resultado || 
                             'Monto: ' || pago_record.monto || ', ' ||
                             'Estado: ' || pago_record.estado || ', ' ||
                             'Nombre Producto: ' || producto_record.nombre || ', ' ||
                             'Porcentaje Impuesto: ' || producto_record.porcentaje_impuesto_precio || ', ';
                EXIT;
            END IF;
        END LOOP;
        CLOSE producto_cursor;

        OPEN usuario_cursor;
        LOOP
            FETCH usuario_cursor INTO usuario_record;
            EXIT WHEN NOT FOUND;
            IF usuario_record.id = pago_record.usuario_id THEN
                resultado := resultado || 
                             'Direccion: ' || usuario_record.direccion || ', ' ||
                             'Email: ' || usuario_record.email || '; ';
                EXIT;
            END IF;
        END LOOP;
        CLOSE usuario_cursor;
    END LOOP;
    CLOSE pago_cursor;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE guardar_comprobante_pago_xml(p_codigo_pago VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    pago_record RECORD;
    usuario_record RECORD;
    tarjeta_record RECORD;
    producto_record RECORD;
    xml_comprobante TEXT;
BEGIN
    SELECT * INTO pago_record
    FROM pagos
    WHERE codigo_pago = p_codigo_pago;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El código de pago % no existe', p_codigo_pago;
    END IF;
    
    SELECT * INTO usuario_record
    FROM usuarios
    WHERE id = pago_record.usuario_id;
    
    SELECT * INTO tarjeta_record
    FROM tarjetas
    WHERE id = pago_record.tarjeta_id;
    
    SELECT * INTO producto_record
    FROM productos
    WHERE id = pago_record.producto_id;

    xml_comprobante := '<pago>' ||
                       '<codigoPago>' || pago_record.codigo_pago || '</codigoPago>' ||
                       '<nombreUsuario>' || usuario_record.nombre || '</nombreUsuario>' ||
                       '<numeroTarjeta>' || tarjeta_record.num_tarjeta || '</numeroTarjeta>' ||
                       '<nombreProducto>' || producto_record.nombre || '</nombreProducto>' ||
                       '<montoPago>' || pago_record.monto || '</montoPago>' ||
                       '</pago>';
    
    INSERT INTO comprobantes_pago_xml (detalle_xml)
    VALUES (xml_comprobante::xml);
END;
$$;


CREATE OR REPLACE PROCEDURE guardar_comprobante_pago_json(p_codigo_pago VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    pago_record RECORD;
    usuario_record RECORD;
    tarjeta_record RECORD;
    producto_record RECORD;
    json_comprobante JSONB;
BEGIN
    SELECT * INTO pago_record
    FROM pagos
    WHERE codigo_pago = p_codigo_pago;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El código de pago % no existe', p_codigo_pago;
    END IF;
    
    SELECT * INTO usuario_record
    FROM usuarios
    WHERE id = pago_record.usuario_id;
    
    SELECT * INTO tarjeta_record
    FROM tarjetas
    WHERE id = pago_record.tarjeta_id;
    
    SELECT * INTO producto_record
    FROM productos
    WHERE id = pago_record.producto_id;
    
    json_comprobante := jsonb_build_object(
        'emailUsuario', usuario_record.email,
        'numeroTarjetas', tarjeta_record.num_tarjeta,
        'tipoTarjeta', tarjeta_record.tipo,
        'codigoProducto', producto_record.codigo_producto,
        'codigoPago', pago_record.codigo_pago,
        'montoPago', pago_record.monto
    );
    
    INSERT INTO comprobantes_pago_json (detalle_json)
    VALUES (json_comprobante);
    
END;
$$;




SELECT obtener_tarjeta_detalle_usuario('1') AS tarjeta_detalle_usuario;


SELECT obtener_pagos_menor_1000_fecha('2024-02-15') AS pagos_detalle;

CALL guardar_comprobante_pago_xml('PAY001');

CALL guardar_comprobante_pago_json('PAY001');

select * from comprobantes_pago_xml;

SELECT * FROM comprobantes_pago_json;

-- PREGUNTA 3

CREATE OR REPLACE FUNCTION validaciones_producto_func()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.porcentaje_impuesto_precio <= 1 OR NEW.porcentaje_impuesto_precio > 20 THEN
        RAISE EXCEPTION 'El porcentaje de impuesto debe ser mayor a 1%% y menor o igual a 20%%.';
    END IF;

    IF NEW.precio <= 0 OR NEW.precio >= 20000 THEN
        RAISE EXCEPTION 'El precio debe ser mayor a 0 y menor a 20000.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER validaciones_producto
BEFORE INSERT ON productos
FOR EACH ROW
EXECUTE FUNCTION validaciones_producto_func();


CREATE OR REPLACE FUNCTION trigger_guardar_comprobante_pago()
RETURNS TRIGGER AS $$
BEGIN
    CALL guardar_comprobante_pago_xml(NEW.codigo_pago);
    call guardar_comprobante_pago_json(NEW.codigo_pago);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_guardar_comprobante
AFTER INSERT ON pagos
FOR EACH ROW
EXECUTE FUNCTION trigger_guardar_comprobante_pago();


INSERT INTO pagos (codigo_pago, fecha, estado, monto, producto_id, tarjeta_id, usuario_id)
VALUES ('PAY006', '2024-11-02', 'Exitoso', 2500, 16, 16, '2');



-- Pregunta 4

CREATE SEQUENCE codigo_producto_seq
    START WITH 5
    INCREMENT BY 5;

CREATE SEQUENCE codigo_pago_seq
    START WITH 1
    INCREMENT BY 100;
   
CREATE OR REPLACE FUNCTION obtener_info_json(p_id integer)
RETURNS TABLE (
    email_usuario VARCHAR,
    codigo_producto VARCHAR,
    monto_pago NUMERIC
) AS $$
DECLARE
    json_comprobante JSONB;
BEGIN
    SELECT detalle_json INTO json_comprobante
    FROM comprobantes_pago_json
    WHERE id = p_id;

    IF json_comprobante IS NULL THEN
        RAISE EXCEPTION 'El comprobante con ID % no existe', p_id;
    END IF;

    email_usuario := json_comprobante->>'emailUsuario';
    codigo_producto := json_comprobante->>'codigoProducto';
    monto_pago := (json_comprobante->>'montoPago')::NUMERIC;

    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_info_xml(p_id integer)
RETURNS TABLE (
    nombre_usuario VARCHAR,
    nombre_producto VARCHAR,
    monto_pago NUMERIC
) AS $$
DECLARE
    xml_comprobante XML;
BEGIN
    SELECT detalle_xml INTO xml_comprobante
    FROM comprobantes_pago_xml
    WHERE id = p_id;

    IF xml_comprobante IS NULL THEN
        RAISE EXCEPTION 'El comprobante con ID % no existe', p_id;
    END IF;

    nombre_usuario := xml_comprobante::TEXT::XML->>'nombreUsuario';
    nombre_producto := xml_comprobante::TEXT::XML->>'nombreProducto';
    monto_pago := xml_comprobante::TEXT::XML->>'montoPago'::NUMERIC;

    RETURN;
END;
$$ LANGUAGE plpgsql;

select 








