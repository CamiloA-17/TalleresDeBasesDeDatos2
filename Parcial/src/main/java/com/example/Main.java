package com.example;


import org.bson.Document;
import com.mongodb.client.MongoCollection;


public class Main {
    public static void main(String[] args) {
        ConexionMongo conexion = ConexionMongo.getInstance();
        MongoCollection<Document> productos = conexion.getCollection("Productos");
        MongoCollection<Document> pedidos = conexion.getCollection("Pedidos");
        MongoCollection<Document> detallePedidos = conexion.getCollection("Detalle_Pedidos");
        MongoCollection<Document> reservas = conexion.getCollection("Reservas");

        //CRUD Productos
        EsquemaNormalizado.insertarProducto(productos, "001", "Laptop", "Laptop Gamer", 1200.0, 10);
        EsquemaNormalizado.insertarProducto(productos, "010", "Mouse", "Mouse Gamer", 50.0, 20);
        EsquemaNormalizado.actualizarProducto(productos, "001", "Laptop", "Laptop Gamer", 1200.0, 5);
        EsquemaNormalizado.consultar(productos);
        EsquemaNormalizado.eliminar(productos, "001");

        //CRUD Pedidos
        EsquemaNormalizado.crearPedido(pedidos, "001", "001", "2021-10-10", "Enviado", 1200.0);
        EsquemaNormalizado.actualizarPedido(pedidos, "001", "001", "2021-10-10", "Enviado", 1200.0);
        EsquemaNormalizado.consultar(pedidos);
        EsquemaNormalizado.eliminarPedido(pedidos, "001");

        //CRUD Detalle Pedidos
        EsquemaNormalizado.crearDetallePedido(detallePedidos, "001", "001", "001", 2, 2400.0);
        EsquemaNormalizado.actualizarDetallePedido(detallePedidos, "001", "001", "001", 2, 2400.0);
        EsquemaNormalizado.consultar(detallePedidos);
        EsquemaNormalizado.eliminarDetallePedido(detallePedidos, "001");

        //Productos con precio mayor a 20
        System.out.println("Productos con precio mayor a 20");
        EsquemaNormalizado.consultarProductosCaros(productos);

        //Pedidos con total mayor a 100
        System.out.println("Pedidos con total mayor a 100");
        EsquemaNormalizado.consultarPedidosAltos(pedidos);

        //Pedidos donde existe un detalle de pedido con el producto 010
        System.out.println("Pedidos con producto 010");
        EsquemaNormalizado.consultarPedidosConProducto(detallePedidos, "010");

        //Esquema Desnormalizado
        Document cliente = new Document("nombre", "Ana Gómez")
                .append("correo", "ana.gomez@example.com")
                .append("telefono", "+54111223344")
                .append("direccion", "Calle Ficticia 123, Buenos Aires, Argentina");

        Document habitacion = new Document("tipo", "Suite")
                .append("numero", 101)
                .append("precio_noche", 200.00)
                .append("capacidad", 2)
                .append("descripcion", "Suite con vista al mar, cama king size, baño privado y balcón.");

        // Insertar reserva
        EsquemaDesnormalizado.insertarReserva(reservas, "reserva001", cliente, habitacion,
                "2024-12-15T14:00:00Z", "2024-12-18T12:00:00Z", 740.00, "Pagado",
                "Tarjeta de Crédito", "2024-11-30T10:00:00Z");

        // Consultar todas las reservas
        EsquemaDesnormalizado.consultar(reservas);

        // Actualizar una reserva
        EsquemaDesnormalizado.actualizarReserva(reservas, "reserva001", cliente, habitacion, "Pendiente");

        // Consultar habitaciones de tipo Sencilla
        System.out.println("Habitaciones Sencillas:");
        EsquemaDesnormalizado.consultarHabitacionesSencillas(reservas);

        // Consultar la sumatoria total de reservas pagadas
        System.out.println("\nSumatoria de Reservas Pagadas:");
        EsquemaDesnormalizado.consultarSumatoriaReservasPagadas(reservas);

        // Consultar reservas con precio noche > 100 dólares
        System.out.println("\nReservas con precio por noche mayor a $100:");
        EsquemaDesnormalizado.consultarReservasPrecioMayor(reservas, 100.0);

        ConexionNeo.connect();

        PersonaService personaService = new PersonaService();

        personaService.crearPersona("1055", "Pepe", "pepe@gmail.com", "Manizales", 19);
        personaService.crearPersona("1054", "Romario", "romario@gmail.com", "Manizales", 19);
        personaService.crearRelacion("1055", "1054", "AMIGO");
    }
}