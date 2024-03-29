
function showThumbnail(imageIntended)
    pushStyle()
    rectMode(CORNER)
    spriteMode(CORNER)
    fill(30, 26, 46)
    rect(WIDTH - (WIDTH/4) - 15, 50, (WIDTH/4) + 10, (HEIGHT/4) + 10)
    sprite(imageIntended, WIDTH - (WIDTH/4) - 10, 55, WIDTH/4, HEIGHT/4)
    popStyle()
end

function printRarely(...)
    if math.random() > 0.99 then
        print(table.unpack({...}))
    end   
end

function randomFromScreen(percent)
    local max = math.max(WIDTH, HEIGHT)
    local product = max * percent
    local integer = math.ceil(product * 10000000000)
    local random = math.random(integer)
    return random / 10000000000
end

function adjustFontSize(thisText, maxWidth)
    local size = 0
    while true do
        size = size + 1
        fontSize(size)
        local w, h = textSize(thisText)
        if w > maxWidth then
            size = size - 1
            fontSize(size)
            return size
        end
    end
end

function screenWrapping(point)
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

local function round(num, places)
    local xNum = num * (10^places)
    local rNum = xNum + (2^52 + 2^51) - (2^52 + 2^51)
    return rNum / (10^places)
end

function drawAxes()
    -- Draw x and y axes
    strokeWidth(2)
    line(50,50,50,HEIGHT)
    line(50,50,WIDTH,50)
    
    -- Draw tick marks on y-axis
    for i=0,35 do
        line(40,50+i*30,50,50+i*30)
    end
    
    -- Draw tick marks on x-axis
    for i=0,70 do
        line(50+i*30,40,50+i*30,50)
    end
end

function drawAxesWithTicks(interval)
    interval = interval or 100
    pushStyle()
    -- Draw the x-axis
    strokeWidth(2)
    stroke(224, 213, 138)
    line(50, 50, WIDTH - 50, 50)
    
    -- Draw the y-axis
    line(50, 50, 50, HEIGHT - 50)
    
    -- Draw tick marks on the x-axis
    for x = interval, WIDTH, interval do
        line(x, 50, x, 60)
    end
    
    -- Draw tick marks on the y-axis
    for y = interval, HEIGHT, interval do
        line(50, y, 60, y)
    end
    popStyle()
end

function drawVecTable(dots, radius)
    radius = radius or 4
    for _, dot in ipairs(dots) do
        ellipse(dot.x, dot.y, radius)
    end
end




--------= color stuff

function hueNumberFromColor(aColor)
    local h, _, _ = colorToHSB(aColor)
    return h / 360 -- Normalize to the range [0, 1]
end

-- Define color categories and their hue ranges
local colorCategories = {
    {name = "RedOrange", hueRange = {0.00, 0.14}, weightedHueRange = {0.00, 0.25}},
    {name = "Yellow", hueRange = {0.14, 0.17}, weightedHueRange = {0.25, 0.26}},
    {name = "Green", hueRange = {0.17, 0.46}, weightedHueRange = {0.26, 0.32}},
    {name = "Blue", hueRange = {0.46, 0.71}, weightedHueRange = {0.32, 0.62}},
    {name = "Purple", hueRange = {0.71, 0.81}, weightedHueRange = {0.62, 0.79}},
    {name = "PinkRed", hueRange = {0.81, 1.0}, weightedHueRange = {0.79, 1.0}}
}
--[[
local colorCategories = {
    {name = "Red", hueRange = {0.00, 0.05}, weightedHueRange = {0.00, 0.17}},
    {name = "Orange", hueRange = {0.12, 0.14}, weightedHueRange = {0.17, 0.34}},
    {name = "Yellow", hueRange = {0.23, 0.17}, weightedHueRange = {0.34, 0.51}},
    {name = "Green", hueRange = {0.33, 0.46}, weightedHueRange = {0.51, 0.52}},
    {name = "Blue", hueRange = {0.52, 0.75}, weightedHueRange = {0.52, 0.85}},
    {name = "Purple", hueRange = {0.75, 1.00}, weightedHueRange = {0.85, 1.0}}
}]]


function hueToWeightedHue(hue)
    -- Ensure hue is within the valid range [0, 1]
    hue = hue % 1.0

    -- Find the category corresponding to the input hue
    for _, category in ipairs(colorCategories) do
        if hue >= category.hueRange[1] and hue <= category.hueRange[2] then
            -- Calculate the percentage within the category's hue range
            local percentage = (hue - category.hueRange[1]) / (category.hueRange[2] - category.hueRange[1])

            -- Map the percentage to the corresponding weighted hue range
            local weightedHue = category.weightedHueRange[1] + percentage * (category.weightedHueRange[2] - category.weightedHueRange[1])

            return weightedHue
        end
    end

    return nil -- This should never happen if categories cover the entire range
