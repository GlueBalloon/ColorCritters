


--[[ ****

Actual Main tab.

-- **** ]]



function setup()
    screen = {x=0,y=0,w=WIDTH,h=HEIGHT} 
    sensor = Sensor {parent=screen} -- tell the object you want to be listening to touches, here the screen
    sensor:onTap( function(event) print("tap") end )
    sensor:onZoom( function(event)
        print( event.dw, event.dh) end )
    
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
    demoControl:addDemo(WigglyStreakers, "Wiggly Streakers")
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
    sensor:touched(touch)
end
