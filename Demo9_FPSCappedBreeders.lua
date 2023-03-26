
--when fps drops below 20 a critter dies every time another critter is born
function Field:draw()
    
    --basic draw cycle prep
    pushStyle()
    noStroke()
    
    --draw to buffer
    setContext(self.buffer)
    
    --functions for spawning custom critters
    function newCritter(pos)
        local new = ColorCritter()
        new.mateColorVariance = 0.01
        new.size = math.random(2, math.ceil(math.max(WIDTH, HEIGHT) * 0.018))
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
        self.backgroundColor = color(25, 34, 43)
        respawn()
        parameter.clear()
        parameter.watch("fps")
        parameter.watch("pop")
        parameter.watch("cull")
        parameter.watch("ages")
        parameter.watch("ageTable")
        parameter.watch("ageTable[#ageTable]")
        parameter.watch("numDeaths")
        parameter.watch("deaths[1]")
        parameter.watch("deaths[#deaths]")
    end
    
    --clear screen
    background(self.backgroundColor)   
    
    --reset deaths, babies, and age tables
    self.deaths = {}
    self.babies = {}
    self.ageTable = {}

    --cycle through critters
    for i, critter in ipairs(self.critters) do
        -- if critter has died, collect index and skip loop
        if critter.alive == false then
            table.insert(self.deaths, i)
            goto nextCritter
        end
        -- call critter's own draw function, which may return a baby
        local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
        -- if it did return a baby, store it
        if babyMaybe ~= nil then
            table.insert(self.babies, babyMaybe)
        end
        -- place in ageTable if needed
        if self.numToCull > 0 then
            local age = critter.age
            if not self.ageTable[age] then
                self.ageTable[age] = {}
            end
            local indexTable = {critter=critter, index=i}
            table.insert(self.ageTable[age], indexTable)
        end
        ::nextCritter::
    end    
    
    --check fps to see if culling is needed
    self.fps=self.fps*.9+.1/DeltaTime
    self:savePopulationHistory(#self.critters)
    self.numToCull = self:adjustmentNeeded(#self.critters, self.fps, 15, 4000)
    fps = self.fps
    pop = #self.critters
    cull = self.numToCull
    ages = #self.ageTable
    ageTable = self.ageTable
    -- if culling is needed, use ageTable to add to kill list
    if self.numToCull > 0 then
       -- self:removeRandomCritters(self.numToCull)
 --       print("culled ", self.numToCull)
   --     self.critters = {}
  --   goto killKludge

        local culledCount = 0

        for age = #self.ageTable, 1, -1 do
            local crittersAtAge = self.ageTable[age]
            if crittersAtAge then
                for i, indexTable in ipairs(crittersAtAge) do
                    local critter = indexTable.critter
                    if critter.alive then
                        critter.alive = false                        
                        table.insert(self.deaths, indexTable.index)  
                        culledCount = culledCount + 1 
                        if culledCount >= self.numToCull then
                            break
                        end
                    end
                end
            end
            if culledCount >= self.numToCull then
                break
            end
        end       

    end
    ::killKludge::
    -- sort death table from lowest to highest
    deaths = self.deaths
    numDeaths = #self.deaths
    table.sort(self.deaths)

    
    -- Step 2: Create a new table and insert unique elements
    local uniqueIndexes = {}
    local prevValue
    
    for _, value in ipairs(self.deaths) do
        if value ~= prevValue then
            table.insert(uniqueIndexes, value)
          --  print("added to uniqueIndexes ", value)
        end
        prevValue = value
    end
    
    --clear out the dead by index and add in the newborn
    --print("before cull ", #self.critters, ", deaths ", #self.deaths)
    for i=#uniqueIndexes, 1, -1 do
       -- print("removing ", uniqueIndexes[i])
        table.remove(self.critters, uniqueIndexes[i])
    end   
   -- print("after cull ", #self.critters)
    for _, baby in ipairs(self.babies) do
        table.insert(self.critters, baby)
    end
    
    self:drawAndSwapBuffer()   
    popStyle()
    
    -- clear everything and start over if touched
    if CurrentTouch.state == BEGAN then
        isSetUp = false
    end
end
