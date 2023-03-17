-- Field class
Field = class()

function Field:init(critters)
    self.backgroundColor = color(24, 27, 40)
    self.critters = critters or {}
    if #self.critters == 0 then
        self:resetCritters()
    end
    self.buffer = image(WIDTH, HEIGHT)
    self.lastBuffer = self.buffer
    self.fps = 60
    self.babies = {}
    self.ageTable = {}
    self.oldest = {}
    self.fpsHistory = {}
    self.targetPopulation = nil
    self.populationHistory = {}
    self.numToCull = 0
end

function Field:resetCritters(numNew)
    self.critters = {}
    if not numNew then
        numNew = math.random(60, 120)
    end
    for i = 1, numNew do
        local newCritter = ColorCritter()
        table.insert(self.critters, newCritter)
        newCritter.id = #self.critters
    end
end

function Field:wrapIfNeeded(point)
    -- Wrap around the edges if the new position is out of bounds
    if point.x <= WIDTH and point.x > 0 and point.y <= HEIGHT and point.y > 0 then
        return point
    end
    point.x = point.x % WIDTH
    point.y = point.y % HEIGHT
    if point.x == 0 then point.x = 1 end
    if point.y == 0 then point.y = 1 end
    return point
end

function Field:drawAndSwapBuffer()
    collectgarbage()
    if not self.buffer then
        self.buffer = image(WIDTH, HEIGHT)
        setContext(self.buffer)
        background(self.backgroundColor)
        self.lastBuffer = self.buffer
    end
    setContext()
    self.lastBuffer = self.buffer
    sprite(self.buffer, WIDTH/2, HEIGHT/2)
    self.buffer = image(WIDTH, HEIGHT)
    setContext(self.buffer)
end

function Field:getMedianFpsPopulationAndRatio()
    local medianTable = self:findMedianFpsTable()
    if not medianTable then return end
    local medianFps = medianTable.fps
    local medianPopulation = medianTable.population
    local ratio = medianPopulation / medianFps
    return medianFps, medianPopulation, ratio
end

function Field:findMedianFpsTable()
    local fpsValues = {}
    for _, pair in ipairs(self.fpsHistory) do
        table.insert(fpsValues, pair)
    end
    table.sort(fpsValues, function(a, b) return a.fps < b.fps end)
    local medianIndex = math.floor(#fpsValues/2)
    return fpsValues[medianIndex]
end

function Field:savePopulationHistory(population)
    table.insert(self.populationHistory, population)
    if #self.populationHistory > 20000 then
        table.remove(self.populationHistory, 1)
    end
end

function Field:savePopulationHistory(population)
    self.populationHistory[#self.populationHistory+1] = population
end

function Field:adjustmentNeeded(population, fps, targetFps, maxPop)
    if maxPop and #self.critters > maxPop then
        return #self.critters - maxPop
    end
    if fps > targetFps then
        self.lastGoodFPS = #self.populationHistory
        return 0
    else
        local adjustment = population - self.populationHistory[self.lastGoodFPS]
        if self.lastGoodFPS % 3 == 0 then
            self.lastGoodFPS = self.lastGoodFPS - 1
        end
        return adjustment
    end
end

function Field:removeRandomCritters(adjustment)
    while adjustment > 0 do
        local index = math.random(#self.critters)
        local value = table.remove(self.critters, index)
        adjustment = adjustment - 1
    end
end

function Field:getPopulationForFpsTarget(medianFps, medianPopulation, targetFps)
    local ratio = medianPopulation / medianFps
    local targetPopulation = math.ceil(targetFps * ratio)
    return targetPopulation
end

function Field:storeFpsHistory(fps, population)
    local pair = {fps=fps, population=population}
    if #self.fpsHistory < 100 then
        table.insert(self.fpsHistory, pair)
    else
        table.insert(self.fpsHistory, 1, pair)
        self.fpsHistory[101] = nil
    end
end

function Field:collectOldest(critter, aTotal)
    local total = aTotal or 100
    if #self.oldest < total then
        table.insert(self.oldest, critter)
    else
        local minAge = self.oldest[1].age
        local minIndex = 1
        for i, oldCritter in ipairs(self.oldest) do
            if oldCritter.age < minAge then
                minAge = oldCritter.age
                minIndex = i
            end
        end
        if critter.age > minAge then
            self.oldest[minIndex] = critter
        end
    end
end