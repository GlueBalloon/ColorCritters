
    

-- define constants
local SCREEN_WIDTH = WIDTH
local SCREEN_HEIGHT = HEIGHT
local NUM_CREATURES = 180
local MUTATION_RATE = 0.01
local FIELD_COLOR = color(91, 83, 140)
local FERTILITY_WAIT = 200
local BODYRADIUS = 10

-- define Creature class
Creature = class()

function Creature:init(x, y, color)
    self.position = vec2(x, y)
    self.color = color
    self.fertilityTimer = 0
    self.reproductionTrigger = 160
    self.strength = 90
end

function Creature:colorsWithinTolerance(color1, color2, tolerance)
    local variance = self:variance(color1, color2)
    local withinTolerance = variance < tolerance    
    return withinTolerance
end

function Creature:colorComponents(thisColor)
    return thisColor.r, thisColor.g, thisColor.b, thisColor.a
end

function Creature:totalColorVariance(color1, color2)
    local r1, g1, b1, a1 = self:colorComponents(color1)
    local r2, g2, b2, a2 = self:colorComponents(color2)
    return math.abs(r1 - r2) + math.abs(g1 - g2) + math.abs(b1 - b2) + math.abs(a1 - a2)
end

function Creature:rollForSurvival(variance, strength)
    if strength > variance then return end
    local survival, chanceOfDeath, diceRoll = true, 0, 0
    local damageDone = variance - strength
    if damageDone > 0 then
        chanceOfDeath = damageDone / strength
        diceRoll = math.random()
        survival = diceRoll > chanceOfDeath
    end
    if math.random() > 0.999 then
        print("\nfight fight fight")
        print("variance and strength:")
        print(variance, ", ", strength)
        print("damage and chanceOfDeath:")
        print(damageDone, ", ", chanceOfDeath)
        print("diceRoll and survival:")
        print(diceRoll, ", ", survival)
        print("-------")
    end
    return survival
end

function Creature:shouldFight(color1, color2)
    local hsb1 = vec3(colorToHSB(color1))
    local hsb2 = vec3(colorToHSB(color2))
    local variance = self:variance(hsb1, hsb2)
    local saturationTest, brightTest = false, false
    if math.abs(hsb1.y - hsb2.y) > 0.02 then
        saturationTest = true
    end
    if math.abs(hsb1.z - hsb2.z) > 6 then
        brightTest = true
    end
    local verdict = ((saturationTest or brightTest) or variance > self.strength)
    return verdict, variance
end

function Creature:variance(hsb1, hsb2)
    local angle = math.abs(hsb1.x - hsb2.x)
    if angle > 180 then
        angle = 360 - angle
    end
    return angle
end


function Creature:moveOrReproduceOrDie(screenImage)
    local move, reproduce, die = nil, nil, nil
    for i=1, 5 do
        local point, direction, pointColor = colorOnImageInRandomDirection(screenImage, self.position, BODYRADIUS)
        if not move then
            if pointColor == FIELD_COLOR then
                move = direction 
            else
                move = reverseDirection(direction)
            end
        end
        if not reproduce then
            --check for similar-enough colors for reproducing
            if self:colorsWithinTolerance(self.color, pointColor, self.reproductionTrigger) then
                if self.fertilityTimer > FERTILITY_WAIT then 
                    reproduce = true 
                end
            end
        end
        if not die then
            --check for color variance higher than strength
            local verdict, variance = self:shouldFight(self.color, pointColor)
            if verdict == true then
                local survival = self:rollForSurvival(variance, self.strength)
                die = survival == false
            end
        end      
    end    
    return move, reproduce, die
end

function getRandomPointInRadius(pt, img, radius)
    local direction = vec2(math.random(-100, 100)/100, math.random(-100, 100)/100)
    local dest = pt + direction * radius
    while not img:contains(dest.x, dest.y) do
        direction = vec2(math.random(-100, 100)/100, math.random(-100, 100)/100)
        dest = pt + direction * radius
    end
    local color = img:get(dest.x, dest.y)
    return dest, color, direction
end

function Creature:adjustColor(ogColor, maxChange)
    local r, g, b = ogColor.r, ogColor.g, ogColor.b
    local deltaR, deltaG, deltaB = math.random(-maxChange, maxChange), math.random(-maxChange, maxChange), math.random(-maxChange, maxChange)
    r = math.max(0, math.min(255, r + deltaR))
    g = math.max(0, math.min(255, g + deltaG))
    b = math.max(0, math.min(255, b + deltaB))
    return color(r, g, b)
end


