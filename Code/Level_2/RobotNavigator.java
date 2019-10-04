//// *PERMISSION n,0 *END_PERMISSION
package command;

import command.RobotDefault;

//// *PERMISSION r,0 *END_PERMISSION

public class RobotNavigator extends RobotDefault {

    //// *PERMISSION w,0 *END_PERMISSION

    // The current orders we can call
    final int MOVE_FORWARD = 1;
    final int TURN_LEFT_45 = 2;
    final int TURN_RIGHT_45 = 3;
    final int TURN_LEFT_90 = 4;
    final int TURN_RIGHT_90 = 5;

    // An array of orders we want to follow
    int orders[];
    // Track our current position in the array
    int currentOrder = -1;
    // True if we are moving or turning
    boolean executingOrder = false;

    public void playerKeyPressed(int code, int pressed) {
        // We we press a button, construct an array of things we want to do
        orders = new int[] { MOVE_FORWARD, TURN_LEFT_90, TURN_RIGHT_90 };
        // Reset the current order to 0
        currentOrder = 0;
    }

    public void giveOrders() {
        // If we are executing an order or we have finished our orders, stop!
        if (executingOrder || currentOrder == -1) {
            return;
        }

        // Choose what we want to do depending on our order!
        switch (orders[currentOrder]) {
            case MOVE_FORWARD:
                moveForward1();
                break;
            case TURN_LEFT_45:
                turnLeft45();
                break;
            case TURN_RIGHT_45:
                turnRight90();
                break;
            case TURN_LEFT_90:
                turnLeft90();
                break;
            case TURN_RIGHT_90:
                turnRight90();
                break;
            default:
                break;
        }

        // We are now executing an order
        executingOrder = true;
    }

    public void treadsFinishedOrder() {
        // Once the treads finish something, increment the order, and say we are no longer
        // executing an order
        currentOrder += 1;
        executingOrder = false;

        // If we get here we are done!
        if (currentOrder == orders.length) {
            currentOrder = -1;
        }
    }

    //// *PERMISSION r,0 *END_PERMISSION

}