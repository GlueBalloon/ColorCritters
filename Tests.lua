
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