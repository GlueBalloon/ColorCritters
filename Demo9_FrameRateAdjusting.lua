


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

function drawFullCurve()
    pushStyle()
    stroke(100, 233, 80)
    fill(102, 233, 80)
    maxWidth = WIDTH
    maxHeight = HEIGHT * 30
    maxGrowthRate = 200
    local curve = {}
    local growthRate = 0.01 -- starting growth rate
    local x = 50
    
    for i = 1, maxWidth * 1.1 do
        growthRate = growthRate + 0.001 * (i/maxWidth) -- increase growth rate
        local y = maxHeight * growthRate/(maxGrowthRate - i/8) -- calculate y position based on growth rate
        curve[i] = vec2(x, y + 50)
        x = x + 0.8
    end
    for _, dot in ipairs(curve) do
        ellipse(dot.x, dot.y, 4)
    end
    popStyle()
    return curve
end

function simulateGrowth(y, dt)
    local maxGrowthRate = 200
    local growthRate = y / (HEIGHT * 1000) * maxGrowthRate
    local dy = growthRate * dt * 1000
    return y + dy
end

function simulateGrowthReversed(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 600
    local slopeChangePoint = 40
    local growthRate = ((levelOffY - y) / (levelOffY - slopeChangePoint)) * maxGrowthRate
    local dy = growthRate * dt * 1.5
    return y + dy
end
    
    


function simulateGrowthCombined(y, dt, ry)
    local maxGrowthRate = 200
    local levelOffY = 600
    local slopeChangePoint = levelOffY / 2
    local growthRate
    local dy
    if not rCache then
        rCache = {simulateGrowthReversed(ry, dt)} 
        incrementer = 1
    else
        rCache[#rCache+1] = simulateGrowthReversed(ry, dt)
    end
    if y <= slopeChangePoint then
        if rCache[#rCache] < slopeChangePoint then
            incrementer = incrementer + 1
        end
        return simulateGrowth(y, dt), rCache[#rCache]
    else
        returnValue = rCache[incrementer]
        incrementer = incrementer + 1
        return returnValue, rCache[#rCache]
    end
end

function simulateGrowth(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 600
    local slopeChangePoint = levelOffY / 2
    local growthRate, dy
    
    if y <= slopeChangePoint then
        growthRate = y / (HEIGHT * 1000) * maxGrowthRate
    else
        local reversedY = levelOffY - y
        growthRate = reversedY / (HEIGHT * 1000) * maxGrowthRate
    end
    
    dy = growthRate * dt * 1000
    return y + dy
end

function simulateGrowth(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 50
    local slopeChangePoint = levelOffY / 2
    local growthRate, dy
    
    if y <= slopeChangePoint then
        growthRate = y / (HEIGHT * 1000) * maxGrowthRate
    else
        local reversedY = levelOffY - y
        growthRate = reversedY / (HEIGHT * 1000) * maxGrowthRate
    end
    
    dy = growthRate * dt * 1000
    return y + dy
end


function drawGrowthCurve()
    if not skip then
        xValues = {}
        yValues = {}
        growthRate = 0.1
        for i = 1, 2000 do
            table.insert(xValues, i + 50)
            table.insert(yValues, growthRate)
            growthRate = growthRate + (i / 1000000)
        end
        skip = true
        
        curvey = drawFullCurve()
        y = simulateGrowth(1, DeltaTime)
        bitty = {vec2(50, y + 50)}
        yy = simulateGrowthReversed(1, DeltaTime)
        bittybitty = {vec2(50, yy + 50)} 
        cy, ry = simulateGrowthCombined(1, DeltaTime, 1)
        combo = {vec2(50, cy + 50)} 
        comboR = {vec2(50, ry + 65)} 
    end
    if true then return end
    strokeWidth(2)
    for i = 2, #xValues do
  --    line(xValues[i-1], yValues[i-1]*HEIGHT-50, xValues[i], yValues[i]*HEIGHT - 50)
    end
    
    
    drawAxes()
  --  drawFullCurve()

    y = simulateGrowth(y, DeltaTime)
    yy = simulateGrowthReversed(yy, DeltaTime)
    cy, ry = simulateGrowthCombined(cy, DeltaTime, ry)
    table.insert(bitty, vec2(#bitty + 51, y + 50))
    table.insert(bittybitty, vec2(#bittybitty + 51, yy + 60))
    table.insert(combo, vec2(#combo + 51, cy + 55))
    table.insert(comboR, vec2(#comboR + 51, ry + 65))
    fill(123, 233, 80)
    drawVecTable(bitty)
    fill(233, 80, 131)
    drawVecTable(bittybitty)
    fill(89, 80, 233)
    drawVecTable(combo)
    fill(217, 233, 80)
    drawVecTable(comboR)
end



function drawVecTable(dots, radius)
    radius = radius or 4
    for _, dot in ipairs(dots) do
        ellipse(dot.x, dot.y, radius)
    end
end

function Field:draw()
    pushStyle()
    noStroke()
    function newCritter(pos)
        local new = ColorCritter()
        new.mateColorVariance = 0.15
        new.size = math.random(2, 64)
        new.speed = math.random(8, 20)
        new.timeToFertility = math.random(80, 160)
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
        testStoreFpsHistory()
        testCollectOldest()
        testFindMedianFps()
        testGetPopulationForFpsTarget()
        testGetMedianFpsPopulationAndRatio()
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
    local popAdjustment = self:adjustmentNeeded(#self.critters, self.fps, 20, 1000)
    printRarely(#self.critters)
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
    local graphUpperIndex = math.min(#self.populationHistory, WIDTH)
        for i = 1, graphUpperIndex do
      --  ellipse(i + 50, (self.populationHistory[i] * 0.4)+70, 2)
    end

    
    
    
    fontSize(25)
    fill(38, 64, 69)
    text(self.fps, (WIDTH/2)+2, 88)
    fill(236, 207, 67)
    text(self.fps, WIDTH/2, 90)
    
    --drawGrowthCurve()

    self:drawAndSwapBuffer()
    popStyle()
end
