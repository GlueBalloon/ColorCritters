
--just like the streakers demo except the critters multiply
function Field:draw()

    function newCritter(pos)
        local new = ColorCritter()
        new.mateColorVariance = 0.15
        new.size = math.random(2, 34)
        new.speed = math.random(8, 20)
        new.timeToFertility = math.random(80, 90)
        new.mortality = new.timeToFertility * math.random(11, 50) * 0.1
        new.position = pos or new.position
        table.insert(field.critters, new)
    end
    function respawn()
        local startingPop = math.max(WIDTH, HEIGHT) * 0.2
        field.critters = {}
        for i = 1, 100 do
            newCritter()
        end
    end
    if not isSetUp then
        isSetUp = true
        self.backgroundColor = color(43, 26, 25)
        respawn()
    end
    
    pushStyle()
    noStroke()
    setContext(self.buffer)
    
    local deaths = {}
    self.babies = {}
    self.oldest = {}
    for _, critter in ipairs(self.critters) do
        -- call critter's own draw function, which may return a baby
        local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
        -- if it did return a baby, tag it and store it
        if babyMaybe ~= nil then
            babyMaybe.id = critter.id
            table.insert(self.babies, babyMaybe)
        end
        -- if creature has died, add index to the death table
        if critter.alive == false then
            table.insert(deaths, i)
        end
    end
    
    for i, index in ipairs(deaths) do
        table.remove(self.critters, index)
    end
    
    for _, baby in ipairs(self.babies) do
        table.insert(self.critters, baby)
    end
    
    self.fps=self.fps*.9+.1/DeltaTime
    self:savePopulationHistory(#self.critters)
    local popAdjustment = self:adjustmentNeeded(#self.critters, self.fps, 30, 2000)
    self:removeRandomCritters(popAdjustment)

    
    if CurrentTouch.state == BEGAN then
        for i, critter in pairs(self.critters) do
            critter.direction = vec2(math.random()-0.5, math.random()-0.5):normalize()
        end
    end
    
    
    self:drawAndSwapBuffer()
    popStyle()
end
