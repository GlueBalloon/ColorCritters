
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

--------= color stuff

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



function randomizeColorWithinVariance(aColor, variance, bias)
    local hsb = vec3(colorToHSB(aColor))
    local varianceScaled = 360 * variance
    local h = randomHueInRange(hsb.x, varianceScaled)
    return hsbToColor(h, hsb.y, hsb.z)
end

function randomHueInRange(value, variance)
    local absVariance = math.abs(variance * 10000)
    local lowerVariance = math.floor(-1 * absVariance)
    local higherVariance = math.ceil(absVariance)
    if lowerVariance == higherVariance then
        return value
    end
    local rngRoll = math.random(lowerVariance, higherVariance)
    local rawResult = (value * 100) + rngRoll
    local fixedResult = rawResult / 10000
    if rawResult < 0 then
        fixedResult = 360 - math.abs(rawResult)
    elseif rawResult > 360 then
        fixedResult = rawResult - 360
    end
    return fixedResult
end

function randomColorBetween(color1, color2)
    local r1, g1, b1 = color1.r, color1.g, color1.b
    local r2, g2, b2 = color2.r, color2.g, color2.b
    
    local r = math.random() * 255 * (r2 - r1) + r1
    local g = math.random() * 255 * (g2 - g1) + g1
    local b = math.random() * 255 * (b2 - b1) + b1
    
    return color(r, g, b)
end

function colorsExceedVariance(color1, color2, variance)
    local hue1 = hueFromColor(color1)
    local hue2 = hueFromColor(color2)
    
    local hueDiff = math.abs(hue1 - hue2)
    if hueDiff > 180 then
        hueDiff = 360 - hueDiff
    end
    
    local allowedVarianceScaled = 36 * (1 - variance) --why not 360?
    local matingAllowed = not (hueDiff > allowedVarianceScaled)
    --print("allowedVarianceScaled, hueDiff, matingAllowed ", allowedVarianceScaled, hueDiff, matingAllowed)
    if hueDiff > allowedVarianceScaled then
        return true
    else
        return false
    end
end

function getHueDifference(color1, color2)
    local hue1 = hueFromColor(color1)
    local hue2 = hueFromColor(color2)
    local difference = math.abs(hue1 - hue2)
    if difference > 180 then
        difference = 360 - difference
    end
    return difference
end

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
