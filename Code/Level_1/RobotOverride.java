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
     * @param code An integer representing the ascii character of the key that you pressed.
     *             zyBooks 2.14 has a table of characters and their ascii code for your reference.
     * @param pressed Whether or not you pressed or released the key. 1 is pressed, 0 is released.
     */
    @Override
    public void playerKeyPressed(int code, int pressed) {
        print("Override\n");
    }

    /**
     * Fill this in to give the robot his orders 30 times per second.
     * New orders will override the ones the robot is currently executing.
     */
    @Override
    public void giveOrders() {

    }

    @Override
    public void playerClicked(float x, float y, int pressed) {

    }

    @Override
    public void treadsFinishedOrder() {

    }

    //// *PERMISSION r,0 *END_PERMISSION

    /**
     * You have access to quite a few functions to help the robot move.
     * moveForward()
     * moveBackward()
     * stopMoving()
     * turnLeft()
     * turnRight()
     * turnLeft90()
     * turnRight90()
     * stopTurning()
     */

}