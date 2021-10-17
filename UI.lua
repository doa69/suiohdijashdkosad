local library = {}

library.__index = library

function library:Tween(asset, info, thing)
    game:GetService("TweenService"):Create(asset, info, thing):Play()
end

function library:DropInfo(asset, info, tbl)
    if not tbl.debounce then
        tbl.debounce = true

        local newText = asset:FindFirstChild("Text"):Clone()
        newText.Parent = asset
        newText.Name = "Info"
        newText.TextTransparency = 1
        newText.TextSize = 24
        newText.Position = UDim2.new(asset:FindFirstChild("Text").Position.X.Scale, asset:FindFirstChild("Text").Position.X.Offset, ((asset:FindFirstChild("Text").Position.Y.Scale / 2) * 3), asset:FindFirstChild("Text").Position.Y.Offset)
        newText.Text = info

        local textAsset = asset:FindFirstChild("Text")

        library:Tween(asset, TweenInfo.new(0.5), {Size = UDim2.new(asset.Size.X.Scale, asset.Size.X.Offset, (asset.Size.Y.Scale * 2), asset.Size.Y.Offset)})
        library:Tween(textAsset, TweenInfo.new(0.5), {Position = UDim2.new(textAsset.Position.X.Scale, textAsset.Position.X.Offset, (textAsset.Position.Y.Scale / 2), textAsset.Position.Y.Offset), Size = UDim2.new(textAsset.Size.X.Scale, textAsset.Size.X.Offset, (textAsset.Size.Y.Scale / 2), textAsset.Size.Y.Offset)})
        library:Tween(asset["Down"], TweenInfo.new(0.3), {Rotation = 180, Position = UDim2.new(asset["Down"].Position.X.Scale, asset["Down"].Position.X.Offset, (asset["Down"].Position.Y.Scale / 2), asset["Down"].Position.Y.Offset)})
        wait(0.5)

        library:Tween(newText, TweenInfo.new(0.5), {TextTransparency = 0})

        wait(0.5)

        tbl.debounce = false
        tbl.showingInfo = true
    end
end

function library:RetractInfo(asset, tbl)
    if not tbl.debounce then
        tbl.debounce = true
        library:Tween(asset["Info"], TweenInfo.new(0.25), {TextTransparency = 1})
        library:Tween(asset["Down"], TweenInfo.new(0.3), {Rotation = 0, Position = UDim2.new(asset["Down"].Position.X.Scale, asset["Down"].Position.X.Offset, (asset["Down"].Position.Y.Scale * 2), asset["Down"].Position.Y.Offset)})
        library:Tween(asset, TweenInfo.new(0.5), {Size = UDim2.new(asset.Size.X.Scale, asset.Size.X.Offset, (asset.Size.Y.Scale / 2), asset.Size.Y.Offset)})	

        local textAsset = asset:FindFirstChild("Text")
        library:Tween(textAsset, TweenInfo.new(0.5), {Position = UDim2.new(textAsset.Position.X.Scale, textAsset.Position.X.Offset, (textAsset.Position.Y.Scale * 2), textAsset.Position.Y.Offset), Size = UDim2.new(textAsset.Size.X.Scale, textAsset.Size.X.Offset, (textAsset.Size.Y.Scale * 2), textAsset.Size.Y.Offset)})

        wait(0.5)
        asset["Info"]:Destroy()
        tbl.debounce = false
        tbl.showingInfo = false
    end
end

