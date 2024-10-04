/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package tallerreturnquery;

import java.math.BigDecimal;
import java.sql.*;


/**
 *
 * @author camiloandresmolanoaristizabal
 */
public class TallerReturnQuery {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
       try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres","postgres","15172223");
            
            CallableStatement obtenerNominaEmpleado = conexion.prepareCall("{ call taller9.obtener_nomina_empleado(?,?,?) } ");
            CallableStatement totalPorContrato = conexion.prepareCall("{ call taller9.total_por_contrato(?) }");
            
            obtenerNominaEmpleado.setInt(1, 4);
            obtenerNominaEmpleado.setString(2, "03");
            obtenerNominaEmpleado.setString(3, "2023");
            totalPorContrato.setInt(1, 3);
            
            ResultSet nominaEmpleado = obtenerNominaEmpleado.executeQuery();
            ResultSet contratoTotal = totalPorContrato.executeQuery();
            BigDecimal  totalNomina = new BigDecimal(0);
            String anno = "";
            String mes = "";
            String nombreEmpleado = "";
            while (nominaEmpleado.next()) {
               
                nombreEmpleado = nominaEmpleado.getString(1);
                totalNomina = nominaEmpleado.getBigDecimal(4);

               
            }
            System.out.println("Nombre Empleado: " + nombreEmpleado);
            System.out.println("Total nómina: " + totalNomina);
            System.out.println("-------------------------------------");
            
            while (contratoTotal.next()) {
               nombreEmpleado = contratoTotal.getString(1);
               anno = contratoTotal.getString(3);
               mes = contratoTotal.getString(4);
               totalNomina = contratoTotal.getBigDecimal(7);
               
                System.out.println("Contrato:");
               
                System.out.println("Nombre Empleado: " + nombreEmpleado);
                System.out.println("Mes: " + mes + "del año; " + anno);
                System.out.println("Total Contrato: " + totalNomina);
                System.out.println("-------------------------------------");
           }
             
            
            obtenerNominaEmpleado.close();
            conexion.close();

            
        } catch (Exception e) {
            System.out.println("Error "+ e.getMessage());
        }
    }
}
