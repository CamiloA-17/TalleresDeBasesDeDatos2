package com.example;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

public class ConexionMongo {
    private static ConexionMongo instance;
    private MongoClient mongoClient;
    private MongoDatabase database;

    private ConexionMongo() {
        try {
            String uri = "mongodb://localhost:27017";
            this.mongoClient = MongoClients.create(uri);
            this.database = mongoClient.getDatabase("parcial");
            System.out.println("Conexión MongoDB exitosa");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static ConexionMongo getInstance() {
        if (instance == null) {
            instance = new ConexionMongo();
        }
        return instance;
    }

    public MongoCollection<Document> getCollection(String collectionName) {
        return database.getCollection(collectionName);
    }
}
