CREATE TABLE taller16.libros (
    isbn VARCHAR(13) PRIMARY KEY,
    descripcion_xml XML
);

CREATE OR REPLACE PROCEDURE taller16.guardar_libro(
    IN p_isbn VARCHAR(13),
    IN p_descripcion_xml XML
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM taller16.libros 
        WHERE isbn = p_isbn 
        OR descripcion_xml::text LIKE '%' || array_to_string(xpath('string(//titulo)', p_descripcion_xml), '') || '%'
    ) THEN
        INSERT INTO taller16.libros (isbn, descripcion_xml)
        VALUES (p_isbn, p_descripcion_xml);
    ELSE
        RAISE NOTICE 'El libro ya existe.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE taller16.actualizar_libro(
    IN p_isbn VARCHAR(13),
    IN p_descripcion_xml XML
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE taller16.libros
    SET descripcion_xml = p_descripcion_xml
    WHERE isbn = p_isbn;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró un libro con el ISBN %', p_isbn;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION taller16.obtener_autor_libro_por_isbn(
    p_isbn VARCHAR(13)
)
RETURNS TEXT AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT array_to_string(xpath('string(//autor)', descripcion_xml), '')
    INTO autor
    FROM taller16.libros
    WHERE isbn = p_isbn;

    IF autor IS NULL OR autor = '' THEN
        RETURN 'No se encontró el libro con el ISBN ' || p_isbn;
    ELSE
        RETURN autor;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION taller16.obtener_autor_libro_por_titulo(
    p_titulo TEXT
)
RETURNS TEXT AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT array_to_string(xpath('string(//autor)', descripcion_xml), '')
    INTO autor
    FROM taller16.libros
    WHERE descripcion_xml::text LIKE '%' || p_titulo || '%';

    IF autor IS NULL OR autor = '' THEN
        RETURN 'No se encontró el libro con el título ' || p_titulo;
    ELSE
        RETURN autor;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION taller16.obtener_libros_por_anio(
    p_anio INTEGER
)
RETURNS TABLE(titulo TEXT, autor TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT array_to_string(xpath('string(//titulo)', descripcion_xml), '')::TEXT,
           array_to_string(xpath('string(//autor)', descripcion_xml), '')::TEXT
    FROM taller16.libros
    WHERE array_to_string(xpath('string(//anio)', descripcion_xml), '')::INTEGER = p_anio;
END;
$$ LANGUAGE plpgsql;


SELECT proname, proargtypes
FROM pg_proc
WHERE proname = 'guardar_libro';

