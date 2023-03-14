
    
function Field:draw()
    if not isSetUp then
        isSetUp = true
        function buffSwap(field)
            setContext()
            sprite(field.buffer, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
            field.lastBuffer = field.buffer
        end
        --toggle these on and off to activate features
        doTouchTest = false
        showLastBufferThumbnail = false
    end
    if doTouchTest then
        if not self.buffer then
            self.buffer = image(WIDTH,HEIGHT)
        end
        setContext(self.buffer)
        -- Draw left box in left color
        rectMode(CORNER)
        fill(236, 67, 155)
        rect(0, 0, WIDTH / 2, HEIGHT)
        
        -- Draw right box in right color
        fill(236, 124, 67)
        rect(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
        
        -- Draw middle box in center color
        fill(153, 67, 236)
        rect(WIDTH/4, HEIGHT/4, WIDTH/2, HEIGHT/2)
        
        buffSwap(self)
        if CurrentTouch.state == BEGAN then
            print(color(field.lastBuffer:get(math.floor(CurrentTouch.x), math.floor(CurrentTouch.y))))
        end
        return
    end
    
    setContext(self.buffer)
    background(self.backgroundColor)
    if #self.critters > 300 then
        crittersConfig = false
    end
    if not crittersConfig then
        local startingPop = math.max(WIDTH, HEIGHT) * 0.02
        self:resetCritters(startingPop)
        for _, critter in ipairs(self.critters) do
            critter.speed = 12
            critter.size = 70
            critter.mateColorVariance = 1
            critter.color = color(141, 0, 255)
            if math.random() > 0.5 then
                critter.color = color(255, 0, 183)
            end
            critter.timeToFertility = 10
        end
        crittersConfig = true
    end
    local babies = {}
    for _, critter in ipairs(self.critters) do
        -- call critter's own draw function, which may return a baby
        local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
        -- if it did return a baby, store it
        if babyMaybe ~= nil then
            table.insert(babies, babyMaybe)
        end
    end
    for _, baby in ipairs(babies) do
        table.insert(self.critters, baby)
    end
    if showLastBufferThumbnail then
        pushStyle()
        rectMode(CORNER)
        spriteMode(CORNER)
        fill(30, 26, 46)
        rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
        sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
        popStyle()
    end
    self:drawAndSwapBuffer()
end
