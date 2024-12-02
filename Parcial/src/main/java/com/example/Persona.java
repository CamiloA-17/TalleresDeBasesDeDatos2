package com.example;

public class Persona {
    private String id;
    private String nombre;
    private String correo;
    private String ciudad;
    private int edad;

    public Persona(String id, String nombre, String email, String ciudad, int edad) {
        this.id = id;
        this.nombre = nombre;
        this.setCorreo(email);
        this.setCiudad(ciudad);
        this.edad = edad;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getEdad() {
        return edad;
    }

    public void setEdad(int edad) {
        this.edad = edad;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }
}
