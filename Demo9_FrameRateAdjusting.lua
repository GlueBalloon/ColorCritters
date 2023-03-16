


function Field:draw()
    pushStyle()
    noStroke()
    function newCritter(pos)
        local new = ColorCritter()
        new.mateColorVariance = 0.15
        new.size = math.random(2, 6)
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
        --[[
        testStoreFpsHistory()
        testCollectOldest()
        testFindMedianFps()
        testGetPopulationForFpsTarget()
        testGetMedianFpsPopulationAndRatio()
        ]]
        respawn()
    end

    setContext(self.buffer)
    background(self.backgroundColor)   

    --[[
    self:storeFpsHistory(self.fps, #self.critters)
    if self.fps < 12 then
        local medfps, medpop, ratio = self:getMedianFpsPopulationAndRatio()
        self.targetPopulation = self:getPopulationForFpsTarget(medfps, medpop, 12)
        print("medfps, medpop, ratio ", medfps, medpop, ratio)
        print("self.targetPopulation ", self.targetPopulation)
    else
        self.targetPopulation = nil
    end
    if self.targetPopulation and self.targetPopulation < #self.critters then
        popAdjustment = #self.critters - self.targetPopulation
        print("should be culling ", popAdjustment, "from ", #self.critters)
        for i = popAdjustment, 1, -1 do
            table.remove(self.critters, i)
        end
    end
    ]]
    
    local deaths = {}
    self.babies = {}
    self.oldest = {}
    for _, critter in ipairs(self.critters) do
        -- check for population adjustment
       -- if popAdjustment then
          --  self:collectOldest(critter, popAdjustment)
      --  end
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
    local popAdjustment = self:adjustmentNeeded(#self.critters, self.fps, 20, 7000)
    self:removeRandomCritters(popAdjustment)
    
    -- for _, oldest in ipairs(self.oldest) do
       -- oldest.alive = false;
   -- end
  --  printRarely("oldest ", #self.oldest)
    
    if CurrentTouch.state == BEGAN then
        isSetUp = false
    end
    

    
    --[[
    for index=#deaths, 1, -1 do
        table.remove(self.critters, index)
    end
    if popAdjustment > 0 then
        print("adjusted pop ", #self.critters)
    end
    printRarely("deaths ", #deaths)
    ]]


    
    
    
    --[[
    fontSize(25)
    fill(38, 64, 69)
    text(self.fps, (WIDTH/2)+2, 88)
    fill(236, 207, 67)
    text(self.fps, WIDTH/2, 90)
    
    ]]
    --drawGrowthCurve()
    if true then
        --[[
        pushStyle()
        rectMode(CORNER)
        spriteMode(CORNER)
        fill(30, 26, 46)
        rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
        sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
        popStyle()
        drawAxesWithTicks(50)
        local graphUpperIndex = math.min(#self.populationHistory, WIDTH)
        for i = 1, graphUpperIndex do
            ellipse(i + 50, (self.populationHistory[i] * 0.2)+50, 2)
        end
        ]]
        printRarely(#self.critters, ":", self.fps)
    end
    

    self:drawAndSwapBuffer()
    

    
    popStyle()
end

function drawAxes()
    -- Draw x and y axes
    strokeWidth(2)
    line(50,50,50,HEIGHT)
    line(50,50,WIDTH,50)
    
    -- Draw tick marks on y-axis
    for i=0,35 do
        line(40,50+i*30,50,50+i*30)
    end
    
    -- Draw tick marks on x-axis
    for i=0,70 do
        line(50+i*30,40,50+i*30,50)
    end
end

function drawAxesWithTicks(interval)
    interval = interval or 100
    pushStyle()
    -- Draw the x-axis
    strokeWidth(2)
    stroke(224, 213, 138)
    line(50, 50, WIDTH - 50, 50)
    
    -- Draw the y-axis
    line(50, 50, 50, HEIGHT - 50)
    
    -- Draw tick marks on the x-axis
    for x = interval, WIDTH, interval do
        line(x, 50, x, 60)
    end
    
    -- Draw tick marks on the y-axis
    for y = interval, HEIGHT, interval do
        line(50, y, 60, y)
    end
    popStyle()
end
