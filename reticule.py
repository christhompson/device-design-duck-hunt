class Reticule:
    RETICULE_DIM = 150
    RETICULE_IMG = "res/shotgun-reticule-150px.png"

    def __init__(self):
        self.dx = 0
        self.dy = 0
        self.img = loadImage(RETICULE_IMG)
        self.x = width / 2.0
        self.y = height / 2.0  # TODO Center this in the viewport?

    def getX(self):
        return self.x

    def getY(self):
        return self.y

    def drawSprite(self):
        image(self.img, self.x - RETICULE_DIM / 2.0,
            self.y - RETICULE_DIM / 2.0)

    def updateLocation(self):
        self.x = mouseX
        self.y = mouseY

        # self.x += self.dx
        # self.y += self.dy
        # if self.x <= 0:
        #     self.x = 0
        # if self.x >= width:
        #     self.x = width
        # if self.y <= 0:
        #     self.y = 0
        # if self.y >= height:
        #     self.y = height
