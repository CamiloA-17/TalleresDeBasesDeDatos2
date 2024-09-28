create table empleados (
	identificacion serial primary key,
	nombre varchar not null,
	tipo_contrato int not null,
	
	foreign key (tipo_contrato) references tipo_contrato(id)
)

create table tipo_contrato (
	id serial primary key,
	descripcion varchar not null,
	cargo varchar null,
	salario_total numeric not null
)

create table conceptos(
	codigo serial primary key,
	nombre varchar check (nombre in ('salario','horas_extras','prestaciones','impuestos')),
	porcentaje numeric
)

create table nomina(
	id serial primary key,
	mes varchar check (mes in ('01','02','03','04','05','06','07','08','09','10','11','12')),
	año varchar,
	fecha_pago date,
	total_devengado numeric,
	total_deducciones numeric,
	total numeric,
	cliente_id int,
	foreign key (cliente_id) references empleados(identificacion)
)


create table detalles_nomina(
	id serial primary key,
	valor numeric,
	concepto_id int,
	nomina_id int,
	foreign key (concepto_id) references conceptos(codigo),
	foreign key (nomina_id) references nomina(id)
)

CREATE OR REPLACE PROCEDURE insertar_tipo_contratos()
LANGUAGE plpgsql
AS $$
DECLARE
    descripciones VARCHAR[] := ARRAY['Indefinido', 'Temporal', 'Por obra'];
    cargos VARCHAR[] := ARRAY[
        'Director de Marketing', 
        'Ingeniero de Software', 
        'Contador', 
        'Especialista en Recursos Humanos', 
        'Desarrollador Frontend', 
        'Gestor de Proyectos', 
        'Analista de Datos', 
        'Soporte IT', 
        'Diseñador UX/UI', 
        'Gerente de Operaciones'
    ];
    descripcion VARCHAR;
    cargo VARCHAR;
    salario NUMERIC;
BEGIN
    FOR i IN 1..10 LOOP
        descripcion := descripciones[(floor(random() * array_length(descripciones, 1)) + 1)::int];
        cargo := cargos[(floor(random() * array_length(cargos, 1)) + 1)::int];
        
        salario := round((random() * (5000 - 1500) + 1500)::numeric, 2);
        
        INSERT INTO tipo_contrato (descripcion, cargo, salario_total)
        VALUES (descripcion, cargo, salario);
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE insertar_empleados()
LANGUAGE plpgsql
AS $$
DECLARE
    nombres VARCHAR[] := ARRAY[
        'Andrés Gómez', 
        'Laura Castillo', 
        'Felipe Rojas', 
        'Daniela Medina', 
        'Jorge Herrera', 
        'Camila Ortega', 
        'Santiago Rodríguez', 
        'Isabella Cruz', 
        'Mateo Vargas', 
        'Valentina Pardo'
    ];
    tipo_contrato_id INT;
    nombre VARCHAR;
BEGIN
    FOR i IN 1..10 LOOP

        nombre := nombres[(floor(random() * array_length(nombres, 1)) + 1)::int];
        tipo_contrato_id := (floor(random() * 10) + 1)::int; -- Genera un ID de contrato entre 1 y 10
        
        INSERT INTO empleados (nombre, tipo_contrato)
        VALUES (nombre, tipo_contrato_id);
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE insertar_nominas()
LANGUAGE plpgsql
AS $$
DECLARE
    meses VARCHAR[] := ARRAY['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
    años VARCHAR[] := ARRAY['2023', '2024', '2025'];
    mes VARCHAR;
    año VARCHAR;
    fecha_pago DATE;
    total_devengado NUMERIC;
    total_deducciones NUMERIC;
    total NUMERIC;
    cliente_id INT;
BEGIN
    FOR i IN 1..5 LOOP

        mes := meses[(floor(random() * array_length(meses, 1)) + 1)::int];
        año := años[(floor(random() * array_length(años, 1)) + 1)::int];
        fecha_pago := TO_DATE(año || '-' || mes || '-28', 'YYYY-MM-DD');
        total_devengado := (random() * 2000) + 3000; 
        total_deducciones := (random() * 500) + 400;  
        total := total_devengado - total_deducciones;
        cliente_id := (floor(random() * 10) + 1)::int;  

        INSERT INTO nomina (mes, año, fecha_pago, total_devengado, total_deducciones, total, cliente_id)
        VALUES (mes, año, fecha_pago, total_devengado, total_deducciones, total, cliente_id);
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE insertar_detalles_nomina()
LANGUAGE plpgsql
AS $$
DECLARE
    valor NUMERIC;
    concepto_id INT;
    nomina_id INT;
BEGIN
    FOR i IN 1..15 LOOP
       
        valor := (random() * 1000) + 100; 
        concepto_id := (floor(random() * 4) + 1)::int;  
        nomina_id := (floor(random() * 5) + 1)::int;  

        INSERT INTO detalles_nomina (valor, concepto_id, nomina_id)
        VALUES (valor, concepto_id, nomina_id);
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE insertar_conceptos()
LANGUAGE plpgsql
AS $$
DECLARE
    nombres TEXT[] := ARRAY['salario', 'horas_extras', 'prestaciones', 'impuestos'];
    porcentajes NUMERIC[] := ARRAY[100.00, 10.00, 8.50, 12.00];
BEGIN
    FOR i IN 1..array_length(nombres, 1) LOOP
        INSERT INTO conceptos (nombre, porcentaje) 
        VALUES (nombres[i], porcentajes[i]);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION obtener_nomina_empleado(emp_identificacion int, nomina_mes varchar, nomina_año varchar)
RETURNS TABLE (
    nombre_empleado varchar,
    total_devengado numeric,
    total_deducido numeric,
    total_nomina numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT e.nombre, n.total_devengado, n.total_deducciones, n.total FROM empleados e JOIN nomina n ON e.identificacion = n.cliente_id
    WHERE e.identificacion = emp_identificacion AND n.mes = nomina_mes AND n.año = nomina_año;
END;
$$;

CREATE OR REPLACE FUNCTION total_por_contrato(
    tipo_contrato_param int
)
RETURNS TABLE (
    nombre_empleado varchar,
    fecha_pago date,
    año varchar,
    mes varchar,
    total_devengado numeric,
    total_deducido numeric,
    total_nomina numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT e.nombre, n.fecha_pago, n.año, n.mes, n.total_devengado, n.total_deducciones, n.total FROM empleados e JOIN nomina n ON e.identificacion = n.cliente_id WHERE  e.tipo_contrato = tipo_contrato_param;
END;
$$;


call insertar_tipo_contratos();
call insertar_empleados();
call insertar_nominas();
call insertar_detalles_nomina();
call insertar_conceptos();

select * from obtener_nomina_empleado(4, '03', '2023');
select * from total_por_contrato(3);