function library:RoundNumber(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function library:Ripple(ui, button, x, y, tbl)
    --stole this from my old lib
    --[[
    spawn(function()
        local circle = ui.Circle:Clone()
        circle.Parent = button;
        local pos = UDim2.new(0,x-button.AbsolutePosition.X,0,y-button.AbsolutePosition.Y-36)
        circle.Position = pos
        circle.Size = UDim2.new(0,1,0,1)
        circle.ImageTransparency = .5

        local goal = {}
        goal.Size = UDim2.new((0.175)*7, 0, ((tbl and tbl.showingInfo == false and 2) or (tbl and tbl.showingInfo == true and 1))*7, 0)
        goal.ImageTransparency = 1

        local tween = game:GetService("TweenService"):Create(circle, TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), goal)
        tween:Play()
        tween.Completed:Wait()
        circle:Destroy();
    end)--]]

    -- this is fresh code from a yt vid ik

    if x and y then
        spawn(function()
            local c = ui.Circle:Clone()
            c.Parent = button;

            c.ImageTransparency = 0.6

            local x, y = (x-button.AbsolutePosition.X), (y-button.AbsolutePosition.Y-36)
            c.Position = UDim2.new(0, x, 0, y)
            local len, size = 0.75, nil
            if button.AbsoluteSize.X >= button.AbsoluteSize.Y then
                size = (button.AbsoluteSize.X * 1.5)
            else
                size = (button.AbsoluteSize.Y * 1.5)
            end
            local tween = {}
            tween.Size = UDim2.new(0, size, 0, size)
            tween.Position = UDim2.new(0.5, (-size / 2), 0.5, (-size / 2))
            tween.ImageTransparency = 1

            local newTween = game:GetService("TweenService"):Create(c, TweenInfo.new(len, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tween)

            newTween:Play()

            newTween.Completed:Wait()

            c:Destroy()
        end)
    end
end

function library.Create(title, titleUnder)
    local lib = {}

    lib.UI = game:GetObjects("rbxassetid://6849423853")[1]
    lib.UI.Parent = game.CoreGui

    lib.Tabs = {}

    lib.UI.Main.Left.UIName.Text = title
    lib.UI.Main.Left.GameName.Text = titleUnder

    local content, isReady = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    lib.UI.Main.Left.BottomLeft.Icon.Image = content
    lib.UI.Main.Left.BottomLeft.PlayerName.Text = game.Players.LocalPlayer.Name

    lib.Notifications = {}
    lib.Notifications.Queue = {}
    lib.Notifications.Current = nil

    local MainFrame = lib.UI.Main

    --Dragging
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return setmetatable(lib, library)
end

function library:Tab(name, imageId)
    local tab = {}

    tab.Assets = {}

    tab.Lib = self
    tab.Tab = self.UI.Main.Left.Container.Template:Clone()
    tab.Tab.Name = name
    tab.Tab.TabName.Text = name
    tab.Tab.Parent = self.UI.Main.Left.Container

    if imageId then
        tab.Tab.TabIcon.Image = "rbxassetid://" .. imageId
    end

    table.insert(self.Tabs, tab)

    tab.Show = function()
        tab.Tab.Visible = true
    end

    tab.Hide = function()
        tab.Tab.Visible = false
    end

    tab.Fix = function()
        self.UI.Main.Container.AutomaticCanvasSize = Enum.AutomaticSize.None
        self.UI.Main.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    end

    local totalAssets = 0
    for i,v in pairs(self.Tabs) do
        totalAssets = totalAssets + 1
    end

    if totalAssets == 1 then
        -- first tab
        delay(0.1, function()
            for i,v in pairs(tab.Assets) do
                if v then
                    v.Show()
                end
            end
            library:Tween(tab.Tab, TweenInfo.new(0.5), {BackgroundTransparency = 0})
        end)
    end

    tab.Fix()

    tab.Tab.MouseButton1Up:Connect(function()
        for i,v in pairs(self.Tabs) do
            library:Tween(v.Tab, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            for i,v in pairs(v.Assets) do
                v.Hide()
            end
        end

        for i,v in pairs(tab.Assets) do
            v.Show()
        end
        tab.Fix()
        library:Tween(tab.Tab, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    end)

    tab.Show()

    return setmetatable(tab, library)
end

function library:Button(text, info, callback)
    local button = {}

    button.callback = callback or function() end
    button.debounce = false
    button.showingInfo = false
    button.button = self.Lib.UI.Main.Container.Button:Clone()
    button.button.Parent = self.Lib.UI.Main.Container
    button.button:FindFirstChild("Text").Text = (text or "No Text")
    button.button.Name = (text or "No Text")

    button.Show = function()
        button.button.Visible = true
    end

    button.Hide = function()
        button.button.Visible = false
    end

    button.button.Down.MouseButton1Up:Connect(function()
        if not button.showingInfo then
            library:DropInfo(button.button, info, button)
        else
            library:RetractInfo(button.button, button)
        end
    end)

    button.button.MouseButton1Up:Connect(function(x,y)
        if not button.debounce then
            library:Ripple(self.Lib.UI, button.button, x, y, button)
            button.callback()
        end
    end)

    table.insert(self.Assets, button)

    return setmetatable(button, library)
end

function library:Toggle(text, info, state, callback)
    local toggle = {}

    toggle.callback = callback or function() end
    toggle.debounce = false
    toggle.showingInfo = false
    toggle.state = state
    toggle.toggle = self.Lib.UI.Main.Container.Toggle:Clone()
    toggle.toggle.Parent = self.Lib.UI.Main.Container
    toggle.toggle:FindFirstChild("Text").Text = (text or "No Text")
    toggle.toggle.Name = (text or "No Text")

    toggle.Show = function()
        toggle.toggle.Visible = true
    end

    toggle.Hide = function()
        toggle.toggle.Visible = false
    end

    toggle.Refresh = function()
        if toggle.state then
            toggle.state = false
            toggle.debounce = true
            spawn(function()
                toggle.callback(toggle.state)
            end)
            local circle = toggle.toggle.Whole.Inner
            local newPosition = UDim2.new((circle.Position.X.Scale / 3), circle.Position.X.Offset, circle.Position.Y.Scale, circle.Position.Y.Offset)

            library:Tween(circle, TweenInfo.new(0.2), {Position = newPosition})
            library:Tween(circle.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(213, 213, 213)})

            wait(0.3)
            toggle.debounce = false
        else 
            toggle.state = true
            toggle.debounce = true
            spawn(function()
                toggle.callback(toggle.state)
            end)
            local circle = toggle.toggle.Whole.Inner
            local newPosition = UDim2.new((circle.Position.X.Scale * 3), circle.Position.X.Offset, circle.Position.Y.Scale, circle.Position.Y.Offset)

            library:Tween(circle, TweenInfo.new(0.2), {Position = newPosition})
            library:Tween(circle.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(248, 86, 86)})

            wait(0.3)
            toggle.debounce = false
        end
    end

    spawn(function()
        if toggle.state then
            toggle.debounce = true
            local circle = toggle.toggle.Whole.Inner
            local newPosition = UDim2.new((circle.Position.X.Scale * 3), circle.Position.X.Offset, circle.Position.Y.Scale, circle.Position.Y.Offset)

            library:Tween(circle, TweenInfo.new(0.2), {Position = newPosition})
            library:Tween(circle.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(248, 86, 86)})

            wait(0.3)
            toggle.debounce = false
        end
    end)

    toggle.toggle.Down.MouseButton1Up:Connect(function()
        if not toggle.showingInfo then
            library:DropInfo(toggle.toggle, info, toggle)
        else
            library:RetractInfo(toggle.toggle, toggle)
        end
    end)

    toggle.toggle.MouseButton1Up:Connect(function(x,y)
        if not toggle.debounce then
            library:Ripple(self.Lib.UI, toggle.toggle, x, y, toggle)
            toggle.Refresh()
        end
    end)

    local ran, failed = pcall(function()
        toggle.callback(toggle.state)
    end)

    if ran then
        print("Ran sucessfully.")
    else
        print("Failed to run but no worries!", failed)
    end

    table.insert(self.Assets, toggle)
    return setmetatable(toggle, library)
