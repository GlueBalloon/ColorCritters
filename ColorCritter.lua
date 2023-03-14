ColorCritter = class()

function ColorCritter:init(size, speed, strength, aColor, 
    aggression, position, direction, timeToFertility, 
    mateColorVariance, mortality)
    self.size = size or math.random(5, 30)
    self.speed = speed or math.random(2, 8)
    self.strength = strength or math.random(1, 5)
    self.color = aColor or color(math.random(0,255), math.random(0,255), math.random(0,255))
  --  self.color = aColor or hsbToColor(math.random(360),  math.random(), math.random())
    self.aggression = aggression or math.random(0, 1000) * 0.001
    self.position = position or vec2(math.random(WIDTH), math.random(HEIGHT))
    self.direction = direction or vec2(math.random()-0.5, math.random()-0.5):normalize()
    self.timeToFertility = timeToFertility or math.random(300, 400)
    self.mateColorVariance = mateColorVariance or math.random(10000) * 0.0001
    self.fertilityCounter = 0
    self.age = 0
    self.mortality = mortality or math.random(200, 50000)
    self.hsbColor = colorToHSB(self.color)
    self.alive = true
end

function ColorCritter:update(backgroundImage, backgroundColor)
    -- age and die if mortality reached
    if self:ageAndCheckMortality() == false then return end
    -- get next movement, child if any, and notice of death if killed
    local move, breed, die = self:moveBreedDie(backgroundImage, backgroundColor)
    -- update position
    self.position = move
    --return child if any
    return breed
end

function ColorCritter:draw(backgroundImage, backgroundColor)
    -- don't draw if dead! lol
    if self.alive == false then return end
    -- update self (may return baby)
    local babyMaybe = self:update(backgroundImage, backgroundColor)
    -- draw self if still alive
    if self.alive then
        fill(self.color)
        ellipse(self.position.x, self.position.y, self.size)  
    end
    -- return possible baby
    return babyMaybe
end

function ColorCritter:moveBreedDie(backgroundImage, backgroundColor)
    -- initialize variables
    local move, breed, die = self.position, nil, false
    -- pick a random direction and get perimeter point and color information at point
    local outsidePoint, outsideDirection, pointColor = self:sampleRandomPoint(backgroundImage, backgroundColor)
    -- was something there?
    local foundSomething = pointColor ~= backgroundColor
    -- get where to move
    move = self:getNextPosition(foundSomething, outsideDirection)
    -- attempt reproduction if anything was found
    if foundSomething then
        breed = self:checkForReproduction(pointColor)
    end
    -- combat not implemented yet
    -- at some point "die" will be set here
    return move, breed, die
end

function ColorCritter:checkForReproduction(pointColor)
    --check if fertile
    if self.fertilityCounter >= self.timeToFertility then
        --check if mate's color is within mateColorVariance
        local incompatible = colorsExceedVariance(self.color, pointColor, 
            self.mateColorVariance)
        if not incompatible then
            --if all is good, birth a child and return it
            return self:reproduce(pointColor)
        end
    end
end

function ColorCritter:sampleRandomPoint(backgroundImage, backgroundColor)
    -- Find a point outside the critter
    local outsidePoint = self:pointOutsideSelf()     
    -- find direction to that point
    local outsideDirection = (outsidePoint - self.position):normalize()
    -- get color at chosen point
    local pointColor = self:colorAtPoint(outsidePoint, backgroundImage)  
    -- send back findings
    return outsidePoint, outsideDirection, pointColor
end

function ColorCritter:getNextPosition(foundSomething, outsideDirection)
    --put a little variance in speed
    local randomizedSpeed = math.random(self.speed)
    --calculate new position 
    local nextPosition = self.position + outsideDirection * randomizedSpeed
    --wrap it if needed
    nextPosition = screenWrapping(nextPosition)   
    -- check if something was detected 
    if foundSomething == false then
        --if nothing of note, store new direction
        self.direction = outsideDirection
    else
        -- if something detected, get original destination (prevents huddling)
        local recalculated = self.position + self.direction * self.speed
        --wrap it if needed
        nextPosition = screenWrapping(recalculated)
    end
    -- return value
    return nextPosition
