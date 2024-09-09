create table clientes (
	id varchar primary key,
	nombre varchar not null,
	email varchar,
	direccion varchar,
	telefono varchar not null

);

create table servicios (
	codigo varchar primary key,
	tipo varchar not null,
	monto numeric not null,
	cuota numeric not null,
	intereses numeric not null,
	valor_total numeric not null,
	cliente_id varchar,
	estado varchar check (estado in ('pago', 'no_pago', 'pendiente_pago')),
	
	foreign key (cliente_id) references clientes(id)
	on update cascade
	on delete cascade
);


create table pagos (
	codigo_transaccion varchar primary key,
	fecha_pago date not null,
	total numeric not null,
	servicio_id varchar,
	
	foreign key (servicio_id) references servicios(codigo)
	on update cascade
	on delete cascade
);

   
CREATE SEQUENCE secuencia_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
   
CREATE SEQUENCE secuencia_codigo
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
   
CREATE SEQUENCE secuencia_transaccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


create or replace procedure poblar_clientes()
language plpgsql
as $$
declare 
    v_id varchar;
    v_nombre varchar;
    v_email varchar;
    v_direccion varchar;
    v_telefono varchar;
begin
    for i in 1..50 loop
        v_id := nextval('secuencia_id');
        v_nombre := (array['Juan', 'María', 'Pedro', 'Ana', 'Luis', 'Sofía', 'Carlos', 'Laura', 'Jorge', 'Marta'])[floor(random() * 10 + 1)];
        v_email := v_nombre || '@example.com';
        v_direccion := (array['Calle 1', 'Calle 2', 'Calle 3', 'Calle 4', 'Calle 5'])[floor(random() * 5 + 1)];
        v_telefono := '3' || lpad((floor(random() * 10000000)::text), 7, '0');
        
        insert into clientes (id, nombre, email, direccion, telefono) values (v_id, v_nombre, v_email, v_direccion, v_telefono);
    end loop;
end;
$$;

call poblar_clientes();
select * from clientes;

create or replace procedure poblar_servicios()
language plpgsql
as $$
declare 
    v_codigo varchar;
    v_tipo varchar;
    v_monto numeric;
    v_cuota numeric;
    v_intereses numeric;
    v_valor_total numeric;
    v_cliente_id varchar;
    v_estado varchar;
begin
    for v_cliente_id in (select id from clientes) loop
        for i in 1..3 loop
            v_codigo := nextval('secuencia_codigo')::varchar;
            v_tipo := (array['tipo1', 'tipo2', 'tipo3'])[floor(random() * 3 + 1)];
            v_monto := round(random() * 1000 + 100)::numeric;
            v_cuota := round(random() * 100 + 10)::numeric;
            v_intereses := round(random() * 10 + 1)::numeric;
            v_valor_total := v_monto + v_intereses;
            v_estado := (array['pago', 'no_pago', 'pendiente_pago'])[floor(random() * 3 + 1)];
            
            insert into servicios (codigo, tipo, monto, cuota, intereses, valor_total, cliente_id, estado) 
            values (v_codigo, v_tipo, v_monto, v_cuota, v_intereses, v_valor_total, v_cliente_id, v_estado);
        end loop;
    end loop;
end;
$$;

create or replace procedure poblar_pagos()
language plpgsql
as $$
declare
    v_codigo_transaccion varchar;
    v_fecha_pago date;
    v_total numeric;
    v_servicio_id varchar;
    v_count integer;
    v_num_pagos integer := 50;
begin
    v_count := 0;
    for v_servicio_id in (
        select s.codigo 
        from servicios s
        where s.estado = 'pago'
    ) loop
        v_codigo_transaccion := nextval('secuencia_transaccion');
        v_fecha_pago := current_date - (floor(random() * 30 + 1)::int);
        v_total := (select s.valor_total from servicios s where s.codigo = v_servicio_id);

        insert into pagos (codigo_transaccion, fecha_pago, total, servicio_id) 
        values (v_codigo_transaccion, v_fecha_pago, v_total, v_servicio_id);
        
        v_count := v_count + 1;


        if v_count >= v_num_pagos then
            exit;
        end if;
    end loop;

    if v_count < v_num_pagos then
        for v_servicio_id in (
            select s.codigo 
            from servicios s
            where s.estado != 'pago'
            order by random()
            limit (v_num_pagos - v_count)
        ) loop
            v_codigo_transaccion := nextval('secuencia_transaccion');
            v_fecha_pago := current_date - (floor(random() * 30 + 1)::int); 
            v_total := (select s.valor_total from servicios s where s.codigo = v_servicio_id);

            insert into pagos (codigo_transaccion, fecha_pago, total, servicio_id) 
            values (v_codigo_transaccion, v_fecha_pago, v_total, v_servicio_id);
        end loop;
    end if;

end;
$$;


call poblar_clientes();
call poblar_servicios();
call poblar_pagos();

select * from clientes;
select * from servicios;
select * from pagos;

drop table clientes;
drop table  servicios;
drop table pagos;

CREATE OR REPLACE FUNCTION transacciones_total_mes(p_mes INTEGER, p_cliente VARCHAR)
RETURNS NUMERIC AS 
$$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(p.total), 0)
    INTO v_total
    FROM pagos p
    JOIN servicios s ON p.servicio_id = s.codigo
    WHERE s.cliente_id = p_cliente
    AND EXTRACT(MONTH FROM p.fecha_pago) = p_mes;

    RETURN v_total;
END;
$$
LANGUAGE plpgsql;

SELECT transacciones_total_mes(1, '3');

