import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;

public class TallerMongo {
    
    private static final String uri = "mongodb://localhost:27017";
    private static final MongoClient mongoClient = MongoClients.create(uri);
    private static final MongoDatabase database = mongoClient.getDatabase("mongoJAVA");
    private static final MongoCollection<org.bson.Document> collection = database.getCollection("productos");
    
    public static void main(String[] args) {
        System.out.println("Conexion exitosa");
        //Agregar productos
        
        // Producto 1
        List<Document> comentarios = new ArrayList<>();
        Document categoria = crearCategoria(1, "Libros");
        comentarios.add(crearComentario(1, "Interesante y educativo", "Ana"));
        comentarios.add(crearComentario(2, "Muy buen libro", "Luis"));
        insertarProducto(1, "El Quijote", "Novela clásica de la literatura española", 15, categoria, comentarios);
        
        // Producto 2
        comentarios.clear();
        categoria = crearCategoria(2, "Tecnología");
        comentarios.add(crearComentario(3, "Innovador y útil", "Marta"));
        comentarios.add(crearComentario(4, "Gran calidad", "Jorge"));
        insertarProducto(2, "Smartphone", "Teléfono inteligente de última generación", 300, categoria, comentarios);
        
        // Producto 3
        comentarios.clear();
        categoria = crearCategoria(3, "Juguetes");
        comentarios.add(crearComentario(5, "Divertido y educativo", "Lucía"));
        comentarios.add(crearComentario(6, "A mis hijos les encanta", "Miguel"));
        insertarProducto(3, "Lego", "Juego de construcción con bloques", 40, categoria, comentarios);
        
        // Producto 4
        comentarios.clear();
        categoria = crearCategoria(4, "Electrodomésticos");
        comentarios.add(crearComentario(7, "Muy útil en la cocina", "Laura"));
        comentarios.add(crearComentario(8, "Buen precio", "Carlos"));
        insertarProducto(4, "Licuadora", "Licuadora de alta potencia", 60, categoria, comentarios);
        
        // Producto 5
        comentarios.clear();
        categoria = crearCategoria(5, "Alimentos");
        comentarios.add(crearComentario(9, "Frescas y deliciosas", "Sofía"));
        comentarios.add(crearComentario(10, "Muy saludables", "Pedro"));
        insertarProducto(5, "Manzanas", "Manzanas orgánicas", 5, categoria, comentarios);
        
        // Producto 6
        comentarios.clear();
        categoria = crearCategoria(6, "Ropa");
        comentarios.add(crearComentario(11, "Muy cómoda", "Juan"));
        comentarios.add(crearComentario(12, "Buena calidad", "María"));
        insertarProducto(6, "Camiseta", "Camiseta de algodón", 20, categoria, comentarios);
        
        // Producto 7
        comentarios.clear();
        categoria = crearCategoria(7, "Muebles");
        comentarios.add(crearComentario(13, "Muy cómodo", "Andrés"));
        comentarios.add(crearComentario(14, "Bonito diseño", "Paula"));
        insertarProducto(7, "Sofá", "Sofá de tres plazas", 200, categoria, comentarios);
        
        // Producto 8
        comentarios.clear();
        categoria = crearCategoria(8, "Deportes");
        comentarios.add(crearComentario(15, "Muy resistente", "Diego"));
        comentarios.add(crearComentario(16, "Buen agarre", "Natalia"));
        insertarProducto(8, "Balón de fútbol", "Balón de fútbol profesional", 30, categoria, comentarios);
        
        // Producto 9
        comentarios.clear();
        categoria = crearCategoria(9, "Jardinería");
        comentarios.add(crearComentario(17, "Muy práctico", "Fernando"));
        comentarios.add(crearComentario(18, "Fácil de usar", "Elena"));
        insertarProducto(9, "Tijeras de podar", "Tijeras de podar de acero inoxidable", 25, categoria, comentarios);
        
        // Producto 10
        comentarios.clear();
        categoria = crearCategoria(10, "Belleza");
        comentarios.add(crearComentario(19, "Muy efectivo", "Clara"));
        comentarios.add(crearComentario(20, "Buen precio", "Raúl"));
        insertarProducto(10, "Crema hidratante", "Crema hidratante para la piel", 15, categoria, comentarios);
        
        // Actualizar productos
        collection.updateOne(eq("id", 1), new Document("$set", new Document("precio", 18)));
        collection.updateOne(eq("id", 2), new Document("$set", new Document("descripcion", "Teléfono inteligente de última generación con cámara mejorada")));
        collection.updateOne(eq("id", 3), new Document("$set", new Document("nombre", "Lego Star Wars")));
        collection.updateOne(eq("id", 4), new Document("$set", new Document("precio", 55)));
        collection.updateOne(eq("id", 5), new Document("$set", new Document("descripcion", "Manzanas orgánicas frescas")));
        
        // Eliminar productos
        collection.deleteOne(eq("id", 6)); 
        collection.deleteOne(eq("id", 7)); 
        
        // Consultas
        consultarProductosMayorA10();
        
        
        consultarProductosMayorA50YCategoriaRopa();
    }
    
    public static void consultarProductosMayorA10() {
        System.out.println("\nProductos mayores a $10 \n");
        for (Document producto : collection.find(gt("precio", 10))) {
            System.out.println(producto.toJson());
        }
    }
    
    public static void consultarProductosMayorA50YCategoriaRopa() {
        System.out.println("\nProductos mayores a $50 y categoría igual a 'Ropa' \n");
        for (Document producto : collection.find(and(gt("precio", 50), eq("categoria.nombre", "Ropa")))) {
            System.out.println(producto.toJson());
        }
    }
    
    private static Document crearCategoria(int id, String nombre) {
        Document categoria = new Document("id", id)
                .append("nombre", nombre);
        return categoria;
    }

    private static Document crearComentario(int id, String texto, String autor) {
        Document comentario = new Document("id", id)
                .append("texto", texto)
                .append("autor", autor);
        return comentario;
    }

    private static void insertarProducto(int id, String nombre, String descripcion, int precio, Document categoria, List<Document> comentarios) {
        Document producto = new Document("id", id)
                .append("nombre", nombre)
                .append("descripcion", descripcion)
                .append("precio", precio)
                .append("categoria", categoria)
                .append("comentarios", comentarios);
        collection.insertOne(producto);
    }
}