end


-- Function to convert weighted hue back to hue
function weightedHueToHue(weightedHue)
    for _, category in ipairs(colorCategories) do
        if weightedHue >= category.weightedHueRange[1] and 
        weightedHue <= category.weightedHueRange[2] then
            local normalizedWeightedHue = 
                (weightedHue - category.weightedHueRange[1]) / 
                (category.weightedHueRange[2] - category.weightedHueRange[1])
            return normalizedWeightedHue * (category.hueRange[2] - 
                category.hueRange[1]) + category.hueRange[1]
        end
    end
    return nil -- This should never happen if categories cover the entire range
end

function weightedHueToHue(weightedHue)
    -- Ensure weightedHue is within the valid range [0, 1]
    weightedHue = weightedHue % 1.0

    -- Find the category corresponding to the input weightedHue
    for _, category in ipairs(colorCategories) do
        if weightedHue >= category.weightedHueRange[1] and 
        weightedHue <= category.weightedHueRange[2] then
            -- Calculate the percentage within the category's weighted hue range
            local percentage = (weightedHue - category.weightedHueRange[1]) / (category.weightedHueRange[2] - category.weightedHueRange[1])

            -- Map the percentage to the corresponding regular hue range
            local hue = category.hueRange[1] + percentage * (category.hueRange[2] - category.hueRange[1])

            return hue
        end
    end

    return nil -- This should never happen if categories cover the entire range
end


-- Function to generate a random color
function randomColor()
    -- Generate a random weighted hue
    local weightedHue = math.random()

    -- Convert the weighted hue to a regular hue
    local hue = weightedHueToHue(weightedHue)

    -- Convert the hue to the 0-360 range
    hue = hue * 360

    -- Generate random saturation and brightness values
    local saturation = math.random(58,100) * 0.01 --not too bright now!
    local brightness = math.random(62,100) * 0.01 --not too dark now!

    -- Return the new color
    return hsbToColor(hue, saturation, brightness)
end

function randomizeColorWithinVariance(aColor, variance)
    local hue, saturation, brightness = colorToHSB(aColor)
    hue = hue / 360 -- Convert to 0-1 range

    -- Convert the hue to a weighted hue
    local weightedHue = hueToWeightedHue(hue)

    -- Calculate the variance range in the weighted hue scale
    local minWeightedHue = math.max(weightedHue - variance, 0)
    local maxWeightedHue = math.min(weightedHue + variance, 1)

    -- Scale up the range to a larger number (e.g., 10000 for precision)
    local scale = 10000
    local minWeightedHueScaled = math.floor(minWeightedHue * scale)
    local maxWeightedHueScaled = math.ceil(maxWeightedHue * scale)

    -- Generate a random weighted hue within this range
    local randomWeightedHueScaled = math.random(minWeightedHueScaled, maxWeightedHueScaled)

    -- Scale the random weighted hue back down
    local randomWeightedHue = randomWeightedHueScaled / scale

    -- Convert the random weighted hue back to a regular hue
    local randomHue = weightedHueToHue(randomWeightedHue)

    -- Create color with random hue and input color's saturation and brightness
    return hsbToColor(randomHue * 360, saturation, brightness)
end


function colorToHSB(aColor)
    local r, g, b = aColor.r / 255, aColor.g / 255, aColor.b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local delta = max - min
    
    local hue = 0
    if delta ~= 0 then
        if max == r then
            hue = ((g - b) / delta) % 6
        elseif max == g then
            hue = ((b - r) / delta) + 2
        else
            hue = ((r - g) / delta) + 4
        end
        hue = hue * 60
        if hue < 0 then hue = hue + 360 end
    end
    
    local saturation = (max == 0) and 0 or (delta / max)
    
    local brightness = max
    
    return hue, saturation, brightness
end

function hsbToColor(h, s, b)
    h = h % 360
    s = math.max(0, math.min(1, s))
    b = math.max(0, math.min(1, b))
    
    local i = math.floor(h / 60)
    local f = (h / 60) - i
    local p = b * (1 - s)
    local q = b * (1 - (s * f))
    local t = b * (1 - (s * (1 - f)))
    
    local r1, g1, b1
    
    if i == 0 then
        r1, g1, b1 = b, t, p
    elseif i == 1 then
        r1, g1, b1 = q, b, p
    elseif i == 2 then
        r1, g1, b1 = p, b, t
    elseif i == 3 then
        r1, g1, b1 = p, q, b
    elseif i == 4 then
        r1, g1, b1 = t, p, b
    else
        r1, g1, b1 = b, p, q
    end
    
    return color(math.floor(r1 * 255), math.floor(g1 * 255), math.floor(b1 * 255))
