
--teeny tiny breeders without any population cap
function Field:draw()
    function newCritter(pos)
        local new = ColorCritter()
        new.size = math.random(5, 8)
        new.speed = math.random(5, 18)
        new.timeToFertility = math.random(60, 110)
        new.mortality = new.timeToFertility * math.random(40, 50) * 0.1
        new.position = pos or new.position
        table.insert(field.critters, new)
    end
    function respawn()
        local startingPop = math.max(WIDTH, HEIGHT) * 0.2
        field.critters = {}
        for i = 1, startingPop do
            newCritter()
        end
    end
    if not isSetUp then
        isSetUp = true
        self.backgroundColor = color(43, 26, 25)
        respawn()
    end
    
    setContext(self.buffer)
    background(self.backgroundColor)
    
    local deaths = {}
    local babies = {}
    for _, critter in ipairs(self.critters) do
        
        -- call critter's own draw function, which may return a baby
        local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
        -- if it did return a baby, tag it and store it
        if babyMaybe ~= nil then
            babyMaybe.id = critter.id
            table.insert(babies, babyMaybe)
        end
        -- if creature has died, add index to the death table
        if critter.alive == false then
            table.insert(deaths, i)
        end

        --[[
        -- check if that color is background color
        if colorAtOutsidePoint == self.backgroundColor or
        colorAtOutsidePoint == critter.color then
            --if so, store the new direction
            critter.direction = outsideDirection
        else
            -- if not, recalculate position without change of direction 
            local recalculated = critter.position + critter.direction * critter.speed
            nextPosition = self:wrapIfNeeded(recalculated)
            --check if fertile
            if critter.fertilityCounter >= critter.timeToFertility then
                --check if mate's color is within mateColorVariance
                local incompatible = 
                colorsExceedVariance(critter.color, colorAtOutsidePoint, 
                critter.mateColorVariance)
                if not incompatible then
                    --if all is good, birth a child
                    local baby = critter:reproduce(colorAtOutsidePoint)
                    baby.id = critter.id
                    table.insert(babies, baby)
                end
            end
        end
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
        local colorAtPoint = color(self.lastBuffer:get(bufferX, bufferY))
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
                local baby = critter:reproduce(colorAtPoint)
                baby.position = outsidePoint
                table.insert(babies, baby)
            end
        end
        ]]

    end
    
    for _, baby in ipairs(babies) do
        table.insert(self.critters, baby)
    end
    
    for index=#deaths, 1, -1 do
        table.remove(self.critters, index)
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
    
    fill(38, 64, 69)
    text(#self.critters, 42, 88)
    fill(236, 207, 67)
    text(#self.critters, 40, 90)

    self:drawAndSwapBuffer()
end
