import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.sql.Date;
import java.time.temporal.ChronoUnit;
import java.util.*;

public interface Command {
    Scanner scanner = new Scanner(System.in);
    void execute(Statement stmt, UserSession userSession);
}

class LogInLogOutCommand implements Command {
    public void logIn(Statement stmt, UserSession userSession){
        Scanner scanner = new Scanner(System.in);
        System.out.println("\tPlease Log In (If you do not have an account, go sign up for a new account.):");
        for (int i = 0; i < 3; i++) {
            System.out.print("\t\tEnter email: ");
            String email = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
            System.out.print("\t\tEnter password: ");
            String password = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
            try {
                String querySQL = "SELECT customer_id, first_name, last_name from Customer " +
                        "WHERE email = '" + email + "' " +
                        "AND password = '" + password + "'";
                java.sql.ResultSet rs = stmt.executeQuery(querySQL);
                int id = -1;
                String first_name = null, last_name = null;
                while (rs.next()) {
                    id = rs.getInt(1);
                    first_name = rs.getString(2);
                    last_name = rs.getString(3);
                }
                if (first_name != null) {
                    System.out.println("\tLog in successful. Welcome "+first_name+" "+last_name+"!");
                    userSession.login(id, first_name, last_name);
                    return;
                } else {
                    System.out.println("\t\tWrong username or password. Try again. Attempts remaining: "+(2-i));
                }
            } catch (SQLException e) {
                int sqlCode = e.getErrorCode(); // Get SQLCODE
                String sqlState = e.getSQLState(); // Get SQLSTATE
                System.out.println("\tError in getting customer information.");
                System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
                System.out.println("\t"+e);
                return;
            }
        }
        System.out.println("\tNo more log in attempts. You will be redirected to the menu.");
    }

    public void logOut(UserSession userSession){
        System.out.println("\tYou have successfully logged out "+userSession.getName()+".");
        userSession.logOut();
    }

    public void execute(Statement stmt, UserSession userSession){
        if(userSession.isLoggedIn()){
            logOut(userSession);
        }
        else{
            logIn(stmt, userSession);
        }
    }
}

class SignUpCommand implements Command {
    public void execute(Statement stmt, UserSession userSession) {

        try {

            System.out.print("\tEnter first name: ");
            String first = scanner.nextLine();

            System.out.print("\tEnter last name: ");
            String last = scanner.nextLine();

            System.out.print("\tEnter email: ");
            String email = scanner.nextLine();

            System.out.print("\tEnter password: ");
            String password = scanner.nextLine();

            String checkSQL =
                    "SELECT customer_id FROM Customer WHERE email = '" + email + "'";
            ResultSet rs = stmt.executeQuery(checkSQL);

            if (rs.next()) {
                System.out.println("\tAccount already exists with this email.");
                return;
            }

            String idSQL = "SELECT MAX(customer_id) FROM Customer";
            rs = stmt.executeQuery(idSQL);

            int newId = 1;
            if (rs.next()) {
                newId = rs.getInt(1) + 1;
            }

            String insertSQL =
                    "INSERT INTO Customer(customer_id, last_name, first_name, email, password) " +
                            "VALUES (" + newId + ", '" + last + "', '" + first + "', '" + email + "', '" + password + "')";

            stmt.executeUpdate(insertSQL);

            System.out.println("\tAccount created successfully. You can now login.");

        } catch (SQLException e) {
            System.out.println("\tError creating account.");
            System.out.println(e.getMessage());
        }
    }
}


class ViewCommand implements Command {

    private void viewAllProducts(Statement stmt) {
        try {
            String sql = "SELECT product_id, name, price FROM Product";
            ResultSet rs = stmt.executeQuery(sql);

            System.out.println("\n\tAll Products:");
            while (rs.next()) {
                System.out.printf("\tID: %d | %s | $%.2f\n",
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getDouble("price"));
            }
        } catch (SQLException e) {
            System.out.println("\tError retrieving products.");
            System.out.println(e.getMessage());
        }
    }

    private void searchProductByName(Statement stmt) {
        System.out.print("\tEnter product name keyword: ");
        String input = scanner.nextLine();

        try {
            String sql =
                    "SELECT product_id, name, price " +
                            "FROM Product " +
                            "WHERE LOWER(name) LIKE LOWER('%" + input + "%')";

            ResultSet rs = stmt.executeQuery(sql);

            System.out.println("\n\tSearch Results:");
            while (rs.next()) {
                System.out.printf("\tID: %d | %s | $%.2f\n",
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getDouble("price"));
            }
        } catch (SQLException e) {
            System.out.println("\tError searching products.");
            System.out.println(e.getMessage());
        }
    }