end

-- Helper function to clamp a value within a range
function clamp(value, min, max)
    return math.min(max, math.max(min, value))
end

-- -- Function to generate a color copy with random variance
-- function randomizeColorWithinVariance(aColor, variance)
--     local h, s, b, a = colorToHSB(aColor)
    
--     -- Apply random variance to each component
--     local hShift = (math.random() * 2 - 1) * variance * 360 -- Hue ranges from 0 to 360
--     local sShift = (math.random() * 2 - 1) * variance      -- Saturation ranges from 0 to 1
--     local bShift = (math.random() * 2 - 1) * variance      -- Brightness ranges from 0 to 1
    
--     -- Clamp the new values to ensure they are within the valid range
--     local newH = clamp(h + hShift, 0, 360)
--     local newS = clamp(s + sShift, 0, 1)
--     local newB = clamp(b + bShift, 0, 1)
    
--     -- Convert back to a color
--     return hsbToColor(newH, newS, newB, a)
-- end

-- function randomHueInRange(value, variance)
--     local absVariance = math.abs(variance * 10000)
--     local lowerVariance = math.floor(-1 * absVariance)
--     local higherVariance = math.ceil(absVariance)
--     if lowerVariance == higherVariance then
--         return value
--     end
--     local rngRoll = math.random(lowerVariance, higherVariance)
--     local rawResult = (value * 100) + rngRoll
--     local fixedResult = rawResult / 10000
--     if rawResult < 0 then
--         fixedResult = 360 - math.abs(rawResult)
--     elseif rawResult > 360 then
--         fixedResult = rawResult - 360
--     end
--     return fixedResult
-- end

function testColorBlending(iterations, blendSteps)
    math.randomseed(os.time())  -- Ensure random seed
    
    local colors = {}
    for i = 1, iterations do
        local color1 = color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
        local color2 = color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
        
        for j = 1, blendSteps do
            local newColor = randomColorBetween(color1, color2)
            color1, color2 = color2, newColor
        end
        
        table.insert(colors, color2)
    end
    
    for i, col in ipairs(colors) do
        print("Color", i, ":", col)
    end
    
    local totalRed, totalGreen, totalBlue = 0, 0, 0
    
    for i, col in ipairs(colors) do
        print("Color", i, ":", col)
        totalRed = totalRed + col.r
        totalGreen = totalGreen + col.g
        totalBlue = totalBlue + col.b
    end
    
    local avgRed = totalRed / #colors
    local avgGreen = totalGreen / #colors
    local avgBlue = totalBlue / #colors
    
    print("Average color:", color(avgRed, avgGreen, avgBlue, 255))
end 

function weightedRandom(min, max, weight)
    local randomVal = math.random() * weight + math.random() * (1 - weight)
    return min + (max - min) * randomVal
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function randomColorBetween(color1, color2)
    local hsb1 = vec3(colorToHSB(color1))
    local hsb2 = vec3(colorToHSB(color2))
    
    local h1, h2 = hsb1.x, hsb2.x
    local s1, s2 = hsb1.y, hsb2.y
    local b1, b2 = hsb1.z, hsb2.z
    
    -- Generate random values for saturation and brightness within the range
    local newSat = math.random() * (s2 - s1) + s1
    local newBri = math.random() * (b2 - b1) + b1
    
    -- Calculate hue change within the range and wrap around
    local hueDiff = h2 - h1
    local newHue = (math.random() * hueDiff + h1) % 360
    
    return hsbToColor(newHue, newSat, newBri)
end

function randomColorAvoidingMuddinessBetween(color1, color2)
    local hsb1 = vec3(colorToHSB(color1))
    local hsb2 = vec3(colorToHSB(color2))

    local h1, h2 = hsb1.x, hsb2.x
    local s1, s2 = hsb1.y, hsb2.y
    local b1, b2 = hsb1.z, hsb2.z

    -- Calculate hue change within the range and wrap around
    local hueDiff = h2 - h1
    local hueChange = (math.random() * hueDiff + h1) % 360

    -- Generate random saturation and brightness within adjusted ranges
    local minSat = math.max(s1, s2) - 0.025
    local maxSat = math.min(s1, s2) + 0.1
    local newSat = randomFloat(minSat, maxSat)

    local minBri = math.max(b1, b2) - 0.025
    local maxBri = math.min(b1, b2) + 0.1
    local newBri = randomFloat(minBri, maxBri)

    return hsbToColor(hueChange, newSat, newBri)
