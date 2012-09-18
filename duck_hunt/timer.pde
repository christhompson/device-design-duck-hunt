class Timer {
    long startTime;   // time in msecs that timer started
    long timeSoFar;   // use to hold total time of run so far, useful in
                      // conjunction with pause and continueRunning
    boolean running;
    int x, y, beginTime;   // location of timer output

    Timer(int inX, int inY, int inBegin) {
        this.x = inX;
        this.y = inY;
        this.beginTime = inBegin;
        this.running = false;
        this.timeSoFar = 0;
    }

    int currentTime() {
        if (this.running) {
            return this.beginTime - int((millis() - this.startTime) / 1000.0);
        } else {
            return this.beginTime - int(this.timeSoFar / 1000.0);
        }
    }

    void start() {
        this.running = true;
        this.startTime = millis();
    }

    void restart() {
        this.start();
    }

    void pause() {
        if (this.running) {
            this.timeSoFar = millis() - this.startTime;
            this.running = false;
        }
        // Else already paused
    }

    void continueRunning() {
        if (! this.running) {
            this.startTime = millis() - this.timeSoFar;
            this.running = true;
        }
        // Else already running
    }

    void DisplayTime() {
        int theTime = this.currentTime();
        fill(255, 0, 0);
        PFont font = createFont("res/Arial-Black-48.vlw", 32.0, true);
        textFont(font);
        text(theTime, this.x, this.y);
    }
}
