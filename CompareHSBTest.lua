function setup()
    -- Define two colors
    leftColor = color(255, 0, 0)
    rightColor = color(0, 255, 0)
    print("Initial colors drawn at " .. os.time())
end

function draw()
    -- Draw left box in left color
    rectMode(CORNER)
    fill(leftColor)
    rect(0, 0, WIDTH / 2, HEIGHT)

    -- Draw right box in right color
    fill(rightColor)
    rect(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
end

function touched(touch)
    -- Randomly change the colors on touch
    if touch.state == BEGAN then
        leftColor = color(math.random(255), math.random(255), math.random(255))
        rightColor = color(math.random(255), math.random(255), math.random(255))
        local areDifferent = colorsExceedVariance(leftColor, rightColor, 0.4)
         print("Colors are different: ", areDifferent)
    end
end
