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
            return self.beginTime - int((millis() - self.startTime) / 1000.0)
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
        font = createFont("res/Arial-Black-48.vlw", 32.0, True)
        textFont(font)
        text(str(theTime), self.x, self.y)
