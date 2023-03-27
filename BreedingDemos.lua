--any critter will mate with any other critter
function BasicMating()
    function Field:draw()
        self:drawAndSwapBuffer()
        if not self.isCustomSetup then
            local startingPop = math.max(WIDTH, HEIGHT) * 0.02
            self:resetCritters(startingPop)
            self.backgroundColor = color(106, 38, 122)
            for _, critter in ipairs(self.critters) do
                critter.speed = 12
                critter.size = 70
                critter.mateColorVariance = 1
                critter.color = color(141, 0, 255)
                if math.random() > 0.5 then
                    critter.color = color(255, 0, 183)
                end
                critter.timeToFertility = 10
            end
            self.isCustomSetup = true
            function buffSwap(field)
                setContext()
                sprite(field.buffer, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
                field.lastBuffer = field.buffer
            end
            --toggle these on and off to activate features
            doTouchTest = false
            showLastBufferThumbnail = false
        end
        if doTouchTest then
            if not self.buffer then
                self.buffer = image(WIDTH,HEIGHT)
            end
            setContext(self.buffer)
            -- Draw left box in left color
            rectMode(CORNER)
            fill(236, 67, 155)
            rect(0, 0, WIDTH / 2, HEIGHT)
            
            -- Draw right box in right color
            fill(236, 124, 67)
            rect(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
            
            -- Draw middle box in center color
            fill(153, 67, 236)
            rect(WIDTH/4, HEIGHT/4, WIDTH/2, HEIGHT/2)
            
            buffSwap(self)
            if CurrentTouch.state == BEGAN then
                print(color(field.lastBuffer:get(math.floor(CurrentTouch.x), math.floor(CurrentTouch.y))))
            end
            return
        end
        
        setContext(self.buffer)
        background(self.backgroundColor)
        self.fps=self.fps*.9+.1/DeltaTime
        if self.fps < 30 then
            self.isCustomSetup = false
        end
        local babies = {}
        for _, critter in ipairs(self.critters) do
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
            -- if it did return a baby, store it
            if babyMaybe ~= nil then
                table.insert(babies, babyMaybe)
            end
        end
        for _, baby in ipairs(babies) do
            table.insert(self.critters, baby)
        end
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end

    end
    field:draw()
end

--look at 'em jitter around! no population cap
function JitteryBreeders()
    function Field:draw()
        self:drawAndSwapBuffer()
        function respawn()
            field.critters = {}
            local limit = math.ceil(randomFromScreen(0.5))
            for i = 1, limit do
                defineCritter(ColorCritter())
            end
        end
        function defineCritter(critter, pos)
            critter.size = randomFromScreen(0.03)
            critter.speed = math.random(5, 30)
            critter.timeToFertility = math.random(4, 665)
            critter.position = pos or critter.position
            critter.mutationRate = 0.0
            table.insert(field.critters, critter)
        end
        --setup functions
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(34, 34, 91)
            respawn()
        end
        
        setContext(self.buffer)
        background(self.backgroundColor)
        
        local babies = {}
        
        --manually control critters
        for _, critter in ipairs(self.critters) do
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
            -- Make the outside point's x and y into non-zero integers inside bounds and get color at that point
            local outsidePointInBounds = self:wrapIfNeeded(outsidePoint)
            local bufferX, bufferY = math.floor(outsidePointInBounds.x), math.floor(outsidePointInBounds.y)
            bufferX, bufferY = math.min(WIDTH, math.max(1, bufferX)), math.min(HEIGHT, math.max(1, bufferY))
            local colorAtPoint = color(self.lastBuffer:get(100,100))
            -- check if that color is background color
            if colorAtPoint == self.backgroundColor or
            colorAtPoint == critter.color then
                --if so, store the new direction
                critter.direction = outsideDirection
            else
                -- if not, recalculate position without change of direction 
                local recalculated = critter.position + critter.direction * critter.speed
                nextPosition = self:wrapIfNeeded(recalculated)
                --and if fertile, make a baby
                if critter.fertilityCounter >= critter.timeToFertility then
                    if #self.critters < 40000 then
                        local baby = critter:reproduce(colorAtPoint)
                        defineCritter(baby, outsidePoint)
                        table.insert(babies, baby)
                    end
                end
            end
            -- update position
            critter.position = nextPosition
            --draw
            fill(critter.color)
            ellipse(critter.position.x, critter.position.y, critter.size)    
            --draw based on setup
            if showOutsidePoints then
                fill(255, 231, 0)
                ellipse(outsidePoint.x, outsidePoint.y, 8)
            end
            if printOutsidePointInfo then
                printRarely(critter.id, bufferX, ", ", bufferY, " - ", colorAtPoint, self.backgroundColor)
            end
        end
        for _, baby in ipairs(babies) do
            table.insert(self.critters, baby)
        end
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end
        if CurrentTouch.state == BEGAN then
            self.isCustomSetup = false
        end
        
        fill(20, 28, 29)
        text(#self.critters, 41.5, 88.5)
        fill(242, 240, 239)
        text(#self.critters, 41, 89)
        
        
    end
    field:draw()
end

--critters that aren't close in color won't mate
function PickyBreeders()
    function Field:draw()
        -- scenario-specific creature settings
        function scenarioSettings(critter)
            --size range relative to width
            local sizeBase = math.max(WIDTH, HEIGHT) * 0.045
            critter.size = math.random(math.floor(sizeBase), math.floor(sizeBase * 2.8))
            --behaviors
            critter.speed = 27
            critter.mateColorVariance = 0.5
            critter.timeToFertility = math.random(60, 70)
            critter.mortality = math.random(80, 90)
            --colors
            self.backgroundColor = color(61, 39, 82)
            critter.id = "b"
            local color1 = color(0, 21, 255)
            local color2 = color(0, 115, 255)
            if math.random() < 0.5 then
                critter.id = "y"
                color1 = color(255, 211, 0)
                color2 = color(229, 255, 0)
            end
            local chosenColor = color1
            if math.random() < 0.5 then
                chosenColor = color2
            end
            critter.color = chosenColor
            local diff = getHueDifference(color1,  color2)
        end    
        -- one-time setup
        if not self.isCustomSetup then
            self.isCustomSetup = true
            generations = 0
            showOutsidePoints = false
            showBufferThumbnail = false
            local startingPop = math.max(WIDTH, HEIGHT) * 0.05
            self:resetCritters(startingPop)
            for i, critter in ipairs(self.critters) do
                scenarioSettings(critter)
            end
        end   
        self:drawAndSwapBuffer()
        -- set draw-cycle variables
        local blueCritterCount = 0
        local yellowCritterCount = 0
        local babies = {}
        local deaths = {}
        generations = generations + 1
        -- set buffer
        setContext(self.buffer)
        background(self.backgroundColor)
        -- go through the critters
        for i, critter in ipairs(self.critters) do  
            
            -- track which 'species' this critter is        
            if critter.id == "y" then
                yellowCritterCount = yellowCritterCount + 1
            elseif critter.id == "b" then
                blueCritterCount = blueCritterCount + 1
            end 
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
            -- if it did return a baby, tag it and store it
            if babyMaybe ~= nil then
                babyMaybe.id = critter.id
                table.insert(babies, babyMaybe)
            end
            -- if creature has died, add index to the death table
            if critter.alive == false then
                table.insert(deaths, i)
            end
            ::next::
        end
        
        for _, baby in ipairs(babies) do
            table.insert(self.critters, baby)
        end
        for index=#deaths, 1, -1 do
            table.remove(self.critters, index)
        end
        
        if showBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            --sprite(self.buffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end
        
        font("HelveticaNeue")
        fontSize(30)
        fill(38, 64, 69)
        text(generations, 100, 88)
        fill(236, 207, 67)
        text(generations, 98, 90)
        
        -- Check if either blue or yellow is zero, and show a message if necessary
        local blueGone, yellowGone = blueCritterCount == 0, yellowCritterCount == 0
        if blueGone or yellowGone then
            font("SourceSansPro-Bold")
            adjustFontSize("There are no more yellow critters", WIDTH * 0.9)
            if blueGone and yellowGone then
                fill(229, 232, 218)
                text("Oops all dead", WIDTH/2, HEIGHT/2 + 80)
                text("Press reset to start again", WIDTH/2, HEIGHT/2)
            elseif blueGone then
                fill(0, 115, 255)
                text("There are no more blue critters", WIDTH/2, HEIGHT/2 + 80)
                text("Press reset to start again", WIDTH/2, HEIGHT/2)
            else
                fill(255, 218, 0)
                text("There are no more yellow critters", WIDTH/2, HEIGHT/2 + 80)
                text("Press reset to start again", WIDTH/2, HEIGHT/2)
            end
        end
    end
    field:draw()
end

--teeny tiny breeders without any population cap
function TinyBreeders()
    function Field:draw()
        function newCritter(pos)
            local new = ColorCritter()
            new.size = math.random(5, 8)
            new.speed = math.random(5, 18)
            new.timeToFertility = math.random(60, 110)
            new.mortality = new.timeToFertility * math.random(40, 50) * 0.1
            new.position = pos or new.position
            table.insert(field.critters, new)
        end
        function respawn()
            local startingPop = math.max(WIDTH, HEIGHT) * 0.2
            field.critters = {}
            for i = 1, startingPop do
                newCritter()
            end
        end
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(43, 26, 25)
            respawn()
        end
        
        self:drawAndSwapBuffer()
        setContext(self.buffer)
        background(self.backgroundColor)
        
        local deaths = {}
        local babies = {}
        for _, critter in ipairs(self.critters) do
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.lastBuffer, self.backgroundColor)
            -- if it did return a baby, tag it and store it
            if babyMaybe ~= nil then
                babyMaybe.id = critter.id
                table.insert(babies, babyMaybe)
            end
            -- if creature has died, add index to the death table
            if critter.alive == false then
                table.insert(deaths, i)
            end
            
        end
        
        for _, baby in ipairs(babies) do
            table.insert(self.critters, baby)
        end
        
        for index=#deaths, 1, -1 do
            table.remove(self.critters, index)
        end
        
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end
        if CurrentTouch.state == BEGAN then
            isSetUp = false
        end
        
        pushStyle()
        textMode(CORNER)
        fill(35)
        text("population: "..tostring(#self.critters), 100, 80)
        fill(173, 88, 189)
        text("population: "..tostring(#self.critters), 102, 82)
        popStyle()
        
        
    end
    field:draw()
end


--when fps drops too low, oldest critters get removed
function PopulationTiedToFPS()
    function Field:draw()
        
        --basic draw cycle prep
        pushStyle()
        noStroke()
        
        self:drawAndSwapBuffer()   
        
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
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(25, 34, 43)
            respawn()
            parameter.clear()
            parameter.watch("fps")
            parameter.watch("pop")
            parameter.watch("cull")
            parameter.watch("numDeaths")
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
        
        
        popStyle()
        
        -- clear everything and start over if touched
        if CurrentTouch.state == BEGAN then
            isSetUp = false
        end
    end
    field:draw()
end


--just like the streakers demo except the critters multiply
function GroupStreakers()
    function Field:draw()
        
        function newCritter(pos)
            local new = ColorCritter()
            new.mateColorVariance = 0.3
            new.size = math.random(10, 42)
            new.speed = math.random(8, 20)
            new.timeToFertility = math.random(20, 80)
            new.mortality = new.timeToFertility * math.random(11, 50) * 0.1
            new.position = pos or new.position
            table.insert(field.critters, new)
        end
        function respawn()
            field.critters = {}
            for i = 1, 100 do
                newCritter()
            end
        end
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(43, 26, 25)
            respawn()
        end
        
        pushStyle()
        self:drawAndSwapBuffer()

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
        
        popStyle()
    end
    field:draw()
end