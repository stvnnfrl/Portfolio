import java.util.Scanner;

public class Menu {
    Scanner scanner = new Scanner(System.in);

    public int showMenu(UserSession userSession) {
        System.out.println("\nBook Store Main Menu");
        if(userSession.isLoggedIn()) {
            System.out.println("\t(Logged in as " + userSession.getName()+")");
            System.out.println("1. Log Out");
        }
        else {
            System.out.println("1. Log In");
        }
        System.out.println("2. Sign up");
        System.out.println("3. View products");
        System.out.println("4. Make an Order");
        System.out.println("5. View your orders");
        System.out.println("6. Return an item");
        System.out.println("7. Quit");

        System.out.print("Enter choice: ");
        return scanner.nextInt();
    }
}
