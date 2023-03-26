function setup()
    print(20 / WIDTH)
    print(90 / WIDTH)
    if false then
        SliderValueHandler = objc.class("SliderValueHandler")
        function SliderValueHandler:sliderValueChanged_(objcArgs)
            print("Slider value:", roundedValue)
        end
        
        sliderHandler = SliderValueHandler()   
        local UIScreen = objc.UIScreen
        local UIScreen_mainScreen = UIScreen:mainScreen()
        local UIScreen_mainScreen_bounds = objc.viewer.view.bounds
        local sliderWidth = 200
        local sliderHeight = 50
        
        iosSlider = objc.UISlider()
        iosSlider.frame = objc.rect(sliderWidth, sliderHeight, 
        (UIScreen_mainScreen_bounds.size.width / 2 - sliderWidth / 2) + 100, 
        objc.viewer.view.bounds.size.height - sliderHeight - 320)
        iosSlider.isContinuous = false
        
        iosSlider:setMinimumValue_(1)
        iosSlider:setMaximumValue_(22)
        iosSlider:setValue_(1)
        
        iosSlider:addTarget_action_forControlEvents_(sliderHandler, 
        objc.selector("sliderValueChanged:"), 
        objc.enum.UIControlEvents.touchUpInside)
        
        objc.viewer.view:addSubview_(iosSlider)
    end
    field = Field()
    demoControl = DemoControl()
    demoControl.resetFunction = function()
        print("reset")
        field:resetCritters()
    end
    demoControl:addDemo(Stillness, "Stillness Demo")
    demoControl:addDemo(Movers, "Movers")
    demoControl:addDemo(Streakers, "Streakers")
    demoControl:addDemo(AccidentalBlobs, "Accidental Blobs")
    
end

function draw()
    if demoControl.iosSlider and not sliderSet then
        local last = #demoControl.demoDrawFunctions
        demoControl.iosSlider:setValue_(last)
        demoControl:updateDemoAndReset(last)
        sliderSet = true
    end
    demoControl:draw()
end

function touched(touch)
end
