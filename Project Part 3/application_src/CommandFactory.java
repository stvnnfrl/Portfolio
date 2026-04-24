public class CommandFactory {
    public static Command get(int choice) {
        switch(choice) {
            case 1: return new LogInLogOutCommand();
            case 2: return new SignUpCommand();
            case 3: return new ViewCommand();
            case 4: return new MakeOrderCommand();
            case 5: return new ViewOrderCommand();
            case 6: return new ReturnCommand();
            default: return new InvalidCommand();
        }
    }
}
