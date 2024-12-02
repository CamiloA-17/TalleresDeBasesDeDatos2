package com.example;

import com.mongodb.client.MongoCollection;
import org.bson.Document;

import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Updates.set;

public class EsquemaNormalizado {

    public static void consultar(MongoCollection<Document> collection) {
        for (Document cursor : collection.find()) {
            System.out.println(cursor.toJson());
        }
    }

    public static void insertarProducto(MongoCollection<Document> collection, String id,
                                        String nombreProducto, String descripcion, Double precio, int stock) {
        Document document = new Document("id", id)
                .append("nombre", nombreProducto)
                .append("descripcion", descripcion)
                .append("precio", precio)
                .append("stock", stock);
        collection.insertOne(document);
    }

    public static void eliminar(MongoCollection<Document> collection, String id) {
        collection.deleteOne(eq("id", id));
    }

    public static void actualizarProducto(MongoCollection<Document> collection, String id,
                                          String nombreProducto, String descripcion, Double precio, int stock) {
        collection.updateOne(eq("id", id), set("nombre", nombreProducto));
        collection.updateOne(eq("id", id), set("descripcion", descripcion));
        collection.updateOne(eq("id", id), set("precio", precio));
        collection.updateOne(eq("id", id), set("stock", stock));
    }

    public static void crearPedido(MongoCollection<Document> collection, String id, String cliente_id, String fecha_pedido,
                                   String estado, Double total) {
        Document document = new Document("id", id)
                .append("cliente_id", cliente_id)
                .append("fecha_pedido", fecha_pedido)
                .append("estado", estado)
                .append("total", total);
        collection.insertOne(document);
    }

    public static void actualizarPedido(MongoCollection<Document> collection, String id, String cliente_id, String fecha_pedido,
                                        String estado, Double total) {
        collection.updateOne(eq("id", id), set("cliente_id", cliente_id));
        collection.updateOne(eq("id", id), set("fecha_pedido", fecha_pedido));
        collection.updateOne(eq("id", id), set("estado", estado));
        collection.updateOne(eq("id", id), set("total", total));
    }

    public static void eliminarPedido(MongoCollection<Document> collection, String id) {
        collection.deleteOne(eq("id", id));
    }

    public static void crearDetallePedido(MongoCollection<Document> collection, String id, String id_pedido,
                                          String id_producto, int cantidad, Double precio_unitario) {
        Document document = new Document("id", id)
                .append("id_pedido", id_pedido)
                .append("id_producto", id_producto)
                .append("cantidad", cantidad)
                .append("precio_unitario", precio_unitario);
        collection.insertOne(document);
    }

    public static void actualizarDetallePedido(MongoCollection<Document> collection, String id, String id_pedido,
                                               String id_producto, int cantidad, Double precio_unitario) {
        collection.updateOne(eq("id", id), set("id_pedido", id_pedido));
        collection.updateOne(eq("id", id), set("id_producto", id_producto));
        collection.updateOne(eq("id", id), set("cantidad", cantidad));
        collection.updateOne(eq("id", id), set("precio_unitario", precio_unitario));
    }

    public static void eliminarDetallePedido(MongoCollection<Document> collection, String id) {
        collection.deleteOne(eq("id", id));
    }

    public static void consultarProductosCaros(MongoCollection<Document> collection) {
        for (Document cursor : collection.find(eq("precio", new Document("$gt", 20)))) {
            System.out.println(cursor.toJson());
        }
    }

    public static void consultarPedidosAltos(MongoCollection<Document> pedidosCollection) {
        for (Document cursor : pedidosCollection.find(new Document("total", new Document("$gt", 100)))) {
            System.out.println(cursor.toJson());
        }
    }

    //Obtener los pedidos en donde exista un detalle de pedido con el producto010
    public static void consultarPedidosConProducto(MongoCollection<Document> detallePedidosCollection, String productoId) {
        for (Document cursor : detallePedidosCollection.find(eq("id_producto", productoId))) {
            System.out.println(cursor.toJson());
        }
    }
}

