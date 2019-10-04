
package command;

import annotations.Command;
import annotations.SetEntity;
import entity.GenericEntity;
import entity.Robot;
import entity.RobotAttachments.Base;
import entity.RobotAttachments.Head;
import util.ByteManager;

import java.nio.ByteBuffer;

public class RobotOpen extends RobotDefault {

    public void playerKeyPressed(int code, int pressed) {
        print("Key Pressed!\n");
    }

    public void giveOrders() {

    }

    public void playerClicked(float x, float y, int pressed) {

    }

    public void treadsFinishedOrder() {

    }

    public void scanned(float[] detectedX, float[] detectedY) {

    }

    public void positionRecieved(float x, float y) {

    }

    public void mapReceived(int[][] map) {

    }


    protected Robot robot = null;

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
                // Handle the data from the click
                // Get the x, y, and the action
                float x = ByteBuffer.wrap(bytes, 8, 4).getFloat();
                float y = ByteBuffer.wrap(bytes, 12, 4).getFloat();
                int action = ByteBuffer.wrap(bytes, 16, 4).getInt();

                // Pass it to the viewable playerKeyPressed function
                this.playerClicked(x, y, action);
            }
        }
        // It might be our base saying we are done moving
        else if (position == Robot.AttachmentPosition.BASE.getNumVal()) {
            // If the type was an action finished
            if (type == Robot.InputType.ACTION_FINISHED.getNumVal()) {
                // Then send the alert
                treadsFinishedOrder();
            }
        }
        // Sensor
        else if (position == Robot.AttachmentPosition.HEAD.getNumVal()) {
            // Event type
            if (type == Robot.InputType.SENSOR_SCAN.getNumVal()) {
                int bodies = ByteBuffer.wrap(bytes, 8, 4).getInt();

                float[] bodiesX = new float[bodies];
                float[] bodiesY = new float[bodies];
                for (int i = 0; i < bodies; i++) {
                    bodiesX[i] = ByteBuffer.wrap(bytes, 12 + i * 4, 4).getFloat();
                    bodiesY[i] = ByteBuffer.wrap(bytes, 16 + i * 4, 4).getFloat();
                }

                scanned(bodiesX, bodiesY);
            }
            else if (type == Robot.InputType.SENSOR_GET_MAP.getNumVal()) {
                int sizeX = ByteBuffer.wrap(bytes, 8, 4).getInt();
                int sizeY = ByteBuffer.wrap(bytes, 12, 4).getInt();

                int[][] map = new int[sizeX][sizeY];

                for (int i = 0; i < sizeX * sizeY; i++) {
                    map[i / sizeX][i % sizeY] = bytes[16 + i];
                    //ByteBuffer.wrap(bytes, 16 + i * 4, 4).getInt();
                }

                mapReceived(map);
            }
            else if (type == Robot.InputType.SENSOR_POSITION.getNumVal()) {
                float x = ByteBuffer.wrap(bytes, 8, 4).getFloat();
                float y = ByteBuffer.wrap(bytes, 12, 4).getFloat();

                this.positionRecieved(x, y);
            }
        }

        return new byte[0];
    }

    @SetEntity
    public void setRobot(GenericEntity robot) {
        this.robot = (Robot)robot;
    }

    public void moveForward1() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.MOVE.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray(1f));
    }

    public void moveBackward1() {
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

    public void turnRight90() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_BY.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray((float)(Math.PI / -2.0)));
    }

    public void turnLeft90() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_BY.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray((float)(Math.PI / 2.0)));
    }

    public void turnRight45() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_BY.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray((float)(Math.PI / -4.0)));
    }

    public void turnLeft45() {
        int position = Robot.AttachmentPosition.BASE.getNumVal();
        int orderType = Base.OrderTypes.ROTATE_BY.getNumVal();

        this.robot.addOrder(position, orderType, ByteManager.convertFloatToByteArray((float)(Math.PI / 4.0)));
    }

    public void getMapData() {
        int position = Robot.AttachmentPosition.HEAD.getNumVal();
        int orderType = Head.OrderTypes.GET_MAP.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void getPosition() {
        int position = Robot.AttachmentPosition.HEAD.getNumVal();
        int orderType = Head.OrderTypes.GET_POSITION.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void toggleScanning() {
        int position = Robot.AttachmentPosition.HEAD.getNumVal();
        int orderType = Head.OrderTypes.TOGGLE_POLLING.getNumVal();

        this.robot.addOrder(position, orderType, new byte[0]);
    }

    public void print(String message) {
        robot.printMessage(message);
    }
    public void print(int message) {
        robot.printMessage(Integer.toString(message));
    }
    public void print(float message) {
        robot.printMessage(Float.toString(message));
    }
    public void print(double message) {
        robot.printMessage(Double.toString(message));
    }
    public void print(char message) {
        robot.printMessage(Character.toString(message));
    }
    public void print(boolean message) {
        robot.printMessage(Boolean.toString(message));
    }
    public void print(byte message) {
        robot.printMessage(Byte.toString(message));
    }
    public void print(short message) {
        robot.printMessage(Short.toString(message));
    }
    public void print(long message) {
        robot.printMessage(Long.toString(message));
    }

    public Robot getRobot() { return robot; }

}

