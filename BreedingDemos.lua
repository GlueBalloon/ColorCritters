--any critter will mate with any other critter
function BasicMating()
    function Field:draw()
        self:drawAndSwapBuffer()
        if not self.isCustomSetup then
            local startingPop = math.max(WIDTH, HEIGHT) * 0.02
            self:resetCritters(startingPop)
            self.drawer.backgroundColor = color(106, 38, 122)
            for _, critter in ipairs(self.critters.all) do
                critter.size = math.max(WIDTH, HEIGHT) * 0.09
                critter.speed = math.random(8, 16)
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
        
        self.tickRate=self.tickRate*.9+.1/DeltaTime
        if #self.critters.all > 700 or self.tickRate < 15 then
            self.isCustomSetup = false
        end
        local babies = {}
        for _, critter in ipairs(self.critters.all) do
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, color(0, 0))
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
            self.drawer.backgroundColor = color(34, 34, 91)
            respawn()
        end
        
        setContext(self.drawer.buffer)
        
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
            if colorAtPoint == color(0,0) or
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
            local sizeBase = math.max(WIDTH, HEIGHT) * 0.04
            critter.size = math.random(math.floor(sizeBase), math.floor(sizeBase * 2.8))
            --behaviors
            critter.speed = 15
            critter.mateColorVariance = 0.09
            critter.timeToFertility = math.random(10, 24)
            critter.mortality = math.random(25, 40)
            --colors
            self.drawer.backgroundColor = color(61, 39, 82)
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

        -- go through the critters
        for i, critter in ipairs(self.critters.all) do  
            
            -- track which 'species' this critter is        
            if critter.id == "y" then
                yellowCritterCount = yellowCritterCount + 1
            elseif critter.id == "b" then
                blueCritterCount = blueCritterCount + 1
            end 
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, color(0, 0))
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
        
        if not blueGone and not yellowGone then
            for _, baby in ipairs(babies) do
                table.insert(self.critters.all, baby)
            end
            for index=#deaths, 1, -1 do
              --  table.remove(self.critters.all, index)
            end
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
        blueGone, yellowGone = blueCritterCount == 0, yellowCritterCount == 0
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
        
        --short-circuit population booms
        if #self.critters.all > 2000 then
            self.isCustomSetup = false
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
            new.speed = math.random(8, 18)
            new.timeToFertility = math.random(60, 110)
            new.mateColorVariance = 0.6
            new.mortality = new.timeToFertility * math.random(40, 50) * 0.1
            new.position = pos or new.position
            table.insert(self.critters.all, new)
        end
        function respawn()
            local startingPop = math.max(WIDTH, HEIGHT) * 0.2
            self.critters.all = {}
            for i = 1, startingPop do
                newCritter()
            end
        end
        if not self.isCustomSetup then
            self.isCustomSetup = true
            self.drawer.backgroundColor = color(43, 26, 25)
            respawn()
        end
        
        self:drawAndSwapBuffer()
        setContext(self.drawer.buffer)
        
        local deaths = {}
        local babies = {}
        for _, critter in ipairs(self.critters.all) do
            
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, color(0, 0))

            -- if it did return a baby, tag it and store it
            if babyMaybe ~= nil then
                babyMaybe.id = critter.id
                table.insert(babies, babyMaybe)
            end
            -- if creature has died, add index to the death table
            if critter.alive == false then
                table.insert(deaths, critter)
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
    --choose from three slightly different critter settings
    local sensoryRange, matingVariance, sizeRange, speedFactor, fertilityRange
    local behaviorSetting = math.random(3)
    if behaviorSetting == 1 then
        --note: a range of 1 lets critters asexually reproduce
        --essentially mating with their own anti-aliasing pixels
        sensoryRange = {min = 1, max = 3}
        matingVariance = 0.19
        sizeRange = {min = 8, max = math.ceil(math.max(WIDTH, HEIGHT) * 0.029)}
        speedFactor = 0.015
        fertilityRange = {min = 120, max = 180}
    elseif behaviorSetting == 2 then
        --note: q range of 1 lets critters asexually reproduce
        --essentially mating with their own anti-aliasing pixels
        sensoryRange = {min = 1, max = 3}
        matingVariance = 0.05
        sizeRange = {min = 8, max = math.ceil(math.max(WIDTH, HEIGHT) * 0.04)}
        speedFactor = 0.02
        fertilityRange = {min = 100, max = 190}
    else
        sensoryRange = {min = 5, max = 7}
        matingVariance = 0.37
        sizeRange = {min = 8, max = math.ceil(math.max(WIDTH, HEIGHT) * 0.024)}
        speedFactor = 0.027
        fertilityRange = {min = 120, max = 140}
    end
    function Field:draw()
        if cycleBackgroundColors then
            -- Initialize variables
            local countUntilStarting = 3
            local rateOfChange = 0.2
            
            -- Update the time
            self.time = self.time + DeltaTime
            
            -- Check if the delay period has passed
            if self.time > countUntilStarting then
                
                -- Start the color change
                if not self.colorChangeStarted then
                    -- Calculate the offset based on the current background color
                    self.rOffset = math.asin((self.drawer.backgroundColor.r - 128) / 127)
                    self.gOffset = math.asin((self.drawer.backgroundColor.g - 128) / 127)
                    self.bOffset = math.asin((self.drawer.backgroundColor.b - 128) / 127)
                    
                    -- Mark the color change as started
                    self.colorChangeStarted = true
                end
                
                -- Calculate the time since the color change started
                local adjustedTime = self.time - countUntilStarting
                
                -- Calculate the new background color using the offset
                local r = math.sin(adjustedTime * rateOfChange + self.rOffset) * 127 + 128
                local g = math.sin(adjustedTime * rateOfChange * 2 + self.gOffset) * 127 + 128
                local b = math.sin(adjustedTime * rateOfChange * 3 + self.bOffset) * 127 + 128
                self.drawer.backgroundColor = color(r, g, b)
            end
        end

        --functions for spawning custom critters
        function newCritter(pos)
            --NOTE:
            local new = ColorCritter()
            new.sensoryRange = sensoryRange
            new.mateColorVariance = matingVariance
            new.size = math.random(sizeRange.min, sizeRange.max)
            new.speed = new.size * speedFactor
            new.timeToFertility = math.random(fertilityRange.min, fertilityRange.max)
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
            self.drawer.backgroundColor = color(25, 19, 27)
            respawn()
            parameter.clear()
            parameter.watch("tickRate")
            parameter.watch("pop")
            parameter.watch("numDeaths")
            parameter.watch("#field.critters.babies")
            parameter.watch("averageCritterSize")
            parameter.watch("medianCritterSize")
            parameter.boolean("cycleBackgroundColors", true)
        end
        
        --basic draw cycle prep
        pushStyle()
        noStroke()
        
        --draw buffer then set context to new buffer
        self:drawAndSwapBuffer()   
        
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
            local babyMaybe = critter:draw(self.drawer.lastBuffer, color(0, 0))
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
        
        
        --update population tracking
        self.popTracker:update(#self.critters.all)
        pop = #self.critters.all
        
        --check tickRate
        self.tickRate=self.tickRate*.9+.1/DeltaTime
        tickRate = self.tickRate --<--for tracking in parameter pane
        
        --if rate is too low, prevent births
        if self.tickRate < self.tickRateTarget then
            self.critters.babies = {}
        else
            --otherwise add in any babies
            for _, baby in ipairs(self.critters.babies) do
                table.insert(self.critters.all, baby) 
            end
        end
            
        -- count backwards through critters and remove any with alive = false
        numDeaths = 0
        for i = #self.critters.all, 1, -1 do
            if self.critters.all[i].alive == false then
                table.remove(self.critters.all, i)
                numDeaths = numDeaths + 1
            end
        end

        --average the size of all critters
        local totalSize = 0
        for _, critter in ipairs(self.critters.all) do
            totalSize = totalSize + critter.size
        end
        averageCritterSize = totalSize / #self.critters.all
        
        --get median and average size of all critters
        local sizes = {}
        for _, critter in ipairs(self.critters.all) do
            table.insert(sizes, critter.size)
        end
        table.sort(sizes)
        medianCritterSize = sizes[math.ceil(#sizes/2)]
        averageCritterSize = 0
        for _, size in ipairs(sizes) do
            averageCritterSize = averageCritterSize + size
        end
        averageCritterSize = averageCritterSize / #sizes
        
        popStyle()
        
        -- clear everything and start over if touched
        if CurrentTouch.state == BEGAN then
            isSetUp = false
        end
        
        -- clear everything and start over if touched
        if CurrentTouch.state == BEGAN then
            isSetUp = false
        end
    
    end
    field:draw()
end


--just like the streakers demo except the critters multiply
function WigglyStreakers()

    function Field:draw()
        
        function newCritter(pos)
            local new = ColorCritter()
            new.mateColorVariance = 1
            new.size = math.random(10, 42)
            new.speed = math.random(1, 9)
            new.timeToFertility = 0
            new.mortality = 80 * math.random(11, 50) * 0.1
            new.position = pos or new.position
            new.mutationRate = 1
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
            self.drawer.backgroundColor = color(43, 26, 25)
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
            background(self.drawer.backgroundColor)
            self:drawAndSwapBuffer()
            sprite(backgroundBlankImage)
            backgroundClearCounter = backgroundClearCounter + 1
        end
        
        local deaths = {}
        self.critters.babies = {}
        self.critters.oldest = {}
        for _, critter in ipairs(self.critters.all) do
            -- Calculate new position based on direction and speed
            local newPosition = critter.position + critter.direction * critter.speed 
            local oldDirection = critter.direction
            -- Wrap around the edges if the new position is out of bounds
            newPosition = self:wrapIfNeeded(newPosition)
            -- force critter position
            critter.position = newPosition
            -- call critter's own draw function, which may return a baby
            local babyMaybe = critter:draw(self.drawer.lastBuffer, color(0,0))
            critter.direction = oldDirection
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