function Creature:mutate(color, maxChange)
    local r, g, b = color.r, color.g, color.b
    local deltaR, deltaG, deltaB = math.random(-maxChange, maxChange), math.random(-maxChange, maxChange), math.random(-maxChange, maxChange)
    r = math.max(0, math.min(255, r + deltaR))
    g = math.max(0, math.min(255, g + deltaG))
    b = math.max(0, math.min(255, b + deltaB))
    return color(r, g, b)
end

function Creature:reproduce()
    local newColor, repro, strength = self.color, self.reproductionTrigger, self.strength
    if math.random() < MUTATION_RATE then
        newColor = self:adjustColor(self.color, 4)
        repro = math.abs(self.reproductionTrigger + (math.random(-5, 5)))
        strength = math.abs(self.strength + (math.random(-5, 5)))
    end
    local newPosition = self:randomOffsetByRadius(self.position, BODYRADIUS)
    local newCritter = Creature(newPosition.x, newPosition.y, newColor)
    newCritter.reproductionTrigger = repro
    newCritter.strength = strength
    return newCritter
end

function Creature:colorOrNilAt(x, y, theImage)
    if x > WIDTH or x <= 0 then return nil end
    if y > HEIGHT or y <= 0 then return nil end
    return color(theImage:get(x,y))
end

function Creature:randomOffsetByRadius(position, radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * radius
    local offset = vec2(distance * math.cos(angle), distance * math.sin(angle))
    return position + offset
end

function Creature:die(die)
    if die == false then return end
end


-- define Evolution class
Evolution = class()

function Evolution:init()
    self.moveCounter = 0
    self.creatures = self:newGeneration()
end


function Evolution:newGeneration()
    local generation = {}
    for i = 1, NUM_CREATURES do
        local x = math.random(SCREEN_WIDTH)
        local y = math.random(SCREEN_HEIGHT)
        local color = color(math.random(255), math.random(255), math.random(255))
        table.insert(generation, Creature(x, y, color))
    end
    return generation
end

function Evolution:nextGeneration()
    local newGeneration = {}
    if self.moveCounter == 4 then self.moveCounter = 0 end
    self.moveCounter = self.moveCounter + 1
    for i, creature in ipairs(self.creatures) do
        if false then
            local point, direction, pointColor = colorOnImageInRandomDirection(screenImage, creature.position, BODYRADIUS)
            creature.position = point
            table.insert(newGeneration, creature) 
        else
            local move, reproduce, die = creature:moveOrReproduceOrDie(screenImage)
            if move then 
                if self.moveCounter == 4 then
                    creature.position = pointOnImageInDirectionAtRadius(screenImage, move, 3, creature.position) 
                end
            end
            if reproduce then creature:reproduce() end
            creature:reproduce()
            if die then
                setContext(screenImage)
                fill(83, 79, 104)
                ellipse(creature.position.x, creature.position.y, BODYRADIUS * 2.1)
                setContext()
            else
                table.insert(newGeneration, creature)
            end
        end
    end
    self.creatures = newGeneration
end

function Evolution:drawGeneration()
    for i, creature in ipairs(self.creatures) do
        fill(creature.color)
        ellipse(creature.position.x, creature.position.y, BODYRADIUS * 2)
    end
end

-- define main function
function setup()
    screenImage = image(WIDTH, HEIGHT)
    setContext(screenImage)
    background(FIELD_COLOR)
    setContext()
    ev = Evolution()
end

function draw()
    sprite(screenImage, WIDTH/2, HEIGHT/2)
    ev:drawGeneration()
    ev:nextGeneration()
end

function colorToHSB(c)
    local r, g, b = c.r, c.g, c.b
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h, s, v = 0, 0, max
    
    if max ~= 0 then
        s = delta / max
        if r == max then
            h = (g - b) / delta
        elseif g == max then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h * 60
        if h < 0 then
            h = h + 360
        end
    end
    
    return h, s, v
end

function pointOnImageInDirectionAtRadius(image, direction, radius, origin)
    local p = origin + direction * radius
    local x = math.floor(p.x) % (image.width) + 1
    local y = math.floor(p.y) % (image.height) + 1
    return vec2(x, y)
end

-- Returns a vec2 representing a random direction
function randomDirection()
    return vec2(math.random() * 2 - 1, math.random() * 2 - 1):normalize()
end

-- Finds the point in a random direction and returns the point, direction, and color at that point
function colorOnImageInRandomDirection(image, origin, radius)
    local direction = randomDirection()
    local point = pointOnImageInDirectionAtRadius(image, direction, radius, origin)
    local color = color(image:get(point.x, point.y))
    return point, direction, color
end


function reverseDirection(direction)
    return vec2(-direction.x, -direction.y)
end