end

function library:Seperator()
    local seperator = {}

    seperator.asset = self.Lib.UI.Main.Container.Seperator:Clone()
    seperator.asset.Parent = self.Lib.UI.Main.Container

    seperator.Show = function()
        seperator.asset.Visible = true
    end

    seperator.Hide = function()
        seperator.asset.Visible = false
    end

    table.insert(self.Assets, seperator)
    return setmetatable(seperator, library)
end

function library:Slider(name, min, max, starting, callback)
    local slider = {}

    slider.callback = callback or function() end
    slider.min = min or 1
    slider.max = max or 100

    slider.asset = self.Lib.UI.Main.Container.Slider:Clone()
    slider.asset.Name = (name or "None")
    slider.asset:FindFirstChild("Slider").Text = (name or "None")
    slider.asset.Parent = self.Lib.UI.Main.Container
    slider.holdAsset = self.Lib.UI.Main.Container

    slider.holdAsset = slider.asset.Holder.Holder.Circle

    local mouse = game.Players.LocalPlayer:GetMouse()
    local uis = game:GetService("UserInputService")
    local Value;

    local bound = slider.holdAsset.Parent.Parent.AbsoluteSize.X
    
    function slider.Refresh(new, bool)
        local pos = (bound * (new/slider.max))

        library:Tween(slider.holdAsset.Parent, TweenInfo.new(0.1), {Size = UDim2.new(0, pos, 1, 0)})

        slider.asset.Percentage.Text = new
        
        if bool then
            slider.callback(new)
        end
    end
    
    slider.Refresh(starting)
    
    slider.holdAsset.MouseButton1Down:Connect(function()
        local Num = (((tonumber(slider.max) - tonumber(slider.min)) / bound) * slider.holdAsset.Parent.AbsoluteSize.X) + tonumber(slider.min)
        local IsDecimal = select(2, math.modf(starting)) ~= 0
        print(IsDecimal)
        Value = (not IsDecimal and math.ceil(Num)) or (IsDecimal and library:RoundNumber(Num, 1)) or 0
        pcall(function()
            slider.callback(Value)
        end)
        library:Tween(slider.holdAsset.Parent, TweenInfo.new(0.1), {Size = UDim2.new(0, math.clamp(mouse.X - slider.holdAsset.Parent.AbsolutePosition.X, 0, bound), 1, 0)})
        moveconnection = mouse.Move:Connect(function()
            slider.asset.Percentage.Text = Value
            local Num = (((tonumber(slider.max) - tonumber(slider.min)) / bound) * slider.holdAsset.Parent.AbsoluteSize.X) + tonumber(slider.min)
            local IsDecimal = select(2, math.modf(starting)) ~= 0
            Value = (not IsDecimal and math.ceil(Num)) or (IsDecimal and library:RoundNumber(Num, 1))
            pcall(function()
                slider.callback(Value)
            end)
            print((mouse.X - slider.holdAsset.Parent.AbsolutePosition.X))
            library:Tween(slider.holdAsset.Parent, TweenInfo.new(0.1), {Size = UDim2.new(0, math.clamp(mouse.X - slider.holdAsset.Parent.AbsolutePosition.X, 0, bound), 1, 0)})
        end)
        releaseconnection = uis.InputEnded:Connect(function(Mouse)
            if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                local Num = (((tonumber(slider.max) - tonumber(slider.min)) / bound) * slider.holdAsset.Parent.AbsoluteSize.X) + tonumber(slider.min)
                local IsDecimal = select(2, math.modf(starting)) ~= 0
                Value = (not IsDecimal and math.ceil(Num)) or (IsDecimal and library:RoundNumber(Num, 1)) 
                pcall(function()
                    slider.callback(Value)
                end)
                library:Tween(slider.holdAsset.Parent, TweenInfo.new(0.1), {Size = UDim2.new(0, math.clamp(mouse.X - slider.holdAsset.Parent.AbsolutePosition.X, 0, bound), 1, 0)})
                moveconnection:Disconnect()
                releaseconnection:Disconnect()
                
                wait()
                slider.Refresh(Value, true)
            end
        end)
    end)
    
    slider.Show = function()
        slider.asset.Visible = true
    end

    slider.Hide = function()
        slider.asset.Visible = false
    end

    table.insert(self.Assets, slider)
    return setmetatable(slider, library)
