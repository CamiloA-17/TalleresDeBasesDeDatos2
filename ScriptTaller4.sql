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

insert into clientes (identificacion, nombre, edad, correo)values('1022322054','miguel angel',20,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322055','santiago valencia',18,'miguelonprez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322056','manuel alejandro',19,'miguelonper1ez300@gmail.com');

insert into productos(codigo, nombre, stock, valor_unitario)values('1','pollo',50,15000);
insert into productos(codigo, nombre, stock, valor_unitario)values('2','carne',50,20000);
insert into productos(codigo, nombre, stock, valor_unitario)values('3','huevo',50,600);

insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-12',2,30000,'1','1022322054', 'PENDIENTE');
insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-13',4,80000,'2','1022322055', 'BLOQUEADO');
insert into facturas( fecha, cantidad, valor_total, producto_id, cliente_id, pedido_estado)values('2003-11-14',2,1200,'3','1022322056', 'ENTREGADO');

create or replace procedure verificar_stock(
p_producto_id varchar,
p_cantidad integer
)
language plpgsql
as $$
declare 
	product_stock integer;
begin 
	select stock into product_stock from productos where codigo = p_producto_id;
	if product_stock >= p_cantidad then
		raise notice 'Si hay stock del producto';
	else
		raise notice 'No hay stock del producto';
	end if;
end;
$$

create or replace procedure actualizar_estado_pedido(
p_id_factura integer,
p_nuevo_estado estado
)
language plpgsql
as $$
declare 
	estado_actual estado;
begin
	select pedido_estado into estado_actual from facturas where p_id_factura = id;
	if estado_actual == p_nuevo_estado then
		raise notice 'Este ya es el estado asignado';
	else
		update facturas set pedido_estado = p_nuevo_estado where p_id_factura = id;
	end if;
end;
$$

call verificar_stock('1',100);
select * from facturas;
call actualizar_estado_pedido(2, 'ENTREGADO');




	