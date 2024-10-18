package tallerxml;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TallerXML {

    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "15172223");
            
            CallableStatement guardarLibro = conexion.prepareCall("call taller16.guardar_libro(?, ?)");
            guardarLibro.setString(1, "9781234567897"); 
            guardarLibro.setObject(2, "<libros><libro><titulo>1984</titulo><autor>George Orwell</autor><anio>1949</anio></libro></libros>", Types.OTHER);
            guardarLibro.execute();
            
            CallableStatement actualizarLibro = conexion.prepareCall("call taller16.actualizar_libro(?, ?)");
            actualizarLibro.setString(1, "9781234567897"); 
            actualizarLibro.setObject(2, "<libros><libro><titulo>1984</titulo><autor>George Orwell</autor><anio>1948</anio></libro></libros>", Types.OTHER);
            actualizarLibro.execute();
            
            CallableStatement obtenerAutorPorIsbn = conexion.prepareCall("SELECT taller16.obtener_autor_libro_por_isbn(?)");
            obtenerAutorPorIsbn.setString(1, "9781234567897"); 
            ResultSet rsAutorPorIsbn = obtenerAutorPorIsbn.executeQuery();
            if (rsAutorPorIsbn.next()) {
                String autorPorIsbn = rsAutorPorIsbn.getString(1);
                System.out.println("Autor del libro con ISBN 9781234567897: " + autorPorIsbn);
            }
            
            CallableStatement obtenerAutorPorTitulo = conexion.prepareCall("SELECT taller16.obtener_autor_libro_por_titulo(?)");
            obtenerAutorPorTitulo.setString(1, "1984"); 
            ResultSet rsAutorPorTitulo = obtenerAutorPorTitulo.executeQuery();
            if (rsAutorPorTitulo.next()) {
                String autorPorTitulo = rsAutorPorTitulo.getString(1);
                System.out.println("Autor del libro con título '1984': " + autorPorTitulo);
            }
            
            CallableStatement obtenerLibrosPorAnio = conexion.prepareCall("SELECT * FROM taller16.obtener_libros_por_anio(?)");
            obtenerLibrosPorAnio.setInt(1, 1949); 
            ResultSet rsLibrosPorAnio = obtenerLibrosPorAnio.executeQuery();
            List<String> librosPorAnio = new ArrayList<>();
            while (rsLibrosPorAnio.next()) {
                String titulo = rsLibrosPorAnio.getString(1);
                String autor = rsLibrosPorAnio.getString(2);
                librosPorAnio.add("Título: " + titulo + ", Autor: " + autor);
            }
            System.out.println("Libros publicados en 1949:");
            librosPorAnio.forEach(System.out::println);
            
            guardarLibro.close();
            actualizarLibro.close();
            obtenerAutorPorIsbn.close();
            obtenerAutorPorTitulo.close();
            obtenerLibrosPorAnio.close();
            conexion.close();
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
