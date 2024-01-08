-- FieldDrawer class
FieldDrawer = class()

function FieldDrawer:init(field)
    self.field = field
    self.buffer = image(WIDTH, HEIGHT)
    self.lastBuffer = self.buffer
end

function FieldDrawer:drawAndSwapBuffer(field)
    local field = field or self.field
    collectgarbage()
    if not self.buffer then
        self.buffer = image(WIDTH, HEIGHT)
        setContext(self.buffer)
        background(field.backgroundColor)
        self.lastBuffer = self.buffer
    end
    setContext()
    self.lastBuffer = self.buffer
    sprite(self.buffer, WIDTH/2, HEIGHT/2)
    self.buffer = image(WIDTH, HEIGHT)
    setContext(self.buffer)
end

-- Ticker class
Ticker = class()

function Ticker:init()
    self.rate = 60
    self.rateHistory = {}
end

function Ticker:updateTickRate(newTickRate)
    self.rate = newTickRate
    table.insert(self.rateHistory, newTickRate)
end

function Ticker:getAverageTickRate()
    local sum = 0
    for i, v in ipairs(self.rateHistory) do
        sum = sum + v
    end
    return sum / #self.rateHistory
end

-- Field class
Field = class()

function Field:init(critters, bgColor)
    self.backgroundColor = bgColor or color(24, 27, 40)
    self.critters = critters or {}
    self.babies = {}
    self.ageTable = {}
    self.oldest = {}
    self.targetPopulation = nil
    self.populationHistory = {}
    self.numToCull = 0
    self.isCustomSetup = false
    self.drawer = FieldDrawer(self)
    self.ticker = Ticker()
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
    --ridiculous un-refactoring of refactoring (for now):
    self.drawer:drawAndSwapBuffer(self)
end

function Field:getMedianTickRatePopulationAndRatio()
    local medianTable = self:findMedianTickRateTable()
    if not medianTable then return end
    local medianTickRate = medianTable.ticker.rate
    local medianPopulation = medianTable.population
    local ratio = medianPopulation / medianTickRate
    return medianTickRate, medianPopulation, ratio
end

function Field:findMedianTickRateTable()
    local tickRateValues = {}
    for _, pair in ipairs(self.ticker.rateHistory) do
        table.insert(tickRateValues, pair)
    end
    table.sort(tickRateValues, function(a, b) return a.ticker.rate < b.ticker.rate end)
    local medianIndex = math.floor(#tickRateValues/2)
    return tickRateValues[medianIndex]
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

function Field:adjustmentNeeded(population, tickRate, targetTickRate, maxPop)
    if maxPop and #self.critters > maxPop then
        return #self.critters - maxPop
    end
    if tickRate > targetTickRate then
        self.lastGoodTickRate = #self.populationHistory
        return 0
    else
        print(targetTickRate, population , self.populationHistory[self.lastGoodTickRate] , targetTickRate)
        local adjustment = population - self.populationHistory[self.lastGoodTickRate] - targetTickRate
        if self.lastGoodTickRate % 3 == 0 then
            self.lastGoodTickRate = self.lastGoodTickRate
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

function Field:getPopulationForTickRateTarget(medianTickRate, medianPopulation, targetTickRate)
    local ratio = medianPopulation / medianTickRate
    local targetPopulation = math.ceil(targetTickRate * ratio)
    return targetPopulation
end

function Field:storeTickRateHistory(tickRate, population)
    local pair = {tickRate=tickRate, population=population}
    if #self.ticker.rateHistory < 100 then
        table.insert(self.ticker.rateHistory, pair)
    else
        table.insert(self.ticker.rateHistory, 1, pair)
        self.ticker.rateHistory[101] = nil
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