    private void viewToys(Statement stmt) {
        try {
            String sql =
                    "SELECT P.product_id, P.name, P.price " +
                            "FROM Product P JOIN Toy T ON P.product_id = T.product_id";

            ResultSet rs = stmt.executeQuery(sql);

            System.out.println("\n\tToys:");
            while (rs.next()) {
                System.out.printf("\tID: %d | %s | $%.2f\n",
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getDouble("price"));
            }
        } catch (SQLException e) {
            System.out.println("\tError retrieving toys.");
            System.out.println(e.getMessage());
        }
    }

    private void movieMenu(Statement stmt) {

        while (true) {

            System.out.println("\n\t=== MOVIES ===");
            System.out.println("\t1. View all movies");
            System.out.println("\t2. View movies by genre");
            System.out.println("\t3. Back");

            System.out.print("\tChoice: ");
            int choice = scanner.nextInt();
            scanner.nextLine();

            switch (choice) {

                case 1:
                    try {
                        String sql =
                                "SELECT P.product_id, P.name, P.price " +
                                        "FROM Product P JOIN Movie M ON P.product_id = M.product_id";

                        ResultSet rs = stmt.executeQuery(sql);

                        System.out.println("\n\tMovies:");
                        while (rs.next()) {
                            System.out.printf("\tID: %d | %s | $%.2f\n",
                                    rs.getInt("product_id"),
                                    rs.getString("name"),
                                    rs.getDouble("price"));
                        }
                    } catch (SQLException e) {
                        System.out.println("\tError retrieving movies.");
                        System.out.println(e.getMessage());
                    }
                    break;

                case 2:
                    viewMoviesByGenre(stmt);
                    break;

                case 3:
                    return;

                default:
                    System.out.println("\tInvalid choice.");
            }
        }
    }

    private void viewMoviesByGenre(Statement stmt) {

        try {

            String sql = "SELECT DISTINCT genre_name FROM MovieGenre";
            ResultSet rs = stmt.executeQuery(sql);

            ArrayList<String> genres = new ArrayList<>();

            System.out.println("\n\tChoose a movie genre:");

            int i = 1;
            while (rs.next()) {
                String g = rs.getString("genre_name");
                genres.add(g);
                System.out.println("\t" + i + ". " + g);
                i++;
            }

            System.out.println("\t" + i + ". Back");

            System.out.print("\tChoice: ");
            int choice = scanner.nextInt();
            scanner.nextLine();

            if (choice == i) return;

            if (choice < 1 || choice > genres.size()) {
                System.out.println("\tInvalid choice.");
                return;
            }

            String genre = genres.get(choice - 1);

            String productQuery =
                    "SELECT P.product_id, P.name, P.price " +
                            "FROM Product P JOIN MovieGenre MG ON P.product_id = MG.product_id " +
                            "WHERE MG.genre_name = '" + genre + "'";

            ResultSet rs2 = stmt.executeQuery(productQuery);

            System.out.println("\n\tMovies in genre: " + genre);

            while (rs2.next()) {
                System.out.printf("\tID: %d | %s | $%.2f\n",
                        rs2.getInt("product_id"),
                        rs2.getString("name"),
                        rs2.getDouble("price"));
            }

        } catch (SQLException e) {
            System.out.println("\tError retrieving movie genres.");
            System.out.println(e.getMessage());
        }
    }

    private void bookMenu(Statement stmt) {

        while (true) {

            System.out.println("\n\t=== BOOKS ===");
            System.out.println("\t1. View all books");
            System.out.println("\t2. View books by genre");
            System.out.println("\t3. Back");

            System.out.print("\tChoice: ");
            int choice = scanner.nextInt();
            scanner.nextLine();

            switch (choice) {

                case 1:
                    try {
                        String sql =
                                "SELECT P.product_id, P.name, P.price " +
                                        "FROM Product P JOIN Book B ON P.product_id = B.product_id";

                        ResultSet rs = stmt.executeQuery(sql);

                        System.out.println("\n\tBooks:");
                        while (rs.next()) {
                            System.out.printf("\tID: %d | %s | $%.2f\n",
                                    rs.getInt("product_id"),
                                    rs.getString("name"),
                                    rs.getDouble("price"));
                        }
                    } catch (SQLException e) {
                        System.out.println("\tError retrieving books.");
                        System.out.println(e.getMessage());
                    }
                    break;

                case 2:
                    viewBooksByGenre(stmt);
                    break;

                case 3:
                    return;

                default:
                    System.out.println("\tInvalid choice.");
            }
        }
    }

