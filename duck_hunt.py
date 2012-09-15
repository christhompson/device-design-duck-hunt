# This is a Python Processing port of the Processing Duck Hunt sketch
#

from pyprocessing import *
from random import *


# CONFIGURATION
RETICULE_DIM = 150
# We cheat and extend the duck's bg as the hit zone.
# This breaks the circular reticule metaphor, but is an easy hack.
DUCK_DIM = RETICULE_DIM
DUCK_IMG = "res/duck-150px.png"
RETICULE_IMG = "res/shotgun-reticule-150px.png"
NUMDUCKS = 3


ducks = []
numNotHidden = NUMDUCKS
WIN_TEXT = "YOU WIN!"
LOSE_TEXT = "You lose."
reticule = None
timer = None
PLAY_TIME = 30000  # 30 seconds


class Timer:
    #long startTime ;   // time in msecs that timer started
    #long timeSoFar ;   // use to hold total time of run so far, useful in
    #                  // conjunction with pause and continueRunning
    #boolean running ;
    #int x, y, beginTime ;   // location of timer output

    def __init__(self, inX, inY, inBegin):
        self.x = inX
        self.y = inY
        self.beginTime = inBegin
        self.running = False
        self.timeSoFar = 0

    def currentTime(self):
        if self.running:
            return self.beginTime - int(millis() - self.startTime / 1000.0)
        else:
            return self.beginTime - int(self.timeSoFar / 1000.0)

    def start(self):
        self.running = True
        self.startTime = millis()

    def restart(self):
        self.start()

    def pause(self):
        if self.running:
            self.timeSoFar = millis() - self.startTime
            self.running = False
        # Else already paused

    def continueRunning(self):
        if not self.running:
            self.startTime = millis() - self.timeSoFar
            self.running = True
        # Else already running

    def DisplayTime(self):
        theTime = self.currentTime()
        fill(255, 0, 0)
        font = createFont("Arial-Black-48.vlw")
        textFont(font)
        text(str(theTime), self.x, self.y)


class Duck:
    def __init__(self, inX, inY):
        self.dx = randint(1, 3)
        self.dy = randint(1, 3)
        self.img = loadImage(DUCK_IMG)
        self.x = inX
        self.y = inY
        self.isHidden = False

    def setIsHidden(self, inValue):
        self.isHidden = inValue

    def getX(self):
        return self.x

    def getY(self):
        return self.y

    def getIsHidden(self):
        return self.isHidden

    def getIsVisible(self):
        return not self.isHidden

    def updateLocation(self):
        self.x += self.dx
        self.y += self.dy
        if self.x <= DUCK_DIM / 2.0 or self.x + DUCK_DIM / 2.0 >= width:
            self.dx = self.dx * -1
        if self.y <= DUCK_DIM / 2.0 or self.y + DUCK_DIM / 2.0 >= height:
            self.dy = self.dy * -1

    def drawSprite(self):
        if self.getIsVisible():
            image(self.img, self.x, self.y)
        image(self.img, self.x, self.y)

    def containsPoint(self, inPx, inPy):
        if inPx > self.x and inPx < self.x + DUCK_DIM and \
        inPy > self.y and inPy < self.y + DUCK_DIM:
            return True
        else:
            return False


class Reticule:
    #float x, y;
    #float xVel, yVel;
    #PImage img;
    #float msWidth, msHeight;

    def __init__(self):
        self.dx = 0
        self.dy = 0
        self.img = loadImage(RETICULE_IMG)
        self.x = 0.0
        self.y = 0.0  # TODO Center this in the viewport?

    def getX(self):
        return self.x

    def getY(self):
        return self.y

    def drawSprite(self):
        image(self.img, self.x - RETICULE_DIM / 2.0,
            self.y - RETICULE_DIM / 2.0)

    def updateLocation(self):
        self.x = mouse.x
        self.y = mouse.y
        # self.x += self.dx
        # self.y += self.dy
        # if self.x <= RETICULE_DIM / 2.0:
        #     self.x = RETICULE_DIM / 2.0
        # if self.x + RETICULE_DIM / 2.0 >= width:
        #     self.x = width - RETICULE_DIM / 2.0
        # if self.y <= RETICULE_DIM / 2.0:
        #     self.y = RETICULE_DIM / 2.0
        # if self.y + RETICULE_DIM / 2.0 >= height:
        #     self.y = height - RETICULE_DIM / 2.0


def setup():
    global ducks, NUMDUCKS, numNotHidden, reticule, timer, PLAY_TIME
    size(800, 800)
    timer = Timer(10, 60, PLAY_TIME)
    timer.start()
    for i in range(NUMDUCKS):
        ducks.append(Duck(randint(1, 700), 800))
    print "DUCKS"
    for duck in ducks:
        print duck
        print duck.x
        print duck.y
        print duck.dx
        print duck.dy
    reticule = Reticule()


def draw():
    global reticule, ducks, timer
    if timer.currentTime() > 0 and numNotHidden > 0:
        background(0, 0, 255)
        timer.DisplayTime()
        fill(0, 255, 0)
        rect(0, 600, 800, 200)
        reticule.updateLocation()
        reticule.drawSprite()
        for duck in ducks:
            print "DUCK DRAW"
            duck.updateLocation()
            duck.drawSprite()
    elif timer.currentTime() > 0 and numNotHidden == 0:
        background(0)
        fill(0, 0, 255)
        text(WIN_TEXT, 300, 400)
    elif timer.currentTime() <= 0 and numNotHidden > 0:
        background(0)
        fill(0, 0, 255)
        text(LOSE_TEXT, 300, 400)


def mousePressed():
    global numNotHidden, ducks
    for duck in ducks:
        if duck.getIsVisible() and duck.containsPoint(mouse.x, mouse.y):
            duck.setIsHidden(True)
            numNotHidden -= 1
    print numNotHidden
    if numNotHidden == 0:
        print "Game Over"

run()
