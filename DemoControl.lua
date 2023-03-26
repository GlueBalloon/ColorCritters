
DemoControl = class()

function DemoControl:init()
    self.demoChangedTime = 0
    self.selectedDemo = 1
    self.demoDrawFunctions = {}
    self.demoTitles = {}
    self.titleFadeSeconds = 3.5
    self.resetFunction = function() end
    self.demoCount = 0
    self.iosSlider = nil
    self.sliderHandler = nil
end

-- Other functions remain the same

function DemoControl:addDemo(drawFunction, title)
    assert(title, "Demo title must be provided")
    local demoIndex = #self.demoDrawFunctions + 1
    self.demoDrawFunctions[demoIndex] = drawFunction
    self.demoTitles[demoIndex] = title
    self.demoCount = demoIndex
    self:setSliderMaxValue(self.demoCount)
end

function DemoControl:setSliderMaxValue(demoCount)
    if self.iosSlider then
        self.iosSlider:setMaximumValue_(demoCount * 10)
    end
end

function DemoControl:updateDemoAndReset(newDemoIndex)
    -- Update the selected demo and call resetFunction
    self.selectedDemo = newDemoIndex
    self.demoChangedTime = ElapsedTime
    self:resetFunction()
end

function DemoControl:makeiOSControl()
    SliderValueHandler = objc.class("SliderValueHandler")
    function SliderValueHandler:sliderValueChanged_(objcArgs)
        local steps = #demoControl.demoDrawFunctions
        local stepValue = 1
        local roundedValue = math.floor((objcArgs.value + stepValue / 2) / stepValue) * stepValue
        objcArgs:setValue_(roundedValue, true) -- Set rounded value to the slider
        print("Slider value:", roundedValue)     
        -- Update the selected demo and call resetFunction
        demoControl.updateDemoAndReset(demoControl, roundedValue)
    end
    
    self.sliderHandler = SliderValueHandler()   
    local UIScreen = objc.UIScreen
    local UIScreen_mainScreen = UIScreen:mainScreen()
    local UIScreen_mainScreen_bounds = objc.viewer.view.bounds
    local sliderWidth = 200
    local sliderHeight = 50
    
    self.iosSlider = objc.UISlider()
    self.iosSlider.frame = objc.rect(sliderWidth, sliderHeight, 
    UIScreen_mainScreen_bounds.size.width / 2 - sliderWidth / 2, 
    objc.viewer.view.bounds.size.height - sliderHeight - 20)
    self.iosSlider:setContinuous_(false)
    
    self.iosSlider:setMinimumValue_(1)
    self.iosSlider:setMaximumValue_(#self.demoDrawFunctions)
    self.iosSlider:setValue_(1)
    
    self.iosSlider:addTarget_action_forControlEvents_(self.sliderHandler, 
    objc.selector("sliderValueChanged:"), 
    objc.enum.UIControlEvents.touchUpInside)
    
    objc.viewer.view:addSubview_(self.iosSlider)
end

function DemoControl:drawTitle()
    local elapsedTime = ElapsedTime - self.demoChangedTime
    local fadeOutPhase = math.min(self.titleFadeSeconds * 0.5, 0.5)
    
    if elapsedTime < self.titleFadeSeconds then
        local alpha
        if elapsedTime < self.titleFadeSeconds - fadeOutPhase then
            alpha = 255
        else
            alpha = 255 * (1 - (elapsedTime - (self.titleFadeSeconds - fadeOutPhase)) / fadeOutPhase)
        end
        
        local title = self.selectedDemo.." of "..tostring(#self.demoTitles)..": "..tostring(self.demoTitles[self.selectedDemo] or "")
        local shadowOffset = vec2(2, -2) -- Offset for the shadow
        
        -- Draw the shadow
        fill(0, 0, 0, alpha)
        fontSize(48)
        textMode(CENTER)
        text(title, (WIDTH / 2) + shadowOffset.x, (HEIGHT - 60) + shadowOffset.y)
        
        -- Draw the title
        fill(255, 255, 255, alpha)
        fontSize(48)
        textMode(CENTER)
        text(title, WIDTH / 2, HEIGHT - 60)
    end
end


function DemoControl:draw()
    if not self.iosSlider then
        self:makeiOSControl()
    end
    _ = self.iosSlider.value --needed or slider is buggy
    local drawFunction = self.demoDrawFunctions[self.selectedDemo]
    if drawFunction then
        drawFunction()
        self:drawTitle()
    else
        print("Invalid demo selected")
        return 
    end  
    if self.shouldErase then
        print("Invalid foop selected")
        background(255, 203, 0)
        self.shouldErase = false
    end
end
