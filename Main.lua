


--[[ ****

Actual Main tab.

-- **** ]]



function setup()
    field = Field()
    field:resetCritters()
    demoControl = DemoControl()
    demoControl.resetFunction = function()
        field:resetCritters()
    end
    demoControl:addDemo(Stillness, "Stillness")
    demoControl:addDemo(Movers, "Movers")
    demoControl:addDemo(Streakers, "Streakers")
    demoControl:addDemo(AccidentalBlobs, "Accidental Blobs")
    demoControl:addDemo(BasicMating, "Basic Mating")
    demoControl:addDemo(JitteryBreeders, "Jittery Breeders")
    demoControl:addDemo(PickyBreeders, "Picky Breeders")
    demoControl:addDemo(TinyBreeders, "Tiny Breeders")
    demoControl:addDemo(PopulationTiedToFPS, "Population Tied To FPS")
    demoControl:addDemo(GroupStreakers, "Group Streakers")
end

function draw()

    if demoControl.iosSlider and not sliderSet then
        --make the chooser default to the last demo
        print("not")
        local last = #demoControl.demoDrawFunctions
        demoControl.iosSlider:setValue_(last)
        demoControl:updateDemoAndReset(last)
        demoControl:draw()
        sliderSet = true
        background(0)
    elseif not demoControl.iosSlider then
        --make the background cleared at least once
        demoControl:draw()
        background(0)
    else  
        demoControl:draw()
    end
end

function touched(touch)
    demoControl:touched(touch)
end
