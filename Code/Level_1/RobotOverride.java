//// *PERMISSION n,0 *END_PERMISSION
package command;

import command.RobotDefault;

//// *PERMISSION r,0 *END_PERMISSION

public class RobotOverride extends RobotDefault {

    //// *PERMISSION w,0 *END_PERMISSION

    /**
     * Called when you have this robot selected, and you press a key.
     * You can find the ASCII codes for each character in ZyBooks 2.14.
     *
     * @param code An integer representing the key that you pressed.
     *             All of the codes will be for the CAPITAL LETTERS.
     * @param pressed Whether or not you pressed or released the key. 1 is pressed, 0 is released.
     */
    public void playerKeyPressed(int code, int pressed) {

    }

    //// *PERMISSION r,0 *END_PERMISSION

    /**
     * Use the print() function to print stuff to this robot's output.
     * For example print("Hello Fred!"); would print "Hello Fred" to the robot's output.
     *
     * You have access to quite a few functions to help Fred and George move.
     * moveForward1()
     * moveBackward1()
     * turnLeft45()
     * turnRight45()
     * turnLeft90()
     * turnRight90()
     */

}