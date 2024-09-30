/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package conexionbd;
import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author camiloandresmolanoaristizabal
 */
public class ConexionBD {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
       try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres","postgres","15172223");
            
            //Procedimientos almacenados
            
            CallableStatement generarAuditoria = conexion.prepareCall("call taller5.generar_auditoria(?,?)");
            CallableStatement simularVentasMes = conexion.prepareCall("call taller5.simular_ventas_mes()");

            
            //Fecha inicio de auditoria
            generarAuditoria.setDate(1, java.sql.Date.valueOf("2023-11-12"));
            //Fecha final de auditoria
            generarAuditoria.setDate(2, java.sql.Date.valueOf("2023-11-13"));
            
            //Funciones almacenadas
            
            CallableStatement transaccionesTotalMes = conexion.prepareCall("{ call taller6.transacciones_total_mes(?,?) }");
            CallableStatement serviciosNoPagados = conexion.prepareCall("{ call taller6.servicios_no_pagados(?) }");
            
            transaccionesTotalMes.setInt(1, 8);
            transaccionesTotalMes.setString(2, "401");
            
            serviciosNoPagados.setString(1, "401");
            
            //Ejecutar consultas
            generarAuditoria.execute();
            simularVentasMes.execute();

            ResultSet resultadoTransacciones = transaccionesTotalMes.executeQuery();
            ResultSet serviciosSinPagar = serviciosNoPagados.executeQuery();
            BigDecimal totalTransacciones = new BigDecimal(0);
            BigDecimal totalServiciosSinPagar = new BigDecimal(0);
            while(resultadoTransacciones.next()){
               totalTransacciones = resultadoTransacciones.getBigDecimal(1);
            }
            while (serviciosSinPagar.next()) {
                totalServiciosSinPagar = serviciosSinPagar.getBigDecimal(1);
               
            }
            System.out.println("Total transacciones: " + totalTransacciones);
            System.out.println("Total servicios sin pagar: " + totalServiciosSinPagar);
            
            //Cerrar conexiones
            generarAuditoria.close();
            simularVentasMes.close();
            transaccionesTotalMes.close();
            serviciosNoPagados.close();
            conexion.close();

            
        } catch (Exception e) {
            System.out.println("Error "+ e.getMessage());
        }
    }
    
}
