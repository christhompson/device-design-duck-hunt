#
# Accelerometer gun input
#

# For simplicity, we store the z gesture in Python source as a list
from gestures import z_flick_gesture
from dtw import DTWDistance

# CALIBRATION FOR X AND Y AXES
X_ADJUSTMENT = 10
NEG_X_THRESHOLD = -50
POS_X_THRESHOLD = 50
X_MIN = -200
X_MAX = 200

Y_ADJUSTMENT = 10
NEG_Y_THRESHOLD = -50
POS_Y_THRESHOLD = 50
Y_MIN = -200
Y_MAX = 200

# Tracking the z-axis window
z_window_size = 100
z_window = []
z_flick_threshold = 20  # FIXME This number is COMPLETELY made up


def adjust_x(x):
    return x - X_ADJUSTMENT


def adjust_y(y):
    return y - Y_ADJUSTMENT


def get_accel_input(in_string):
    global z_window, z_window_size
    # Split into axes
    parts = in_string.split(",")
    x_axis = float(parts[0])
    y_axis = float(parts[1])
    z_axis = float(parts[2])

    # Normalize x and y axes
    # (z can be left untouched, as we sample a gesture and match it)
    x_input = adjust_x(x_axis)
    y_input = adjust_y(y_axis)

    # Slide the z_window
    if len(z_window) == z_window_size:
        z_window.pop()
    z_window.append(z_axis)

    # Two things:
    # 1) pass normal input to reticule update
    # 2) detect our "gesture" using DTW on third axis
    # Since third axis isn't moving normally (much), we can be
    # generous on our recognition threshold. We collect z-axis on a windowed
    # basis and compare at each time?
    d = DTWDistance(z_window, z_flick_gesture)
    is_z_flick = False
    if d < z_flick_threshold:
        is_z_flick = True
        # Clear the window
        z_window = []

    return (x_input, y_input, is_z_flick)
