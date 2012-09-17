class Reticule:
    dim = 150
    img = "res/shotgun-reticule-150px.png"

    def __init__(self, is_mouse):
        self.is_mouse = is_mouse
        self.dx = 0
        self.dy = 0
        self.img = loadImage(Reticule.img)
        self.x = width / 2.0
        self.y = height / 2.0  # TODO Center this in the viewport?

    def getX(self):
        return self.x

    def getY(self):
        return self.y

    def drawSprite(self):
        image(self.img, self.x - Reticule.dim / 2.0,
            self.y - Reticule.dim / 2.0)

    def updateLocation(self):
        if self.is_mouse:
            self.x = mouseX
            self.y = mouseY
        else:
            self.x += self.dx
            self.y += self.dy
            if self.x <= 0:
                self.x = 0
            if self.x >= width:
                self.x = width
            if self.y <= 0:
                self.y = 0
            if self.y >= height:
                self.y = height
