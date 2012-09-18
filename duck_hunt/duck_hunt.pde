
// Duck Hunt for 3-axis accelerometer "gun" input and NFC tags

// Copyright (C) 2012  Chris Thompson

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

import processing.serial.*;
import java.io.*;

// CONFIGURATION
int NUMDUCKS = 30;
int PLAY_TIME = 60;  // 15 seconds
boolean MOUSE_INPUT = false;  // Set to False to use accel gun input

String PLAYERS_FILE = "players.db";
String SCORES_FILE = "high_scores.db";

ArrayList ducks = new ArrayList();
int numNotHidden = NUMDUCKS;
String WIN_TEXT = "YOU WIN!";
String LOSE_TEXT = "You lose.";
Reticule reticule = null;
Timer timer = null;
PlayerTuple player_tuple = null;
boolean gameOn = false;
boolean timer_started = false;
boolean has_updated = false;
Serial myPort = null;
int whichPort = 8;
int score = 0;
AccelGun gun = new AccelGun();

class PlayerTuple {
    public String id;
    public int totalScore;
    public int highScore;

    public PlayerTuple(String id, int totalScore, int highScore) {
        this.id = id;
        this.totalScore = totalScore;
        this.highScore = highScore;
    }
}


PlayerTuple lookup_player(String id) {
    //"""Load player list from disk and search for player by UID"""
    String[] lines = loadStrings(PLAYERS_FILE);
    String[] newLines = new String[lines.length+1];
    for (int i = 0; i < lines.length; i++) {
        newLines[i] = lines[i];
        String[] parts = split(lines[i], '\t');
        if (parts[0] == id) {
            return new PlayerTuple(id, int(parts[1]), int(parts[2]));
        }
    }

    // Else it's a new player, so add them to DB, write to disk, and return
    newLines[newLines.length-1] = id + "\t0\t0";
    saveStrings(PLAYERS_FILE, newLines);

    return new PlayerTuple(id, 0, 0);  // New player!
}


PlayerTuple get_player() {
    String[] nfcPollArgs = {"/usr/local/bin/nfc-poll"};
    CommandResult res = run_command(nfcPollArgs);
    println(res.output);
    //println(res.error);

    if (res.i != 0) {
        println("nfc-poll nonzero status");
        System.exit(-1);
    }

    // Parse the output
    String tag_uid = null;
    String[] lines = split(res.output, '\n');
    for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().length() > 14 && lines[i].trim().substring(0,13).equals("UID (NFCID1):")) {
            println("FOUND LINE");
            tag_uid = lines[i].trim().substring(14);
        }
    }

    if (tag_uid == null) {
        println("Error reading tag UID");
        System.exit(-1);
    }

    // Lookup player from UID on tag
    PlayerTuple p = lookup_player(tag_uid);
    return p;
}

void update_scores(PlayerTuple player, int score) {
    // Update the score for player
    int player_high;
    int player_total = player.totalScore + score;  // total score
    if (score > player.highScore) {
        player_high = score;  // New high score for the player
        player.highScore = score;
    } else {
        player_high = player.highScore;
    }

    // Read in player DB, output but change the line for the player
    String[] lines = loadStrings(PLAYERS_FILE);
    
    ArrayList updatedLines = new ArrayList();
    for (int i = 0; i < lines.length; i++) {
        String[] parts = split(lines[i], '\t');
        if (parts[0] == player.id) {
            updatedLines.add(player.id + "\t" + player.totalScore + "\t" + player.highScore);
        } else {
            updatedLines.add(lines[i]);
        }
    }

    // Append score to db
    String[] s = loadStrings(SCORES_FILE);
    String[] s2 = new String[s.length+1];
    for (int i = 0; i < s.length; i++) {
        s2[i] = s[i];
    }
    s2[s2.length-1] = player.id + "\t" + score;
    saveStrings(SCORES_FILE, s2);
}

void show_high_scores(PlayerTuple player, int this_score) {
    // Show scores
    text("YOUR HIGH SCORE: " + player.highScore, 200, 300);
    
    // Show player's total score?
    text("YOUR TOTAL SCORE: " + (player.totalScore + this_score), 200, 400);
}

