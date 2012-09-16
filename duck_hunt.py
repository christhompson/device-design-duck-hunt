#
# Duck Hunt for 3-axis accelerometer "gun" input and NFC tags
#
# Copyright (C) 2012  Chris Thompson
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

from accel_gun import get_accel_input
from timer import Timer
from duck import Duck
from reticule import Reticule
from command import run_command
from processing.serial import Serial

# CONFIGURATION
NUMDUCKS = 30
PLAY_TIME = 15000  # 15 seconds

PLAYERS_FILE = "players.db"
SCORES_FILE = "high_scores.db"

ducks = []
numNotHidden = NUMDUCKS
WIN_TEXT = "YOU WIN!"
LOSE_TEXT = "You lose."
reticule = None
timer = None
player_tuple = None
gameOn = False
has_updated = False


def lookup_player(id):
    """Load player list from disk and search for player by UID"""
    player_db = []
    reader = createReader(PLAYERS_FILE)
    line = reader.readLine()
    while line != None:
        player_db.append(line.split("\t"))
        line = reader.readLine()
    for player in player_db:
        if player[0] == id:
            return (id, int(player[1]), int(player[2]))

    # Else it's a new player, so add them to DB, write to disk, and return
    player_db.append((id, "0", "0"))

    writer = createWriter(PLAYERS_FILE)
    for record in player_db:
        writer.println("\t".join(record))
    writer.flush()
    writer.close()

    return (id, 0, 0)  # New player!


def get_player():
    (i, output, error) = run_command(["nfc-poll"])
    print output
    print error

    if i != 0:
        print "nfc-poll nonzero status"
        return (i, None)

    # Parse the output
    tag_uid = None
    for line in output.split('\n'):
        # print line.strip()[0:13]
        if line.strip()[0:13] == "UID (NFCID1):":
            tag_uid = line.strip()[14:]

    if tag_uid == None:
        print "ERROR"
        return (-1, None)
    # Lookup player from UID on tag
    player_tuple = lookup_player(tag_uid)
    return (i, player_tuple)


def update_scores(player, score):
    # Update the score for player
    player_total = player[1] + score  # total score
    if score > player[2]:
        player_high = score  # New high score for the player
    else:
        player_high = player[2]

    # Read in player DB, output but change the line for the player
    players_db = []
    reader1 = createReader(PLAYERS_FILE)
    line = reader1.readLine()
    while line != None:
        players_db.append(line.split("\t"))
        line = reader1.readLine()

    writer1 = createWriter(PLAYERS_FILE)
    for record in players_db:
        if record[0] == player[0]:
            writer1.println("\t".join([player[0],
                                    str(player_total),
                                    str(player_high)]))
        else:
            writer1.println("\t".join(record))
    writer1.flush()
    writer1.close()

    # Append score to db
    scores_db = []
    reader2 = createReader(SCORES_FILE)
    line = reader2.readLine()
    while line != None:
        scores_db.append(line.split("\t"))
        line = reader2.readLine()
    writer2 = createWriter(SCORES_FILE)
    for record in scores_db:
        writer2.println("\t".join(record))
    writer2.println("\t".join([player[0], str(score)]))
    writer2.flush()
    writer2.close()


def show_high_scores(player, this_score):
    scores_db = []
    reader = createReader(SCORES_FILE)
    line = reader.readLine()
    while line != None:
        scores_db.append(line.split("\t"))
        line = reader.readLine()
    # Sort DB
    rev_sorted_db = sorted(scores_db, key=lambda x: int(x[1]))
    sorted_db = list(reversed(rev_sorted_db))

    # Show top 5 in db
    end = min(len(sorted_db), 5)
    text("HIGH SCORES", 200, 300)
    for i in range(end):
        id = sorted_db[i][0]
        score = sorted_db[i][1]
        text("%s:\t %s" % (id, score), 200, 400 + 50 * i)
    # Show player's total score?
    text("YOUR TOTAL SCORE: %d" % (player[1] + this_score), 200, 700)


def setup():
    global ducks, NUMDUCKS, numNotHidden, reticule, timer, PLAY_TIME
    global player_tuple, gameOn

    (status, player_tuple) = get_player()
    if status != 0:
        print "Error getting player."
        exit()
    elif player_tuple == None:
        print "New player!"
        #player_tuple = (0,0,0)
    else:
        print "Player found."
        print "Total: %d; High: %d" % (player_tuple[1], player_tuple[2])

    print Serial.list()
    #myPort = Serial(this, Serial.list()[0], 9600)
    #myPort.bufferUntil(lf)

    size(1400, 800)
    timer = Timer(10, 60, PLAY_TIME)
    timer.start()
    for i in range(NUMDUCKS):
        ducks.append(Duck(int(random(150, 1200)), 500))
    # print "DUCKS"
    # for duck in ducks:
    #     print duck
    #     print duck.x
    #     print duck.y
    #     print duck.dx
    #     print duck.dy
    reticule = Reticule()
    gameOn = True


def draw():
    global reticule, ducks, timer, NUMDUCKS, player_tuple, gameOn, has_updated
    if timer.currentTime() > 0 and numNotHidden > 0:
        background(0, 0, 255)
        timer.DisplayTime()
        fill(0, 255, 0)
        rect(0, 600, 1400, 200)
        for duck in ducks:
            duck.updateLocation()
            duck.drawSprite()
        reticule.updateLocation()
        reticule.drawSprite()

    if timer.currentTime() > 0 and numNotHidden == 0:
        gameOn = False
        background(0)
        fill(0, 0, 255)
        text(WIN_TEXT, 200, 100)
        score = NUMDUCKS
        score_str = "You got all " + str(NUMDUCKS) + " ducks!"
        text(score_str, 200, 200)
        if not has_updated:
            update_scores(player_tuple, score)
            has_updated = True
        show_high_scores(player_tuple, score)

    if timer.currentTime() <= 0 and numNotHidden > 0:
        gameOn = False
        background(0)
        fill(0, 0, 255)
        text(LOSE_TEXT, 200, 100)
        score = NUMDUCKS - numNotHidden
        score_str = "You got " + str(NUMDUCKS - numNotHidden) + " ducks."
        text(score_str, 200, 200)
        if not has_updated:
            update_scores(player_tuple, score)
            has_updated = True
        show_high_scores(player_tuple, score)


def mousePressed():
    global numNotHidden, ducks, gameOn
    if gameOn:
        for duck in ducks:
            if duck.getIsVisible() and duck.containsPoint(mouseX, mouseY):
                duck.setIsHidden(True)
                numNotHidden -= 1
        print numNotHidden
        if numNotHidden == 0:
            print "Game Over"
            gameOn = False


# def serialEvent(port):
#     """
#     Reads in the input from the Arduino about the accelerometer.
#     This is in the form
#         x,y,z
#     Each line being one reading from all three axes.
#     Normalization and warping can be done here, or on the Arduino.
#     """
#     global z_window_size, z_window
#     in_string = port.readString()
#     get_accel_input(in_string)


run()
