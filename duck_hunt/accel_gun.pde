//
// Accelerometer gun input
//

// CALIBRATION FOR X AND Y AXES


class Inputs {
    int leftRight;
    int downUp;
    boolean fire;

    Inputs(int lr, int du, boolean fire) {
        this.leftRight = lr;
        this.downUp = du;
        this.fire = fire;
    }
    int getLeftRight() {
        return this.leftRight;
    }
    int getDownUp() {
        return this.downUp;
    }
    boolean getFire() {
        return this.fire;
    }
}

class AccelGun {
  float X_LOW = 284.783;
  float X_HIGH = 365.217;

  float Z_LOW = 306.522;
  float Z_HIGH = 363.043;

  float SHOOT_THRESHOLD = 353.261;
  
  AccelGun() {
  }
  
  Inputs get_accel_input(String inString) {
    
    float x_input;
    float y_input;
    float z_input;

    if (inString != null) {
      inString = trim(inString);    // trim off any whitespace:

      // split into the three axes of accelerometer input
      String[] xyz = split(inString, ',');

      // convert to floats
      if (xyz.length != 3) {
        return null;
      } else {
        x_input = float(xyz[0]);
        y_input = float(xyz[1]);
        z_input = float(xyz[2]);
      }
    } else {
        return null;
    }

    // Threshold axes and detect input

    int left_right = 0;
    if (x_input < X_LOW) {
        left_right = 15;
    }    
    if (x_input > X_HIGH) {
        left_right = -15;
    }

    int down_up = 0;
    if (z_input < Z_LOW) {
        down_up = 15;
    }
    if (z_input > Z_HIGH) {
        down_up = -15;
    }

    boolean fire = false;
    if (y_input > SHOOT_THRESHOLD) {
        fire = true;
    }    
    return new Inputs(left_right, down_up, fire);
  }
}

