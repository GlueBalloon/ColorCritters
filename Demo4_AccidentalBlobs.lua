function Field:draw()
    
    self:drawAndSwapBuffer()
    
    background(self.backgroundColor)
    
    if #self.critters > 400 then
        self:resetCritters(1)
    end
    local babies = {}
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
        -- Make its x and y into non-zero integers inside bounds and get color at that point
        local bufferX, bufferY = math.floor(nextPosition.x), math.floor(nextPosition.y)
        bufferX, bufferY = math.min(WIDTH, math.max(1, bufferX)), math.min(HEIGHT, math.max(1, bufferY))
        local colorAtPoint = color(self.lastBuffer:get(bufferX, bufferY))
        -- check if that color is background color
        if colorAtPoint == self.backgroundColor then
            --if so, store the new direction
            critter.direction = outsideDirection
        else
            -- if not, recalculate position without change of direction 
            local recalculated = critter.position + critter.direction * critter.speed
            nextPosition = self:wrapIfNeeded(recalculated)
            --and make baby!
            local baby = critter:reproduce()
            table.insert(babies, critter:reproduce())
        end
        -- update position
        critter.position = nextPosition
        --draw
        fill(critter.color)
        ellipse(critter.position.x, critter.position.y, critter.size)       
    end
    for _, baby in ipairs(babies) do
        table.insert(self.critters, baby)
    end
    if CurrentTouch.state == BEGAN then
        local new = ColorCritter()
        new.position = CurrentTouch.pos
        field.critters = {new}
    end
end