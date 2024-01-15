


--[[ ****

Actual Main tab.

-- **** ]]



function setup()
    viewer.mode = FULLSCREEN
    field = Field()
    field:resetCritters()
    demoControl = DemoControl()
    demoControl.resetFunction = function()
        field:resetCritters()
    end
    demoControl:addDemo(Immobile, "Immobile")
    demoControl:addDemo(Movers, "Movers")
    demoControl:addDemo(Streakers, "Streakers")
    demoControl:addDemo(AccidentalBlobs, "Accidental Blobs")
    demoControl:addDemo(BasicMating, "Basic Mating")
    demoControl:addDemo(JitteryBreeders, "Jittery Breeders")
    demoControl:addDemo(PickyBreeders, "Narrow-range Breeders")
    demoControl:addDemo(TinyBreeders, "Tiny Breeders")
    demoControl:addDemo(PopulationTiedToTickRate, "Frame Rate Caps Birth Rate")
end

function draw()

    if demoControl.iosSlider and not sliderSet then
        --make the chooser default to the last demo
        print("not defaulting to last demo yet")
        local startDemo = 9
        local last = #demoControl.demoDrawFunctions
       -- demoControl.iosSlider:setValue_(last)
        demoControl.iosSlider:setValue_(startDemo)-- start with PopulationTiedToTickRate
       -- demoControl:updateDemoAndReset(last)
        demoControl:updateDemoAndReset(startDemo)
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
