
--first ever drawing of critters   
function Field:draw()
    background(231, 96, 89)
    for i, critter in ipairs(self.critters) do
        -- Draw critter as an ellipse with size and color
        fill(critter.color.r, critter.color.g, critter.color.b, critter.color.a)
        ellipse(critter.position.x, critter.position.y, critter.size)
    end
end
