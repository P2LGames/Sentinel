//// *NOACCESS
package command;

import annotations.Command;
import annotations.SetEntity;
import entity.GenericEntity;
import entity.Robot;
import entity.RobotAttachments.Base;
import util.ByteManager;

import java.nio.ByteBuffer;

//// *READONLY

public class RobotDefault {

    //// *READWRITE

    int w = 0;

    /**
     * Called when you have this robot selected, and you press a key.
     * @param code An integer representing the key that you pressed
     * @param pressed Whether or not you pressed or released the key. 1 is pressed, 0 is released.
     */
    public void playerKeyPressed(int code, int pressed) {
        print(code + " " + pressed + "\n");

        if (code == 87) {
            this.w = pressed;
        }

    }

    /**
     * Fill this in to give the robot his orders. Right now he can only move forward when w is pressed.
     * Can you help him do more things?
     */
    public void giveOrders() {

        if (this.w > 0) {
            moveForward();
        }

    }

    //// *READONLY

    // moveForward()
    // moveBackward()
    // stopMoving()
    // turnLeft()
    // turnRight()
    // stopTurning()
    // print(String)

    //// *NOACCESS

    private Robot robot;

    public boolean isActionPressed(int pressed) {
        return pressed == 1;
    }

    @Command(commandName = "process", id = 0)
    public byte[] process() {
        giveOrders();

        byte[] orders = robot.getOrders();

        // Clear the robot's orders for the next loop
        robot.clearOrders();

        return orders;
    }

    @Command(commandName = "input", id = 1)
    public byte[] input(byte[] bytes) {
        // Turn the bytes into a stream
        int position = ByteBuffer.wrap(bytes, 0, 4).getInt();
        int type = ByteBuffer.wrap(bytes, 4, 4).getInt();
//        System.out.println("Position: " + position + " Type: " + type + " Byte length: " + bytes.length);

        // If the signal came from the robot
        if (position == Robot.AttachmentType.SELF.getNumVal()) {

            // If the input type was a player key stroke
            if (type == Robot.InputType.PLAYER_KEY.getNumVal()) {
                // Handle the data from the keystroke
                // Get the character code and the action
                int code = ByteBuffer.wrap(bytes, 8, 4).getInt();
                int action = ByteBuffer.wrap(bytes, 12, 4).getInt();

                // Pass it to the viewable playerKeyPressed function
                this.playerKeyPressed(code, action);
            }
            // If the input type was a player mouse input
            else if (type == Robot.InputType.PLAYER_MOUSE.getNumVal()) {

            }

        }

        return new byte[0];
    }

    @SetEntity
    public void setRobot(GenericEntity robot) {
        this.robot = (Robot)robot;
    }

    public void moveForward() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.MOVE.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray(1f));
    }

    public void moveBackward() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.MOVE.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray(-1f));
    }

    public void stopMoving() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.STOP_MOVEMENT.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void turnLeft() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_LEFT.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void turnRight() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_RIGHT.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void stopTurning() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.STOP_ROTATION.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void print(String message) {
        robot.printMessage(message);
    }

    public Robot getRobot() { return robot; }

    //// *READONLY

}


