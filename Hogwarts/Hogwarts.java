import java.util.Scanner;
public class Hogwarts {
    public static void quit(){
        System.out.println("\nYou have quitted the game.");
        System.exit(0);
    }
    public static void foreword(){
        Scanner in = new Scanner(System.in);
        System.out.println("\n\033[1;37mBATTLE OF HOGWARTS\033[0m   Author: HalQAQ\n");  //intro
        System.out.println("The army of Lord Voldemort has reached the gate of Hogwarts. The wizarding world is in great danger.");
        System.out.println("The only way for Harry Potter to defeat Voldemort is using the power of the Deadly Hallows: ");
        System.out.println("\033[0;32mthe Cloak of Invisibility\033[0m, \033[0;31mthe Resurrection Stone\033[0m, and \033[0;35mthe Elderly Wand\033[0m.");
        System.out.println("\033[0;33mGuide Harry to explore the Hogwarts Castle. Find all the Deadly Hallow and defeat Voldemort.\n\033[0m");
        while(true){
            System.out.print("start or quit: ");
            String begin = in.next();  //type startto begin，quit to exit
            if(begin.equals("start")){
                break;
            }
            else if(begin.equals("quit")){quit();}
            else{
                System.out.println("Input error. Please type again.");
            }
        }
        //in.close();
    }

    public static void run(){
        new Lobby();
        while(true){
            if((Harry.at==2&Harry.go==2)||(Harry.at==3&Harry.go==4)||(Harry.at==4&Harry.go==1)||(Harry.at==6&Harry.go==3)){
                new Lobby();
            }
            else if((Harry.at==1&Harry.go==1)){
                new Courtyard();
            }
            else if((Harry.at==1&Harry.go==3)){
                new TheGreatHall();
            }
            else if((Harry.at==1&Harry.go==2)||(Harry.at==5&Harry.go==1)){
                new TheWoodenBridge();
            }
            else if((Harry.at==4&Harry.go==2)){
                new HagridsHut();
            }
            else if((Harry.at==1&Harry.go==4)||(Harry.at==7&Harry.go==6)){
                new StairsOne();
            }
            else if((Harry.at==6&Harry.go==5)||(Harry.at==8&Harry.go==4)||(Harry.at==11&Harry.go==6)){
                new StairsTwo();
            }
            else if((Harry.at==7&Harry.go==3)||(Harry.at==9&Harry.go==4)||(Harry.at==10&Harry.go==1)){
                new Corridor();
            }
            else if((Harry.at==8&Harry.go==3)){
                new TheGryffindorCommonRoom();
            }
            else if((Harry.at==8&Harry.go==2)){
                new RoomOfRequirement();
            }
            else if((Harry.at==7&Harry.go==5)||(Harry.at==12&Harry.go==4)||(Harry.at==13&Harry.go==1)){
                new StairsThree();
            }
            else if((Harry.at==11&Harry.go==3)){
                new TransfigurationClassroom();
            }
            else if((Harry.at==11&Harry.go==2)){
                new TheHeadmastersOffice();
            }
        }
    }

    public static class Harry{
        public static int at;
        public static int go;
        public static String roomName;
        public static int floor;
        public static Boolean cloak = false;
        public static Boolean stone = false;
        public static Boolean wand = false;
        public static Boolean lupin = false;
        public static Boolean mcgonagall = false;
    }

    public static class Room{
        private Boolean goNorth = false;
        private Boolean goSouth = false;
        private Boolean goWest = false;
        private Boolean goEast = false;
        private Boolean goUp = false;
        private Boolean goDown = false;

        public void position(){
            System.out.println("\nYou are at \033[1;37m"+Harry.roomName+"\033[0m, floor \033[1;37m"+Harry.floor+"\033[0m");
        }

        public void backpack(){
            System.out.print("BACKPACK: ");
            if(Harry.cloak){
                System.out.print(" \033[0;32mcloak\033[0m ");
            }
            if(Harry.stone){
                System.out.print(" \033[0;31mstone\033[0m ");
            }
            if(Harry.wand){
                System.out.print(" \033[0;35mwand\033[0m ");
            }
            if((!Harry.cloak)&&(!Harry.stone)&&(!Harry.wand)){
                System.out.print("\033[1;37mEMPTY\033[0m");
            }
            System.out.print("\n");
        }

        public void guidance(){
            System.out.println("Type \"?\" to get help.");
        }

