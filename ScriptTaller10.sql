create table cursor.empleados(
	id varchar primary key,
	nombre varchar,
	correo varchar,
	salario double precision
	
)

insert into cursor.empleados(id, nombre, correo, salario) values ('1091354977', 'Abel Gomez', 'abelsantiago1000@gmail.com', 20000000);
insert into cursor.empleados(id, nombre, correo, salario) values ('1', 'Daniela', 'daniela@gmail.com', 200000000);
insert into cursor.empleados(id, nombre, correo, salario) values ('2', 'Jose', 'jose1000@gmail.com', 200000000);
insert into cursor.empleados(id, nombre, correo, salario) values ('3', 'Sonia', 'sonia1000@gmail.com', 200000000);
insert into cursor.empleados(id, nombre, correo, salario) values ('4', 'Mily', 'mily1000@gmail.com', 200000000);

CREATE OR REPLACE PROCEDURE actualizar_salarios()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_cursor CURSOR FOR SELECT id, correo, salario from cursor.empleados;
	v_aumento NUMERIC;
	v_id varchar;
	v_correo varchar;
	v_salario double precision;
BEGIN
	OPEN v_cursor;
	LOOP
		FETCH v_cursor INTO v_id, v_correo, v_salario;
		EXIT WHEN NOT FOUND;
		
		--Calcular el aumento
		v_aumento := v_salario * 0.2;
		raise notice 'El correo es: % y el aumento es de: %', v_correo, v_aumento;
		--Actualizar el salario
		UPDATE cursor.empleados SET salario = salario + v_aumento WHERE id = v_id;
	END LOOP;
	CLOSE v_cursor;
END;
$$;



call cursor.actualizar_salarios();


