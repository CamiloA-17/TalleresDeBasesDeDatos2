ALTER USER TALLER6PLSQL QUOTA UNLIMITED ON USERS;


CREATE TABLE clientes(
	identificacion varchar (30) primary key,
	nombre varchar (30) not null,
	edad integer,
	correo varchar(30)not null
	);

CREATE TABLE productos(
	codigo varchar (30) primary key,
	nombre varchar (30) not null,
	stock integer,
	valor_unitario float
);

CREATE TABLE facturas(
	id varchar(30) primary key,
	fecha date not null,
	cantidad integer,
	valor_total float,
	pedido_estado varchar(20) CHECK (pedido_estado IN ('PAGO', 'NO PAGO', 'PENDIENTE')),
	producto_id varchar (30) not null,
	cliente_id varchar (30) not null,
	foreign key(producto_id) references productos(codigo),
	foreign key(cliente_id) references clientes(identificacion)	
);

insert into clientes (identificacion, nombre, edad, correo) values ('1', 'Santi', 20, 'santi@example');
insert into clientes (identificacion, nombre, edad, correo) values ('2', 'Manuel', 22, 'manuel@example');
insert into productos (codigo, nombre, stock, valor_unitario) values ('1', 'Chocolate', 4, 4000);
insert into productos (codigo, nombre, stock, valor_unitario) values ('2', 'Manzana', 10, 500);
insert into facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) values ('1', TO_DATE('2024/04/04', 'YYYY/MM/DD'), 10, 48000, 'NO PAGO', '1', '1');
insert into facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) values ('2', TO_DATE('2024/04/04', 'YYYY/MM/DD'), 12, 48000, 'NO PAGO', '2', '2');


CREATE OR REPLACE PROCEDURE verificar_stock(
	p_producto_id IN VARCHAR,
	p_cantidad_compra IN NUMBER
	)
IS
	p_stock NUMBER := 0;
BEGIN
	--Obtener el stock del producto
	SELECT stock INTO p_stock FROM productos WHERE codigo = p_producto_id;
	--Verificar que si haya stock
	IF p_cantidad_compra > p_stock THEN
		DBMS_OUTPUT.PUT_LINE('No hay suficiente stock de este producto');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Si hay stock suficiente');
	END IF;
END;

CALL verificar_stock('1', 1)