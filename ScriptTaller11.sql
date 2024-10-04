CREATE TYPE estado_tipo AS ENUM ('pendiente', 'en ruta', 'entregado');

create table taller10.envios(
	id serial primary key,
	fecha_envio date,
	destino varchar,
	observacion varchar,
	estado estado_tipo
);

CREATE OR REPLACE PROCEDURE poblar_envios()
LANGUAGE plpgsql
AS $$
DECLARE
    i INTEGER;
    fecha DATE;
    destino varchar;
    observacion varchar;
    estado estado_tipo;
    destinos varchar[] := ARRAY['Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena'];
BEGIN
    FOR i IN 1..50 LOOP
        fecha := CURRENT_DATE - (FLOOR(RANDOM() * 30) + 1)::INT;

        destino := destinos[FLOOR(RANDOM() * ARRAY_LENGTH(destinos, 1) + 1)::INT];

        observacion := 'Observación ' || i;

        estado := (enum_range(NULL::estado_tipo))[FLOOR(RANDOM() * 3 + 1)::INT];

        INSERT INTO envios (fecha_envio, destino, observacion, estado)
        VALUES (fecha, destino, observacion, estado);
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE primera_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    envio RECORD;
    cursor_envios CURSOR FOR
        SELECT id, estado
        FROM envios
        WHERE estado = 'pendiente';
BEGIN
    OPEN cursor_envios;

    LOOP
        FETCH cursor_envios INTO envio;
        EXIT WHEN NOT FOUND;  

        UPDATE envios
        SET estado = 'en_ruta',
            observacion = 'Primera etapa del envio'
        WHERE id = envio.id;
    END LOOP;

    CLOSE cursor_envios;

    RAISE NOTICE 'Envios pendientes actualizados a en_ruta.';
END $$;


CREATE OR REPLACE PROCEDURE ultima_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    envio RECORD;
    cursor_envios CURSOR FOR
        SELECT id, fecha_envio, estado
        FROM envios
        WHERE estado = 'en_ruta' AND CURRENT_DATE - fecha_envio > 5;
BEGIN
    OPEN cursor_envios;
    
    LOOP
        FETCH cursor_envios INTO envio;
        EXIT WHEN NOT FOUND;  
        
        UPDATE envios
        SET estado = 'entregado',
            observacion = 'Envio realizado satisfactoriamente'
        WHERE id = envio.id;
    END LOOP;
    
    CLOSE cursor_envios;
    
    RAISE NOTICE 'Envios actualizados satisfactoriamente.';
END $$;

CALL poblar_envios();

select * from envios;


