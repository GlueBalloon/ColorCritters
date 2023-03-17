
--look at 'em jitter around! no population cap
function Field:draw()
    
    function respawn()
        field.critters = {}
        local limit = math.ceil(randomFromScreen(0.5))
        for i = 1, limit do
            defineCritter(ColorCritter())
        end
    end
    function defineCritter(critter, pos)
        critter.size = randomFromScreen(0.03)
        critter.speed = math.random(5, 30)
        critter.timeToFertility = math.random(4, 665)
        critter.position = pos or critter.position
        table.insert(field.critters, critter)
    end
    --setup functions
    if not isSetUp then
        isSetUp = true
        self.backgroundColor = color(37, 37, 41)
        respawn()
    end
    
    setContext(self.buffer)
    background(self.backgroundColor)
    
    local babies = {}
    
    --manually control critters
    for _, critter in ipairs(self.critters) do
        --advance fertility
        critter.fertilityCounter = critter.fertilityCounter + 1
        -- Find a point outside the critter
        local outsidePoint = critter:pointOutsideSelf()       
        -- find direction to that point
        local outsideDirection = (outsidePoint - critter.position):normalize()
        --calculate new position 
        local nextPosition = critter.position + outsideDirection * critter.speed
        --wrap it
        nextPosition = self:wrapIfNeeded(nextPosition)
        -- Make the outside point's x and y into non-zero integers inside bounds and get color at that point
        local outsidePointInBounds = self:wrapIfNeeded(outsidePoint)
        local bufferX, bufferY = math.floor(outsidePointInBounds.x), math.floor(outsidePointInBounds.y)
        bufferX, bufferY = math.min(WIDTH, math.max(1, bufferX)), math.min(HEIGHT, math.max(1, bufferY))
        local colorAtPoint = color(self.lastBuffer:get(100,100))
        -- check if that color is background color
        if colorAtPoint == self.backgroundColor or
        colorAtPoint == critter.color then
            --if so, store the new direction
            critter.direction = outsideDirection
        else
            -- if not, recalculate position without change of direction 
            local recalculated = critter.position + critter.direction * critter.speed
            nextPosition = self:wrapIfNeeded(recalculated)
            --and if fertile, make a baby
            if critter.fertilityCounter >= critter.timeToFertility then
                if #self.critters < 40000 then
                    local baby = critter:reproduce(colorAtPoint)
                    defineCritter(baby, outsidePoint)
                    table.insert(babies, baby)
                end
            end
        end
        -- update position
        critter.position = nextPosition
        --draw
        fill(critter.color)
        ellipse(critter.position.x, critter.position.y, critter.size)    
        --draw based on setup
        if showOutsidePoints then
            fill(255, 231, 0)
            ellipse(outsidePoint.x, outsidePoint.y, 8)
        end
        if printOutsidePointInfo then
            printRarely(critter.id, bufferX, ", ", bufferY, " - ", colorAtPoint, self.backgroundColor)
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
    if CurrentTouch.state == BEGAN then
        isSetUp = false
    end
    
    fill(20, 28, 29)
    text(#self.critters, 41.5, 88.5)
    fill(242, 240, 239)
    text(#self.critters, 41, 89)
    
    self:drawAndSwapBuffer()
end
