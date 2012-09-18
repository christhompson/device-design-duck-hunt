class Reticule {
    int dim = 150;
    String img_path = "res/shotgun-reticule-150px.png";
    boolean is_mouse;
    int dx, dy, x, y;
    PImage img;

    Reticule(boolean is_mouse) {
        this.is_mouse = is_mouse;
        this.dx = 0;
        this.dy = 0;
        this.img = loadImage(img_path);
        this.x = int(width / 2.0);
        this.y = int(height / 2.0);  // TODO Center this in the viewport?
    }

    int getX() {
        return this.x;
    }

    int getY() {
        return this.y;
    }

    void drawSprite() {
        image(this.img, this.x - dim / 2.0, this.y - dim / 2.0);
    }

    void updateLocation() {
        if (this.is_mouse) {
            this.x = mouseX;
            this.y = mouseY;
        } else {
            this.x += this.dx;
            this.y += this.dy;
            if (this.x <= 0) { this.x = 0; }
            if (this.x >= width) { this.x = width; }
            if (this.y <= 0) { this.y = 0; }
            if (this.y >= height) { this.y = height; }
        }
    }
}
