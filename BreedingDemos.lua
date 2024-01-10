--any critter will mate with any other critter
function BasicMating()
    function Field:draw()
        self:drawAndSwapBuffer()
        if not self.isCustomSetup then
            local startingPop = math.max(WIDTH, HEIGHT) * 0.02
            self:resetCritters(startingPop)
            self.backgroundColor = color(106, 38, 122)
            for _, critter in ipairs(self.critters.all) do
                critter.speed = 12
                critter.size = 70
                critter.mateColorVariance = 1.0
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
                field.drawer.lastBuffer = field.drawer.buffer
            end
            --toggle these on and off to activate features
            doTouchTest = false
            showLastBufferThumbnail = false
        end
        if doTouchTest then
            if not self.drawer.buffer then
                self.drawer.buffer = image(WIDTH,HEIGHT)
            end
            setContext(self.drawer.buffer)
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
                print(color(field.drawer.lastBuffer:get(math.floor(CurrentTouch.x), math.floor(CurrentTouch.y))))
            end
            return
        end
        
        setContext(self.drawer.buffer)
        background(self.backgroundColor)
        self.tickRate=self.tickRate*.9+.1/DeltaTime
        if self.tickRate < 30 then
            self.isCustomSetup = false
        end
        local babies = {}
        for _, critter in ipairs(self.critters.all) do
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, self.backgroundColor)
            -- if it did return a baby, store it
            if babyMaybe ~= nil then
                table.insert(babies, babyMaybe)
            end
        end
        for _, baby in ipairs(babies) do
            table.insert(self.critters.all, baby)
        end
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.drawer.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
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
            field.critters.all = {}
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
            table.insert(field.critters.all, critter)
        end
        --setup functions
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(34, 34, 91)
            respawn()
        end
        
        setContext(self.drawer.buffer)
        background(self.backgroundColor)
        
        local babies = {}
        
        --manually control critters
        for _, critter in ipairs(self.critters.all) do
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
            local colorAtPoint = color(self.drawer.lastBuffer:get(100,100))
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
                    if #self.critters.all < 40000 then
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
            table.insert(self.critters.all, baby)
        end
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.drawer.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end
        if CurrentTouch.state == BEGAN then
            self.isCustomSetup = false
        end
        
        fill(20, 28, 29)
        text(#self.critters.all, 41.5, 88.5)
        fill(242, 240, 239)
        text(#self.critters.all, 41, 89)
        
        
    end
    field:draw()
end

--critters that aren't close in color won't mate
function PickyBreeders()
    function Field:draw()
        -- scenario-specific creature settings
        function scenarioSettings(critter)
            --size range relative to width
            local sizeBase = math.max(WIDTH, HEIGHT) * 0.07
            critter.size = math.random(math.floor(sizeBase), math.floor(sizeBase * 2.8))
            --behaviors
            critter.speed = 27
            critter.mateColorVariance = 0.4
            critter.timeToFertility = math.random(20, 54)
            critter.mortality = math.random(25, 50)
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
            --local diff = getHueDifference(color1,  color2)
        end    
        -- one-time setup
        if not self.isCustomSetup then
            self.isCustomSetup = true
            generations = 0
            showOutsidePoints = false
            showBufferThumbnail = false
            local startingPop = math.max(WIDTH, HEIGHT) * 0.05
            self:resetCritters(startingPop)
            for i, critter in ipairs(self.critters.all) do
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
        setContext(self.drawer.buffer)
        background(self.backgroundColor)
        -- go through the critters
        for i, critter in ipairs(self.critters.all) do  
            
            -- track which 'species' this critter is        
            if critter.id == "y" then
                yellowCritterCount = yellowCritterCount + 1
            elseif critter.id == "b" then
                blueCritterCount = blueCritterCount + 1
            end 
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, self.backgroundColor)
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
            table.insert(self.critters.all, baby)
        end
        for index=#deaths, 1, -1 do
            table.remove(self.critters.all, index)
        end
        
        if showBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            --sprite(self.drawer.buffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            sprite(self.drawer.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
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
            table.insert(field.critters.all, new)
        end
        function respawn()
            local startingPop = math.max(WIDTH, HEIGHT) * 0.2
            field.critters.all = {}
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
        setContext(self.drawer.buffer)
        background(self.backgroundColor)
        
        local deaths = {}
        local babies = {}
        for _, critter in ipairs(self.critters.all) do
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, self.backgroundColor)
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
            table.insert(self.critters.all, baby)
        end
        
        for index=#deaths, 1, -1 do
            table.remove(self.critters.all, index)
        end
        
        if showLastBufferThumbnail then
            pushStyle()
            rectMode(CORNER)
            spriteMode(CORNER)
            fill(30, 26, 46)
            rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
            sprite(self.drawer.lastBuffer, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
            popStyle()
        end
        if CurrentTouch.state == BEGAN then
            isSetUp = false
        end
        
        pushStyle()
        textMode(CORNER)
        fill(35)
        text("population: "..tostring(#self.critters.all), 100, 80)
        fill(173, 88, 189)
        text("population: "..tostring(#self.critters.all), 102, 82)
        popStyle()
        
        
    end
    field:draw()
end


--when tickRate drops too low, oldest critters get removed
function PopulationTiedToTickRate()
    function Field:draw()

        --functions for spawning custom critters
        function newCritter(pos)
            local new = ColorCritter()
            new.mateColorVariance = 0.06
            new.size = math.random(3, math.ceil(math.max(WIDTH, HEIGHT) * 0.029))
            new.speed = new.size * 0.02
            new.timeToFertility = math.random(80, 90)
            new.mortality = new.timeToFertility * math.random(11, 180) * 0.1
            new.position = pos or new.position
            table.insert(field.critters.all, new)
        end
        function respawn()
            local startingPop = math.max(WIDTH, HEIGHT) * 0.2
            field.critters.all = {}
            for i = 1, 100 do
                newCritter()
            end
        end
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(16, 21, 16)
            respawn()
            parameter.clear()
            parameter.watch("tickRate")
            parameter.watch("pop")
            parameter.watch("cull")
            parameter.watch("numDeaths")
            parameter.watch("randosAdded")
        end
        
        --basic draw cycle prep
        pushStyle()
        noStroke()
        
        self:drawAndSwapBuffer()   
        
        --draw to buffer
        setContext(self.drawer.buffer)
        
        --clear screen
        background(self.backgroundColor)   
        
        --reset deaths, babies, and age tables
        self.deaths = {}
        self.critters.babies = {}
        self.critters.ageTable = {}
        self.randoPercent = 0.08 --not in self by default
        self.tickRateTarget = 13 --not in self by default
        
        --cycle through critters
        for i, critter in ipairs(self.critters.all) do
            -- if critter has died, collect index and skip loop
            if critter.alive == false then
                table.insert(self.deaths, i)
                goto nextCritter
            end
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, self.backgroundColor)
            -- if it did return a baby, store it
            if babyMaybe ~= nil then
                table.insert(self.critters.babies, babyMaybe)
            end
            -- place in critters.ageTable if needed
            if self.numToCull > 0 then
                local age = critter.age
                if not self.critters.ageTable[age] then
                    self.critters.ageTable[age] = {}
                end
                local indexTable = {critter=critter, index=i}
                table.insert(self.critters.ageTable[age], indexTable)
            end
            ::nextCritter::
        end    
        
        if false then 
            
            --update population tracking
            self.popTracker:update(#self.critters.all)
            
            --if frame rate is too low, prevent births
            if self.tickRate < self.tickRateTarget * 1.3 then
                self.critters.babies = {}
            end
            
            --add in any babies
            for _, baby in ipairs(self.critters.babies) do
                table.insert(self.critters.all, baby) 
            end
            
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
                end
                prevValue = value
            end
            
            --clear out the dead by index and add in the newborn
            for i=#uniqueIndexes, 1, -1 do
                --allow for randos to add
                if i > self.numToCull * self.randoPercent then
                    table.remove(self.critters.all, uniqueIndexes[i])
                end
            end   
            
            popStyle()
            
            -- clear everything and start over if touched
            if CurrentTouch.state == BEGAN then
                isSetUp = false
            end
            
            
            return 
        end
        
        --older more complicated frame-rate stuff:
        
        --check tickRate to see if culling is needed
        self.tickRate=self.tickRate*.9+.1/DeltaTime
        self.popTracker:update(#self.critters.all)
        local tickRateTargetTweaked = self.tickRateTarget * 1.3
        self.numToCull = self.popTracker:amountOverTarget(#self.critters.all, self.tickRate, tickRateTargetTweaked, 10000)
        --add a little extra to numToCull if not zero, for random replacements
        self.numToCull = math.ceil(self.numToCull * (1 + self.randoPercent))
        tickRate = self.tickRate
        pop = #self.critters.all
        cull = self.numToCull
        
        ages = #self.critters.ageTable
        --ageTable = self.critters.ageTable
        -- if culling is needed, use critters.ageTable to add to kill list
        if self.numToCull > 0 then
            
            local culledCount = 0
            
            for age = #self.critters.ageTable, 1, -1 do
                local crittersAtAge = self.critters.ageTable[age]
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
            end
            prevValue = value
        end
        
        --clear out the dead by index and add in the newborn
        for i=#uniqueIndexes, 1, -1 do
            --allow for randos to add
            if i > self.numToCull * self.randoPercent then
                table.remove(self.critters.all, uniqueIndexes[i])
            end
        end   

        for _, baby in ipairs(self.critters.babies) do
            table.insert(self.critters.all, baby)
        end
        
        --if some were culled, add in some new random creatures
        --(prevents entire domination by one color)
        if #uniqueIndexes > 0 then
            local randosToAdd = math.floor(self.numToCull * self.randoPercent)
            self:removeRandomCritters(randosToAdd)
            randosAdded = 0
            for i=1, randosToAdd do
                newCritter()
                randosAdded = randosAdded + 1
            end
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
            new.speed = math.random(1, 9)
            new.timeToFertility = math.random(20, 80)
            new.mortality = new.timeToFertility * math.random(11, 50) * 0.1
            new.position = pos or new.position
            table.insert(field.critters.all, new)
        end
        function respawn()
            field.critters.all = {}
            for i = 1, 100 do
                newCritter()
            end
        end
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.backgroundColor = color(43, 26, 25)
            respawn()
            backgroundBlankImage = image(WIDTH,HEIGHT)
            backgroundClearCounter = 0
        end
        if #self.critters.all > 2000 then
            respawn()
        end
        
        -- apparently without this kludge I can't truly clear the screen after other demos
        if backgroundClearCounter and backgroundClearCounter < 4 then
            print("noo")
            background(self.backgroundColor)
            self:drawAndSwapBuffer()
            sprite(backgroundBlankImage)
            backgroundClearCounter = backgroundClearCounter + 1
        end
        
        local deaths = {}
        self.critters.babies = {}
        self.critters.oldest = {}
        for _, critter in ipairs(self.critters.all) do
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, self.backgroundColor)
            -- if it did return a baby, tag it and store it
            if babyMaybe ~= nil then
                babyMaybe.id = critter.id
                table.insert(self.critters.babies, babyMaybe)
            end
            -- if creature has died, add index to the death table
            if critter.alive == false then
                table.insert(deaths, i)
            end
        end
        
        for i, index in ipairs(deaths) do
            table.remove(self.critters.all, index)
        end
        
        for _, baby in ipairs(self.critters.babies) do
            table.insert(self.critters.all, baby)
        end
        
        self.tickRate=self.tickRate*.9+.1/DeltaTime
        self.popTracker:update(#self.critters.all)
        local popAdjustment = self.popTracker:amountOverTarget(#self.critters.all, self.tickRate, 30, 2000)
        self:removeRandomCritters(popAdjustment)
        
        
        if CurrentTouch.state == BEGAN then
            for i, critter in pairs(self.critters.all) do
                critter.direction = vec2(math.random()-0.5, math.random()-0.5):normalize()
            end
        end
        
        popStyle()
    end
    field:draw()
end