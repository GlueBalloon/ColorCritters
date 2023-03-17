
--critters that travel in a straight line, painting the screen
function Field:draw()
    for i, critter in ipairs(self.critters) do
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
    self:drawAndSwapBuffer()
    if CurrentTouch.state == BEGAN then
        for i, critter in pairs(self.critters) do
            critter.direction = vec2(math.random()-0.5, math.random()-0.5):normalize()
        end
    end
end