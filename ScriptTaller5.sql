CREATE type estado as enum('PENDIENTE', 'BLOQUEADO', 'ENTREGADO');

create table clientes (
	nombre varchar(30) not null,
	identificacion varchar(15) primary key,
	edad integer not null,
	correo varchar(100) unique not null
);

CREATE TABLE productos (
    codigo varchar(10) PRIMARY KEY,
    nombre varchar(30) NULL,
    stock integer NULL,
    valor_unitario float NOT NULL
);


CREATE TABLE facturas (
    id serial PRIMARY KEY,
    fecha date NOT NULL,
    cantidad int NOT NULL,
    valor_total float NOT NULL,
    pedido_estado estado not null,
    producto_id varchar(10), 
    cliente_id varchar(30),
    FOREIGN KEY (producto_id) REFERENCES productos(codigo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(identificacion)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

create table auditorias(
	id serial primary key,
	fecha_inicio date not null,
	fecha_final date not null,
	factura_id integer,
	pedido_estado estado not null,
	foreign key(factura_id) references facturas(id)
		on delete set null
		on update cascade
);

insert into clientes (identificacion, nombre, edad, correo)values('1022322054','miguel angel',20,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322055','santiago valencia',18,'miguelonprez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322056','manuel alejandro',19,'miguelonper1ez300@gmail.com');

insert into productos(codigo, nombre, stock, valor_unitario)values('1','pollo',50,15000);
insert into productos(codigo, nombre, stock, valor_unitario)values('2','carne',50, 30000);
insert into productos(codigo, nombre, stock, valor_unitario)values('3','huevo',50, 17000);
insert into productos (codigo, nombre, stock, valor_unitario)values('4', 'Leche',20, 5600);

insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-12',2,30000,'1','1022322054', 'PENDIENTE');
insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-13',4,80000,'2','1022322055', 'BLOQUEADO');
insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-14',2,1200,'3','1022322056', 'ENTREGADO');


create or replace procedure obtener_total_stock()
language plpgsql
as $$
declare 
	v_total_stock integer:= 0;
	v_stock_actual integer;
	v_nombre_producto varchar;
begin
	for v_nombre_producto, v_stock_actual in select nombre, stock from productos
	loop
		raise notice 'El nombre del producto es: %', v_nombre_producto;
		raise notice 'El stock actual del producto es de: %', v_stock_actual;
		v_total_stock := v_total_stock + v_stock_actual;
	end loop;
	raise notice 'El stock total es de: %', v_total_stock;
end;
$$;

call obtener_total_stock();

create or replace procedure generar_auditoria(
	p_fecha_inicio date,
	p_fecha_final date
)
language plpgsql
as $$
declare 
	v_factura_id integer;
	v_estado_actual estado;
	v_fecha_inicio date;
begin 
	for v_factura_id, v_estado_actual, v_fecha_inicio in select id, pedido_estado, fecha from facturas
	loop
		if v_fecha_inicio between p_fecha_inicio and p_fecha_final then 
			insert into auditorias(fecha_inicio, fecha_final, factura_id, pedido_estado)values(p_fecha_inicio, p_fecha_final, v_factura_id, v_estado_actual);
			raise notice 'Se ha creado la auditoria';
		end if;
	end loop;

end;
$$;
	
call generar_auditoria('2003-11-12', '2003-11-13');
select * from auditorias a ;

create or replace procedure simular_ventas_mes()
language plpgsql
as $$
declare 
	v_dia integer := 1;
	v_identificacion varchar;
	v_cantidad integer;
begin
		while v_dia <= 30 loop
			for v_identificacion in select identificacion from clientes
			loop
				v_cantidad := floor(1+random()*10);
				insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values(now(),v_cantidad,30000,'1',v_identificacion, 'PENDIENTE');
			end loop;
			v_dia := v_dia +1;	
		end loop;
end;
$$;

call simular_ventas_mes();
select * from facturas;

