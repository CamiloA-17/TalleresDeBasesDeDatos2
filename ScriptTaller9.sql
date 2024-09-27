
    create table tipo_contrato (
        id serial primary key,
        nombre varchar,
        cargo varchar,
        salario_total numeric
    );

    create table empleados (
        identificacion serial primary key,
        nombre varchar,
        tipo_contrato_id integer,
        foreign key(tipo_contrato_id) references tipo_contrato(id)
    );

    create type nombre_concepto as enum('salario', 'horas_extra','prestaciones', 'impuestos');

    create table conceptos(
        codigo serial primary key,
        nombre nombre_concepto,
        porcentaje numeric
    );

    create table nomina(
        codigo serial primary key,
        mes integer,
        anio integer,
        fecha_pago date,
        total_devengado numeric,
        total_deducciones numeric,
        total numeric, 
        empleado_id integer,
        foreign key(empleado_id) references empleados(identificacion)
    );

    create table detalles_nomina(
        concepto_id integer,
        valor numeric, 
        nomina_id integer,
        primary key(concepto_id, nomina_id),
        foreign key(nomina_id) references nomina(codigo),
        foreign key(concepto_id) references conceptos(codigo)
    );

    create table contratos (
        id serial primary key,
        empleado_id integer,
        fecha_inicio date,
        fecha_fin date,
        tipo_contrato varchar,
        foreign key(empleado_id) references empleados(identificacion)
    );


    CREATE OR REPLACE PROCEDURE poblar_tablas() 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        i INTEGER;
    BEGIN

        INSERT INTO tipo_contrato (nombre, cargo, salario_total) VALUES
        ('Contrato 1', 'Admin', 1000),
        ('Contrato 2', 'Secretario', 2000),
        ('Contrato 3', 'Vendedor', 3000);

        FOR i IN 1..10 LOOP
            INSERT INTO empleados (nombre, tipo_contrato_id)
            VALUES 
            ('Empleado' || i, (i % 3) + 1);
        END LOOP;

        FOR i IN 1..10 LOOP
            INSERT INTO contratos (empleado_id, fecha_inicio, fecha_fin, tipo_contrato)
            VALUES 
            (i, '2022-01-01', '2022-12-31', 'Indefinido');
        END LOOP;

        FOR i IN 1..5 LOOP
            INSERT INTO nomina (mes, anio, fecha_pago, total_devengado, total_deducciones, total, empleado_id)
            VALUES 
            (i, 2023, '2023-01-' || (i * 5), 3000 + (i * 500), 500 + (i * 100), 2500 + (i * 400), i);
        END LOOP;

        FOR i IN 1..15 LOOP
            INSERT INTO conceptos (nombre, porcentaje)
            VALUES 
            (CASE 
                WHEN i % 4 = 0 THEN 'salario'
                WHEN i % 4 = 1 THEN 'horas_extra'
                WHEN i % 4 = 2 THEN 'prestaciones'
                ELSE 'impuestos'
             END, 5 + (i * 2));
        END LOOP;

        FOR i IN 1..15 LOOP
            INSERT INTO detalles_nomina (concepto_id, valor, nomina_id)
            VALUES 
            (i, 100 + (i * 10), (i % 5) + 1);
        END LOOP;
    END;
    $$;

    CALL poblar_tablas();


    CREATE OR REPLACE FUNCTION obtener_nomina_empleado(identificacion integer, mes integer, anio integer)
    RETURNS TABLE (
        nombre_empleado varchar,
        total_devengado numeric,
        total_deducciones numeric,
        total numeric
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT e.nombre, n.total_devengado, n.total_deducciones, n.total
        FROM empleados e
        JOIN nomina n ON e.identificacion = n.empleado_id
        WHERE e.identificacion = identificacion AND n.mes = mes AND n.anio = anio;
    END;
    $$ LANGUAGE plpgsql;


    select * from obtener_nomina_empleado(1, 1, 2023);

    CREATE OR REPLACE FUNCTION total_por_contrato(tipo_contrato varchar)
    RETURNS TABLE (
        nombre_empleado varchar,
        fecha_pago date,
        anio integer,
        mes integer,
        total_devengado numeric,
        total_deducciones numeric,
        total numeric
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT e.nombre, n.fecha_pago, n.anio, n.mes, n.total_devengado, n.total_deducciones, n.total
        FROM empleados e
        JOIN nomina n ON e.identificacion = n.empleado_id
        JOIN contratos c ON e.identificacion = c.empleado_id
        WHERE c.tipo_contrato = tipo_contrato;
    END;
    $$ LANGUAGE plpgsql;

    select * from total_por_contrato(2);
