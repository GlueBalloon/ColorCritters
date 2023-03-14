function setup()
    -- Define two colors
    refreshColors()
    screenGrab = image(WIDTH, HEIGHT)
end

function draw()
    setContext(screenGrab)
    -- Draw left box in left color
    rectMode(CORNER)
    fill(leftColor)
    rect(0, 0, WIDTH / 2, HEIGHT)

    -- Draw right box in right color
    fill(rightColor)
    rect(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
    
    -- Draw middle box in center color
    fill(centerColor)
    rect(WIDTH/4, HEIGHT/4, WIDTH/2, HEIGHT/2)
    setContext()
    sprite(screenGrab, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
end

function touched(touch)
    -- Randomly change the colors on touch
    if touch.state == BEGAN then
        print(color(screenGrab:get(math.floor(touch.x), math.floor(touch.y))))
    end
end

function refreshColors()
    leftColor = color(math.random(255), math.random(255), math.random(255))
    rightColor = color(math.random(255), math.random(255), math.random(255))
    centerColor = randomColorBetween(leftColor, rightColor)
end
