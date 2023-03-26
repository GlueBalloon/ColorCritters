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

