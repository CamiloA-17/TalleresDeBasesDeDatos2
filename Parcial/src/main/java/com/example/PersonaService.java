package com.example;

import org.neo4j.driver.Driver;
import org.neo4j.driver.Session;
import org.neo4j.driver.SessionConfig;
import org.neo4j.driver.Values;

public class PersonaService {
    private static final Driver driver = ConexionNeo.getDriver();
    private Session session;

    public PersonaService() {
        this.session = driver.session(SessionConfig.forDatabase("neo4j"));
    }

    public void crearPersona(String id, String nombre, String correo, String ciudad, int edad){
        String cypherQuery = "CREATE (p:Persona {id: $id, nombre: $nombre, correo: $correo, ciudad: $ciudad,  edad: $edad})";
        session.run(cypherQuery, Values.parameters("id", id, "nombre", nombre, "correo", correo, "ciudad", ciudad ,"edad", edad));
        System.out.println("Persona creada: " + id);
    }

    public Persona obtenerPersona(String identificacion){
        String cypherQuery = "MATCH (p:Persona {id: $identificacion}) RETURN p.id";
        org.neo4j.driver.Record record = session.run(cypherQuery, Values.parameters("id", identificacion)).single();
        if (record != null){
            return new Persona(
                    record.get("id").asString(),
                    record.get("nombre").asString(),
                    record.get("correo").asString(),
                    record.get("ciudad").asString(),
                    record.get("edad").asInt()
            );
        }
        return null;
    }

    public void actualizarPersona(String identificacion, int nuevaEdad){
        String cypherQuery = "MATCH (p:Persona {id: $identifcacion}) SET p.edad = $nuevaEdad";
        session.run(cypherQuery, Values.parameters("id", identificacion, "nuevaEdad", nuevaEdad));
        System.out.println("Persona actualizada");
    }

    public void crearRelacion(String identificacion1, String identificacion2, String descripcion){
        String cypherQuery = "MATCH (p1:Persona {id: $identificacion1}), (p2:Persona {id: $identificacion2})" + "CREATE (p1)-[:COMENTARIO{descripcion: $descripcion}] -> (p2)";
        session.run(cypherQuery, Values.parameters("identificacion1", identificacion1, "identificacion2", identificacion2, "descripcion", descripcion));
        System.out.println("Relacion creada");
    }
}