    private void viewBooksByGenre(Statement stmt) {

        try {

            String sql = "SELECT DISTINCT genre_name FROM BookGenre";
            ResultSet rs = stmt.executeQuery(sql);

            ArrayList<String> genres = new ArrayList<>();

            System.out.println("\n\tChoose a book genre:");

            int i = 1;
            while (rs.next()) {
                String g = rs.getString("genre_name");
                genres.add(g);
                System.out.println("\t" + i + ". " + g);
                i++;
            }

            System.out.println("\t" + i + ". Back");

            System.out.print("\tChoice: ");
            int choice = scanner.nextInt();
            scanner.nextLine();

            if (choice == i) return;

            if (choice < 1 || choice > genres.size()) {
                System.out.println("\tInvalid choice.");
                return;
            }

            String genre = genres.get(choice - 1);

            String productQuery =
                    "SELECT P.product_id, P.name, P.price " +
                            "FROM Product P JOIN BookGenre BG ON P.product_id = BG.product_id " +
                            "WHERE BG.genre_name = '" + genre + "'";

            ResultSet rs2 = stmt.executeQuery(productQuery);

            System.out.println("\n\tBooks in genre: " + genre);

            while (rs2.next()) {
                System.out.printf("\tID: %d | %s | $%.2f\n",
                        rs2.getInt("product_id"),
                        rs2.getString("name"),
                        rs2.getDouble("price"));
            }

        } catch (SQLException e) {
            System.out.println("\tError retrieving book genres.");
            System.out.println(e.getMessage());
        }
    }

    public void execute(Statement stmt, UserSession userSession) {

        while (true) {

            System.out.println("\n\t=== VIEW PRODUCTS ===");
            System.out.println("\t1. View all products");
            System.out.println("\t2. Search product by name");
            System.out.println("\t3. View toys");
            System.out.println("\t4. View movies");
            System.out.println("\t5. View books");
            System.out.println("\t6. Back");

            System.out.print("\tChoice: ");

            int choice = scanner.nextInt();
            scanner.nextLine();

            switch (choice) {

                case 1:
                    viewAllProducts(stmt);
                    break;

                case 2:
                    searchProductByName(stmt);
                    break;

                case 3:
                    viewToys(stmt);
                    break;

                case 4:
                    movieMenu(stmt);
                    break;

                case 5:
                    bookMenu(stmt);
                    break;

                case 6:
                    return;

                default:
                    System.out.println("\tInvalid choice.");
            }
        }
    }
}


class MakeOrderCommand implements Command{
    record OrderItem(int product_id, int quantity, double price) {};
    private OrderItem addItem(Statement stmt){
        System.out.print("\t\tEnter product id (you can search beforehand to get this): ");
        int product_id = scanner.nextInt();
        scanner.nextLine();
        System.out.print("\t\tEnter quantity: ");
        int quantity = scanner.nextInt();
        scanner.nextLine();
        // get the price
        double price = -1;
        try{
            String querySQL = "SELECT price from Product " +
                    "WHERE product_id = '" + product_id + "' ";
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            while (rs.next()) {
                price = rs.getDouble(1);
            }
            if (price == -1){
                System.out.println("\t\tInvalid Product Id");
                return null;
            }
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting the product information.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return null;
        }
        return new OrderItem(product_id, quantity, price);
    }

    private int getPaymentInfo(Statement stmt, double totalPrice){
        // get payment info
        System.out.print("\t\tEnter payment method: ");
        String payment_method = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
        System.out.print("\t\tEnter credit card number: ");
        long card_number = scanner.nextLong();
        scanner.nextLine();

        String last_four = String.format("%04d", card_number % 10000);

        Date now = new Date(System.currentTimeMillis());
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String formattedTimestampNow = dateFormat.format(now);

        // get a payment id and transaction token that doesn't exist
        // in reality the payment id is our job, but then we would give the info
        // to our third party which would gives us a unique transaction token
        int payment_id = -1;
        String transaction_token = "";
        try{
            String querySQL = "SELECT MAX(payment_id), MAX(transaction_token) from Payment";
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            int max_payment_id = -1;
            String max_transaction_token = null;
            while (rs.next()) {
                max_payment_id = rs.getInt(1);
                max_transaction_token = rs.getString(2);
            }
            payment_id = max_payment_id+1;
            // parse the next transaction token
            String letters = max_transaction_token.replaceAll("\\d", "");
            String numbers = max_transaction_token.replaceAll("\\D", "");
            transaction_token = letters + Integer.parseInt(numbers) + 1;
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting the payment and transaction token.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return -1;
        }

        // insert into payment
        try {
            String insertSQL = "INSERT INTO Payment VALUES ("+payment_id+", '"+formattedTimestampNow+
                    "', '"+payment_method+"', '"+transaction_token+"', "+totalPrice+", '"+last_four+"')" ;
            stmt.executeUpdate(insertSQL) ;
        }
        catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in inserting payment.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return -1;
        }

