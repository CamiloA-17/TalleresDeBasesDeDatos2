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

CREATE TABLE pedidos (
    id serial PRIMARY KEY,
    fecha date NOT NULL,
    cantidad int NOT NULL,
    valor_total float NOT NULL,
    producto_id varchar(10),
    cliente_id varchar(30),
    FOREIGN KEY (producto_id) REFERENCES productos(codigo)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(identificacion)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


begin;

insert into clientes (identificacion, nombre, edad, correo) values ('123456789', 'Juan Perez', 30, 'juan.perez@example.com');
insert into clientes (identificacion, nombre, edad, correo) values ('12345678', 'Santiago Marin', 20, 'santiago.marin@example.com');
insert into clientes (identificacion, nombre, edad, correo) values ('1234567', 'Miguel Perez', 25, 'miguel.perez@example.com');

insert into productos (codigo, nombre, stock, valor_unitario) values ('10', 'Macbook', 15, '1250000');
insert into productos (codigo, nombre, stock , valor_unitario) values ('11', 'Samsung S24', 5, '800000');
insert into productos (codigo, nombre, stock, valor_unitario) values ('9', 'Ferrari', 2, '20000000');

insert into pedidos (fecha, cantidad, valor_total, producto_id, cliente_id) values ('2024-08-23', 2, 2500000, '10', '1234567');
insert into pedidos (fecha, cantidad, valor_total, producto_id, cliente_id) values ('2024-08-23', 4, 3200000, '11', '123456789');
insert into pedidos (fecha, cantidad, valor_total, producto_id, cliente_id) values ('2024-08-23', 2, 20000000, '9', '12345678');

update productos set valor_unitario = 3000000 where codigo = '10';
update productos set stock = 12 where codigo = '11';
update clientes  set edad = 31 where identificacion = '123456789';
update clientes set correo = 'miguelon.perez@example.com' where identificacion = '1234567';
update pedidos set valor_total = 6000000 where id = 1;
update pedidos set cantidad = 6 where id = 3;


delete from pedidos  where id = '1';
delete from productos where codigo = '10';
delete from clientes  where  identificacion = '1234567';

commit;







	