        public int input(){  // north-1 south-2 west-3 east-4 up-5 down-6
            Scanner in = new Scanner(System.in);
            while(true){
                System.out.print("Type here: ");
                String input = in.nextLine();
                if(input.equals("go north")){
                    if(goNorth){
                        //in.close();
                        return 1;
                    }
                    else{
                        System.out.println("\nThere is no way toward north.");
                    }
                }
                else if(input.equals("go south")){
                    if(goSouth){
                        //in.close();
                        return 2;
                    }
                    else{
                        System.out.println("\nThere is no way toward south.");
                    }
                }
                else if(input.equals("go west")){
                    if(goWest){
                        //in.close();
                        return 3;
                    }
                    else{
                        System.out.println("\nThere is no way toward west.");
                    }
                }
                else if(input.equals("go east")){
                    if(goEast){
                        //in.close();
                        return 4;
                    }
                    else{
                        System.out.println("\nThere is no way toward east.");
                    }
                }
                else if(input.equals("go up")){
                    if(goUp){
                        //in.close();
                        return 5;
                    }
                    else{
                        System.out.println("\nThere is no way up.");
                    }
                }
                else if(input.equals("go down")){
                    if(goDown){
                        //in.close();
                        return 6;
                    }
                    else{
                        System.out.println("\nThere is no way down.");
                    }
                }
                else if(input.equals("?")){
                    help();;
                }
                else if(input.equals("map")){
                    map();
                }
                else if(input.equals("quit")){
                    quit();
                }
                else{
                    System.out.println("\nInput error. Please try again.");
                }
            }
            //in.close();
            //return 0;
        }

        public void map(){
            if(Harry.floor==1){
                System.out.println("                    -----------                  ^ N");
                System.out.println("                   | Courtyard |                 |");
                System.out.println("                    ----------- ");
                System.out.println("                         |");
                System.out.println(" ----------------     -------     -------- ");
                System.out.println("| The Great Hall |===| Lobby |===| Stairs |");
                System.out.println(" ----------------     -------     -------- ");
                System.out.println("                         |");
                System.out.println("                     -------- ");
                System.out.println("                    |  The   |");
                System.out.println("                    | Wooden |");
                System.out.println("                    | Bridge |");
                System.out.println("                     -------- ");
                System.out.println("                         |");
                System.out.println("                   -------------- ");
                System.out.println("                  | Hagrid's Hut |");
                System.out.println("                   -------------- ");
            }
            else if(Harry.floor==2){
                System.out.println(" -------------                                   ^ N");
                System.out.println("|    The      |    ----------     --------       |");
                System.out.println("| Gryffindor  |===| Corridor |===| Stairs |");
                System.out.println("| Common Room |    ----------     -------- ");
                System.out.println(" ------------- ");
            }
            else if(Harry.floor==3){
                System.out.println(" -----------------                               ^ N");
                System.out.println("| Transfiguration |    --------                  |");
                System.out.println("|    Classroom    |===| Stairs |");
                System.out.println(" -----------------     -------- ");
                System.out.println("                           |");
                System.out.println("               ------------------------- ");
                System.out.println("              | The Headmaster's Office |");
                System.out.println("               ------------------------- ");
            }
        }

        public void help(){
            System.out.println("\nType \"map\" to look at the map");
            System.out.println("Type \"go north/south/west/east/up/down\" to move");
            System.out.println("Type \"quit\" to quit");
        }
    }

