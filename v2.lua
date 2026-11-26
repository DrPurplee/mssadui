-- VoidUI | standalone Luau UI library | MIT
local UIS = game:GetService('UserInputService')
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local Library = {Version = '1.1.0'}
local C = {bg=Color3.fromRGB(10,9,12), panel=Color3.fromRGB(14,13,16), field=Color3.fromRGB(19,18,22), line=Color3.fromRGB(32,29,36), text=Color3.fromRGB(230,227,234), muted=Color3.fromRGB(131,126,139)}
local function new(class, parent, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function corner(o,r) new('UICorner',o,{CornerRadius=UDim.new(0,r or 3)}) end
local function stroke(o) return new('UIStroke',o,{Color=C.line,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function text(p,s,sz,color)
    return new('TextLabel',p,{BackgroundTransparency=1,Text=tostring(s or ''),TextColor3=color or C.text,Font=Enum.Font.Gotham,TextSize=sz or 12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.fromScale(1,1)})
end
local function button(p,s)
    local b=new('TextButton',p,{BackgroundColor3=C.field,BorderSizePixel=0,AutoButtonColor=false,Text=tostring(s or ''),TextColor3=C.text,TextSize=12,Font=Enum.Font.Gotham,Size=UDim2.fromScale(1,1)})
    corner(b,3); return b
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
    local gui=new('ScreenGui',parent,{Name='VoidUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    local size=o.Size or Vector2.new(650,520)
    local main=new('Frame',gui,{Name='Window',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(size.X,size.Y),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true}); corner(main,4); stroke(main)
    local scale=new('UIScale',main,{Scale=1})
    local function fit()
        local cam=workspace.CurrentCamera; if cam then local v=cam.ViewportSize; scale.Scale=math.max(.3,math.min(1,(v.X-16)/size.X,(v.Y-16)/size.Y)) end
    end
    fit(); if workspace.CurrentCamera then w:Connect(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fit) end
    local top=new('Frame',main,{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.panel,BorderSizePixel=0})
    local brand=text(top,o.Title or 'void.ui',13); brand.Active=true; brand.Position=UDim2.fromOffset(12,0); brand.Size=UDim2.new(0,112,1,0); w:Tint(brand,'TextColor3')
    local nav=new('ScrollingFrame',top,{Position=UDim2.fromOffset(125,0),Size=UDim2.new(1,-165,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X}); list(nav,3,true)
    local hide=button(top,'–'); hide.Position=UDim2.new(1,-33,0,7); hide.Size=UDim2.fromOffset(26,24)
    local body=new('Frame',main,{Position=UDim2.fromOffset(8,46),Size=UDim2.new(1,-16,1,-78),BackgroundTransparency=1})
    local footer=new('Frame',main,{Position=UDim2.new(0,0,1,-25),Size=UDim2.new(1,0,0,25),BackgroundColor3=C.panel,BorderSizePixel=0})
    local status=text(footer,o.Footer or 'VoidUI  /  v'..Library.Version,11); status.Position=UDim2.fromOffset(10,0); status.Size=UDim2.new(.5,-10,1,0); w:Tint(status,'TextColor3')
    local hint=text(footer,'Menu: '..w.ToggleKey.Name,11,C.muted); hint.Position=UDim2.fromScale(.5,0); hint.Size=UDim2.new(.5,-10,1,0); hint.TextXAlignment=Enum.TextXAlignment.Right
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
        local tabButton=button(nav,name); tabButton.BackgroundTransparency=1; tabButton.TextColor3=C.muted; tabButton.Size=UDim2.fromOffset(math.max(48,#name*7+16),38)
        local underline=new('Frame',tabButton,{Position=UDim2.new(0,5,1,-2),Size=UDim2.new(1,-10,0,1),BorderSizePixel=0,BackgroundColor3=w.Accent,Visible=false}); w:Tint(underline,'BackgroundColor3')
        local page=new('Frame',body,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
        local function column(x)
            local c=new('ScrollingFrame',page,{Position=UDim2.new(x,x==0 and 0 or 4,0,0),Size=UDim2.new(.5,-4,1,0),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=w.Accent}); w:Tint(c,'ScrollBarImageColor3'); list(c,7); return c
        end
        local left,right=column(0),column(.5)
        function tab:Select()
            for _,t in ipairs(w.Tabs) do t.Page.Visible=false; t.Button.TextColor3=C.muted; t.Underline.Visible=false end
            page.Visible=true; tabButton.TextColor3=w.Accent; underline.Visible=true; w.ActiveTab=tab
        end
        tab.Page=page; tab.Button=tabButton; tab.Underline=underline; w:Tint(tabButton,'TextColor3',function() return w.ActiveTab==tab end)
        w:Connect(tabButton.Activated,function() tab:Select() end); if #w.Tabs==1 then tab:Select() end
        function tab:AddSection(name,side)
            if type(name)=='table' then side=name.Side; name=name.Name or name.Title end
            local section={}; local p=new('Frame',side and tostring(side):lower()=='right' and right or left,{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.panel,BorderSizePixel=0}); corner(p,3); stroke(p); pad(p,8); list(p,5)
            section.Frame=p
            function section:SetVisible(v) p.Visible=not not v end
            local heading=text(p,name or 'Section',12); heading.Size=UDim2.new(1,0,0,20); w:Tint(heading,'TextColor3')
            local function row(h) return new('Frame',p,{Size=UDim2.new(1,0,0,h or 24),BackgroundTransparency=1}) end
            local function label(r,s,f) local t=text(r,s,12); t.Size=UDim2.new(f or .6,-5,1,0); return t end
            local function input(r,placeholder)
                local b=new('TextBox',r,{BackgroundColor3=C.field,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.text,PlaceholderColor3=C.muted,PlaceholderText=placeholder or '',Text='',ClearTextOnFocus=false,Size=UDim2.fromScale(1,1)}); corner(b,3); stroke(b); return b
            end
            function section:AddLabel(s) local r=row(22); local t=text(r,type(s)=='table' and s.Name or s,12,C.muted); return {Set=function(_,v) t.Text=tostring(v) end} end
            function section:AddButton(a) local r=row(27); local b=button(r,a.Name or 'Button'); stroke(b); w:Connect(b.Activated,function() safe(a.Callback) end); return b end
            function section:AddToggle(a)
                local r=row(22); local b=button(r,''); b.BackgroundTransparency=1; local square=new('Frame',b,{Size=UDim2.fromOffset(15,15),Position=UDim2.fromOffset(0,3),BackgroundColor3=C.field,BorderSizePixel=0}); corner(square,3); stroke(square)
                local mark=text(square,'✓',13,C.bg); mark.TextXAlignment=Enum.TextXAlignment.Center; mark.Visible=false
                local t=text(b,a.Name or 'Toggle'); t.Position=UDim2.fromOffset(22,0); t.Size=UDim2.new(1,-22,1,0)
                local ctl=control(a,function(v) if type(v)=='boolean' then return v end end,function(v) square.BackgroundColor3=v and w.Accent or C.field; mark.Visible=v end,a.Default==true)
                w:Tint(square,'BackgroundColor3',function() return ctl:Get() end); w:Connect(b.Activated,function() ctl:Set(not ctl:Get()) end); return ctl
            end
            function section:AddSlider(a)
                local lo,hi=a.Min or 0,a.Max or 100; assert(hi>lo,'Slider Max must exceed Min'); local step=a.Step or 1; assert(step>0,'Slider Step must be positive')
                local r=row(36); local t=text(r,a.Name or 'Slider'); t.Size=UDim2.new(.7,0,0,19); local val=text(r,'',11,C.muted); val.Position=UDim2.fromScale(.7,0); val.Size=UDim2.new(.3,0,0,19); val.TextXAlignment=Enum.TextXAlignment.Right
                local bar=button(r,''); bar.Position=UDim2.fromOffset(0,20); bar.Size=UDim2.new(1,0,0,12); bar.BackgroundTransparency=1
                local track=new('Frame',bar,{Position=UDim2.fromOffset(0,4),Size=UDim2.new(1,0,0,4),BackgroundColor3=C.field,BorderSizePixel=0}); corner(track,2)
                local fill=new('Frame',track,{Size=UDim2.fromScale(0,1),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(fill,2); w:Tint(fill,'BackgroundColor3')
                local knob=new('Frame',track,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(8,8),Position=UDim2.fromScale(0,.5),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(knob,4); w:Tint(knob,'BackgroundColor3')
                local ctl=control(a,function(v) v=tonumber(v); if v and v==v and math.abs(v)<math.huge then if v>=hi then return hi end; return math.clamp(lo+math.round((v-lo)/step)*step,lo,hi) end end,function(v) local f=(v-lo)/(hi-lo); fill.Size=UDim2.fromScale(f,1); knob.Position=UDim2.fromScale(f,.5); val.Text=string.format('%.6g',v)..(a.Suffix or '') end,a.Default or lo)
                local sliding,touch=false,nil
                local function update(x) if bar.AbsoluteSize.X>0 then ctl:Set(lo+math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(hi-lo)) end end
                w:Connect(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; touch=i; update(i.Position.X) end end)
                w:Connect(UIS.InputChanged,function(i) if sliding and (i==touch or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i.Position.X) end end)
                w:Connect(UIS.InputEnded,function(i) if i==touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end); return ctl
            end
            function section:AddDropdown(a)
                local items={}; for _,v in ipairs(a.Options or {}) do table.insert(items,tostring(v)) end
                local r=row(48); local t=text(r,a.Name or 'Dropdown',11,C.muted); t.Size=UDim2.new(1,0,0,17)
                local b=button(r,''); b.Position=UDim2.fromOffset(0,19); b.Size=UDim2.new(1,0,0,25); b.TextXAlignment=Enum.TextXAlignment.Left; pad(b,7); stroke(b)
                local panel=new('Frame',r,{Position=UDim2.fromOffset(0,48),Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,Visible=false}); list(panel,3)
                local opened=false; local optionButtons={}
                local function open(v) opened=v; panel.Visible=v; local h=#items*25; panel.Size=UDim2.new(1,0,0,h); r.Size=UDim2.new(1,0,0,v and 48+h or 48) end
                local function normalize(v)
                    if a.Multi then if type(v)~='table' then return nil end; local out={}; for _,item in ipairs(items) do if table.find(v,item) then table.insert(out,item) end end; return out end
                    if table.find(items,tostring(v)) then return tostring(v) end; if #items==0 then return '' end
                end
                local ctl=control(a,normalize,function(v)
                    local s=type(v)=='table' and table.concat(v,', ') or v; b.Text=(s=='' and 'Select...' or s)..'  ▾'
                    for item,ob in pairs(optionButtons) do local active=type(v)=='table' and table.find(v,item)~=nil or v==item; ob.TextColor3=active and w.Accent or C.text end
                end,a.Default or (a.Multi and {} or items[1] or ''))
                for _,item in ipairs(items) do local ob=button(panel,item); ob.Size=UDim2.new(1,0,0,22); optionButtons[item]=ob; w:Tint(ob,'TextColor3',function() local v=ctl:Get(); return type(v)=='table' and table.find(v,item)~=nil or v==item end); w:Connect(ob.Activated,function() if a.Multi then local v=table.clone(ctl:Get() or {}); local idx=table.find(v,item); if idx then table.remove(v,idx) else table.insert(v,item) end; ctl:Set(v) else ctl:Set(item); open(false) end end) end
                if ctl:Get()~=nil then ctl:Set(ctl:Get(),true) else ctl:Set(a.Multi and {} or items[1] or '',true) end; w:Connect(b.Activated,function() open(not opened) end); return ctl
            end
            function section:AddTextbox(a)
                local r=row(46); local t=text(r,a.Name or 'Text',11,C.muted); t.Size=UDim2.new(1,0,0,17); local b=input(r,a.Placeholder); b.Position=UDim2.fromOffset(0,19); b.Size=UDim2.new(1,0,0,25)
                local ctl=control(a,function(v) if type(v)=='string' then return v end end,function(v) b.Text=v end,a.Default or ''); w:Connect(b.FocusLost,function() ctl:Set(b.Text) end); return ctl
            end
            function section:AddKeybind(a)
                local r=row(26); label(r,a.Name or 'Keybind'); local b=button(r,''); b.Position=UDim2.fromScale(.6,0); b.Size=UDim2.fromScale(.4,1); stroke(b)
                local ctl=control(a,keycode,function(v) b.Text=v.Name end,keycode(a.Default) or Enum.KeyCode.Unknown,function(v) return v.Name end)
                w:Connect(b.Activated,function() if w.Capturing then local old=w.Capturing; w.Capturing=nil; old(nil) end; b.Text='Press key...'; w.Capturing=function(k) if k and k~=Enum.KeyCode.Escape then ctl:Set(k) else b.Text=ctl:Get().Name end end end)
                table.insert(w.Keybinds,{Control=ctl,Callback=a.OnPressed}); return ctl
            end
            function section:AddColorPicker(a)
                local r=row(27); label(r,a.Name or 'Color',.48); local sw=new('Frame',r,{Position=UDim2.new(.48,0,0,4),Size=UDim2.fromOffset(20,19),BackgroundColor3=w.Accent,BorderSizePixel=0}); corner(sw,3); stroke(sw)
                local b=input(r,'#FFFFFF'); b.Position=UDim2.new(.48,25,0,1); b.Size=UDim2.new(.52,-25,1,-2)
                local ctl=control(a,color,function(v) sw.BackgroundColor3=v; b.Text=hex(v) end,color(a.Default) or w.Accent,hex)
                w:Connect(b.FocusLost,function() if not ctl:Set(b.Text) then b.Text=hex(ctl:Get()) end end); return ctl
            end
            -- Generic searchable table. Rows are plain display data.
            function section:AddTable(a)
                local headers=a.Headers or {'Name'}
                local data=a.Rows or {}
                local wrap=row(28); wrap.AutomaticSize=Enum.AutomaticSize.Y; list(wrap,3)
                local function drawLine(values, header)
                    local line=new('Frame',wrap,{Size=UDim2.new(1,0,0,24),BackgroundColor3=header and C.field or C.panel,BorderSizePixel=0}); list(line,2,true)
                    for i=1,#headers do
                        local cell=text(line,values[i] or '',11,header and C.muted or C.text)
                        cell.Size=UDim2.new(1/#headers,-2,1,0)
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
                            local line=drawLine(strings,false); line.LayoutOrder=#lines+1; table.insert(lines,line)
                        end
                    end
                end
                function api:SetRows(v) data=v or {}; refresh() end
                function api:SetFilter(v) filter=string.lower(tostring(v or '')); refresh() end
                refresh(); return api
            end
            -- Generic selectable cards. Image is an optional Roblox asset URI.
            function section:AddCardGrid(a)
                local items=a.Items or {}; local columns=math.max(1,math.floor(a.Columns or 2))
                local holder=row(1); local cellHeight=84; local cells={}; local selected=nil; local filter=''
                local grid=new('UIGridLayout',holder,{CellSize=UDim2.new(1/columns,-4,0,cellHeight),CellPadding=UDim2.fromOffset(4,4),SortOrder=Enum.SortOrder.LayoutOrder,FillDirectionMaxCells=columns})
                local api={}
                local function refresh()
                    for _,cell in ipairs(cells) do cell:Destroy() end; table.clear(cells)
                    for _,item in ipairs(items) do
                        local item=type(item)=='table' and item or {Name=tostring(item)}
                        local name=tostring(item.Name or '')
                        if filter=='' or string.find(string.lower(name),filter,1,true) then
                            local card=button(holder,''); card.LayoutOrder=#cells+1; local outline=stroke(card)
                            outline.Color=selected==name and w.Accent or C.line
                            local preview=new('ImageLabel',card,{BackgroundTransparency=1,Position=UDim2.fromOffset(5,4),Size=UDim2.new(1,-10,0,53),Image=item.Image or '',ScaleType=Enum.ScaleType.Fit})
                            if not item.Image then local placeholder=text(preview,'◇',24,C.muted); placeholder.TextXAlignment=Enum.TextXAlignment.Center end
                            local title=text(card,name,11); title.Position=UDim2.new(0,3,1,-25); title.Size=UDim2.new(1,-6,0,20); title.TextXAlignment=Enum.TextXAlignment.Center
                            new('Frame',card,{Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),BorderSizePixel=0,BackgroundColor3=color(item.Color) or C.line})
                            card.Activated:Connect(function() selected=name; safe(a.Callback,item); refresh() end)
                            table.insert(cells,card)
                        end
                    end
                    holder.Size=UDim2.new(1,0,0,math.max(1,math.ceil(#cells/columns)*(cellHeight+4)-4))
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
            local menu=self:AddSection(title or 'Categories','Left')
            local api={Entries={}}
            function api:Select(name)
                for _,entry in ipairs(self.Entries) do
                    local active=entry.Name==name
                    entry.Section:SetVisible(active)
                    entry.Button.TextColor3=active and w.Accent or C.muted
                end
            end
            function api:Add(name)
                local section=tab:AddSection(name,'Right')
                local b=menu:AddButton({Name=name,Callback=function() api:Select(name) end})
                b.TextXAlignment=Enum.TextXAlignment.Left; pad(b,7)
                table.insert(self.Entries,{Name=name,Section=section,Button=b})
                if #self.Entries==1 then self:Select(name) else section:SetVisible(false); b.TextColor3=C.muted end
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
