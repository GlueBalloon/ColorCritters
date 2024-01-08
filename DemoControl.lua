
DemoControl = class()

function DemoControl:init()
    pushStyle()
    self.fontSize = math.max(WIDTH, HEIGHT) * 0.0295
    fontSize(self.fontSize)
    _, self.textHeight = textSize("aAbBhHjJkKpPtTyY@\"'!?()//@{}%")
    popStyle()
    self.sliderHeight = 0
    self.demoChangedTime = 0
    self.selectedDemo = 1
    self.demoDrawFunctions = {}
    self.demoTitles = {}
    self.titleFadeSeconds = 3.5
    self.resetFunction = function() end
    self.demoCount = 0
    self.iosSlider = nil
    self.sliderHandler = nil
    self.lastSliderValue = 1
    self.touchActive = false
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
    field = Field()
    field:resetCritters()
    output.clear()
    parameter.clear()
    self.lastSliderValue = newDemoIndex
    self.selectedDemo = newDemoIndex
    self.demoChangedTime = ElapsedTime
    self:resetFunction()
end

function DemoControl:makeiOSControl()
    SliderValueHandler = objc.class("SliderValueHandler")
    function SliderValueHandler:sliderValueChanged_(objcArgs)
        demoControl.touchActive = true
        local steps = #demoControl.demoDrawFunctions
        local stepValue = 1
        local roundedValue = math.floor((objcArgs.value + stepValue / 2) / stepValue) * stepValue
        if demoControl.lastSliderValue == roundedValue then return end
        objcArgs:setValue_(roundedValue, true) -- Set rounded value to the slider
        -- Update the selected demo and call resetFunction
        demoControl.updateDemoAndReset(demoControl, roundedValue)
    end
    
    self.sliderHandler = SliderValueHandler()   
    local UIScreen = objc.UIScreen
    local UIScreen_mainScreen = UIScreen:mainScreen()
    local UIScreen_mainScreen_bounds = objc.viewer.view.bounds
    local sliderWidth = math.floor(WIDTH * 0.45)
    self.sliderHeight = math.floor(self.textHeight * 0.55)
    local heighfOffset = self.sliderHeight
    if WIDTH == math.min(WIDTH, HEIGHT) then
        heighfOffset = heighfOffset + layout.safeArea.top
    end
    
    self.iosSlider = objc.UISlider()
    self.iosSlider.frame = objc.rect(math.floor(WIDTH / 2 - sliderWidth / 2), 
    heighfOffset, sliderWidth, self.sliderHeight)
      
    self.iosSlider:setMinimumValue_(1)
    self.iosSlider:setMaximumValue_(#self.demoDrawFunctions)
    self.iosSlider:setValue_(1)
    --self.iosSlider:setContinuous_(false)
    
    self.iosSlider:addTarget_action_forControlEvents_(self.sliderHandler, 
    objc.selector("sliderValueChanged:"), 
    objc.enum.UIControlEvents.touchUpInside | objc.enum.UIControlEvents.valueChanged)
    
    objc.viewer.view:addSubview_(self.iosSlider)
end

function DemoControl:drawTitle()
    local elapsedTime = ElapsedTime - self.demoChangedTime
    local fadeOutPhase = math.min(self.titleFadeSeconds * 0.5, 0.5)
    
    if elapsedTime <= self.titleFadeSeconds then
        local alpha
        if elapsedTime < self.titleFadeSeconds - fadeOutPhase then
            alpha = 255
        else
            alpha = 255 * (1 - (elapsedTime - (self.titleFadeSeconds - fadeOutPhase)) / fadeOutPhase)
        end
        
        local title = self.lastSliderValue.." of "..tostring(#self.demoTitles)..": "..tostring(self.demoTitles[self.lastSliderValue] or "")
        local shadowOffset = vec2(2, -2) -- Offset for the shadow
        
        fontSize(self.fontSize)
        local heighfOffset = (self.textHeight + self.sliderHeight) * 1.35
        if WIDTH == math.min(WIDTH, HEIGHT) then
            heighfOffset = heighfOffset + layout.safeArea.top
        end
        -- Draw the shadow
        fill(0, 0, 0, alpha)
        textMode(CENTER)
        text(title, (WIDTH / 2) + shadowOffset.x, (HEIGHT - heighfOffset) + shadowOffset.y)
        
        -- Draw the title
        fill(255, 255, 255, alpha)
        textMode(CENTER)
        text(title, WIDTH / 2, HEIGHT - heighfOffset)
    end
end


function DemoControl:draw()
    if not self.iosSlider then
        self:makeiOSControl()
    end
    sliderValue = self.iosSlider.value --needed or slider is buggy
    local roundedValue = math.floor(sliderValue + 1 / 2)
    self.iosSlider:setValue_(roundedValue, true) -- Set rounded value to the slider
    local sliderChanged = roundedValue ~= self.lastSliderValue
    if sliderChanged and self.touchActive then
        self.lastSliderValue = roundedValue
        self.demoChangedTime = ElapsedTime
    end
    local drawFunction = self.demoDrawFunctions[self.selectedDemo]
    if drawFunction then
        drawFunction()
        self:drawTitle()
    else
        print("Invalid demo selected")
        return 
    end  
end

function DemoControl:touched(touch)
    self.touchActive = touch.state == BEGAN or touch.state == CHANGED
end
