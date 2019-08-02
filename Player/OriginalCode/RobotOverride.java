//// *NOACCESS
package command;

import annotations.Command;
import annotations.SetEntity;
import entity.GenericEntity;
import entity.Robot;
import entity.RobotAttachments.Base;
import util.ByteManager;

import java.io.*;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

//// *READONLY

public class RobotOverride {

    //// *READWRITE

    public void giveOrders() {

    }

    //// *NOACCESS

    private Robot robot;
    private int move = 0;
    private int rotate = 0;

    public void playerInput(int move, int rotate) {
        this.move = move;
        this.rotate = rotate;
    }

    @Command(commandName = "process", id = 0)
    public byte[] process() {
        robot.clearOrders();

        giveOrders();

        byte[] orders = robot.getOrders();

        return orders;
    }

    @Command(commandName = "input", id = 1)
    public byte[] input(byte[] bytes) {
        // Turn the bytes into a stream
        int position = ByteBuffer.wrap(bytes, 0, 4).getInt();
        int type = ByteBuffer.wrap(bytes, 4, 4).getInt();
//        System.out.println("Position: " + position + " Type: " + type + " Byte length: " + bytes.length);

        // If it was ourselves, and the player
        if (position == Robot.AttachmentType.SELF.getNumVal()
                && type == Robot.InputType.PLAYER.getNumVal()) {

            // There will we two ints, move and rotate that follow
            int move = ByteBuffer.wrap(bytes, 8, 4).getInt();
            int rotate = ByteBuffer.wrap(bytes, 12, 4).getInt();

            // Pass it to the viewable playerInput function
            this.playerInput(move, rotate);
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


