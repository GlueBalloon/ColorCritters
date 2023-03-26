function setup()
    field = Field()
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
end

function draw()
    --make the chooser default to the last demo
    if demoControl.iosSlider and not sliderSet then
        local last = #demoControl.demoDrawFunctions
        demoControl.iosSlider:setValue_(last)
        demoControl:updateDemoAndReset(last)
        sliderSet = true
    end
    demoControl:draw()
end

function touched(touch)
    demoControl:touched(touch)
end
