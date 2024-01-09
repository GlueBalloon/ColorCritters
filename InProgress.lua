function Field:draw()
    self:drawAndSwapBuffer()
    
    background(0)
    if not setupDone then
        setupDone = true
        field:resetCritters(8000)
    end
    for _, critter in ipairs(self.critters.all) do
        
        -- Find a point outside the critter
        local outsidePoint = critter:pointOutsideSelf()       
        -- find direction to that point
        local outsideDirection = (outsidePoint - critter.position):normalize()
        --calculate new position 
        local nextPosition = critter.position + outsideDirection * critter.speed
        --wrap it
        nextPosition = self:wrapIfNeeded(nextPosition)
        -- Make its x and y into non-zero integers inside bounds and get color at that point
        local bufferX, bufferY = math.floor(nextPosition.x), math.floor(nextPosition.y)
        bufferX, bufferY = math.min(WIDTH, math.max(1, bufferX)), math.min(HEIGHT, math.max(1, bufferY))
        local colorAtPoint = color(self.buffer:get(bufferX, bufferY))
        -- check if that color is background color
        if colorAtPoint == self.backgroundColor then
            --if so, store the new direction
            critter.direction = outsideDirection
        else
            -- if not, recalculate position without change of direction 
            local recalculated = critter.position + critter.direction * critter.speed
            nextPosition = self:wrapIfNeeded(recalculated)
        end
        -- update position
        critter.position = nextPosition
        --draw
        fill(critter.color)
        ellipse(critter.position.x, critter.position.y, critter.size)       
    end
end

-- Helper functions for bitwise operations
function bit_and(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then
            result = result + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
    end
    return result
end

function bit_or(a, b)
    local result = 0
    local bitval = 1
    while a > 0 or b > 0 do
        if a % 2 == 1 or b % 2 == 1 then
            result = result + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
    end
    return result
end

-- Encoding function
function encode_data(r, g, b, data)
    local mask = 0xFFF -- 12 bits set to 1
    data = bit_and(data, mask) -- Keep only the 12 least significant bits of data
    
    -- Encode data into color channels
    local new_r = bit_or(bit_and(r, 0xF0), data % 16)
    data = math.floor(data / 16)
    local new_g = bit_or(bit_and(g, 0xF0), data % 16)
    data = math.floor(data / 16)
    local new_b = bit_or(bit_and(b, 0xF0), data % 16)
    
    return new_r, new_g, new_b
end

-- Decoding function
function decode_data(r, g, b)
    local data = 0
    data = bit_or(data, bit_and(b, 0x0F))
    data = data * 16
    data = bit_or(data, bit_and(g, 0x0F))
    data = data * 16
    data = bit_or(data, bit_and(r, 0x0F))
    
    return data
end

function testColorEncoding()
    -- Helper function to generate random colors
    function random_color()
        return color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    end
    
    -- Test with 10 random values
    for i = 1, 10 do
        local original_color = random_color()
        local data = math.random(0, 2^12 - 1) -- Generate random data within the 12-bit range
        
        -- Encode data into color channels
        local encoded_color = color( encode_data(
        original_color.r,
        original_color.g,
        original_color.b,
        data) )
        
        -- Decode data from color channels
        local decoded_data = decode_data(encoded_color.r, encoded_color.g, encoded_color.b)
        
        -- Check if the original and decoded data match
        assert(decoded_data == data, "Decoding failed: original data = " .. data .. ", decoded data = " .. decoded_data)
        print("datae: ", data, ", ", decoded_data)
    end
    
    print("All tests passed!")
end