void setup() {
    //global ducks, NUMDUCKS, numNotHidden, reticule, timer, PLAY_TIME
    //global player_tuple, gameOn, timer_started, myPort

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    if (!MOUSE_INPUT) {
        println("Select serial port of accelerometer gun");
        println(Serial.list());
        //print(">> ");
        //try {
        //    whichPort = int(br.readLine());
        //} catch (IOException ioe) {
        //    println("IO Error reading your port.");
        //    System.exit(-1);
        //}
        myPort = new Serial(this, Serial.list()[whichPort], 9600);
        myPort.bufferUntil('\n');
    }

    println("Place NFC tag on reader...");
    //delay(5000);
    
    player_tuple = get_player();
    println("Player found.");
    println("Total: " + player_tuple.totalScore + "; High: " + player_tuple.highScore);

    size(1400, 800);
    timer_started = false;  // Hack to get timer to restart on first frame
    timer = new Timer(10, 60, PLAY_TIME);
    timer.start();
    for (int i = 0; i < NUMDUCKS; i++) {
        ducks.add(new Duck(int(random(150, 1200)), 500));
    }
    reticule = new Reticule(MOUSE_INPUT);
    gameOn = true;
}


void draw() {
    //global reticule, ducks, timer, NUMDUCKS, player_tuple, gameOn, timer_started, has_updated

    // Hack to fix timer rundown during setup
    if (!timer_started) {
        timer.restart();
        timer_started = true;
    }

    if (timer.currentTime() > 0 && numNotHidden > 0) {
        background(0, 0, 255);
        timer.DisplayTime();
        fill(0, 255, 0);
        rect(0, 600, 1400, 200);
        for (int i = 0; i < ducks.size(); i++) {
            Duck duck = (Duck) ducks.get(i);
            duck.updateLocation();
            duck.drawSprite();
        }
        reticule.updateLocation();
        reticule.drawSprite();
    }

    if (timer.currentTime() > 0 && numNotHidden == 0) {
        gameOn = false;
        background(0);
        fill(0, 0, 255);
        text(WIN_TEXT, 200, 100);
        score = NUMDUCKS;
        String score_str = "You got all " + NUMDUCKS + " ducks!";
        text(score_str, 200, 200);
        if (!has_updated) {
            update_scores(player_tuple, score);
            has_updated = true;
        }
        show_high_scores(player_tuple, score);
    }

    if (timer.currentTime() <= 0 && numNotHidden > 0) {
        gameOn = false;
        background(0);
        fill(0, 0, 255);
        text(LOSE_TEXT, 200, 100);
        score = NUMDUCKS - numNotHidden;
        String score_str = "You got " + (NUMDUCKS - numNotHidden) + " ducks.";
        text(score_str, 200, 200);
        if (!has_updated) {
            update_scores(player_tuple, score);
            has_updated = true;
        }
        show_high_scores(player_tuple, score);
    }
}

void fire(int x, int y) {
    //global numNotHidden, ducks, gameOn
    if (gameOn) {
        for (int i = 0; i < ducks.size(); i++) {
            Duck duck = (Duck) ducks.get(i);
            if (duck.getIsVisible() && duck.containsPoint(x, y)) {
                duck.setIsHidden(true);
                numNotHidden -= 1;
            }
        }
        println(numNotHidden);
        if (numNotHidden == 0) {
            println("Game Over");
            gameOn = false;
        }
    }
}

void mousePressed() {
    fire(mouseX, mouseY);
}

void serialEvent(Serial myPort) {
    //"""
    //Reads in the input from the Arduino about the accelerometer.
    //This is in the form
    //    x,y,z
    //Each line being one reading from all three axes.
    //Normalization and warping can be done here, or on the Arduino.
    //"""
    print("DEBUG: Serial Event");
    String in_string = myPort.readStringUntil('\n');
    Inputs i = gun.get_accel_input(in_string);
    if (i == null) {
        return;  // Failed to get full input, so skip
    }

    println(in_string);
    
    if (gameOn) {

    // Fire event
    if (i.fire) {
        fire(reticule.x, reticule.y);
        reticule.dx = 0;
        reticule.dy = 0;
    } else {
        reticule.dx = i.leftRight;
        reticule.dy = i.downUp;
    }
    }
}

