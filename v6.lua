-- MossadUI | standalone Luau UI library | MIT
local UIS = game:GetService('UserInputService')
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')
local Library = {Version = '1.4.1'}
local C = {bg=Color3.fromRGB(9,9,11), panel=Color3.fromRGB(12,11,14), field=Color3.fromRGB(15,14,18), line=Color3.fromRGB(28,26,32), text=Color3.fromRGB(234,232,237), muted=Color3.fromRGB(154,150,160), selected=Color3.fromRGB(25,20,32), track=Color3.fromRGB(31,28,37), alternate=Color3.fromRGB(15,14,17)}
local function new(class, parent, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function corner(o,r) new('UICorner',o,{CornerRadius=UDim.new(0,r or 2)}) end
local function stroke(o) return new('UIStroke',o,{Color=C.line,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function text(p,s,sz,color)
    return new('TextLabel',p,{BackgroundTransparency=1,Text=tostring(s or ''),TextColor3=color or C.text,Font=Enum.Font.Arial,TextSize=sz or 13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.fromScale(1,1)})
end
local function button(p,s)
    local b=new('TextButton',p,{BackgroundColor3=C.field,BorderSizePixel=0,AutoButtonColor=true,Text=tostring(s or ''),TextColor3=C.text,TextSize=13,Font=Enum.Font.Arial,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.fromScale(1,1)})
    corner(b,2); return b
end
local function list(p, gap, horizontal)
    return new('UIListLayout',p,{Padding=UDim.new(0,gap or 4),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical})
end
local function pad(p,n) new('UIPadding',p,{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)}) end
local function safe(cb,...)
    if type(cb)=='function' then local ok,err=pcall(cb,...); if not ok then warn('[MossadUI] '..tostring(err)) end end
end
local function keycode(k)
    if typeof(k)=='EnumItem' and k.EnumType==Enum.KeyCode then return k end
    if type(k)=='string' then local ok,v=pcall(function() return Enum.KeyCode[k] end); if ok then return v end end
end
local function hex(c) return string.format('#%02X%02X%02X',math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local function color(v)
    if typeof(v)=='Color3' then return v end
    if type(v)=='string' then local s=v:gsub('^#',''); if #s==6 and s:match('^%x+$') then return Color3.fromRGB(tonumber(s:sub(1,2),16),tonumber(s:sub(3,4),16),tonumber(s:sub(5,6),16)) end end
end
function Library:CreateWindow(o)
    o=o or {}
    local w={Accent=color(o.Accent) or Color3.fromRGB(180,126,229),Flags={},Controls={},Connections={},AccentBindings={},Tabs={},Keybinds={},Alive=true,ToggleKey=keycode(o.ToggleKey) or Enum.KeyCode.Insert}
    function w:Connect(signal,fn) local c=signal:Connect(fn); table.insert(self.Connections,c); return c end
    function w:Tint(obj,prop,active)
        table.insert(self.AccentBindings,{obj,prop,active}); if not active or active() then obj[prop]=self.Accent end
    end
    function w:SetAccent(v)
        local c=color(v); if not c then return false end; self.Accent=c
        for _,b in ipairs(self.AccentBindings) do if b[1].Parent and (not b[3] or b[3]()) then b[1][b[2]]=c end end
        return true
    end
    local parent=o.Parent or Players.LocalPlayer:WaitForChild('PlayerGui')
    local gui=new('ScreenGui',parent,{Name='MossadUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    local size=o.Size or Vector2.new(680,500)
    local main=new('Frame',gui,{Name='Window',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(size.X,size.Y),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true}); corner(main,3); stroke(main)
    local scale=new('UIScale',main,{Scale=1})
    local preferredScale=math.clamp(tonumber(o.Scale) or 1,.65,1.25)
    local function fit()
        local cam=workspace.CurrentCamera; if cam then local v=cam.ViewportSize; scale.Scale=math.max(.3,math.min(preferredScale,(v.X-16)/size.X,(v.Y-16)/size.Y)) end
    end
    function w:SetScale(value)
        local n=tonumber(value); if not n or n~=n then return false end
        preferredScale=math.clamp(n,.65,1.25); fit(); return true
    end
    fit(); if workspace.CurrentCamera then w:Connect(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fit) end
    local top=new('Frame',main,{Size=UDim2.new(1,0,0,33),BackgroundColor3=C.panel,BorderSizePixel=0})
    local brand=text(top,o.Title or 'void.ui',13); brand.Font=Enum.Font.ArialBold; brand.Active=true; brand.Position=UDim2.fromOffset(10,0); local brandWidth=math.clamp(math.ceil(TextService:GetTextSize(brand.Text,13,Enum.Font.ArialBold,Vector2.new(1000,33)).X)+15,82,132); brand.Size=UDim2.new(0,brandWidth-6,1,0); w:Tint(brand,'TextColor3')
    local nav=new('ScrollingFrame',top,{Position=UDim2.fromOffset(brandWidth+10,0),Size=UDim2.new(1,-brandWidth-34,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=w.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X}); list(nav,2,true); w:Tint(nav,'ScrollBarImageColor3')
    local hide=button(top,'-'); hide.Position=UDim2.new(1,-22,0,6); hide.Size=UDim2.fromOffset(16,20); hide.BackgroundTransparency=1; hide.TextColor3=C.muted
    new('Frame',top,{Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.line,BorderSizePixel=0})
    local body=new('Frame',main,{Position=UDim2.fromOffset(5,38),Size=UDim2.new(1,-10,1,-65),BackgroundTransparency=1})
    local footer=new('Frame',main,{Position=UDim2.new(0,0,1,-23),Size=UDim2.new(1,0,0,23),BackgroundColor3=C.panel,BorderSizePixel=0})
    local status=text(footer,o.Footer or 'MossadUI  /  v'..Library.Version,12); status.Position=UDim2.fromOffset(10,0); status.Size=UDim2.new(.5,-10,1,0); w:Tint(status,'TextColor3')
    local hint=text(footer,'Menu: '..w.ToggleKey.Name,12,C.muted); hint.Position=UDim2.fromScale(.5,0); hint.Size=UDim2.new(.5,-10,1,0); hint.TextXAlignment=Enum.TextXAlignment.Right
    -- One shared HSV popup per window. The row's HEX input remains editable.
    local colorTarget, colorDrag, colorTouch
    local hue, saturation, brightness = 0, 0, 1
    local paletteWriting = false
    local overlay=new('Frame',gui,{Name='ColorPickerOverlay',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=50})
    local dismiss=new('TextButton',overlay,{Name='Dismiss',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text='',AutoButtonColor=false,ZIndex=50})
    local popup=new('Frame',overlay,{Name='ColorPalette',Size=UDim2.fromOffset(206,191),BackgroundColor3=C.panel,BorderSizePixel=0,Active=true,ZIndex=51}); corner(popup,2)
    local outline=stroke(popup); outline.Color=Color3.fromRGB(63,57,72)
    local paletteScale=new('UIScale',popup,{Scale=1})
    local heading=text(popup,'Color picker',12,C.text); heading.Font=Enum.Font.ArialBold; heading.Position=UDim2.fromOffset(8,3); heading.Size=UDim2.fromOffset(166,20); heading.ZIndex=52; w:Tint(heading,'TextColor3')
    local closeButton=button(popup,'x'); closeButton.Position=UDim2.fromOffset(181,4); closeButton.Size=UDim2.fromOffset(17,18); closeButton.BackgroundTransparency=1; closeButton.TextColor3=C.muted; closeButton.ZIndex=52
    local function surface(name,pos,dimensions)
        return new('TextButton',popup,{Name=name,Position=pos,Size=dimensions,BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Text='',AutoButtonColor=false,ZIndex=52})
    end
    local sv=surface('SaturationValue',UDim2.fromOffset(8,27),UDim2.fromOffset(164,128))
    local white=new('Frame',sv,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=53})
    new('UIGradient',white,{Transparency=NumberSequence.new(0,1)})
    local black=new('Frame',sv,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=54})
    new('UIGradient',black,{Rotation=90,Transparency=NumberSequence.new(1,0)})
    local hueBar=surface('Hue',UDim2.fromOffset(180,27),UDim2.fromOffset(18,128))
    local rainbow={}
    for i=0,6 do rainbow[i+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1)) end
    new('UIGradient',hueBar,{Rotation=90,Color=ColorSequence.new(rainbow)})
    local svMarker=new('Frame',sv,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(8,8),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.35,BorderSizePixel=0,ZIndex=55}); corner(svMarker,4)
    new('UIStroke',svMarker,{Color=Color3.new(1,1,1),Thickness=1.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    local hueMarker=new('Frame',hueBar,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,0),Size=UDim2.new(1,4,0,4),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=55})
    new('UIStroke',hueMarker,{Color=Color3.new(0,0,0),Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    local preview=new('Frame',popup,{Position=UDim2.fromOffset(8,163),Size=UDim2.fromOffset(23,19),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=52}); stroke(preview)
    local code=text(popup,'#FFFFFF',12,C.text); code.Position=UDim2.fromOffset(37,162); code.Size=UDim2.fromOffset(87,21); code.ZIndex=52
    local reset=button(popup,'Reset'); reset.Position=UDim2.fromOffset(145,162); reset.Size=UDim2.fromOffset(53,21); reset.ZIndex=52; stroke(reset)
    local function drawPalette(v)
        sv.BackgroundColor3=Color3.fromHSV(hue,1,1)
        svMarker.Position=UDim2.fromScale(saturation,1-brightness)
        hueMarker.Position=UDim2.fromScale(.5,hue)
        preview.BackgroundColor3=v; code.Text=hex(v)
    end
    local function syncPalette(v,initial)
        local h,sat,val=v:ToHSV()
        if initial or (sat>0 and val>0) then hue=h end
        if initial or val>0 then saturation=sat end
        brightness=val; drawPalette(v)
    end
    local function closePalette()
        colorTarget=nil; colorDrag=nil; colorTouch=nil; overlay.Visible=false
    end
    local function openPalette(target)
        if colorTarget==target then closePalette(); return end
        closePalette(); colorTarget=target; heading.Text=target.Name
        syncPalette(target.Control:Get(),true)
        local pos,dimensions=target.Swatch.AbsolutePosition,target.Swatch.AbsoluteSize
        local viewport=overlay.AbsoluteSize
        if viewport.X<=0 or viewport.Y<=0 then
            local cam=workspace.CurrentCamera; viewport=cam and cam.ViewportSize or Vector2.new(800,600)
        end
        local factor=math.min(scale.Scale,math.max(.1,(viewport.X-12)/206),math.max(.1,(viewport.Y-12)/191))
        paletteScale.Scale=factor
        local width,height=206*factor,191*factor
        local x=pos.X+dimensions.X-width
        local y=pos.Y+dimensions.Y+5
        if y+height>viewport.Y-6 then y=pos.Y-height-5 end
        popup.Position=UDim2.fromOffset(math.clamp(x,6,math.max(6,viewport.X-width-6)),math.clamp(y,6,math.max(6,viewport.Y-height-6)))
        overlay.Visible=true
    end
    local function updatePalette(pos)
        if not colorTarget or not colorDrag then return end
        local surfaceObject=colorDrag=='SV' and sv or hueBar
        local origin,dimensions=surfaceObject.AbsolutePosition,surfaceObject.AbsoluteSize
        if dimensions.X<=0 or dimensions.Y<=0 then return end
        local x=math.clamp((pos.X-origin.X)/dimensions.X,0,1)
        local y=math.clamp((pos.Y-origin.Y)/dimensions.Y,0,1)
        if colorDrag=='SV' then saturation=x; brightness=1-y else hue=y end
        local v=Color3.fromHSV(hue,saturation,brightness)
        paletteWriting=true; colorTarget.Control:Set(v); paletteWriting=false
        if colorTarget then drawPalette(colorTarget.Control:Get()) end
    end
    local function beginPaletteDrag(kind,i)
        if not colorTarget then return end
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            colorDrag=kind; colorTouch=i; updatePalette(i.Position)
        end
    end
    w:Connect(sv.InputBegan,function(i) beginPaletteDrag('SV',i) end)
    w:Connect(hueBar.InputBegan,function(i) beginPaletteDrag('Hue',i) end)
    w:Connect(UIS.InputChanged,function(i)
        if colorDrag and (i==colorTouch or (colorTouch and colorTouch.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then updatePalette(i.Position) end
    end)
    w:Connect(UIS.InputEnded,function(i)
        if i==colorTouch or (colorTouch and colorTouch.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseButton1) then colorDrag=nil; colorTouch=nil end
    end)
    w:Connect(UIS.WindowFocusReleased,function() colorDrag=nil; colorTouch=nil end)
    w:Connect(dismiss.Activated,closePalette)
    w:Connect(closeButton.Activated,closePalette)
    w:Connect(reset.Activated,function() if colorTarget then local target=colorTarget; target.Control:Set(target.Default); if colorTarget==target then syncPalette(target.Control:Get(),true) end end end)
    w:Connect(scale:GetPropertyChangedSignal('Scale'),closePalette)
    w:Connect(overlay:GetPropertyChangedSignal('AbsoluteSize'),closePalette)
    function w:SetVisible(v) if not v then closePalette() end; gui.Enabled=not not v end
    function w:Toggle() self:SetVisible(not gui.Enabled) end
    function w:SetToggleKey(v) local k=keycode(v); if k then self.ToggleKey=k; hint.Text='Menu: '..k.Name end end
    function w:SetStatus(v) status.Text=tostring(v) end
    function w:Destroy() if not self.Alive then return end; self.Alive=false; for _,c in ipairs(self.Connections) do c:Disconnect() end; gui:Destroy() end
    w.Gui=gui; w.Frame=main
    w:Connect(hide.Activated,function() w:Toggle() end)
    local dragging,dragStart,startPos,dragTouch
    w:Connect(brand.InputBegan,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=i.Position; startPos=main.Position; dragTouch=i end
    end)
    w:Connect(UIS.InputChanged,function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i==dragTouch) then local d=i.Position-dragStart; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
    end)
    w:Connect(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i==dragTouch then dragging=false end end)
    w:Connect(UIS.InputBegan,function(i,processed)
        if colorTarget and i.KeyCode==Enum.KeyCode.Escape then closePalette(); return end
        if processed or UIS:GetFocusedTextBox() then return end
        if w.Capturing then local cb=w.Capturing; w.Capturing=nil; if i.KeyCode==Enum.KeyCode.Unknown then cb(nil) else cb(i.KeyCode) end; return end
        if i.KeyCode==w.ToggleKey then w:Toggle() end
        if i.KeyCode~=Enum.KeyCode.Unknown then for _,entry in ipairs(w.Keybinds) do if i.KeyCode==entry.Control:Get() then safe(entry.Callback,i.KeyCode) end end end
    end)
    function w:GetConfig() return HttpService:JSONEncode(self.Flags) end
    function w:LoadConfig(v,silent)
        if type(v)=='string' then local ok,r=pcall(function() return HttpService:JSONDecode(v) end); if not ok then return false,r end; v=r end
        if type(v)~='table' then return false,'Expected JSON object or table' end
        for k,x in pairs(v) do if self.Controls[k] then self.Controls[k]:Set(x,silent) end end; return true
    end
    local nextFlag=0
    local function control(opts,normalize,render,default,encode)
        nextFlag+=1; local flag=opts.Flag or tostring(nextFlag)
        assert(not w.Controls[flag], 'Duplicate flag: '..flag)
        local ctl={Flag=flag}
        function ctl:Set(v,silent)
            local normalized=normalize(v); if normalized==nil then return false end
            self.Value=normalized; render(normalized); if not opts.NoSave then w.Flags[flag]=encode and encode(normalized) or normalized end
            if not silent then safe(opts.Callback,normalized) end; return true
        end
        function ctl:Get() return self.Value end
        w.Controls[flag]=ctl; ctl:Set(default,true); return ctl
    end
    function w:AddTab(name)
        if type(name)=='table' then name=name.Name or name.Title end; name=tostring(name or 'Tab')
        local tab={Window=self}; table.insert(self.Tabs,tab)
        local tabButton=button(nav,name); tabButton.BackgroundTransparency=1; tabButton.TextColor3=C.muted; tabButton.TextSize=13; tabButton.LayoutOrder=#self.Tabs; local nameWidth=TextService:GetTextSize(name,13,Enum.Font.Arial,Vector2.new(10000,33)).X; tabButton.Size=UDim2.fromOffset(math.max(32,math.ceil(nameWidth)+12),32)
        local underline=new('Frame',tabButton,{Position=UDim2.new(0,5,1,-1),Size=UDim2.new(1,-10,0,1),BorderSizePixel=0,BackgroundColor3=w.Accent,Visible=false}); w:Tint(underline,'BackgroundColor3')
        local page=new('Frame',body,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
        local function column(x)
            local c=new('ScrollingFrame',page,{Position=UDim2.new(x,x==0 and 0 or 3,0,0),Size=UDim2.new(.5,-3,1,0),BackgroundColor3=C.panel,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2,ScrollBarImageColor3=w.Accent,ScrollBarImageTransparency=.2}); stroke(c); w:Tint(c,'ScrollBarImageColor3'); list(c,3); return c
        end
        local left,right=column(0),column(.5)
        function tab:Select()
            closePalette()
            for _,t in ipairs(w.Tabs) do t.Page.Visible=false; t.Button.TextColor3=C.muted; t.Button.BackgroundTransparency=1; t.Underline.Visible=false end
            page.Visible=true; tabButton.TextColor3=w.Accent; tabButton.BackgroundColor3=C.selected; tabButton.BackgroundTransparency=1; underline.Visible=true; w.ActiveTab=tab
        end
        tab.Page=page; tab.Button=tabButton; tab.Underline=underline; w:Tint(tabButton,'TextColor3',function() return w.ActiveTab==tab end)
        w:Connect(tabButton.Activated,function() tab:Select() end); if #w.Tabs==1 then tab:Select() end
        function tab:AddSection(name,side)
            if type(name)=='table' then side=name.Side; name=name.Name or name.Title end
            local section={}; local p=new('Frame',side and tostring(side):lower()=='right' and right or left,{Size=UDim2.new(1,-2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0}); pad(p,6); list(p,2)
            section.Frame=p
            function section:SetVisible(v) if not v and colorTarget and colorTarget.Swatch:IsDescendantOf(p) then closePalette() end; p.Visible=not not v end
            local heading=text(p,name or 'Section',13); heading.Font=Enum.Font.ArialBold; heading.Size=UDim2.new(1,0,0,19); heading.LayoutOrder=0; w:Tint(heading,'TextColor3')
            local rowOrder=0
            local function row(h) rowOrder+=1; return new('Frame',p,{LayoutOrder=rowOrder,Size=UDim2.new(1,0,0,h or 20),BackgroundTransparency=1}) end
            local function label(r,s,f) local t=text(r,s,13); t.Size=UDim2.new(f or .6,-5,1,0); return t end
            local function input(r,placeholder)
                local b=new('TextBox',r,{BackgroundColor3=C.field,BorderSizePixel=0,Font=Enum.Font.Arial,TextSize=13,TextColor3=C.text,PlaceholderColor3=C.muted,PlaceholderText=placeholder or '',Text='',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.fromScale(1,1)}); corner(b,2); stroke(b); new('UIPadding',b,{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5)}); return b
            end
            function section:AddLabel(s) local r=row(18); local t=text(r,type(s)=='table' and s.Name or s,13,C.muted); return {Set=function(_,v) t.Text=tostring(v) end} end
            function section:AddButton(a) local r=row(21); local b=button(r,a.Name or 'Button'); stroke(b); w:Connect(b.Activated,function() safe(a.Callback) end); return b end
            function section:AddToggle(a)
                local r=row(19); local b=button(r,''); b.BackgroundTransparency=1; local square=new('Frame',b,{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(0,2),BackgroundColor3=C.field,BorderSizePixel=0}); corner(square,2); stroke(square)
                local mark=new('Frame',square,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
                new('Frame',mark,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(5,8),Size=UDim2.fromOffset(4,2),Rotation=45,BackgroundColor3=C.bg,BorderSizePixel=0})
                new('Frame',mark,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(8,7),Size=UDim2.fromOffset(8,2),Rotation=-45,BackgroundColor3=C.bg,BorderSizePixel=0})
                local t=text(b,a.Name or 'Toggle'); t.Position=UDim2.fromOffset(19,0); t.Size=UDim2.new(1,-19,1,0)
                local ctl=control(a,function(v) if type(v)=='boolean' then return v end end,function(v) square.BackgroundColor3=v and w.Accent or C.field; mark.Visible=v; t.TextColor3=v and C.text or C.muted end,a.Default==true)
                w:Tint(square,'BackgroundColor3',function() return ctl:Get() end); w:Connect(b.Activated,function() ctl:Set(not ctl:Get()) end); return ctl
            end
            function section:AddSlider(a)
                local lo,hi=a.Min or 0,a.Max or 100; assert(hi>lo,'Slider Max must exceed Min'); local step=a.Step or 1; assert(step>0,'Slider Step must be positive')
                local r=row(29); local t=text(r,a.Name or 'Slider'); t.Size=UDim2.new(.72,-4,0,15); local val=text(r,'',13,C.text); val.Position=UDim2.fromScale(.72,0); val.Size=UDim2.new(.28,0,0,15); val.TextXAlignment=Enum.TextXAlignment.Right
                local bar=button(r,''); bar.Position=UDim2.fromOffset(3,15); bar.Size=UDim2.new(1,-6,0,13); bar.BackgroundTransparency=1
                local track=new('Frame',bar,{Position=UDim2.fromOffset(0,5),Size=UDim2.new(1,0,0,3),BackgroundColor3=C.track,BorderSizePixel=0}); corner(track,2)
                local fill=new('Frame',track,{Size=UDim2.fromScale(0,1),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(fill,2); w:Tint(fill,'BackgroundColor3')
                local knob=new('Frame',track,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(7,7),Position=UDim2.fromScale(0,.5),BackgroundColor3=C.track,BorderSizePixel=0}); corner(knob,4)
                local ctl=control(a,function(v) v=tonumber(v); if v and v==v and math.abs(v)<math.huge then if v>=hi then return hi end; return math.clamp(lo+math.round((v-lo)/step)*step,lo,hi) end end,function(v) local f=(v-lo)/(hi-lo); fill.Size=UDim2.fromScale(f,1); knob.Position=UDim2.fromScale(f,.5); val.Text=string.format('%.6g',v)..(a.Suffix or '') end,a.Default or lo)
                local sliding,touch=false,nil
                local function update(x) if bar.AbsoluteSize.X>0 then ctl:Set(lo+math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(hi-lo)) end end
                w:Connect(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; touch=i; update(i.Position.X) end end)
                w:Connect(UIS.InputChanged,function(i) if sliding and (i==touch or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i.Position.X) end end)
                w:Connect(UIS.InputEnded,function(i) if i==touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end); return ctl
            end
            function section:AddDropdown(a)
                local items={}; for _,v in ipairs(a.Options or {}) do table.insert(items,tostring(v)) end
                local r=row(37); local t=text(r,a.Name or 'Dropdown',13,C.muted); t.Size=UDim2.new(1,0,0,15)
                local b=button(r,''); b.Position=UDim2.fromOffset(0,16); b.Size=UDim2.new(1,0,0,20); b.TextXAlignment=Enum.TextXAlignment.Left; new('UIPadding',b,{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,16)}); stroke(b)
                local arrow=new('Frame',b,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-1,.5,0),Size=UDim2.fromOffset(10,10),BackgroundColor3=C.field,BorderSizePixel=0,ZIndex=3})
                for _,part in ipairs({{3,45},{6,-45}}) do new('Frame',arrow,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(part[1],5),Size=UDim2.fromOffset(5,1),Rotation=part[2],BackgroundColor3=C.muted,BorderSizePixel=0,ZIndex=4}) end
                local panel=new('Frame',r,{Position=UDim2.fromOffset(0,39),Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,Visible=false}); list(panel,2)
                local opened=false; local optionButtons={}
                local function open(v) opened=v; panel.Visible=v; local h=math.max(0,#items*22-2); panel.Size=UDim2.new(1,0,0,h); r.Size=UDim2.new(1,0,0,v and 39+h or 37) end
                local function normalize(v)
                    if a.Multi then if type(v)~='table' then return nil end; local out={}; for _,item in ipairs(items) do if table.find(v,item) then table.insert(out,item) end end; return out end
                    if table.find(items,tostring(v)) then return tostring(v) end; if #items==0 then return '' end
                end
                local ctl=control(a,normalize,function(v)
                    local s=type(v)=='table' and table.concat(v,', ') or v; b.Text=(s=='' and 'Select...' or s)
                    for item,ob in pairs(optionButtons) do local active=type(v)=='table' and table.find(v,item)~=nil or v==item; ob.TextColor3=active and w.Accent or C.text end
                end,a.Default or (a.Multi and {} or items[1] or ''))
                for _,item in ipairs(items) do local ob=button(panel,item); ob.Size=UDim2.new(1,0,0,20); optionButtons[item]=ob; w:Tint(ob,'TextColor3',function() local v=ctl:Get(); return type(v)=='table' and table.find(v,item)~=nil or v==item end); w:Connect(ob.Activated,function() if a.Multi then local v=table.clone(ctl:Get() or {}); local idx=table.find(v,item); if idx then table.remove(v,idx) else table.insert(v,item) end; ctl:Set(v) else ctl:Set(item); open(false) end end) end
                if ctl:Get()~=nil then ctl:Set(ctl:Get(),true) else ctl:Set(a.Multi and {} or items[1] or '',true) end; w:Connect(b.Activated,function() open(not opened) end); return ctl
            end
            function section:AddTextbox(a)
                local r=row(37); local t=text(r,a.Name or 'Text',13,C.muted); t.Size=UDim2.new(1,0,0,15); local b=input(r,a.Placeholder); b.Position=UDim2.fromOffset(0,16); b.Size=UDim2.new(1,0,0,20)
                local ctl=control(a,function(v) if type(v)=='string' then return v end end,function(v) b.Text=v end,a.Default or ''); local function commit() if b.Text~=ctl:Get() then ctl:Set(b.Text) end end; if a.Live then w:Connect(b:GetPropertyChangedSignal('Text'),commit) end; w:Connect(b.FocusLost,commit); return ctl
            end
            function section:AddKeybind(a)
                local r=row(21); label(r,a.Name or 'Keybind'); local b=button(r,''); b.Position=UDim2.fromScale(.68,0); b.Size=UDim2.fromScale(.32,1); b.BackgroundTransparency=1; b.TextXAlignment=Enum.TextXAlignment.Right
                local ctl=control(a,keycode,function(v) b.Text=v==Enum.KeyCode.Unknown and 'None' or v.Name end,keycode(a.Default) or Enum.KeyCode.Unknown,function(v) return v.Name end)
                w:Connect(b.Activated,function() if w.Capturing then local old=w.Capturing; w.Capturing=nil; old(nil) end; b.Text='Press key...'; w.Capturing=function(k) if k and k~=Enum.KeyCode.Escape then ctl:Set(k) else b.Text=ctl:Get()==Enum.KeyCode.Unknown and 'None' or ctl:Get().Name end end end)
                table.insert(w.Keybinds,{Control=ctl,Callback=a.OnPressed}); return ctl
            end
            function section:AddColorPicker(a)
                local r=row(21); label(r,a.Name or 'Color',.48)
                local sw=button(r,''); sw.Position=UDim2.new(.48,0,0,4); sw.Size=UDim2.fromOffset(20,13); sw.AutoButtonColor=false; stroke(sw)
                local b=input(r,'#FFFFFF'); b.Position=UDim2.new(.48,25,0,1); b.Size=UDim2.new(.52,-25,1,-2)
                local target={Name=a.Name or 'Color',Swatch=sw,Default=color(a.Default) or w.Accent}
                local ctl=control(a,color,function(v)
                    sw.BackgroundColor3=v; b.Text=hex(v)
                    if colorTarget==target and not paletteWriting then syncPalette(v,false) end
                end,target.Default,hex)
                target.Control=ctl
                w:Connect(sw.Activated,function() openPalette(target) end)
                w:Connect(b.FocusLost,function() if b.Text~=hex(ctl:Get()) and not ctl:Set(b.Text) then b.Text=hex(ctl:Get()) end end)
                return ctl
            end
            -- Generic searchable table. Rows are plain display data.
            function section:AddTable(a)
                local headers=a.Headers or {'Name'}
                local data=a.Rows or {}
                local wrap=row(23); wrap.AutomaticSize=Enum.AutomaticSize.Y; list(wrap,2)
                local function drawLine(values, header, index)
                    local line=new('Frame',wrap,{Size=UDim2.new(1,0,0,23),BackgroundColor3=header and C.field or ((index or 0)%2==0 and C.alternate or C.panel),BorderSizePixel=0}); corner(line,1)
                    local x=0
                    for i=1,#headers do
                        local width=(a.Widths and a.Widths[i]) or 1/#headers
                        local cell=text(line,values[i] or '',header and 12 or 13,header and C.muted or C.text)
                        if header then cell.Font=Enum.Font.ArialBold end
                        cell.Position=UDim2.new(x,4,0,0); cell.Size=UDim2.new(width,-8,1,0); x+=width
                    end
                    return line
                end
                local header=drawLine(headers,true); header.LayoutOrder=0
                local lines={}; local filter=''
                local api={}
                local function refresh()
                    for _,line in ipairs(lines) do line:Destroy() end; table.clear(lines)
                    for _,values in ipairs(data) do
                        local strings={}; for i=1,#headers do strings[i]=tostring(values[i] or '') end
                        if filter=='' or string.find(string.lower(table.concat(strings,' ')),filter,1,true) then
                            local line=drawLine(strings,false,#lines+1); line.LayoutOrder=#lines+1; table.insert(lines,line)
                        end
                    end
                    if #lines==0 then local empty=drawLine({'No results'},false,1); empty.LayoutOrder=1; table.insert(lines,empty) end
                end
                function api:SetRows(v) data=v or {}; refresh() end
                function api:SetFilter(v) filter=string.lower(tostring(v or '')); refresh() end
                refresh(); return api
            end
            -- Generic selectable cards. Image is an optional Roblox asset URI.
            function section:AddCardGrid(a)
                local items=a.Items or {}; local columns=math.max(1,math.floor(a.Columns or 2))
                local holder=row(1); local cellHeight=100; local cells={}; local selected=nil; local filter=''
                local grid=new('UIGridLayout',holder,{CellSize=UDim2.new(1/columns,-6,0,cellHeight),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder,FillDirectionMaxCells=columns})
                local api={}
                local function refresh()
                    for _,cell in ipairs(cells) do cell:Destroy() end; table.clear(cells)
                    for _,item in ipairs(items) do
                        local item=type(item)=='table' and item or {Name=tostring(item)}
                        local name=tostring(item.Name or '')
                        if filter=='' or string.find(string.lower(name),filter,1,true) then
                            local card=button(holder,''); card.LayoutOrder=#cells+1; local outline=stroke(card)
                            outline.Color=selected==name and w.Accent or C.line
                            local preview=new('ImageLabel',card,{BackgroundTransparency=1,Position=UDim2.fromOffset(5,4),Size=UDim2.new(1,-10,0,62),Image=item.Image or '',ScaleType=Enum.ScaleType.Fit})
                            if not item.Image then local placeholder=text(preview,'-',18,C.muted); placeholder.TextXAlignment=Enum.TextXAlignment.Center end
                            local title=text(card,name,13); title.Position=UDim2.new(0,5,1,-36); title.Size=UDim2.new(1,-10,0,31); title.TextXAlignment=Enum.TextXAlignment.Center; title.TextWrapped=true; title.TextTruncate=Enum.TextTruncate.None
                            new('Frame',card,{Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),BorderSizePixel=0,BackgroundColor3=color(item.Color) or C.line})
                            card.Activated:Connect(function() selected=name; safe(a.Callback,item); refresh() end)
                            table.insert(cells,card)
                        end
                    end
                    holder.Size=UDim2.new(1,0,0,math.max(1,math.ceil(#cells/columns)*(cellHeight+6)-6))
                end
                function api:SetItems(v) items=v or {}; refresh() end
                function api:SetFilter(v) filter=string.lower(tostring(v or '')); refresh() end
                function api:Get() return selected end
                refresh(); return api
            end
            return section
        end
        -- Category navigation: side list by default, optional horizontal strip.
        function tab:AddCategories(title, placement)
            local horizontal=placement=='Top'
            local menu,strip
            if horizontal then
                left.Visible=false
                right.Position=UDim2.fromOffset(0,30); right.Size=UDim2.new(1,0,1,-30)
                strip=new('ScrollingFrame',page,{Size=UDim2.new(1,0,0,26),BackgroundColor3=C.panel,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=1,ScrollBarImageColor3=w.Accent})
                list(strip,2,true); w:Tint(strip,'ScrollBarImageColor3'); stroke(strip)
            else
                left.Size=UDim2.new(.42,-3,1,0); right.Position=UDim2.new(.42,3,0,0); right.Size=UDim2.new(.58,-3,1,0)
                menu=self:AddSection(title or 'Categories','Left')
            end
            local api={Entries={}}
            function api:Select(name)
                closePalette()
                for _,entry in ipairs(self.Entries) do
                    local active=entry.Name==name
                    entry.Section:SetVisible(active)
                    entry.Button.TextColor3=active and w.Accent or C.muted
                    entry.Button.BackgroundColor3=C.selected; entry.Button.BackgroundTransparency=(active and not horizontal) and 0 or 1
                    if entry.Marker then entry.Marker.Visible=active end
                end
            end
            function api:Add(name)
                local section=tab:AddSection(name,'Right')
                local b,marker
                if horizontal then
                    b=button(strip,name); b.Size=UDim2.fromOffset(math.max(35,math.ceil(TextService:GetTextSize(name,13,Enum.Font.Arial,Vector2.new(10000,26)).X)+12),25)
                    b.LayoutOrder=#self.Entries+1
                    marker=new('Frame',b,{Position=UDim2.new(0,4,1,-1),Size=UDim2.new(1,-8,0,1),BackgroundColor3=w.Accent,BorderSizePixel=0,Visible=false}); w:Tint(marker,'BackgroundColor3')
                    w:Connect(b.Activated,function() api:Select(name) end)
                else
                    b=menu:AddButton({Name=name,Callback=function() api:Select(name) end})
                    b.TextXAlignment=Enum.TextXAlignment.Left
                    local outline=b:FindFirstChildOfClass('UIStroke'); if outline then outline:Destroy() end
                    new('UIPadding',b,{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,4)})
                end
                b.BackgroundTransparency=1; b.TextColor3=C.muted
                table.insert(self.Entries,{Name=name,Section=section,Button=b,Marker=marker})
                if #self.Entries==1 then self:Select(name) else section:SetVisible(false) end
                w:Tint(b,'TextColor3',function() return section.Frame.Visible end)
                return section
            end
            return api
        end
        return tab
    end
    return w
end
return Library
