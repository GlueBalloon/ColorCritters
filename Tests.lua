
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
    local growthRate = y / (HEIGHT * 1000) * maxGrowthRate
    local dy = growthRate * dt * 1000
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

function simulateGrowth(y, dt)
    local maxGrowthRate = 200
    local levelOffY = 600
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



function drawVecTable(dots, radius)
    radius = radius or 4
    for _, dot in ipairs(dots) do
        ellipse(dot.x, dot.y, radius)
    end
end
    
    
function testFindMedianFps()
    local field = Field()
    local testPairs = {}
    
    -- Generate 100 fps and population pairs
    for i = 1, 100 do
        local newPair = {fps = math.random(10, 20), population = math.random(1000, 5000)}
        table.insert(testPairs, newPair)
    end
    
    -- Run all pairs through storeFpsHistory
    for _, pair in ipairs(testPairs) do
        field:storeFpsHistory(pair.fps, pair.population)
    end
    
    -- Sort the pairs by fps
    table.sort(testPairs, function(a, b) return a.fps < b.fps end)
    
    -- Find the median fps
    local indexOfExpected = math.floor(#field.fpsHistory/2)
    local expectedMedian = testPairs[indexOfExpected].fps
    local actualMedian = field:findMedianFpsTable().fps
    -- Check that the median fps was found correctly
    assert(actualMedian == expectedMedian, "findMedianFpsTable test failed: expected "..
    tostring(expectedMedian).." at "..indexOfExpected.." but got "..tostring(actualMedian))
    
    print("findMedianFps test passed")
end

function testGetMedianFpsPopulationAndRatio()
    local field = Field()
    field.fpsHistory = {
        {fps = 10, population = 1000},
        {fps = 9, population = 900},
        {fps = 8, population = 800},
        {fps = 7, population = 700},
        {fps = 6, population = 600},
        {fps = 5, population = 500},
        {fps = 4, population = 400},
        {fps = 3, population = 300},
        {fps = 2, population = 200},
        {fps = 1, population = 100},
    }
    
    local medianFps, medianPopulation, ratio = field:getMedianFpsPopulationAndRatio()
    
    assert(medianFps == 5, "Test 1 failed: expected 5, got " .. medianFps)
    assert(medianPopulation == 500, "Test 2 failed: expected 500, got " .. medianPopulation)
    assert(math.abs(ratio - 100) < 0.0001, "Test 3 failed: expected 100, got " .. ratio)
    
    print("testGetMedianFpsPopulationAndRatio passed")
end

function getFakeHistory()
    return {
        {fps = 10, population = 1000},
        {fps = 9, population = 900},
        {fps = 8, population = 800},
        {fps = 7, population = 700},
        {fps = 6, population = 600},
        {fps = 5, population = 500},
        {fps = 4, population = 400},
        {fps = 3, population = 300},
        {fps = 2, population = 200},
        {fps = 1, population = 100},
    }
end

function testGetPopulationForFpsTarget()
    local medianFps = 18
    local medianPopulation = 5000
    local targetFps = 12
    
    -- Step 1: Find the ratio such that medianFps * ratio = medianPopulation
    local ratio = medianPopulation / medianFps
    print("Ratio: ", ratio)
    
    -- Step 2: Test that medianPopulation / ratio = medianFps
    assert(math.floor(medianPopulation / ratio) == medianFps, "Step 2 failed: medianPopulation / ratio does not equal medianFps")
    
    -- Step 3: Call the function to find the necessary population for the target fps
    local targetPopulation = Field:getPopulationForFpsTarget(medianFps, medianPopulation, targetFps)
    print("Target Population: ", targetPopulation)
    
    -- Step 4: Test that 12 * ratio = targetPopulation
    assert(math.ceil(12 * ratio) == targetPopulation, "Step 4 failed: 12 * ratio does not equal targetPopulation")
    
    -- Step 5: Test that targetPopulation / ratio = 12
    assert(math.floor(targetPopulation / ratio) == targetFps, "Step 5 failed: targetPopulation / ratio does not equal targetFps")
    
    print("testGetPopulationForFpsTarget passed")
end

function testStoreFpsHistory()
    local field = Field()  -- create an instance of the Field class
    
    -- Test with less than or equal to 100 fpsHistory entries
    for i=1, 100 do
        field:storeFpsHistory(i, i*10)
        assert(#field.fpsHistory == i, "length wrong")  -- check that the length of fpsHistory is correct
        assert(field.fpsHistory[i].fps == i, "fps value wrong")  -- check that the fps value is correct
        assert(field.fpsHistory[i].population == i*10, "population wrong")  -- check that the population value is correct
    end
    
    -- Test with more than 100 fpsHistory entries
    for i=101, 199 do
        field:storeFpsHistory(i, i*10)
        assert(#field.fpsHistory == 100, "stored over 100: "..tostring(#field.fpsHistory))  -- check that the length of fpsHistory is capped at 100
        assert(field.fpsHistory[1].fps == i, "fps value wrong at beginning")  -- check that the most recent fps value is at the beginning
        assert(field.fpsHistory[1].population == i*10, "pop value wrong at beginning")  -- check that the most recent population value is at the beginning
        assert(field.fpsHistory[100].fps == 200-i, 
        "fps value wrong at end, was: "..tostring(field.fpsHistory[100].fps)..", i: "..i..
        ", expected: ".."200-"..i)  -- check that the oldest fps value is at the end
        assert(field.fpsHistory[100].population == (100-(i-100))*10, 
        "pop value wrong at end: "..tostring(field.fpsHistory[100].population))  -- check that the oldest population value is at the end=
    end
    print("testStoreFpsHistory passed")
end

function testCollectOldest()
    local field = Field()
    local testCritters = {}
    
    -- Generate 500 critters with ages between 0 and 999
    for i = 1, 500 do
        local newCritter = ColorCritter()
        newCritter.age = math.random(0, 999)
        newCritter.id = math.random(0, 999)
        table.insert(testCritters, newCritter)
    end
    
    -- Run all those critters through collectOldest
    for _, critter in ipairs(testCritters) do
        field:collectOldest(critter)
    end
    
    -- Sort the critters by age
    table.sort(testCritters, function(a, b) return a.age > b.age end)
    table.sort(field.oldest, function(a, b) return a.age > b.age end)
    
    -- Check that the 100 oldest critters were collected
    for i = 1, 100 do
        assert(tostring(field.oldest[i].age) == tostring(testCritters[i].age), 
        "field.oldest table is wrong at "..i..
        ", field.oldest[i] is "..tostring(field.oldest[i].age)..", testCritters[i] is "..
        tostring(testCritters[i].age))
    end
    
    print("collectOldest test passed")
end