        return payment_id;
    }

    private int getShippingInfo(Statement stmt){
        // get shipping info
        System.out.print("\t\tEnter shipping address: ");
        String to_address = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
        // get a shipping id that doesn't exist
        int shipping_id = -1;
        String tracking_number = "";
        try{
            String querySQL = "SELECT MAX(shipping_id), MAX(tracking_number) from Shipping";
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            int max_shipping_id = -1;
            String max_tracking_number = "";
            while (rs.next()) {
                max_shipping_id = rs.getInt(1);
                max_tracking_number = rs.getString(2);
            }
            shipping_id = max_shipping_id+1;
            // parse the next tracking number
            String letters = max_tracking_number.replaceAll("\\d", "");
            String numbers = max_tracking_number.replaceAll("\\D", "");
            tracking_number = letters + Integer.parseInt(numbers) + 1;
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting shipping id and tracking number.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return -1;
        }

        // tracking number, to_address, carrier_name, status, and expected_delivery
        // all come from a third party, so I will invent data for it
        String from_address = "4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3";
        String carrier = "FedEx";
        String status = "pending";
        String expected_date = "2026-04-15";
        // insert into shipping
        try {
            String insertSQL = "INSERT INTO Shipping VALUES ("+shipping_id+", '"+from_address+
                    "', '"+to_address+"', '"+tracking_number+"', '"+carrier+
                    "', '"+status+"', '"+expected_date+"')" ;
            stmt.executeUpdate(insertSQL) ;
        }
        catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in inserting shipping information.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return -1;
        }
        return shipping_id;
    }

    public void execute(Statement stmt, UserSession userSession) {
        if(!userSession.isLoggedIn()){
            System.out.println("Sorry, you need to be logged in to this. Go back to the menu and log in.");
            return;
        }

        // get all the orderitems
        ArrayList<OrderItem> orderItems = new ArrayList<>();
        while(true){
            System.out.print("\tDo you want to add an item (1) or finalize and make your payment (2)?: ");
            int choice = scanner.nextInt();
            scanner.nextLine();
            if (choice == 1){
                OrderItem result = addItem(stmt);
                if (result == null) continue;
                orderItems.add(result);
            }
            else if (choice == 2){
                double totalPrice = 0;
                for(OrderItem oi : orderItems){
                    totalPrice += oi.price*oi.quantity;
                }
                System.out.println("\t\tTotal price: "+ String.format("%.2f", totalPrice));

                // get payment and shipping info
                int payment_id = getPaymentInfo(stmt, totalPrice);
                int shipping_id = getShippingInfo(stmt);
                if (payment_id == -1 || shipping_id == -1) break;

                // now insert the order and orderitems now that we have payment/shipping
                // get an order id that doesn't exist
                int order_id = -1;
                try{
                    String querySQL = "SELECT MAX(order_id) from \"Order\"";
                    java.sql.ResultSet rs = stmt.executeQuery(querySQL);
                    int max_order_id = -1;
                    while (rs.next()) {
                        max_order_id = rs.getInt(1);
                    }
                    order_id = max_order_id+1;
                }
                catch (SQLException e) {
                    int sqlCode = e.getErrorCode(); // Get SQLCODE
                    String sqlState = e.getSQLState(); // Get SQLSTATE
                    System.out.println("\tError in getting order id.");
                    System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
                    System.out.println("\t"+e);
                    break;
                }
                // insert into order
                Date now = new Date(System.currentTimeMillis());
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String formattedTimestampNow = dateFormat.format(now);

                try {
                    String insertSQL = "INSERT INTO \"Order\" VALUES ("+order_id+", '"+formattedTimestampNow+
                            "', "+ userSession.getCustomerId()+", "+payment_id+", "+shipping_id+")" ;
                    stmt.executeUpdate(insertSQL) ;
                }
                catch (SQLException e) {
                    int sqlCode = e.getErrorCode(); // Get SQLCODE
                    String sqlState = e.getSQLState(); // Get SQLSTATE
                    System.out.println("\tError in inserting order.");
                    System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
                    System.out.println("\t"+e);
                    break;
                }
                // insert into order items
                try {
                    for(OrderItem oi: orderItems){
                        String insertSQL = "INSERT INTO OrderItem VALUES ("+order_id+", "+oi.product_id+
                                ", "+oi.quantity+", "+oi.price+")" ;
                        stmt.executeUpdate(insertSQL);
                    }
                }
                catch (SQLException e) {
                    int sqlCode = e.getErrorCode(); // Get SQLCODE
                    String sqlState = e.getSQLState(); // Get SQLSTATE
                    System.out.println("\tError in inserting order item.");
                    System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
                    System.out.println("\t"+e);
                    break;
                }
                System.out.println("\tOrder Completed! (For reference, order_id = "+order_id+")");
                System.out.println("\tYou will get an email with payment and shipping details.");
                break;
            }
            else{
                break;
            }
        }
    }
}

