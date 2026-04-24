import java.sql.Driver;
import java.sql.DriverManager;

import com.ibm.db2.jcc.DB2Driver;

import java.sql.*;

public class Main {
    public static void main(String[] args) {
        String url = "jdbc:db2://winter2026-comp421.cs.mcgill.ca:50000/COMP421";
        String user = "cs421g27";          // replace with null later when using export
        String password = "G27IsGoated!";  // replace with null later when using export

        try {
            DriverManager.registerDriver(new com.ibm.db2.jcc.DB2Driver());

            Connection con = DriverManager.getConnection(url, user, password);
            Statement stmt = con.createStatement();

            UserSession userSession = new UserSession(); // this is to maintain which user is logged in

            // all the queries etc.
            while(true) {
                Menu menu = new Menu();
                int choice = menu.showMenu(userSession);   // only UI responsibility

                if (choice == 7) break;  // Quit

                Command cmd = CommandFactory.get(choice);
                cmd.execute(stmt, userSession);
            }

            stmt.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}