
--critters that aren't close in color won't mate
function Field:draw()
    -- scenario-specific creature settings
    function scenarioSettings(critter)
        --size range relative to width
        local sizeBase = math.max(WIDTH, HEIGHT) * 0.06
        critter.size = math.random(math.floor(sizeBase), math.floor(sizeBase * 2.8))
        --behaviors
        critter.speed = 27
        critter.mateColorVariance = 0.10
        critter.timeToFertility = math.random(60, 70)
        critter.mortality = math.random(70, 90)
        --colors
        self.backgroundColor = color(21, 21, 31)
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
        print(critter.id, ": ", diff)
    end    
    -- one-time setup
    if not isSetUp then
        isSetUp = true
        generations = 0
        showOutsidePoints = false
        showBufferThumbnail = false
        local startingPop = math.max(WIDTH, HEIGHT) * 0.05
        self:resetCritters(startingPop)
        for i, critter in ipairs(self.critters) do
            scenarioSettings(critter)
        end
    end   
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
    self:drawAndSwapBuffer()
end

