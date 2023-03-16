
    
function setup()
    field = Field()
    testHueFromColor()
    testSaturationFromColor()
    testBrightnessFromColor()
    testHSBtoRGB()
    --dragWin = DraggableSafariWindow("https://chat.openai.com/chat/4878a61e-d598-427b-b586-8da448b359db")
end

function draw()
    field:draw()
    --dragWin:draw()
end

function touched(touch)
    --dragWin:touched(touch)
end