class ViewOrderCommand implements Command{
    private LinkedHashMap<Integer, String> getOrderInformation(Statement stmt, int cust_id){
        LinkedHashMap<Integer,String> orderInformation = new LinkedHashMap<>();
        try{
            String querySQL = "SELECT order_id, order_timestamp from \"Order\" " +
                    "WHERE customer_id = " + cust_id;
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            while (rs.next()) {
                int order_id = rs.getInt(1);
                Date order_timestamp = rs.getDate(2);
                orderInformation.put(order_id, "\t\tOrder ID " + order_id + " from " + order_timestamp);
            }
            return orderInformation;
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting all of the orders associated with the customer.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return null;
        }
    }

    private String getProductName(Statement stmt, int product_id){
        try {
            String querySQL = "SELECT name from Product " +
                    "WHERE product_id = " + product_id;
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            String name = "";
            while (rs.next()) {
                name = rs.getString(1);
            }
            return name;
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting product name.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return null;
        }
    }

    private void getOrderItemInfo(Statement stmt, int order_id){
        try {
            String querySQL = "SELECT product_id, quantity, price_at_purchase from OrderItem " +
                    "WHERE order_id = " + order_id;
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            ArrayList<Integer> product_ids = new ArrayList<>();
            ArrayList<String> toPrint = new ArrayList<>();
            while (rs.next()) {
                int product_id = rs.getInt(1);
                int quantity = rs.getInt(2);
                double price_at_purchase = rs.getDouble(3);
                product_ids.add(product_id);
                toPrint.add(String.format(", Quantity bought: %d, Price Paid: %.2f\n", quantity, price_at_purchase * quantity));
            }
            for (int j = 0; j < product_ids.size(); j++) {
                String name = getProductName(stmt, product_ids.get(j));
                if (name == null) return;
                System.out.printf("\t\t\t%s (product_id %d)%s", name, product_ids.get(j), toPrint.get(j));
            }
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting the all the order items.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
        }
    }

    public void execute(Statement stmt, UserSession userSession) {
        if(!userSession.isLoggedIn()){
            System.out.println("Sorry, you need to be logged in to this. Go back to the menu and log in.");
            return;
        }

        System.out.println("\tHere are all of your orders "+userSession.getName()+":");

        // get all the orderids associated to this customer
        LinkedHashMap<Integer, String> orderInformation = getOrderInformation(stmt, userSession.getCustomerId());
        if (orderInformation == null) return;

        if(orderInformation.isEmpty()){
            System.out.println("\t\tSorry, you have no orders.");
            return;
        }

        for (Map.Entry<Integer, String> oi : orderInformation.entrySet()){
            int order_id = oi.getKey();
            System.out.println(oi.getValue()); // print the associated string
            // get the orderitem info in order_id and print it out
            getOrderItemInfo(stmt, order_id);
        }
    }
}

