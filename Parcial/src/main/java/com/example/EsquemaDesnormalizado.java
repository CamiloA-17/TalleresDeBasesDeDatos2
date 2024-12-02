package com.example;

import com.mongodb.client.MongoCollection;
import org.bson.Document;

import static com.mongodb.client.model.Filters.*;
import static com.mongodb.client.model.Aggregates.*;
import static com.mongodb.client.model.Accumulators.sum;
import static com.mongodb.client.model.Updates.combine;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Updates.set;

import java.util.Arrays;

public class EsquemaDesnormalizado {

    public static void consultar(MongoCollection<Document> collection) {
        for (Document cursor : collection.find()) {
            System.out.println(cursor.toJson());
        }
    }

    public static void insertarReserva(MongoCollection<Document> collection, String id, Document cliente,
                                       Document habitacion, String fechaEntrada, String fechaSalida,
                                       double total, String estadoPago, String metodoPago, String fechaReserva) {
        Document reserva = new Document("_id", id)
                .append("cliente", cliente)
                .append("habitacion", habitacion)
                .append("fecha_entrada", fechaEntrada)
                .append("fecha_salida", fechaSalida)
                .append("total", total)
                .append("estado_pago", estadoPago)
                .append("metodo_pago", metodoPago)
                .append("fecha_reserva", fechaReserva);
        collection.insertOne(reserva);
    }

    public static void eliminarReserva(MongoCollection<Document> collection, String id) {
        collection.deleteOne(eq("_id", id));
    }

    public static void actualizarReserva(MongoCollection<Document> collection, String id, Document cliente,
                                         Document habitacion, String estadoPago) {
        collection.updateOne(eq("_id", id), combine(
                set("cliente", cliente),
                set("habitacion", habitacion),
                set("estado_pago", estadoPago)
        ));
    }

    public static void consultarHabitacionesSencillas(MongoCollection<Document> collection) {
        for (Document cursor : collection.find(eq("habitacion.tipo", "Sencilla"))) {
            System.out.println(cursor.toJson());
        }
    }

    public static void consultarSumatoriaReservasPagadas(MongoCollection<Document> collection) {
        Document resultado = collection.aggregate(Arrays.asList(
                match(eq("estado_pago", "Pagado")),
                group(null, sum("total_pagado", "$total"))
        )).first();

        double totalPagado = resultado != null ? resultado.getDouble("total_pagado") : 0.0;
        System.out.println("Total pagado en reservas: $" + totalPagado);
    }

    public static void consultarReservasPrecioMayor(MongoCollection<Document> collection, double precioMinimo) {
        for (Document cursor : collection.find(gt("habitacion.precio_noche", precioMinimo))) {
            System.out.println(cursor.toJson());
        }
    }
}
