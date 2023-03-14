
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

--------= color stuff

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

function hsbToColor (h, s, b)
    local min, max, abs = math.min, math.max, math.abs
    local k1 = b*(1-s)
    local k2 = b - k1
    local R = min (max (3*abs (((h      )/180)%2-1)-1, 0), 1)
    local G = min (max (3*abs (((h  -120)/180)%2-1)-1, 0), 1)
    local B = min (max (3*abs (((h  +120)/180)%2-1)-1, 0), 1)
    return color(k1 + k2 * R, k1 + k2 * G, k1 + k2 * B)
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


function hueFromColor(color)
    local r, g, b = color.r / 255, color.g / 255, color.b / 255
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


function colorsExceedVarianceRGB(color1, color2, variance)
    local allowedVarianceScaled = 255 * variance
    local higherColor = {math.max(color1.r, color2.r), math.max(color1.g, color2.g), math.max(color1.b, color2.b)}
    local lowerColor = {math.min(color1.r, color2.r), math.min(color1.g, color2.g), math.min(color1.b, color2.b)}
    local actualVariance = {higherColor[1] - lowerColor[1], higherColor[2] - lowerColor[2], higherColor[3] - lowerColor[3]}
    if actualVariance[1] > allowedVarianceScaled or actualVariance[2] > allowedVarianceScaled or actualVariance[3] > allowedVarianceScaled then
        return true
    else
        return false
    end
end

--[[
function saturationBoost(aColor, decimalMinimum)
    decimalMinimum = decimalMinimum or 0.5
    local h, s, b = colorToHSB(aColor)
    if s > decimalMinimum then return aColor end
    local boostRange = math.floor((1 - decimalMinimum) * 100)
    if s < decimalMinimum then s = s + math.random(boostRange) * 0.01 end
    return hsbToColor(h, s, b)
end

function brightnessBoost(aColor, integerMinimum)
    minSaturation = minSaturation or 200
    local h, s, b = colorToHSB(aColor)
    if b > integerMinimum then return aColor end
    local boostRange = 255 - integerMinimum
    if b < integerMinimum then b = b + math.random(boostRange) end
    return hsbToColor(h, s, b)
end

function saturationFromColor(color)
    -- Convert RGB values to percentages
    local r = color.r / 255
    local g = color.g / 255
    local b = color.b / 255
    
    -- Find the minimum and maximum RGB values
    local min = math.min(r, g, b)
    local max = math.max(r, g, b)
    
    -- Calculate the difference between the minimum and maximum RGB values
    local delta = max - min
    
    -- Calculate the saturation
    local saturation = 0.0
    if max ~= 0 then
        saturation = delta / max
    end
    
    -- Print the intermediate results
    
    print("RGB values:", r, g, b)
    print("Minimum RGB value:", min)
    print("Maximum RGB value:", max)
    print("Delta:", delta)
    print("Saturation:", saturation)
    
    
    return delta
end

function saturationFromColor(aColor)
    
    r, g, b = aColor.r / 255, aColor.g / 255, aColor.b / 255
    
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l
    
    l = (max + min) / 2
    
    if max == min then
        h, s = 0, 0 -- achromatic
    else
        local d = max - min
        local s
        if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    print("RGB values:", r,g,b )
    print("Minimum RGB value:", min)
    print("Maximum RGB value:", max)
    print("l:", l)
    print("Saturation:", s)
    
    if true then return s or 1.0 end
    
    	local R = aColor.r / 255
    	local G = aColor.g / 255
    	local B = aColor.b / 255
    local max, min = math.max(R, G, B), math.min(R, G, B)
    	local l, s, h
    
    	-- Get luminance
    	l = (max + min) / 2
    
    	-- short circuit saturation and hue if it's grey to prevent divide by 0
    	if max == min then
        		s = 0
        		h = obj.h or obj[4] or 0
        		return s
    	end
    
    	-- Get saturation
    	if l <= 0.5 then s = (max - min) / (max + min)
    	else s = (max - min) / (2 - max - min)
    	end
    
    
    print("RGB values:", R, G, B)
    print("Minimum RGB value:", min)
    print("Maximum RGB value:", max)
    print("b:", l)
    print("Saturation:", s)
    
    
    	return s
end



function testSaturationFromColor()
    print("saturation tests")
    local red = color(255, 0, 0)
    local green = color(0, 255, 0)
    local blue = color(0, 0, 255)
    local purple = color(77, 32, 96)
    local yellow = color(255, 255, 0)
    print(colorToHSB(red) == 1) -- prints "true"
    local fullRed = colorToHSB(red)
    local darkerRed = colorToHSB(color(204, 0, 0))
    local darkerDarkerRed = colorToHSB(color(153, 0, 0))
    local darkestRed = colorToHSB(color(102, 0, 0))
    print(fullRed, fullRed == 1) -- prints "true"
    print(darkerRed, darkerRed == 0.8) -- prints "true"
    print(darkerDarkerRed, darkerDarkerRed == 0.6) -- prints "true"
    print(darkestRed, darkestRed == 0.4) -- prints "true"
    print(saturationFromColor(green) == 1) -- prints "true"
    print(saturationFromColor(color(0, 204, 0)), saturationFromColor(color(0, 204, 0)) == 0.8) -- prints "true"
    print(saturationFromColor(color(0, 153, 0)), saturationFromColor(color(0, 153, 0)) == 0.6) -- prints "true"
    print(saturationFromColor(color(0, 102, 0)), saturationFromColor(color(0, 102, 0)) == 0.4) -- prints "true"
    print(saturationFromColor(blue) == 1) -- prints "true"
    print(saturationFromColor(color(0, 0, 204)) == 0.8) -- prints "true"
    print(saturationFromColor(color(0, 0, 153)) == 0.6) -- prints "true"
    print(saturationFromColor(color(0, 0, 102)) == 0.4) -- prints "true"
    print("purple, ",saturationFromColor(purple), saturationFromColor(purple) == 0.94) -- prints "true"
    print(saturationFromColor(color(120, 24, 180)), saturationFromColor(color(120, 24, 180)) == 0.7109375) -- prints "true"
    print(saturationFromColor(color(80, 16, 120)), saturationFromColor(color(80, 16, 120)) == 0.7109375) -- prints "true"
    print(saturationFromColor(color(40, 8, 60)) == 0.7109375) -- prints "true"
    print(saturationFromColor(yellow) == 1) -- prints "true"
    print(saturationFromColor(color(204, 204, 0)) == 0.8) -- prints "true"
    print(saturationFromColor(color(153, 153, 0)) == 0.6) -- prints "true"
    print(saturationFromColor(color(102, 102, 0)) == 0.4) -- prints "true"
    local randomColor = color(math.random(255), math.random(255), math.random(255))
    print(saturationFromColor(randomColor)) -- prints saturation of the random color
    print(randomColor) -- prints the RGB values of the random color
end


]]