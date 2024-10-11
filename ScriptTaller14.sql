create table factura(
	codigo varchar primary key,
	cliente varchar,
	producto varchar,
	descuento numeric,
	valor_total numeric,
	numero_fe varchar


);

CREATE SEQUENCE codigo_seq
	START WITH 1
	INCREMENT BY 1;

CREATE SEQUENCE numero_fe_seq
	START WITH 100
	INCREMENT BY 100;
	
create or replace procedure poblar_facturas()
language plpgsql
as $$
declare 
    v_codigo varchar;
    v_cliente varchar;
    v_producto varchar;
	v_descuento numeric;
	v_total numeric;
	v_numero_fe varchar;
begin
    for i in 1..10 loop
        v_codigo := nextval('codigo_seq');
        v_cliente := (array['Santiago', 'Andres', 'Juan', 'Marcela', 'Mariana'])[floor(random() * 5 + 1)];
		v_producto := (array['PC', 'TV', 'XBOX', 'PS', 'NINTENTO'])[floor(random() * 5 + 1)];
		v_descuento := floor(random() + 0.1); 
		v_total := floor(random()*10+1);
		v_numero_fe := nextval('numero_fe_seq');
        insert into factura (codigo, cliente, producto, descuento, valor_total, numero_fe) 
		values (v_codigo, v_cliente, v_producto, v_descuento, v_total, v_numero_fe);
    end loop;
end;
$$;

call poblar_facturas();
select * from factura;