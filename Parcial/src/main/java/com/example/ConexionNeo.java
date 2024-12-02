package com.example;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;

public class ConexionNeo {
    private static Driver driver;

    public static void connect() {
        driver = GraphDatabase.driver("bolt://localhost:7687", AuthTokens.basic("neo4j", "15172223"));
    }

    public static void close() {
        driver.close();
    }

    public static Driver getDriver(){
        return driver;
    }

}