end

function ColorCritter:colorAtPoint(pointToSample, imageToSampleFrom)
    -- Make the point's x and y into non-zero integers inside bounds
    local pointInBounds = screenWrapping(pointToSample)
    -- ensure that x, y values are integers
    local safeX, safeY = math.floor(pointInBounds.x), math.floor(pointInBounds.y)
    -- ensure that x, y values are in bounds
    safeX = math.min(imageToSampleFrom.width, math.max(1, safeX))
    safeY = math.min(imageToSampleFrom.height, math.max(1, safeY))
    -- sample the image at that point
    local colorAtPoint = color(imageToSampleFrom:get(safeX, safeY))
    return colorAtPoint
end

function ColorCritter:ageAndCheckMortality()
    self.age = self.age + 1
    self.fertilityCounter = self.fertilityCounter + 1
    if self.age >= self.mortality then
        self.alive = false
        return false
    end
    return true
end

function ColorCritter:pointOutsideSelf()
    local center, radius = self.position, (self.size / 2) + math.random(5)
    local angle = math.random() * math.pi * 2
    local x = center.x + radius * math.cos(angle)
    local y = center.y + radius * math.sin(angle)
    return vec2(x, y)
end

function ColorCritter:directionTowardsPoint(point)
    return (point - self.position):normalize()
end

function ColorCritter:reproduce(mateColor)
    
    local mutationRate = 0.0025 -- chance of mutation
    local babyColor = self.color
    if mateColor then
        --babyColor = randomColorBetween(babyColor, mateColor)
        --[[
        print("me: ", self.color)
        print("them: ", mateColor)
        print("baby: ", babyColor)
        print("-----")
        ]]
    end
    -- Create a new critter with the same properties
    local baby = ColorCritter(
        self.size, self.speed, self.strength, 
        babyColor, self.aggression, self.position, self.direction, 
        self.timeToFertility, self.mateColorVariance, 
        self.mortality
    )

    -- Apply mutations if they occur
    if math.random() < mutationRate then
        baby.mateColorVariance = math.max(0.0, math.min(1, self.mateColorVariance + (math.random(-5,5) * 0.001)))
        -- baby.mateColorVariance = 1.0
        printRarely("mutation at "..tostring(self.position).."\n.  mateColorVariance: "..tostring(baby.mateColorVariance))
        local hsbH, hsbS, hsbB = colorToHSB(baby.color)
        local newH = randomHueInRange(hsbH, math.min(1, self.mateColorVariance + (math.random(-5,5) * 0.001)))
        baby.color = hsbToColor(newH, hsbS, hsbB)
        baby.color = randomizeColorWithinVariance(self.color, math.min(1, self.mateColorVariance + (math.random(-5,5) * 0.001)))
        baby.hsbColor = colorToHSB(baby.color)
        baby.speed = math.max(0.1, math.min(40, self.speed + math.random(-math.floor(self.speed/5), math.floor(self.speed/5))))
        baby.aggression = math.max(0, math.min(100, self.aggression + math.random(-3, 3)))
        baby.strength = math.max(0, math.min(100, self.strength + math.random(-6, 6)))
        baby.size = math.max(1, math.min(50, self.size + math.random(-math.floor(self.size/2), math.floor(self.size/2))))
        baby.mortality = self.mortality + math.random(-5, 5)
        baby.timeToFertility = math.max(baby.mortality * 0.05, math.min(baby.mortality * 0.9, self.timeToFertility + math.random(-8, 8)))
    end
    
    -- Place the new critter at a random point on its perimeter
    local angle = math.random() * 2 * math.pi
    local radius = self.size + baby.size
    local offset = vec2(radius * math.cos(angle), radius * math.sin(angle))
    baby.position = self.position + offset
    
    -- Reset the fertility counter
    self.fertilityCounter = 0
    
    return baby
end
