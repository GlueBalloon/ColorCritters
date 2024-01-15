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

function FieldDrawer:drawBuffer()
    setContext()
    background(self.field and self.field.backgroundColor or color(82, 128, 142))
    sprite(self.buffer, WIDTH/2, HEIGHT/2)
end

function FieldDrawer:swapBuffer()
    self.lastBuffer = self.buffer
    self.buffer = image(WIDTH, HEIGHT)
    setContext(self.buffer)
    collectgarbage()
end




-- PopTracker class
PopTracker = class()

function PopTracker:init(targetPopulation)
    self.population = 0
    self.targetPopulation = targetPopulation or 0
    self.lastGoodTickRate = 0
    self.history = {}
end

function PopTracker:update(newPopulation)
    self.population = newPopulation
    table.insert(self.history, newPopulation)
end

function PopTracker:amountOverTarget(population, tickRate, targetRate, maxPop)
    maxPop = maxPop or self.targetPopulation
    if maxPop and population > maxPop then
        return population - maxPop
    end
    if tickRate > targetRate then
        self.lastGoodTickRate = #self.history
        return 0
    elseif self.history[self.lastGoodTickRate] then
        local overage = 
            population - self.history[self.lastGoodTickRate] - targetRate
        if self.lastGoodTickRate % 3 == 0 then
            self.lastGoodTickRate = self.lastGoodTickRate
        end
        return overage
    else
        return 0
    end 
end




-- CritterTracker class
CritterTracker = class()

function CritterTracker:init(critters)
    self.all = critters or {}
    self.babies = {}
    self.ageTable = {}
    self.oldest = {}
end




-- Field class
Field = class()

function Field:init(critters, bgColor)
    self.time = 0
    self.backgroundColor = bgColor or color(63, 95, 233)
    self.critters = CritterTracker(critters)
    self.popHistory = {}
    self.numToCull = 0
    self.isCustomSetup = false
    self.drawer = FieldDrawer(self)
    self.tickRate = 0
    self.popTracker = PopTracker()
end

function Field:resetCritters(numNew)
    self.critters.all = {}
    if not numNew then
        numNew = math.random(60, 120)
    end
    for i = 1, numNew do
        local newCritter = ColorCritter()
        table.insert(self.critters.all, newCritter)
        newCritter.id = #self.critters.all
    end
end

function Field:wrapIfNeeded(point)
    -- Wrap around the edges if the new position is out of bounds
    if point.x <= WIDTH and point.x > 0 and 
        point.y <= HEIGHT and point.y > 0 then
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

function Field:updatePopHistory(population)
    self.popHistory[#self.popHistory+1] = population
end

function Field:amountOverTargetPop(population, tickRate, targetRate, maxPop)
    local tracker = self.popTracker
    return tracker:amountOverTarget(population, tickRate, targetRate, maxPop)
end

function Field:removeRandomCritters(adjustment)
    while adjustment > 0 do
        local index = math.random(#self.critters.all)
        local value = table.remove(self.critters.all, index)
        adjustment = adjustment - 1
    end
end

function Field:setContextToBuffer()
    self.drawer:setContextToBuffer()
end
