-- VoidUI | standalone Luau UI library | MIT
local UIS = game:GetService('UserInputService')
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')
local Library = {Version = '1.3.0'}
local C = {bg=Color3.fromRGB(13,12,16), panel=Color3.fromRGB(19,18,24), field=Color3.fromRGB(29,27,36), line=Color3.fromRGB(46,43,55), text=Color3.fromRGB(244,242,249), muted=Color3.fromRGB(183,178,194), selected=Color3.fromRGB(43,34,56), track=Color3.fromRGB(49,45,61), alternate=Color3.fromRGB(24,22,31)}
local function new(class, parent, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function corner(o,r) new('UICorner',o,{CornerRadius=UDim.new(0,r or 5)}) end
local function stroke(o) return new('UIStroke',o,{Color=C.line,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function text(p,s,sz,color)
    return new('TextLabel',p,{BackgroundTransparency=1,Text=tostring(s or ''),TextColor3=color or C.text,Font=Enum.Font.Gotham,TextSize=sz or 14,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.fromScale(1,1)})
end
local function button(p,s)
    local b=new('TextButton',p,{BackgroundColor3=C.field,BorderSizePixel=0,AutoButtonColor=true,Text=tostring(s or ''),TextColor3=C.text,TextSize=14,Font=Enum.Font.GothamMedium,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.fromScale(1,1)})
    corner(b,5); return b
end
local function list(p, gap, horizontal)
    return new('UIListLayout',p,{Padding=UDim.new(0,gap or 4),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical})
end
local function pad(p,n) new('UIPadding',p,{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)}) end
local function safe(cb,...)
    if type(cb)=='function' then local ok,err=pcall(cb,...); if not ok then warn('[VoidUI] '..tostring(err)) end end
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
    local w={Accent=color(o.Accent) or Color3.fromRGB(192,151,247),Flags={},Controls={},Connections={},AccentBindings={},Tabs={},Keybinds={},Alive=true,ToggleKey=keycode(o.ToggleKey) or Enum.KeyCode.Insert}
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
    local gui=new('ScreenGui',parent,{Name='VoidUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    local size=o.Size or Vector2.new(740,530)
    local main=new('Frame',gui,{Name='Window',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(size.X,size.Y),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true}); corner(main,8); stroke(main)
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
    local top=new('Frame',main,{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.panel,BorderSizePixel=0})
    local brand=text(top,o.Title or 'void.ui',15); brand.Font=Enum.Font.GothamBold; brand.Active=true; brand.Position=UDim2.fromOffset(12,0); brand.Size=UDim2.new(0,86,1,0); w:Tint(brand,'TextColor3')
    local nav=new('ScrollingFrame',top,{Position=UDim2.fromOffset(100,0),Size=UDim2.new(1,-138,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=w.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X}); list(nav,2,true); w:Tint(nav,'ScrollBarImageColor3')
    local hide=button(top,'–'); hide.Position=UDim2.new(1,-32,0,7); hide.Size=UDim2.fromOffset(25,26)
    local body=new('Frame',main,{Position=UDim2.fromOffset(9,49),Size=UDim2.new(1,-18,1,-84),BackgroundTransparency=1})
    local footer=new('Frame',main,{Position=UDim2.new(0,0,1,-26),Size=UDim2.new(1,0,0,26),BackgroundColor3=C.panel,BorderSizePixel=0})
    local status=text(footer,o.Footer or 'VoidUI  /  v'..Library.Version,12); status.Position=UDim2.fromOffset(10,0); status.Size=UDim2.new(.5,-10,1,0); w:Tint(status,'TextColor3')
    local hint=text(footer,'Menu: '..w.ToggleKey.Name,12,C.muted); hint.Position=UDim2.fromScale(.5,0); hint.Size=UDim2.new(.5,-10,1,0); hint.TextXAlignment=Enum.TextXAlignment.Right
    function w:SetVisible(v) gui.Enabled=not not v end
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
        local tabButton=button(nav,name); tabButton.BackgroundTransparency=1; tabButton.TextColor3=C.muted; tabButton.TextSize=13; tabButton.LayoutOrder=#self.Tabs; local nameWidth=TextService:GetTextSize(name,13,Enum.Font.GothamMedium,Vector2.new(10000,40)).X; tabButton.Size=UDim2.fromOffset(math.max(39,math.ceil(nameWidth)+13),40)
        local underline=new('Frame',tabButton,{Position=UDim2.new(0,5,1,-2),Size=UDim2.new(1,-10,0,2),BorderSizePixel=0,BackgroundColor3=w.Accent,Visible=false}); w:Tint(underline,'BackgroundColor3')
        local page=new('Frame',body,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
        local function column(x)
            local c=new('ScrollingFrame',page,{Position=UDim2.new(x,x==0 and 0 or 6,0,0),Size=UDim2.new(.5,-6,1,0),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ScrollBarImageColor3=w.Accent}); w:Tint(c,'ScrollBarImageColor3'); list(c,7); return c
        end
        local left,right=column(0),column(.5)
        function tab:Select()
            for _,t in ipairs(w.Tabs) do t.Page.Visible=false; t.Button.TextColor3=C.muted; t.Button.BackgroundTransparency=1; t.Underline.Visible=false end
            page.Visible=true; tabButton.TextColor3=w.Accent; tabButton.BackgroundColor3=C.selected; tabButton.BackgroundTransparency=.45; underline.Visible=true; w.ActiveTab=tab
        end
        tab.Page=page; tab.Button=tabButton; tab.Underline=underline; w:Tint(tabButton,'TextColor3',function() return w.ActiveTab==tab end)
        w:Connect(tabButton.Activated,function() tab:Select() end); if #w.Tabs==1 then tab:Select() end
        function tab:AddSection(name,side)
            if type(name)=='table' then side=name.Side; name=name.Name or name.Title end
            local section={}; local p=new('Frame',side and tostring(side):lower()=='right' and right or left,{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.panel,BorderSizePixel=0}); corner(p,5); stroke(p); pad(p,9); list(p,5)
            section.Frame=p
            function section:SetVisible(v) p.Visible=not not v end
            local heading=text(p,name or 'Section',15); heading.Font=Enum.Font.GothamBold; heading.Size=UDim2.new(1,0,0,22); heading.LayoutOrder=0; w:Tint(heading,'TextColor3')
            local rowOrder=0
            local function row(h) rowOrder+=1; return new('Frame',p,{LayoutOrder=rowOrder,Size=UDim2.new(1,0,0,h or 26),BackgroundTransparency=1}) end
            local function label(r,s,f) local t=text(r,s,14); t.Size=UDim2.new(f or .6,-5,1,0); return t end
            local function input(r,placeholder)
                local b=new('TextBox',r,{BackgroundColor3=C.field,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=14,TextColor3=C.text,PlaceholderColor3=C.muted,PlaceholderText=placeholder or '',Text='',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.fromScale(1,1)}); corner(b,5); stroke(b); new('UIPadding',b,{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,9)}); return b
            end
            function section:AddLabel(s) local r=row(22); local t=text(r,type(s)=='table' and s.Name or s,13,C.muted); return {Set=function(_,v) t.Text=tostring(v) end} end
            function section:AddButton(a) local r=row(28); local b=button(r,a.Name or 'Button'); stroke(b); w:Connect(b.Activated,function() safe(a.Callback) end); return b end
            function section:AddToggle(a)
                local r=row(25); local b=button(r,''); b.BackgroundTransparency=1; local square=new('Frame',b,{Size=UDim2.fromOffset(17,17),Position=UDim2.fromOffset(0,4),BackgroundColor3=C.field,BorderSizePixel=0}); corner(square,3); stroke(square)
                local mark=text(square,'✓',14,C.bg); mark.TextXAlignment=Enum.TextXAlignment.Center; mark.Visible=false
                local t=text(b,a.Name or 'Toggle'); t.Position=UDim2.fromOffset(24,0); t.Size=UDim2.new(1,-24,1,0)
                local ctl=control(a,function(v) if type(v)=='boolean' then return v end end,function(v) square.BackgroundColor3=v and w.Accent or C.field; mark.Visible=v end,a.Default==true)
                w:Tint(square,'BackgroundColor3',function() return ctl:Get() end); w:Connect(b.Activated,function() ctl:Set(not ctl:Get()) end); return ctl
            end
            function section:AddSlider(a)
                local lo,hi=a.Min or 0,a.Max or 100; assert(hi>lo,'Slider Max must exceed Min'); local step=a.Step or 1; assert(step>0,'Slider Step must be positive')
                local r=row(38); local t=text(r,a.Name or 'Slider'); t.Size=UDim2.new(.72,-4,0,19); local val=text(r,'',13,C.text); val.Position=UDim2.fromScale(.72,0); val.Size=UDim2.new(.28,0,0,19); val.TextXAlignment=Enum.TextXAlignment.Right
                local bar=button(r,''); bar.Position=UDim2.fromOffset(5,20); bar.Size=UDim2.new(1,-10,0,16); bar.BackgroundTransparency=1
                local track=new('Frame',bar,{Position=UDim2.fromOffset(0,6),Size=UDim2.new(1,0,0,4),BackgroundColor3=C.track,BorderSizePixel=0}); corner(track,2)
                local fill=new('Frame',track,{Size=UDim2.fromScale(0,1),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(fill,2); w:Tint(fill,'BackgroundColor3')
                local knob=new('Frame',track,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(10,10),Position=UDim2.fromScale(0,.5),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(knob,6); w:Tint(knob,'BackgroundColor3')
                local ctl=control(a,function(v) v=tonumber(v); if v and v==v and math.abs(v)<math.huge then if v>=hi then return hi end; return math.clamp(lo+math.round((v-lo)/step)*step,lo,hi) end end,function(v) local f=(v-lo)/(hi-lo); fill.Size=UDim2.fromScale(f,1); knob.Position=UDim2.fromScale(f,.5); val.Text=string.format('%.6g',v)..(a.Suffix or '') end,a.Default or lo)
                local sliding,touch=false,nil
                local function update(x) if bar.AbsoluteSize.X>0 then ctl:Set(lo+math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(hi-lo)) end end
                w:Connect(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; touch=i; update(i.Position.X) end end)
                w:Connect(UIS.InputChanged,function(i) if sliding and (i==touch or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i.Position.X) end end)
                w:Connect(UIS.InputEnded,function(i) if i==touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end); return ctl
            end
            function section:AddDropdown(a)
                local items={}; for _,v in ipairs(a.Options or {}) do table.insert(items,tostring(v)) end
                local r=row(51); local t=text(r,a.Name or 'Dropdown',14,C.muted); t.Size=UDim2.new(1,0,0,19)
                local b=button(r,''); b.Position=UDim2.fromOffset(0,21); b.Size=UDim2.new(1,0,0,28); b.TextXAlignment=Enum.TextXAlignment.Left; new('UIPadding',b,{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,9)}); stroke(b)
                local panel=new('Frame',r,{Position=UDim2.fromOffset(0,54),Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,Visible=false}); list(panel,3)
                local opened=false; local optionButtons={}
                local function open(v) opened=v; panel.Visible=v; local h=math.max(0,#items*30-3); panel.Size=UDim2.new(1,0,0,h); r.Size=UDim2.new(1,0,0,v and 54+h or 51) end
                local function normalize(v)
                    if a.Multi then if type(v)~='table' then return nil end; local out={}; for _,item in ipairs(items) do if table.find(v,item) then table.insert(out,item) end end; return out end
                    if table.find(items,tostring(v)) then return tostring(v) end; if #items==0 then return '' end
                end
                local ctl=control(a,normalize,function(v)
                    local s=type(v)=='table' and table.concat(v,', ') or v; b.Text=(s=='' and 'Select...' or s)..'  ▾'
                    for item,ob in pairs(optionButtons) do local active=type(v)=='table' and table.find(v,item)~=nil or v==item; ob.TextColor3=active and w.Accent or C.text end
                end,a.Default or (a.Multi and {} or items[1] or ''))
                for _,item in ipairs(items) do local ob=button(panel,item); ob.Size=UDim2.new(1,0,0,27); optionButtons[item]=ob; w:Tint(ob,'TextColor3',function() local v=ctl:Get(); return type(v)=='table' and table.find(v,item)~=nil or v==item end); w:Connect(ob.Activated,function() if a.Multi then local v=table.clone(ctl:Get() or {}); local idx=table.find(v,item); if idx then table.remove(v,idx) else table.insert(v,item) end; ctl:Set(v) else ctl:Set(item); open(false) end end) end
                if ctl:Get()~=nil then ctl:Set(ctl:Get(),true) else ctl:Set(a.Multi and {} or items[1] or '',true) end; w:Connect(b.Activated,function() open(not opened) end); return ctl
            end
            function section:AddTextbox(a)
                local r=row(51); local t=text(r,a.Name or 'Text',14,C.muted); t.Size=UDim2.new(1,0,0,19); local b=input(r,a.Placeholder); b.Position=UDim2.fromOffset(0,21); b.Size=UDim2.new(1,0,0,28)
                local ctl=control(a,function(v) if type(v)=='string' then return v end end,function(v) b.Text=v end,a.Default or ''); local function commit() if b.Text~=ctl:Get() then ctl:Set(b.Text) end end; if a.Live then w:Connect(b:GetPropertyChangedSignal('Text'),commit) end; w:Connect(b.FocusLost,commit); return ctl
            end
            function section:AddKeybind(a)
                local r=row(28); label(r,a.Name or 'Keybind'); local b=button(r,''); b.Position=UDim2.fromScale(.6,0); b.Size=UDim2.fromScale(.4,1); stroke(b)
                local ctl=control(a,keycode,function(v) b.Text=v.Name end,keycode(a.Default) or Enum.KeyCode.Unknown,function(v) return v.Name end)
                w:Connect(b.Activated,function() if w.Capturing then local old=w.Capturing; w.Capturing=nil; old(nil) end; b.Text='Press key...'; w.Capturing=function(k) if k and k~=Enum.KeyCode.Escape then ctl:Set(k) else b.Text=ctl:Get().Name end end end)
                table.insert(w.Keybinds,{Control=ctl,Callback=a.OnPressed}); return ctl
            end
            function section:AddColorPicker(a)
                local r=row(28); label(r,a.Name or 'Color',.48); local sw=new('Frame',r,{Position=UDim2.new(.48,0,0,5),Size=UDim2.fromOffset(19,18),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(sw,3); stroke(sw)
                local b=input(r,'#FFFFFF'); b.Position=UDim2.new(.48,25,0,1); b.Size=UDim2.new(.52,-25,1,-2)
                local ctl=control(a,color,function(v) sw.BackgroundColor3=v; b.Text=hex(v) end,color(a.Default) or w.Accent,hex)
                w:Connect(b.FocusLost,function() if not ctl:Set(b.Text) then b.Text=hex(ctl:Get()) end end); return ctl
            end
            -- Generic searchable table. Rows are plain display data.
            function section:AddTable(a)
                local headers=a.Headers or {'Name'}
                local data=a.Rows or {}
                local wrap=row(30); wrap.AutomaticSize=Enum.AutomaticSize.Y; list(wrap,2)
                local function drawLine(values, header, index)
                    local line=new('Frame',wrap,{Size=UDim2.new(1,0,0,30),BackgroundColor3=header and C.field or ((index or 0)%2==0 and C.alternate or C.panel),BorderSizePixel=0}); corner(line,4)
                    local x=0
                    for i=1,#headers do
                        local width=(a.Widths and a.Widths[i]) or 1/#headers
                        local cell=text(line,values[i] or '',header and 13 or 14,header and C.muted or C.text)
                        if header then cell.Font=Enum.Font.GothamBold end
                        cell.Position=UDim2.new(x,8,0,0); cell.Size=UDim2.new(width,-14,1,0); x+=width
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
                local holder=row(1); local cellHeight=104; local cells={}; local selected=nil; local filter=''
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
                            if not item.Image then local placeholder=text(preview,'◇',24,C.muted); placeholder.TextXAlignment=Enum.TextXAlignment.Center end
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
        -- Create a left-side category menu and switch between right-side sections.
        function tab:AddCategories(title)
            left.Size=UDim2.new(.31,-6,1,0); right.Position=UDim2.new(.31,6,0,0); right.Size=UDim2.new(.69,-6,1,0)
            local menu=self:AddSection(title or 'Categories','Left')
            local api={Entries={}}
            function api:Select(name)
                for _,entry in ipairs(self.Entries) do
                    local active=entry.Name==name
                    entry.Section:SetVisible(active)
                    entry.Button.TextColor3=active and w.Accent or C.text
                    entry.Button.BackgroundColor3=active and C.selected or C.field
                    entry.Marker.Visible=active
                end
            end
            function api:Add(name)
                local section=tab:AddSection(name,'Right')
                local b=menu:AddButton({Name=name,Callback=function() api:Select(name) end})
                b.TextXAlignment=Enum.TextXAlignment.Left; b.TextSize=14; new('UIPadding',b,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,6)})
                local marker=new('Frame',b.Parent,{ZIndex=3,Size=UDim2.new(0,3,1,-8),Position=UDim2.fromOffset(1,4),BackgroundColor3=w.Accent,BorderSizePixel=0,Visible=false}); corner(marker,2); w:Tint(marker,'BackgroundColor3')
                table.insert(self.Entries,{Name=name,Section=section,Button=b,Marker=marker})
                if #self.Entries==1 then self:Select(name) else section:SetVisible(false); b.TextColor3=C.text end
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
