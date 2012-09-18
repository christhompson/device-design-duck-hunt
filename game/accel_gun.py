#
# Accelerometer gun input
#

# CALIBRATION FOR X AND Y AXES
X_LOW = 308.696
X_HIGH = 356.522

Z_LOW = 304.348
Z_HIGH = 360.870

SHOOT_THRESHOLD = 314.130


def get_accel_input(in_string):
    global z_window, z_window_size
    # Split into axes
    parts = in_string.split(",")
    if len(parts) != 3:
        return None
    x_input = float(parts[0])
    y_input = float(parts[1])
    z_input = float(parts[2])

    # Threshold axes and detect input

    left_right = 0
    if x_input < X_LOW:
        left_right = -1
    if x_input > X_HIGH:
        left_right = 1

    down_up = 0
    if z_input < Z_LOW:
        down_up = -1
    if z_input > Z_HIGH:
        down_up = 1

    fire = 0
    if y_input > SHOOT_THRESHOLD:
        fire = True

    print "INPUT: %d, %d, %d" % (left_right, down_up, int(fire))

    return (left_right, down_up, fire)
