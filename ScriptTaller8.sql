create table usuarios(
	id varchar primary key,
	nombre varchar not null,
	edad numeric not null,
	correo varchar not null unique
);

create table facturas(
	id serial primary key,
	fecha date not null,
	producto varchar not null,
	cantidad numeric,
	valor_unitario numeric,
	valor_total numeric,
	usuario_id varchar,
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE SET NULL
);

CREATE SEQUENCE secuencia_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE secuencia_facturas
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
   
drop table usuarios;
drop table facturas; 

create or replace procedure poblar_usuarios()
language plpgsql
as $$
declare 
    v_id varchar;
    v_nombre varchar;
    v_email varchar;
	v_edad numeric;
begin
    for i in 1..50 loop
        v_id := nextval('secuencia_id');
        v_nombre := (array['Santiago', 'Andres', 'Juan', 'Marcela', 'Mariana'])[floor(random() * 5 + 1)];
        v_email := v_nombre || v_id || '@example.com';
		v_edad := floor(random() * 10+1);
        insert into usuarios (id, nombre, correo, edad) values (v_id, v_nombre, v_email, v_edad);
    end loop;
end;
$$;

CREATE OR REPLACE PROCEDURE poblar_facturas()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_fecha DATE := '2024-09-16';
    v_producto VARCHAR;
    v_cantidad NUMERIC;
    v_valor_unitario NUMERIC;
    v_valor_total NUMERIC;
    v_usuario_id INTEGER; 
BEGIN 
    FOR i IN 1..50 LOOP
        v_producto := (ARRAY['Banano', 'Manzana', 'Mango', 'Pera'])[FLOOR(RANDOM() * 4 + 1)];
        v_cantidad := FLOOR(RANDOM() * 10 + 1);
        v_valor_unitario := FLOOR(RANDOM() * 100 + 1);
        v_valor_total := v_valor_unitario * v_cantidad;
        v_usuario_id := NEXTVAL('secuencia_facturas');
        INSERT INTO facturas (fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) 
        VALUES (v_fecha, v_producto, v_cantidad, v_valor_unitario, v_valor_total, v_usuario_id); 
    END LOOP;
END;
$$;

create or replace procedure prueba_producto_vacio()
language  plpgsql
as $$
begin 
	insert into facturas(fecha, producto, cantidad, valor_unitario, valor_total, usuario_id)
	values('2024-09-16', 'Banano', 3, 1500, 4500, '2');
	insert into facturas(fecha, cantidad, valor_unitario, valor_total, usuario_id)
	values('2024-09-16', 3, 1500, 4500, '2');
exception 
	when others then
		rollback;
		raise notice 'Error al insertar en facturas: %', sqlerrm;
end;
$$;

create or replace procedure prueba_identificacion_unica()
language plpgsql
as $$
declare 
	v_nueva_identificacion numeric;
	v_email varchar;
begin 
	v_nueva_identificacion:= nextval('secuencia_id');
	v_email:= 'pepe' || v_nueva_identificacion || '@example.com';
	insert into usuarios(id, nombre, edad, correo) values ('2', 'Pepe', 39, v_email);
exception 
	when unique_violation then 
		rollback;
		raise notice 'Ya existe un registro en usuarios con este valor. Error: %', sqlerrm;
		insert into usuarios(id, nombre, edad, correo) values (v_nueva_identificacion, 'Pepe', 39, v_email);
		raise notice 'Se ha insertado el usuario con la identifiacion: %', v_nueva_identificacion;
end;
$$;

create or replace procedure prueba_cliente_debe_existir()
language plpgsql
as $$
begin 
	insert into facturas(fecha, cantidad, valor_unitario, valor_total, usuario_id)
	values('2024-09-16', 3, 1500, 4500, '1');
	insert into facturas(fecha, cantidad, valor_unitario, valor_total, usuario_id)
	values('2024-09-16', 3, 1500, 4500, '53');
exception
	when not_null_violation then
		rollback;
		raise notice 'No puede haber campos nulos. Error: %', sqlerrm;
end;
$$;




call poblar_usuarios();
call poblar_facturas();
select * from usuarios;
select * from facturas;

call prueba_producto_vacio();
select * from facturas;

call prueba_identificacion_unica();
select * from usuarios;

call prueba_cliente_debe_existir();
select * from usuarios;

