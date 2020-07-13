local function ThrowError ( ErrMode, strCommand, strNeeded, strData )
	if ErrMode == 1 then
		ErrorNoHalt("!!PHX.UI.CreateVGUIType() --> [" .. strCommand .. "] argument 'data' is empty. Panel creation discarded.", 2)
	elseif ErrMode == 2 then
		error( "!!PHX.UI.CreateVGUIType() --> [" .. strCommand .. "] FAILED! - 'data' argument must contain ".. strNeeded .." value, got: " .. tostring(type(strData)) .." instead!!", 2 )
	end
end

PHX.CLUI = {
["check"]	= function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end

	if ( d and type(d) == "string" ) then
		local chk = vgui.Create("DCheckBoxLabel")
		chk:SetPos(0, p:GetRowHeight() / 2)
		chk:SetSize(p:GetColWide(),p:GetRowHeight())
		chk:SetText(l)
		chk:SetFont("HudHintTextLarge")
		local num = GetConVar(c):GetBool()
		if num then 
			chk:SetChecked(true); chk:SetValue(1);
		else
			chk:SetChecked(false); chk:SetValue(0);
		end
		function chk:OnChange(bool)
			local v = 0
			if bool then
				v = 1
			else
				v = 0
			end
			if d == "SERVER" then
				net.Start("SvCommandReq")
				  net.WriteString(c)
				  net.WriteInt(v,2)
				net.SendToServer()
			elseif d == "CLIENT" then
				RunConsoleCommand(c, v)
				chat.AddText(Color(200,0,0),"[Settings]", color_white, " Cvar '"..c.."' has been changed to "..v)
				if v == 1 then
					surface.PlaySound("buttons/button9.wav")
				else
					surface.PlaySound("buttons/button19.wav")
				end
			end
		end
		return chk
	else
		ThrowError(2, c, "string", d)
	end
	
end,

["label"] = function( c, d, p, l )
	local txt = vgui.Create("DLabel")
	txt:SetSize(p:GetColWide(),p:GetRowHeight())
	txt:SetText(l)
	if !d then
		txt:SetFont("HudHintTextLarge")
	else
		txt:SetFont(d)
	end
	txt:SetTextColor(color_white)
	return txt
end,

["spacer"] = function( c, d, p, l )
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide(),p:GetRowHeight())
	pnl:SetBackgroundColor(Color(0,0,0,0))
	
	return pnl
end,

["btn"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end

	if ( d and type(d) == "table" ) then
		-- How many buttons do we need to make. 
		-- Note: Currently, Maximum is 6 buttons per 1 panel segment.
		
		-- Legal Value. Override value if they are invalid or less then specific.
		local legal = d.max
		if d.max < 1 then legal = 1 end
		if d.max > 6 then legal = 6 end
		
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide(),p:GetRowHeight())
		pnl:SetBackgroundColor( Color(0,0,0,0) )
		
		local function m_btncreation( m_panel, m_panelText, m_func )
			local btn = vgui.Create("DButton", m_panel)
			btn:SetText(m_panelText)
			btn:Dock(LEFT)
			btn:DockMargin(0,2,8,2)
			-- If this looks stupid, but it working, it ain't stupid!
			btn:SizeToContents()
			btn:SetSize(btn:GetWide()+16,btn:GetTall())
			btn.DoClick = m_func
		end
		
		for i=1,legal do
			m_btncreation(pnl,d.textdata[i][1], d.textdata[i][2])
		end
		return pnl
	else
		ThrowError(2, c, "table", d)
	end
end,

