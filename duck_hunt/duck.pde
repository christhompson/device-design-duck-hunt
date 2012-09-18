//

class Duck {
    int dim = 150;
    String img_path = "res/duck.png";

    int x, y, dx, dy;
    PImage img;
    boolean isHidden;

    Duck(int inX, int inY) {
        this.dx = int(random(1, 8));
        this.dy = int(random(1, 8));
        this.img = loadImage(img_path);
        this.x = inX;
        this.y = inY;
        this.isHidden = false;
    }

    void setIsHidden(boolean inValue) {
        this.isHidden = inValue;
    }

    int getX() {
        return this.x;
    }

    int getY() {
        return this.y;
    }

    boolean getIsHidden() {
        return this.isHidden;
    }

    boolean getIsVisible() {
        return (!this.isHidden);
    }

    void updateLocation() {
        this.x += this.dx;
        this.y += this.dy;
        if (this.x <= dim / 2.0 || this.x + dim / 2.0 >= width) {
            this.dx = this.dx * -1;
        }
        if (this.y <= dim / 2.0 || this.y + dim / 2.0 >= height) {
            this.dy = this.dy * -1;
        }
    }

    void drawSprite() {
        if (this.getIsVisible()) {
            image(this.img, this.x, this.y);
        }
    }

    boolean containsPoint(int inPx, int inPy) {
        if (inPx > this.x - dim / 2.0 &&
            inPx < this.x + dim / 2.0 &&
            inPy > this.y - dim / 2.0 &&
            inPy < this.y + dim / 2.0) {
            return true;
        } else {
            return false;
        }
    }
}