end

function randomFloat(min, max)
    return min + math.random() * (max - min)
end

function sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

-- function colorsExceedVariance(color1, color2, variance)
--     local hue1 = hueFromColor(color1)
--     local hue2 = hueFromColor(color2)
    
--     local hueDiff = math.abs(hue1 - hue2)
--     if hueDiff > 180 then
--         hueDiff = 360 - hueDiff
--     end
    
--     local allowedVarianceScaled = 360 * variance --why not 360?
--     local matingAllowed = not (hueDiff > allowedVarianceScaled)
--    -- print("allowedVarianceScaled, hueDiff, matingAllowed ", allowedVarianceScaled, ", ", hueDiff, ", ", matingAllowed)
--     if hueDiff > allowedVarianceScaled then
--         return true
--     else
--         return false
--     end
-- end

function colorsExceedVariance(color1, color2, variance)
    
    if variance <= 0.0 or variance <= 0 then return true end
    
    local hue1 = hueFromColor(color1) / 360 -- Convert to 0-1 range
    local hue2 = hueFromColor(color2) / 360 -- Convert to 0-1 range
    
    -- Convert the hues to weighted hues
    local weightedHue1 = hueToWeightedHue(hue1)
    local weightedHue2 = hueToWeightedHue(hue2)

    local hueDiff = math.abs(weightedHue1 - weightedHue2)
    if hueDiff > 0.5 then
        hueDiff = 1 - hueDiff
    end

    local allowedVariance = variance -- No need to scale by 360 now
    local matingAllowed = not (hueDiff > allowedVariance)

    if hueDiff > allowedVariance then
        return true
    else
        return false
    end
end

-- function getHueDifference(color1, color2)
--     local hue1 = hueFromColor(color1)
--     local hue2 = hueFromColor(color2)
--     local difference = math.abs(hue1 - hue2)
--     if difference > 180 then
--         difference = 360 - difference
--     end
--     return difference
-- end

function hueFromColor(aColor)
    local r, g, b = aColor.r / 255, aColor.g / 255, aColor.b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    if delta == 0 then
        return 0
    elseif max == r then
        return ((g - b) / delta) % 6 * 60
    elseif max == g then
        return ((b - r) / delta + 2) * 60
    else
        return ((r - g) / delta + 4) * 60
    end
end

function saturationFromColor(aColor, rounding)
    local min = math.min(aColor.r, aColor.g, aColor.b) / 255
    local max = math.max(aColor.r, aColor.g, aColor.b) / 255
    local delta = max - min
    
    local saturation = 0.0
    if max ~= 0 then
        saturation = delta / max
    end
    if rounding then
        return round(saturation, rounding)
    else 
        return saturation
    end 
end

function brightnessFromColor(aColor, rounding)
    local max = math.max(aColor.r, aColor.g, aColor.b)
    local brightness = max / 255
    if rounding then
        return round(brightness, rounding)
    else 
        return brightness
    end 
end

function testHueFromColor()
    print("hue tests")
    print(hueFromColor(color(255, 0, 0)) == 0)
    print(hueFromColor(color(255, 255, 0)) == 60)
    print(hueFromColor(color(0, 255, 0)) == 120)
    print(hueFromColor(color(0, 255, 255)) == 180)
    print(hueFromColor(color(0, 0, 255)) == 240)
    print(hueFromColor(color(255, 0, 255)) == 300)
    print(hueFromColor(color(255, 255, 255)) == 0)
    print(hueFromColor(color(0, 0, 0)) == 0)
end

