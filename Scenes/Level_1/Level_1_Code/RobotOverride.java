//// *PERMISSION n,0 *END_PERMISSION
package command;

import annotations.Command;
import annotations.SetEntity;
import entity.GenericEntity;
import entity.Robot;
import entity.RobotAttachments.Base;
import util.ByteManager;
import command.RobotDefault;

import java.nio.ByteBuffer;

//// *PERMISSION r,0 *END_PERMISSION

public class RobotOverride extends RobotDefault {

    //// *PERMISSION w,0 *END_PERMISSION

    /**
     * Called when you have this robot selected, and you press a key.
     * @param code An integer representing the key that you pressed
     * @param pressed Whether or not you pressed or released the key. 1 is pressed, 0 is released.
     */
    @Override
    public void playerKeyPressed(int code, int pressed) {
        if (code == 87 && pressed == 1) {
            System.out.println("W");
            print("Override\n");
        }
    }

    /**
     * Fill this in to give the robot his orders.
     * Can you help him move around? We gotta get to the finish!
     */
    @Override
    public void giveOrders() {

    }

//    @Override
//    @Command(commandName = "process", id = 0)
//    public byte[] process() {
//        return super.process();
//    }
//
//    @Override
//    @Command(commandName = "input", id = 1)
//    public byte[] input(byte[] bytes) {
//        return super.input(bytes);
//    }
//
//    @Override
//    @SetEntity
//    public void setRobot(GenericEntity robot) {
//        this.robot = (Robot)robot;
//    }

    //// *PERMISSION r,0 *END_PERMISSION

}