["slider"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end
	
	if ( d and type(d) == "table" ) then
		local min = d.min
		local max = d.max
		local dval = d.init
		local dec = d.dec
		local kind = d.kind
		local float = d.float
		
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide(),p:GetRowHeight()-6)
		pnl:SetBackgroundColor(Color(120,120,120,200))
		
		local slider = vgui.Create("DNumSlider",pnl)
		slider:SetPos(10,0)
		slider:SetSize(p:GetColWide()-30,p:GetRowHeight()-6)
		slider:SetText(l)
		slider:SetMin(min)
		slider:SetMax(max)
		slider:SetValue(dval)
		slider:SetDecimals(dec)
		slider.OnValueChanged = function(self,value)
			self:SetValue(value)
			if kind == "SERVER" then
				net.Start("SvCommandSliderReq")
				net.WriteString(c)
				net.WriteBool(float)
				if float then
					net.WriteFloat(value)
				else
					net.WriteInt(self:GetValue(), 16)
				end
				net.SendToServer()
			elseif kind == "CLIENT" then
				if float then
					RunConsoleCommand(c, value)
				else
					RunConsoleCommand(c, math.Round( value ))
				end
			end
		end
		return pnl
	else
		ThrowError(2, c, "table", d)
	end
end,

["mute"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end
	
	if ( d and type(d) == "Player" and IsValid(d) ) then
		local ply = d
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide(),p:GetRowHeight()-6)
		pnl:SetBackgroundColor(Color(20,20,20,150))
		
		local ava = vgui.Create("AvatarImage", pnl)
		ava:Dock(LEFT)
		ava:SetSize(24,24)
		ava:SetPlayer(ply,32)
		
		local name = vgui.Create("DLabel", pnl)
		name:Dock(LEFT)
		name:DockMargin(8,4,8,4)
		name:SetSize(p:GetColWide()/2,0)
		name:SetText(ply:Nick())
		name:SetFont("HudHintTextLarge")
		name:SetTextColor(color_white)
		
		local imagebtn
		local button = vgui.Create("DButton", pnl)
		button:Dock(RIGHT)
		button:DockMargin(4,0,4,0)
		button:SetSize(24,0)
		button:SetText("")
		button.Paint = function(self)
			surface.SetDrawColor(90,90,90,0)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		
		button.DoClick = function()
			if not IsValid(ply) then return end
			if ply:IsAdmin() or table.HasValue(PHX.IgnoreMutedUserGroup, string.lower(ply:GetUserGroup())) then return end
			
			local mute = ply:IsMuted()
			ply:SetMuted(not mute)
			imagebtn:SetImage(PHX.UI:GetMutedStateIcon(not mute))
		end
		
		if ply == LocalPlayer() then
			button:SetVisible(false)
		else
			button:SetVisible(true)
		end
		
		if ply:IsAdmin() or table.HasValue( PHX.IgnoreMutedUserGroup, string.lower(ply:GetUserGroup()) ) then
			button:SetVisible(false)
		end
		
		imagebtn = vgui.Create("DImage",button)
		imagebtn:Dock(FILL)
		imagebtn:SetImage(PHX.UI:GetMutedStateIcon(ply:IsMuted()))
		
		return pnl
	else
		ThrowError(2, c, "Player Entity", d)
	end
end,

["binder"] = function( c, d, p, l )	
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide(),p:GetRowHeight())
	pnl:SetBackgroundColor( Color(0,0,0,0) )
	
	local label = vgui.Create("DLabel", pnl)
	label:Dock(LEFT)
	label:SetSize(250,0)
	label:DockMargin(2,0,0,0)
	label:SetFont("HudHintTextLarge")
	label:SetText(l)
	
	local bind = vgui.Create("DBinder", pnl)
	bind:Dock(LEFT)
	bind:SetSize(128 , 0)
	bind:DockMargin(4,2,0,2)
	
	local keyNum = GetConVar(c):GetInt()
	bind:SetValue(keyNum)
	function bind:OnChange( num )	
		RunConsoleCommand(c, tostring(num))
		local tkeyName = input.GetKeyName(num)
		chat.AddText(Color(200,0,0),"[Settings]", color_white, " CVar '"..c.."' has been changed to ["..tostring(tkeyName).."]")
		surface.PlaySound("buttons/button9.wav")
	end
	return pnl
end,

-- Add More here :)
}