end

function library:Dropdown(name, list, callback)
    local dropdown = {}

    dropdown.table = list
    dropdown.callback = callback or function() end

    dropdown.debounce = false

    dropdown.asset = self.Lib.UI.Main.Container.Dropdown:Clone()
    dropdown.asset.Parent = self.Lib.UI.Main.Container

    dropdown.assets = {}
    dropdown.connections = {}

    dropdown.asset:FindFirstChild("Text").Text = dropdown.table[1]

    function dropdown.Refresh()
        if not table.find(dropdown.table, dropdown.asset:FindFirstChild("Text").Text) then
            dropdown.asset:FindFirstChild("Text").Text = dropdown.table[1]
        end
    end

    dropdown.showing = false

    dropdown.asset.MouseButton1Up:Connect(function(x, y)
        if not dropdown.debounce then
            library:Ripple(self.Lib.UI, dropdown.asset, x, y, {["showingInfo"] = false})
            if #dropdown.assets < 1 then
                dropdown.debounce = true
                local passed = false
                local num = 0
                local assets = {}
                for i,v in ipairs(dropdown.asset.Parent:GetChildren()) do
                    if v.ClassName ~= "Folder" and v.ClassName ~= "UIListLayout" and v.ClassName ~= "UIAspectRatioConstraint"  and v.Visible and not passed and v == dropdown.asset then
                        passed = true
                    end

                    if passed then
                        if v ~= dropdown.asset then
                            num = num + 1
                            v.Parent = v.Parent.Hold
                            table.insert(assets, v)
                        end
                    end
                end

                library:Tween(dropdown.asset["Down"], TweenInfo.new(0.3), {Rotation = 180})

                for i = 1, #dropdown.table do
                    local newDrop = self.Lib.UI.Main.Container.DropdownDrop:Clone()
                    newDrop.Parent = self.Lib.UI.Main.Container


                    newDrop:FindFirstChild("Text").Text = dropdown.table[i]

                    newDrop.Visible = true
                    library:Tween(newDrop, TweenInfo.new(0.2), {BackgroundTransparency = 0})
                    library:Tween(newDrop:FindFirstChild("Text"), TweenInfo.new(0.3), {TextTransparency = 0})

                    local thing = {}

                    thing.Asset = newDrop

                    thing.Show = function()
                        dropdown.assets[i].Visible = true
                    end

                    thing.Hide = function()
                        dropdown.assets[i].Visible = false
                    end

                    table.insert(dropdown.assets, newDrop)
                    table.insert(self.Assets, thing)

                    local con;

                    con = thing.Asset.MouseButton1Up:Connect(function(x, y)
                        if dropdown.showing then
                            table.insert(dropdown.connections, con)
                            dropdown.debounce = true
                            library:Tween(dropdown.asset["Down"], TweenInfo.new(0.3), {Rotation = 0})

                            if dropdown.asset:FindFirstChild("Text").Text ~= dropdown.table[i] then
                                dropdown.asset:FindFirstChild("Text").Text = dropdown.table[i]
                                dropdown.callback(dropdown.table[i])
                            end						

                            for i,v in pairs(dropdown.connections) do
                                v:Disconnect()
                                table.remove(dropdown.connections, i)
                            end

                            for i = #dropdown.assets, 1, -1 do
                                library:Tween(dropdown.assets[i], TweenInfo.new(0.2), {BackgroundTransparency = 1})
                                library:Tween(dropdown.assets[i]:FindFirstChild("Text"), TweenInfo.new(0.3), {TextTransparency = 1})

                                game:GetService("RunService").RenderStepped:Wait()

                                dropdown.assets[i]:Destroy()

                                for a,v in pairs(self.Assets) do
                                    if v.Asset == dropdown.assets[i] then
                                        table.remove(self.Assets, a)
                                    end
                                end				
                                table.remove(dropdown.assets, i)
                            end

                            dropdown.debounce = false
                        end
                    end)

                    game:GetService("RunService").RenderStepped:Wait()
                end

                for i,v in ipairs(assets) do
                    v.Parent = v.Parent.Parent
                end

                for i,v in pairs(assets) do
                    table.remove(assets, i)
                end

                dropdown.showing = true
                dropdown.debounce = false
            else
                dropdown.debounce = true
                library:Tween(dropdown.asset["Down"], TweenInfo.new(0.3), {Rotation = 0})
                for i = #dropdown.assets, 1, -1 do
                    library:Tween(dropdown.assets[i], TweenInfo.new(0.2), {BackgroundTransparency = 1})
                    library:Tween(dropdown.assets[i]:FindFirstChild("Text"), TweenInfo.new(0.3), {TextTransparency = 1})

                    game:GetService("RunService").RenderStepped:Wait()

                    dropdown.assets[i]:Destroy()

                    for a,v in pairs(self.Assets) do
                        if v.Asset == dropdown.assets[i] then
                            table.remove(self.Assets, a)
                        end
                    end				
                    table.remove(dropdown.assets, i)
                end
                dropdown.showing = false
                dropdown.debounce = false
            end
        end
    end)

    dropdown.Hide = function()
        dropdown.asset.Visible = false
    end

    dropdown.Show = function()
        dropdown.asset.Visible = true
    end

    table.insert(self.Assets, dropdown)
    return setmetatable(dropdown, library)