function testSaturationFromColor()
    print("saturation tests")
    local red = color(255, 0, 0)
    local green = color(0, 255, 0)
    local blue = color(0, 0, 255)
    local purple = color(77, 32, 96)
    local yellow = color(255, 255, 0)
    print(saturationFromColor(red) == 1) -- prints "true"
    print(saturationFromColor(color(202, 33, 33), 3) == 0.837) -- prints "true"
    print(saturationFromColor(color(139, 33, 33), 3) == 0.763) -- prints "true"
    print(saturationFromColor(color(87, 33, 33), 3) == 0.621) -- prints "true"
    print(saturationFromColor(green) == 1) -- prints "true"
    print(saturationFromColor(color(28, 204, 28), 3) == 0.863) -- prints "true"
    print(saturationFromColor(color(28, 153, 28), 3) == 0.817) -- prints "true"
    print(saturationFromColor(color(28, 102, 28), 3) == 0.725) -- prints "true"
    print(saturationFromColor(blue) == 1) -- prints "true"
    print(saturationFromColor(color(12, 12, 204), 3) == 0.941) -- prints "true"
    print(saturationFromColor(color(12, 12, 153), 3) == 0.922) -- prints "true"
    print(saturationFromColor(color(12, 12, 102), 3) == 0.882) -- prints "true"
    print(saturationFromColor(purple, 3) == 0.667) -- prints "true"
    print(saturationFromColor(color(120, 24, 180), 3) == 0.867) -- prints "true"
    print(saturationFromColor(color(80, 16, 120), 3) == 0.867) -- prints "true"
    print(saturationFromColor(color(40, 8, 60), 3) == 0.867) -- prints "true"
    print(saturationFromColor(yellow) == 1) -- prints "true"
    print(saturationFromColor(color(243, 243, 37), 3) == 0.848) -- prints "true"
    print(saturationFromColor(color(139, 139, 59), 3) == 0.576) -- prints "true"
    print(saturationFromColor(color(100, 100, 32), 3) == 0.68) -- prints "true"
end

function testBrightnessFromColor()
    print("brightness tests")
    local gray1 = color(30, 30, 30)
    local gray2 = color(80, 80, 80)
    local gray3 = color(130, 130, 130)
    local gray4 = color(180, 180, 180)
    local color1 = color(176, 34, 34)
    local color2 = color(120, 224, 120)
    local color3 = color(36, 22, 234)
    local color4 = color(234, 199, 26)
    
    print(brightnessFromColor(gray1, 2) == 0.12)
    print(brightnessFromColor(gray2, 2) == 0.31)
    print(brightnessFromColor(gray3, 2) == 0.51)
    print(brightnessFromColor(gray4, 2) == 0.71)
    print(brightnessFromColor(color1, 2) == 0.69)
    print(brightnessFromColor(color2, 2) == 0.88)
    print(brightnessFromColor(color3, 2) == 0.92)
    print(brightnessFromColor(color4, 2) == 0.92)
end

function testHSBtoRGB()
    print("hsbToColor tests")
    -- Test 1: black
    local black = color(0, 0, 0)
    local h, s, b = colorToHSB(black)
    local result = hsbToColor(h, s, b)
    assert(result.r == 0 and result.g == 0 and result.b == 0, "Test 1 failed")
    print(true)
    
    -- Test 2: white
    local white = color(255, 255, 255)
    h, s, b = colorToHSB(white)
    result = hsbToColor(h, s, b)
    assert(result.r == 255 and result.g == 255 and result.b == 255, "Test 2 failed")
    print(true)
    
    -- Test 3: red
    local red = color(255, 0, 0)
    h, s, b = colorToHSB(red)
    result = hsbToColor(h, s, b)
    assert(result.r == 255 and result.g == 0 and result.b == 0, "Test 3 failed")
    print(true)
    
    -- Test 4: green
    local green = color(0, 255, 0)
    h, s, b = colorToHSB(green)
    result = hsbToColor(h, s, b)
    assert(result.r == 0 and result.g == 255 and result.b == 0, "Test 4 failed")
    print(true)
    
    -- Test 5: blue
    local blue = color(0, 0, 255)
    h, s, b = colorToHSB(blue)
    result = hsbToColor(h, s, b)
    assert(result.r == 0 and result.g == 0 and result.b == 255, "Test 5 failed")
    print(true)
    
    -- Test 6: purple
    local purple = color(128, 0, 128)
    h, s, b = colorToHSB(purple)
    result = hsbToColor(h, s, b)
    assert(result.r == 128 and result.g == 0 and result.b == 128, "Test 6 failed")
    print(true)
    
    -- Test 7: yellow
    local yellow = color(255, 255, 0)
    h, s, b = colorToHSB(yellow)
    result = hsbToColor(h, s, b)
    assert(result.r == 255 and result.g == 255 and result.b == 0, "Test 7 failed")
    print(true)
    
    -- Test 8: cyan
    local cyan = color(0, 255, 255)
    h, s, b = colorToHSB(cyan)
    result = hsbToColor(h, s, b)
    assert(result.r == 0 and result.g == 255 and result.b == 255, "Test 8 failed")
    print(true)
    
    print("All HSB to RGB tests passed!")
end

