CREATE TABLE facturas (
    id SERIAL PRIMARY KEY,
    data JSONB
);

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    data JSONB
);

CREATE OR REPLACE FUNCTION guardar_factura(factura JSONB) RETURNS TEXT AS $$
DECLARE
    total NUMERIC;
    descuento NUMERIC;
BEGIN

    total := (factura->>'total')::NUMERIC;
    descuento := (factura->>'descuento')::NUMERIC;

    IF total > 10000 THEN
        RETURN 'Error: El valor total de la factura no puede superar 10,000 dólares.';
    ELSIF descuento > 50 THEN
        RETURN 'Error: El descuento máximo para una factura debe ser de 50 dólares.';
    END IF;

    INSERT INTO facturas (data) VALUES (factura);

    RETURN 'Factura guardada exitosamente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_factura(codigo_factura TEXT, nueva_factura JSONB) RETURNS TEXT AS $$
BEGIN
    UPDATE facturas
    SET data = nueva_factura
    WHERE data->>'codigo' = codigo_factura;

    IF FOUND THEN
        RETURN 'Factura actualizada exitosamente.';
    ELSE
        RETURN 'Error: No se encontró una factura con ese código.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_nombre_cliente(identificacion TEXT) RETURNS TEXT AS $$
DECLARE
    nombre_cliente TEXT;
BEGIN

    SELECT data->>'nombre' INTO nombre_cliente
    FROM clientes
    WHERE data->>'identificacion' = identificacion;

    IF nombre_cliente IS NULL THEN
        RETURN 'Error: Cliente no encontrado.';
    ELSE
        RETURN nombre_cliente;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_facturas() RETURNS TABLE (
    cliente TEXT,
    identificacion TEXT,
    codigo_factura TEXT,
    total_descuento NUMERIC,
    total_factura NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        data->>'cliente' AS cliente,
        data->>'identificacion' AS identificacion,
        data->>'codigo' AS codigo_factura,
        (data->>'descuento')::NUMERIC AS total_descuento,
        (data->>'total')::NUMERIC AS total_factura
    FROM facturas;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_productos(codigo_factura TEXT) RETURNS TABLE (
    producto JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_array_elements(data->'productos') AS producto
    FROM facturas
    WHERE data->>'codigo' = codigo_factura;
END;
$$ LANGUAGE plpgsql;

INSERT INTO clientes (data) VALUES ('{
    "nombre": "Juan Pérez",
    "identificacion": "1234567890"
}'::jsonb);

INSERT INTO facturas (data) VALUES ('{
    "codigo": "FAC123",
    "cliente": "Juan Pérez",
    "identificacion": "1234567890",
    "total": 5000,
    "descuento": 30,
    "productos": [
        {
            "nombre": "Producto 1",
            "cantidad": 2,
            "precio": 100
        },
        {
            "nombre": "Producto 2",
            "cantidad": 1,
            "precio": 200
        }
    ]
}'::jsonb);


SELECT guardar_factura('{
    "codigo": "FAC002",
    "cliente": "Ana García",
    "identificacion": "987654321",
    "total": 8500,
    "descuento": 45,
    "productos": [
        {
            "nombre": "Producto 1",
            "cantidad": 1,
            "precio": 8500
        }
    ]
}'::jsonb);

SELECT actualizar_factura('FAC123', '{
    "codigo": "FAC123",
    "cliente": "Juan Pérez",
    "identificacion": "1234567890",
    "total": 5500,
    "descuento": 35,
    "productos": [
        {
            "nombre": "Producto 1",
            "cantidad": 2,
            "precio": 150
        }
    ]
}'::jsonb);

SELECT obtener_nombre_cliente('1234567890');

SELECT * FROM obtener_facturas();

SELECT * FROM obtener_productos('FAC123');

SELECT * FROM facturas;
SELECT * FROM clientes;