end

function library:Label(text)
    local label = {}

    label.asset = self.Lib.UI.Main.Container.Label:Clone()
    label.asset.Parent = self.Lib.UI.Main.Container

    label.class = "label"

    function label.Refresh(newText)
        label.asset:FindFirstChild("Text").Text = newText
    end

    label.Refresh(text)

    label.Show = function()
        label.asset.Visible = true
    end

    label.Hide = function()
        label.asset.Visible = false
    end

    table.insert(self.Assets, label)
    return setmetatable(label, library)
end

function library:TextBox(text, callback)
    local textbox = {}
    
    textbox.Name = text
    textbox.callback = callback or function() end
    textbox.class = "textbox"
    textbox.debounce = false
    
    textbox.asset = self.Lib.UI.Main.Container.TextBox:Clone()
    textbox.asset.Parent = self.Lib.UI.Main.Container
    textbox.asset:FindFirstChild("Text").Text = text
    
    textbox.typing = false
    
    textbox.connections = {}
    
    textbox.asset.Outline.Box.Focused:Connect(function()
        if not textbox.typing then
            textbox.asset.Outline.Box:ReleaseFocus()
        end
    end)
    
    textbox.asset.MouseButton1Up:Connect(function(x,y)
        if not textbox.debounce then
            textbox.debounce = true
            textbox.typing = true
            library:Ripple(self.Lib.UI, textbox.asset, x, y, textbox)
            library:Tween(textbox.asset.Outline, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
                Size = UDim2.new((textbox.asset.Outline.Size.X.Scale + 0.225), textbox.asset.Outline.Size.X.Offset, textbox.asset.Outline.Size.Y.Scale, textbox.asset.Outline.Size.Y.Offset),
                Position = UDim2.new((textbox.asset.Outline.Position.X.Scale - 0.1125), textbox.asset.Outline.Position.X.Offset, textbox.asset.Outline.Position.Y.Scale, textbox.asset.Outline.Position.Y.Offset)
            })
            wait(0.35)
            textbox.asset.Outline.Box:CaptureFocus()
            textbox.asset.Outline.Box.FocusLost:Wait()
            textbox.typing = false
            library:Tween(textbox.asset.Outline, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
                Size = UDim2.new((textbox.asset.Outline.Size.X.Scale - 0.225), textbox.asset.Outline.Size.X.Offset, textbox.asset.Outline.Size.Y.Scale, textbox.asset.Outline.Size.Y.Offset),
                Position = UDim2.new((textbox.asset.Outline.Position.X.Scale + 0.1125), textbox.asset.Outline.Position.X.Offset, textbox.asset.Outline.Position.Y.Scale, textbox.asset.Outline.Position.Y.Offset),
            })
            
            textbox.callback(textbox.asset.Outline.Box.Text)
            
            wait(0.35)
            
            textbox.debounce = false
        end
    end)
    
    textbox.Show = function()
        textbox.asset.Visible = true
    end
    
    textbox.Hide = function()
        textbox.asset.Visible = false
    end
    
    table.insert(self.Assets, textbox)
    return setmetatable(textbox, library)
