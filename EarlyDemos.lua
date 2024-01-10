
--first ever drawing of critters   
function Immobile()
    if demoControl.selectedDemo ~= 1 then
        return
    end
    function Field:draw()
        background(204, 110, 171)
        for i, critter in ipairs(self.critters.all) do
            -- Draw critter as an ellipse with size and color
            fill(critter.color.r, critter.color.g, critter.color.b, critter.color.a)
            ellipse(critter.position.x, critter.position.y, critter.size)
        end
    end
    field:draw()
end

--critters that try to avoid each other (but don't always succeed)
function Movers()
    function Field:draw()
        self:drawAndSwapBuffer()   
        self.backgroundColor = color(21, 31, 21)
        background(self.backgroundColor)   
        for _, critter in ipairs(self.critters.all) do       
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
            local colorAtPoint = color(self.drawer.buffer:get(bufferX, bufferY))
            -- check if that color is background color
            if colorAtPoint == self.backgroundColor then
                --if so, store the new direction
                critter.direction = outsideDirection
            else
                -- if not, reverse direction
                critter.direction = vec2(-outsideDirection.x, -outsideDirection.y)
                --recalculate position 
                local recalculated = critter.position + critter.direction * critter.speed
                nextPosition = self:wrapIfNeeded(recalculated)
            end
            -- update position
            critter.position = nextPosition
            --draw
            fill(critter.color)
            ellipse(critter.position.x, critter.position.y, critter.size)       
        end
    end 
    field:draw()
end

function Streakers()
    --critters that travel in a straight line, painting the screen
    function Field:draw()
        for i, critter in ipairs(self.critters.all) do
            -- Calculate new position based on direction and speed
            local newPosition = critter.position + critter.direction * critter.speed 
            
            -- Wrap around the edges if the new position is out of bounds
            newPosition = self:wrapIfNeeded(newPosition)
            
            -- Update critter position
            critter.position = newPosition
            
            -- Draw critter as an ellipse with size and color
            fill(critter.color.r, critter.color.g, critter.color.b, critter.color.a)
            ellipse(critter.position.x, critter.position.y, critter.size)
        end
        -- buffer swap
        self:drawAndSwapBuffer()
        -- randomize direction on touch
        if CurrentTouch.state == BEGAN then
            for i, critter in pairs(self.critters.all) do
                critter.direction = vec2(math.random()-0.5, math.random()-0.5):normalize()
            end
        elseif CurrentTouch.state == CHANGED then
            for i, critter in pairs(self.critters.all) do
                critter.direction = vec2(math.random()-0.5, math.random()-0.5):normalize()
            end
        end
    end
    field:draw()
end


function AccidentalBlobs()
    --a fun accident that was kept because it's fun
    function Field:draw()
        
        self:drawAndSwapBuffer()
        
        background(self.backgroundColor)
        
        if #self.critters.all > 2000 then
            local new = ColorCritter()
            new.mutationRate = 0.95
            self.critters.all = {new}
        end
        local babies = {}
        for _, critter in ipairs(self.critters.all) do
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
            local colorAtPoint = color(self.drawer.lastBuffer:get(bufferX, bufferY))
            -- check if that color is background color
            if colorAtPoint == self.backgroundColor then
                --if so, store the new direction
                critter.direction = outsideDirection
            else
                -- if not, recalculate position without change of direction 
                local recalculated = critter.position + critter.direction * critter.speed * critter.size * 0.17
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
            table.insert(self.critters.all, baby)
        end
        if CurrentTouch.state == BEGAN then
            local new = ColorCritter()
            new.position = CurrentTouch.pos
            field.critters = {new}
        elseif CurrentTouch.state == CHANGED then
            local new = ColorCritter()
            new.position = CurrentTouch.pos
            table.insert(field.critters, new)
        end
    end
    field:draw()
end