    public static class Lobby extends Room{
        public Lobby() {
            Harry.at = 1;
            Harry.roomName = "lobby";
            Harry.floor = 1;
            super.goNorth = true;
            super.goSouth = true;
            super.goWest = true;
            super.goEast = true;
            super.position();
            System.out.println("\033[0;33mVoldemort is at the courtyard. Don't try to get close to him, unless you have all the three Deadly Hallows.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class Courtyard extends Room{
        public Courtyard() {
            Harry.at = 2;
            Harry.roomName = "courtyard";
            Harry.floor = 1;
            super.position();
            if(Harry.cloak&&Harry.stone&&Harry.wand){
                System.out.println("\033[0;33mWith the help of the Deadly Hallows, Voldemort is defeated.\033[0m");
                System.out.println("\033[1;36mHogwarts wins!\033[0m");
                System.exit(0);
            }
            else{
                System.out.println("\033[0;33mHarry is not strong enough to fight Voldemort without all the three Deadly Hallows. Harry is lost.\033[0m");
                System.out.println("GAME OVER");
                System.exit(0);
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class TheGreatHall extends Room{
        public TheGreatHall() {
            Harry.at = 3;
            Harry.roomName = "the great hall";
            Harry.floor = 1;
            super.goEast = true;
            super.position();
            if(!Harry.lupin){
                System.out.println("\033[0;31mLupin:\033[0m \033[0;33mPeter Pettigrew is going on patrol on the wooden bridge. You need the Cloak of Invisibility to pass it. I think it's still in the Gryffindor common room.\033[0m");
                Harry.lupin = true;
            }
            else{
                System.out.println("\033[0;31mLupin:\033[0m \033[0;33mHey, kid! Go and find the Cloak of Invisibility in the Gryffindor common room.\033[0m");
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class TheWoodenBridge extends Room{
        public TheWoodenBridge() {
            Harry.at = 4;
            Harry.roomName = "the wooden bridge";
            Harry.floor = 1;
            super.goNorth = true;
            super.goSouth = true;
            super.position();
            if(Harry.cloak){
                System.out.println("\033[0;33mIn the Cloak of Invisibility, Harry passes the bridge.\033[0m");
            }
            else{
                System.out.println("\033[0;33mWithout the help of the Cloak of Invisibility, Harry is caught by Peter Pettigrew.\033[0m");
                System.out.println("GAME OVER");
                System.exit(0);
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class HagridsHut extends Room{
        public HagridsHut() {
            Harry.at = 5;
            Harry.roomName = "Hagrid's hut";
            Harry.floor = 1;
            super.goNorth = true;
            super.position();
            System.out.println("\033[0;31mHagrid:\033[0m \033[0;33mThere is a hidden room called \"Room of Requirement\" on the second floor. You may get something useful there.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class StairsOne extends Room{
        public StairsOne() {
            Harry.at = 6;
            Harry.roomName = "Stairs";
            Harry.floor = 1;
            super.goWest = true;
            super.goUp = true;
            super.position();
            System.out.println("\033[0;33mYou can go up or down at the stairs.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class StairsTwo extends Room{
        public StairsTwo() {
            Harry.at = 7;
            Harry.roomName = "Stairs";
            Harry.floor = 2;
            super.goWest = true;
            super.goUp = true;
            super.goDown = true;
            super.position();
            System.out.println("\033[0;33mYou can go up or down at the stairs.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class StairsThree extends Room{
        public StairsThree() {
            Harry.at = 11;
            Harry.roomName = "Stairs";
            Harry.floor = 3;
            super.goSouth = true;
            super.goWest = true;
            super.goDown = true;
            super.position();
            System.out.println("\033[0;33mYou can go up or down at the stairs.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class Corridor extends Room{
        public Corridor() {
            Harry.at = 8;
            Harry.roomName = "corridor";
            Harry.floor = 2;
            super.goSouth = true;
            super.goWest = true;
            super.goEast = true;
            super.position();
            System.out.println("\033[0;33mThe corridor is long and open. There is a tapestry on the southern wall.\033[0m");
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class TheGryffindorCommonRoom extends Room{
        public TheGryffindorCommonRoom() {
            Harry.at = 9;
            Harry.roomName = "the Gryffindor common room";
            Harry.floor = 2;
            super.goEast = true;
            super.position();
            if(!Harry.cloak){
                System.out.println("\033[0;33mThank goodness. The cloak of invisibility is still here.\033[0m");
                Harry.cloak = true;
            }
            else{
                System.out.println("\033[0;33mOnly the bonefire sparks in the common room.\033[0m");
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class RoomOfRequirement extends Room{
        public RoomOfRequirement() {
            Harry.at = 10;
            Harry.roomName = "Room of Requirement";
            Harry.floor = 2;
            super.goNorth = true;
            System.out.println("\033[0;33mA door is open behind the tapestry!\033[0m");
            super.position();
            if(!Harry.wand){
                System.out.println("\033[0;33mThe Elderly Wand is nicely placed in the room.\033[0m");
                Harry.wand = true;
            }
            else{
                System.out.println("\033[0;33mThere is nothing helpful in the common room.\033[0m");
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class TransfigurationClassroom extends Room{
        public TransfigurationClassroom() {
            Harry.at = 12;
            Harry.roomName = "transfiguration classroom";
            Harry.floor = 3;
            super.goEast = true;
            super.position();
            if(!Harry.mcgonagall){
                System.out.println("\033[0;31mDr. McGonagall:\033[0m \033[0;33mDumbledore has left something to you. You need a spell to enter his office, which is \"Dumbledore\".\033[0m");
                Harry.mcgonagall = true;
            }
            else{
                System.out.println("\033[0;31mDr. McGonagall:\033[0m \033[0;33mRemember, the spell is \"Dumbledore\".\033[0m");
            }
            super.backpack();
            super.guidance();
            Harry.go = super.input();
        }
    }

    public static class TheHeadmastersOffice extends Room{
        public TheHeadmastersOffice() {
            Scanner in = new Scanner(System.in);
            Harry.at = 13;
            while(true){
                System.out.print("\nSpell: ");
                String input = in.nextLine();
                if(input.equals("Dumbledore")){
                    Harry.roomName = "the headmaster's office";
                    Harry.floor = 3;
                    super.goNorth = true;
                    System.out.println("\033[0;33m\nThe door is open after the spell.\033[0m");
                    super.position();
                    if(!Harry.stone){
                        System.out.println("\033[0;33mA goden snitch is on the table, It opens when Harry holds it in hand. The Resurrection Stone is inside.\033[0m");
                        Harry.stone = true;
                    }
                    else{
                        System.out.println("\033[0;33mFor Harry, the only thing that fills in this room is his memory.\033[0m");
                    }
                    super.backpack();
                    super.guidance();
                    Harry.go = super.input();
                    break;
                }
                else{
                    System.out.print("Spell is wrong.\n");
                    Harry.go = 1;
                    break;
                }
            }
        }
    }

    public static void main(String[] args) {
        foreword();
        run();
    }
}