end

function library:Notification(text)
    local notification = {}
    notification.NotifText = text
    notification.Bind = nil
    table.insert(self.Lib.Notifications.Queue, notification)
    
    spawn(function()

        for notif = 1, #self.Lib.Notifications.Queue do
            repeat wait() until not self.Lib.Notifications.Current
            self.Lib.Notifications.Current = self.Lib.Notifications.Queue[notif]
            
            local Cover = self.Lib.UI.Main.BackgroundCover
            Cover.Visible = true
            
            Cover.Notification.NotificationLabel.Text = (self.Lib.Notifications.Queue[notif].NotifText or "No text provided")
            
            local TweenData = {
                Transparency = 0.5
            }
            
            local CoverTween = game:GetService("TweenService"):Create(Cover, TweenInfo.new(0.5), TweenData)
            CoverTween:Play()
            CoverTween.Completed:Wait()
            
            local TweenData2 = {
                Position = UDim2.new(0.5, 0, 0.7, 0)
            }	
            
            local NotifTween = game:GetService("TweenService"):Create(Cover.Notification, TweenInfo.new(0.5), TweenData2)
            NotifTween:Play()
            NotifTween.Completed:Wait()
            
            self.Lib.Notifications.Queue[notif].Bind = Cover.Notification.Ok.MouseButton1Click:Connect(function()
                local TweenData3 = {
                    Position = UDim2.new(0.5, 0, 1, 0)
                }	

                local NotifTween2 = game:GetService("TweenService"):Create(Cover.Notification, TweenInfo.new(0.5), TweenData3)
                NotifTween2:Play()
                NotifTween2.Completed:Wait()
                
                local TweenData4 = {
                    Transparency = 1
                }

                local CoverTween2 = game:GetService("TweenService"):Create(Cover, TweenInfo.new(0.5), TweenData4)
                CoverTween2:Play()
                CoverTween2.Completed:Wait()
                Cover.Visible = false
                
                self.Lib.Notifications.Queue[notif].Bind:Disconnect()			
                table.remove(self.Lib.Notifications.Queue, notif)
                
                self.Lib.Notifications.Current = nil
            end)
        end

    end)
end

function library:Update(new, new2, new3)
    if self.table then
        self.table = new
        self.Refresh()
    elseif self.min and self.max then
        self.min = new
        self.max = new2
        self.Refresh(new3 or self.max/2, true)
    elseif self.toggle then
        if new ~= self.state then
            --self.state = (not new)
            self.Refresh()
        end
    elseif self.class == "label" then
        self.Refresh(new)
    end
end

function library:ToggleUI()
    self.UI.Enabled = not self.UI.Enabled 
end
