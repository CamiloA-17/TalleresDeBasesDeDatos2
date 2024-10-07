
CREATE TABLE empleado (
    nombre VARCHAR(100),
    identificacion INT PRIMARY KEY,
    edad INT,
    correo VARCHAR(100),
    salario NUMERIC
);

CREATE TABLE nomina (
    id SERIAL PRIMARY KEY,
    fecha DATE,
    total_ingresos NUMERIC,
    total_deducciones NUMERIC,
    total_neto NUMERIC,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES empleado(identificacion)
);

CREATE TABLE detalle_de_nomina (
    id SERIAL PRIMARY KEY,
    concepto VARCHAR(100),
    tipo VARCHAR(50),
    valor NUMERIC,
    nomina_id INT,
    FOREIGN KEY (nomina_id) REFERENCES nomina(id)
);

CREATE TABLE auditoria_nomina (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    identificacion INTEGER NOT NULL,
    total_neto NUMERIC(12, 2) NOT NULL
);

CREATE TABLE auditoria_empleado (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    identificacion INTEGER NOT NULL,
    concepto VARCHAR(20) NOT NULL,  -- "AUMENTO" o "DISMINUCION"
    valor NUMERIC(12, 2) NOT NULL
);

INSERT INTO empleado (nombre, identificacion, edad, correo, salario)
VALUES 
('Pedro', 1, 15, 'pedro@email.com', 3000000),
('Marta', 2, 30, 'marta@email.com', 3500000),
('Camilo', 3, 10, 'camilo@email.com', 2800000);

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES 
('2024-01-01', 3000000, 500000, 2500000, 1),
('2024-01-01', 3500000, 600000, 2900000, 2),
('2024-01-01', 2800000, 400000, 2400000, 3);

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES ('2024-02-01', 10000000, 1000000, 9000000, 3);  


UPDATE empleado
SET salario = 7000000
WHERE identificacion = 2;  

CREATE OR REPLACE FUNCTION validar_presupuesto_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_nomina_mes NUMERIC;
BEGIN
    SELECT SUM(total_neto) INTO total_nomina_mes
    FROM nomina
    WHERE EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM NEW.fecha)
    AND EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM NEW.fecha)
    AND usuario_id = NEW.usuario_id;

    IF (total_nomina_mes + NEW.total_neto) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de nómina para este mes ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_presupuesto_nomina
BEFORE INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION validar_presupuesto_nomina();

CREATE OR REPLACE FUNCTION auditar_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO auditoria_nomina(fecha, nombre, identificacion, total_neto)
    SELECT NOW(), e.nombre, e.identificacion, NEW.total_neto
    FROM empleado e
    WHERE e.identificacion = NEW.usuario_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditar_nomina
AFTER INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION auditar_nomina();

CREATE OR REPLACE FUNCTION validar_actualizacion_salario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_salario NUMERIC;
BEGIN
    SELECT SUM(salario) INTO total_salario
    FROM empleado
    WHERE identificacion != OLD.identificacion;

    IF (total_salario + NEW.salario) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de salarios ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_actualizacion_salario
BEFORE UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION validar_actualizacion_salario();

CREATE OR REPLACE FUNCTION auditar_actualizacion_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    concepto VARCHAR(20);
    diferencia NUMERIC;
BEGIN
    -- Determinar si es un aumento o disminución
    IF NEW.salario > OLD.salario THEN
        concepto := 'AUMENTO';
        diferencia := NEW.salario - OLD.salario;
    ELSE
        concepto := 'DISMINUCION';
        diferencia := OLD.salario - NEW.salario;
    END IF;

    INSERT INTO auditoria_empleado(fecha, nombre, identificacion, concepto, valor)
    VALUES(NOW(), NEW.nombre, NEW.identificacion, concepto, diferencia);

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditar_actualizacion_empleado
AFTER UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION auditar_actualizacion_empleado();

select * from auditoria_empleado;
select * from auditoria_nomina;
select * from detalle_de_nomina;
select * from empleado;
select * from nomina;
