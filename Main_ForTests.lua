


--[[ ****

Only for testing. To see, move tab to right of Main tab.

-- **** ]]




ccTests = {}

function setup()
    ccTests.leftColor = color(0, 0, 255) -- blue
    ccTests.rightColor = color(255, 255, 0) -- yellow
    ccTests.randomizeColors()
    ccTests.screenGrab = image(WIDTH, HEIGHT)
    ccTests.variance = 0.4
    fontSize(30)
    textMode(CENTER)
end

function draw()
    setContext(ccTests.screenGrab)
    -- Draw left box in left color
    rectMode(CORNER)
    fill(ccTests.leftColor)
    rect(0, 0, WIDTH / 2, HEIGHT)
    
    -- Draw right box in right color
    fill(ccTests.rightColor)
    rect(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
    
    -- Draw middle box in center color
    fill(ccTests.centerColor)
    rect(WIDTH/4, HEIGHT/4, WIDTH/2, HEIGHT/2)
    setContext()
    sprite(ccTests.screenGrab, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
    
    
    fill(ccTests.centerColor)
    
    text("running from 'Main_WithTests' tab", WIDTH/2, HEIGHT - 60)
end

function touched(touch)
    if touch.state == BEGAN then
        --  on touch down print the color touched and report variance
        print(color(ccTests.screenGrab:get(math.floor(touch.x), math.floor(touch.y))))
        local areDifferent = colorsExceedVariance(ccTests.leftColor, ccTests.rightColor, ccTests.variance)
        print("Left and right colors exceed variance: ", areDifferent)
    elseif touch.state == ENDED then
        -- on touch up change colors
        ccTests.randomizeColors()
    end 
end

function ccTests.randomizeColors()
    --[[
    ccTests.leftColor = color(math.random(255), math.random(255), math.random(255))
    ccTests.rightColor = color(math.random(255), math.random(255), math.random(255))
    ccTests.leftColor = color(0, 0, 255) -- blue
    ccTests.rightColor = color(255, 255, 0) -- yellow
    ]]
    ccTests.centerColor = randomColorBetween(ccTests.leftColor, ccTests.rightColor)
end

function drawFullCurve()
    pushStyle()
    stroke(100, 233, 80)
    fill(102, 233, 80)
    maxWidth = WIDTH
    maxHeight = HEIGHT * 30
    maxGrowthRate = 200
    local curve = {}
    local growthRate = 0.01 -- starting growth rate
    local x = 50
    
    for i = 1, maxWidth * 1.1 do
        growthRate = growthRate + 0.001 * (i/maxWidth) -- increase growth rate
        local y = maxHeight * growthRate/(maxGrowthRate - i/8) -- calculate y position based on growth rate
        curve[i] = vec2(x, y + 50)
        x = x + 0.8
    end
    for _, dot in ipairs(curve) do
        ellipse(dot.x, dot.y, 4)
    end
    popStyle()
    return curve
end

function simulateGrowth(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 50
    local slopeChangePoint = levelOffY / 2
    local growthRate, dy
    
    if y <= slopeChangePoint then
        growthRate = y / (HEIGHT * 1000) * maxGrowthRate
    else
        local reversedY = levelOffY - y
        growthRate = reversedY / (HEIGHT * 1000) * maxGrowthRate
    end
    
    dy = growthRate * dt * 1000
    return y + dy
end


function simulateGrowthReversed(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 600
    local slopeChangePoint = 40
    local growthRate = ((levelOffY - y) / (levelOffY - slopeChangePoint)) * maxGrowthRate
    local dy = growthRate * dt * 1.5
    return y + dy
end

function simulateGrowthCombined(y, dt, ry)
    local maxGrowthRate = 200
    local levelOffY = 600
    local slopeChangePoint = levelOffY / 2
    local growthRate
    local dy
    if not rCache then
        rCache = {simulateGrowthReversed(ry, dt)} 
        incrementer = 1
    else
        rCache[#rCache+1] = simulateGrowthReversed(ry, dt)
    end
    if y <= slopeChangePoint then
        if rCache[#rCache] < slopeChangePoint then
            incrementer = incrementer + 1
        end
        return simulateGrowth(y, dt), rCache[#rCache]
    else
        returnValue = rCache[incrementer]
        incrementer = incrementer + 1
        return returnValue, rCache[#rCache]
    end
end

function drawGrowthCurve()
    if not skip then
        xValues = {}
        yValues = {}
        growthRate = 0.1
        for i = 1, 2000 do
            table.insert(xValues, i + 50)
            table.insert(yValues, growthRate)
            growthRate = growthRate + (i / 1000000)
        end
        skip = true
        
        curvey = drawFullCurve()
        y = simulateGrowth(1, DeltaTime)
        bitty = {vec2(50, y + 50)}
        yy = simulateGrowthReversed(1, DeltaTime)
        bittybitty = {vec2(50, yy + 50)} 
        cy, ry = simulateGrowthCombined(1, DeltaTime, 1)
        combo = {vec2(50, cy + 50)} 
        comboR = {vec2(50, ry + 65)} 
    end
    if true then return end
    strokeWidth(2)
    for i = 2, #xValues do
        --    line(xValues[i-1], yValues[i-1]*HEIGHT-50, xValues[i], yValues[i]*HEIGHT - 50)
    end
    
    
    drawAxes()
    --  drawFullCurve()
    
    y = simulateGrowth(y, DeltaTime)
    yy = simulateGrowthReversed(yy, DeltaTime)
    cy, ry = simulateGrowthCombined(cy, DeltaTime, ry)
    table.insert(bitty, vec2(#bitty + 51, y + 50))
    table.insert(bittybitty, vec2(#bittybitty + 51, yy + 60))
    table.insert(combo, vec2(#combo + 51, cy + 55))
    table.insert(comboR, vec2(#comboR + 51, ry + 65))
    fill(123, 233, 80)
    drawVecTable(bitty)
    fill(233, 80, 131)
    drawVecTable(bittybitty)
    fill(89, 80, 233)
    drawVecTable(combo)
    fill(217, 233, 80)
    drawVecTable(comboR)
end
    
function testGettingColorBetween()
    local color1 = color(0, 0, 255) -- blue
    local color2 = color(255, 255, 0) -- yellow
    local numTests = 100
    
    for i = 1, numTests do
        local newColor = randomColorBetween(color1, color2)
        local newHSB = vec3(colorToHSB(newColor))
        
        local minHSB = vec3(colorToHSB(color1))
        local maxHSB = vec3(colorToHSB(color2))
        
        if minHSB.x > maxHSB.x then
            minHSB, maxHSB = maxHSB, minHSB
        end
        
        if newHSB.x < minHSB.x or newHSB.x > maxHSB.x or
        newHSB.y < minHSB.y or newHSB.y > maxHSB.y or
        newHSB.z < minHSB.z or newHSB.z > maxHSB.z then
            print("Test failed:", i, "New Color:", newColor)
        else
            print("Test passed:", i, "New Color:", newColor)
        end
    end
end

    