class ReturnCommand implements Command{
    private boolean isValidAndWithin30Days(Statement stmt, int order_id, int cust_id){
        try{
            String querySQL = "SELECT order_timestamp from \"Order\" " +
                    "WHERE order_id = " + order_id + " AND customer_id = " + cust_id;
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            boolean found = false;
            Date order_timestamp_date = null;
            while (rs.next()) {
                found = true;
                order_timestamp_date = rs.getDate(1);
            }
            if(!found){
                System.out.println("\tThis is not a valid order id for your orders.");
                return false;
            }
            LocalDate order_timestamp = order_timestamp_date.toLocalDate();
            LocalDate today = LocalDate.now();
            long daysBetween = ChronoUnit.DAYS.between(order_timestamp, today);
            if(daysBetween > 30){
                System.out.println("\tIt has been more than 30 days. I'm sorry. You cannot return this item.");
                return false;
            }
        }
        catch (SQLException e){
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting order id.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return false;
        }
        return true;
    }

    private boolean productIDExists(Statement stmt, int order_id, int product_id){
        try {
            String querySQL = "SELECT product_id from OrderItem " +
                    "WHERE order_id = " + order_id + " AND product_id = " + product_id;
            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            while (rs.next()) {
                return true;
            }
            return false;
        } catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting order item.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return false;
        }
    }

    private Boolean isQuantityValid(Statement stmt, int order_id, int product_id, int quantity){
        try {
            String querySQL = "SELECT OI.quantity - (SELECT COALESCE(SUM(R.quantity),0) FROM \"Return\" R"
                    + " WHERE R.order_id = " + order_id
                    + " AND R.product_id = " + product_id + ")"
                    + " FROM OrderItem OI"
                    + " WHERE OI.order_id = " + order_id
                    + " AND OI.product_id = " + product_id;

            java.sql.ResultSet rs = stmt.executeQuery(querySQL);
            int quantity_remaining = -1;
            while (rs.next()) {
                quantity_remaining = rs.getInt(1);
            }
            if(quantity_remaining <= 0){
                System.out.println("\tSorry, you cannot return anymore of this product.");
                return null;
            }
            if(quantity_remaining < quantity){
                System.out.println("\tSorry, you only have "+quantity_remaining+" units of this product left that you can return.");
                return false;
            }
            return true;
        } catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in getting quantity of orderitem and previous returns.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
            return null;
        }
    }

    public void execute(Statement stmt, UserSession userSession) {
        if(!userSession.isLoggedIn()){
            System.out.println("Sorry, you need to be logged in to this. Go back to the menu and log in.");
            return;
        }

        System.out.println("\tYou will need the order id and product id of what you want to return.\n\tFor the numbers, view all your orders first.");
        System.out.print("\tEnter the order id: ");
        int order_id = scanner.nextInt();
        scanner.nextLine();

        // go check if it's possible, i.e. within 30 days
        if(!isValidAndWithin30Days(stmt, order_id, userSession.getCustomerId())) return;

        int product_id;
        while(true) {
            System.out.print("\tEnter the product id: ");
            product_id = scanner.nextInt();
            scanner.nextLine();

            // check if this product id exists
            boolean productExists = productIDExists(stmt, order_id, product_id);
            if (!productExists) {
                System.out.println("\tYou did not buy this product in this order.");
                System.out.print("\tDo you want to try another one? (Y/N): ");
                String response = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
                if(!response.equals("Y")) return;
            }
            else break;
        }

        int quantity;
        while(true) {
            System.out.print("\tEnter the quantity to return: ");
            quantity = scanner.nextInt();
            scanner.nextLine();

            // check if the quantity is valid, i.e. the quantity you have bought - the quantity you returned is less
            Boolean isValid = isQuantityValid(stmt, order_id, product_id, quantity);
            if(isValid == null) return;
            if(!isValid){
                System.out.print("\tDo you want to adjust your number or go back to menu? (A/M): ");
                String response = scanner.nextLine().replaceAll("\\r\\n|\\r|\\n", "");
                if(!response.equals("A")) return;
            }
            else break;
        }

        // now add the return
        Date now = new Date(System.currentTimeMillis());
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String formattedTimestampNow = dateFormat.format(now);

        try {
            String insertSQL = "INSERT INTO \"Return\"(return_timestamp, order_id, product_id, quantity) "
                    +"VALUES ('"+formattedTimestampNow+"',"+order_id+", "+product_id+", "+quantity+")";
            stmt.executeUpdate(insertSQL) ;
        }
        catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE
            System.out.println("\tError in inserting new return.");
            System.out.println("\tCode: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println("\t"+e);
        }
        System.out.println("\tSuccessfully initiated return! You will get an email about how to ship it to us.");
    }
}

class InvalidCommand implements Command {
    public void execute(Statement stmt, UserSession userSession) {
        System.out.println("Invalid command, try again.");
    }
}
