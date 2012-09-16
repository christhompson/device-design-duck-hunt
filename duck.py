class Duck:
    dim = 150
    img = "res/duck.png"

    def __init__(self, inX, inY):
        self.dx = int(random(1, 8))
        self.dy = int(random(1, 8))
        self.img = loadImage(Duck.img)
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
        if self.x <= Duck.dim / 2.0 or self.x + Duck.dim / 2.0 >= width:
            self.dx = self.dx * -1
        if self.y <= Duck.dim / 2.0 or self.y + Duck.dim / 2.0 >= height:
            self.dy = self.dy * -1

    def drawSprite(self):
        if self.getIsVisible():
            image(self.img, self.x, self.y)

    def containsPoint(self, inPx, inPy):
        if inPx > self.x - Duck.dim / 2.0 and \
        inPx < self.x + Duck.dim / 2.0 and \
        inPy > self.y - Duck.dim / 2.0 and \
        inPy < self.y + Duck.dim / 2.0:
            return True
        else:
            return False
