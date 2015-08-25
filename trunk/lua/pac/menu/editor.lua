local PANEL = vgui.Register( "PACEditor", { }, "Panel" )

PAC.InPreview = false

local windows = {}

function PANEL:SetFocus(focus)
	self.focus = focus
	if focus then
		self.dragframe = vgui.Create("PACDragPanel")
		self.dragframe:SetSize(ScrW(),ScrH())
		self.dragframe:SetVisible(true)
		self.dragframe:RequestFocus()
		self.dragframe:SetMouseInputEnabled(true)
		self.dragframe:SetKeyboardInputEnabled(false)
		self.dragframe:Enable(true)
	else
		if IsValid(self.dragframe) then
			self.dragframe:SetVisible(false)
			self.dragframe:SetMouseInputEnabled(false)
			self.dragframe:MoveToBack()
		end
	end
	for key, panel in pairs(windows) do
		if focus then
			panel:GetParent():SetMouseInputEnabled(true)
			panel:GetParent():SetKeyboardInputEnabled(true)
			panel:GetParent():MoveToFront()
			panel:GetParent():MakePopup()
		else			
			panel:GetParent():KillFocus()
			panel:GetParent():SetMouseInputEnabled(false)
			panel:GetParent():SetKeyboardInputEnabled(false)
		end
		self.hasfocus = focus
	end
end

function PANEL:SetVisible(enable)

	self:SetFocus(enable)
		
	PAC.InPreview = enable
	
	if not enable then
		PAC.CurrentPart = nil
	end
	
	if IsValid(self.dragframe) and not enable then
		self.dragframe:Enable(false)
		self.dragframe:Remove()
	end
	
	gui.EnableScreenClicker(enable)
	
	for key, panel in pairs(windows) do
		panel:GetParent():SetVisible(enable or false)
	end
end

function PANEL:Init()

	hook.Add("PlayerBindPress", "PAC.PlayerBindPress", function(ply, bind, pressed)
		
		if PAC.InPreview then
			if pressed then
				if string.find(bind, "showscores") or string.find(bind, "messagemode") or string.find(bind, "menu_context") then
					self:SetFocus(true)
				end
			else
				self:SetFocus(false)
			end
		end
	end)
	
	hook.Add("Think", "PAC.KeyPressThink", function()
		if PAC.InPreview then
		
			if input.IsKeyDown(KEY_LALT) and input.IsKeyDown(KEY_Q) then
				self:SetFocus(false)
				if not g_SpawnMenu:IsVisible() then
					RunConsoleCommand("+menu")
				end
				timer.Create("PACQmenu",0.25,1,function()
					self:SetFocus(true)
					RunConsoleCommand("-menu")
				end)
			end
			
			if input.IsKeyDown(KEY_LALT) and input.IsKeyDown(KEY_W) then
				self:SetFocus(false)
				if not g_ContextMenu:IsVisible() then
					RunConsoleCommand("+menu_context")
				end
				timer.Create("PACQmenu",0.25,1,function()
					self:SetFocus(true)
					RunConsoleCommand("-menu_context")
				end)
			end
			
			if input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_S) then
				if not self.saved then
					self.FileBar:SaveToClient()
					self.saved = true
				end
				timer.Create("PACSaved",0.5,1,function()
					self.saved = false
				end)
			end	

			if input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_E) then
				if (self.last_focus or 0) < CurTime() then
					surface.PlaySound("buttons/button9.wav")
					self.FileBar.Anchor.DoClick()
					self.last_focus = CurTime()+0.5
				end
			end	
			
			if input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_D) then
				if not self.saved then
					surface.PlaySound("buttons/button9.wav")
					PAC.SubmitConfig( LocalPlayer( ):GetPACConfig( ) )
					self.saved = true
				end
				timer.Create("PACSaved",0.5,1,function()
					self.saved = false
				end)
			end			
		
		end
	end)

	concommand.Add("pac_show_editor", function()
		if not PAC.Editor then return end
		PAC.Editor:SetVisible(true)
	end)
	
	PAC.Editor = self
	
	self.properties_width = math.Clamp(ScrW()/5, 160, 210)
		
	do -- Filebar
		local width = 300
		local height = 50
		local frame = vgui.Create("DFrame")
		frame:SetSize(width,height)
		frame:SetTitle("Save")
		frame:AlignRight(self.properties_width)
		frame:AlignBottom()
		frame:ShowCloseButton(false)
		
		local panel = vgui.Create("PACFileBar", frame)
		panel:StretchToParent(PAC.Spacing,PAC.Spacing+20,PAC.Spacing,PAC.Spacing)
		
		self.FileBar = panel
		windows.FileBar = panel
	end

	do -- Parts
		local width = ScrW()-self.properties_width
		local height = 90
		local frame = vgui.Create("DFrame")
		frame:SetSize(width,height)
		frame:SetTitle("Parts")
		frame:AlignTop()
		frame:AlignLeft()
		frame:ShowCloseButton(true)
		
		frame.Close = function()
			frame:SetVisible(false)
			self:SetVisible(false)
		end

		local panel = vgui.Create("PACParts", frame)
		panel:StretchToParent(PAC.Spacing,PAC.Spacing+20,PAC.Spacing,PAC.Spacing)
		
		self.Parts = panel
		windows.Parts = panel
	end

	do -- Properties
		local width = self.properties_width
		local height = ScrH()
		local frame = vgui.Create("DFrame")
		frame:SetSize(width,height)
		frame:SetTitle("Properties")
		frame:AlignRight()
		frame:ShowCloseButton(false)

		local panel = vgui.Create("PACProperties", frame)
		panel:SetSize(width,height)
		panel:StretchToParent(PAC.Spacing,PAC.Spacing+20,PAC.Spacing,PAC.Spacing)
		
		self.Properties = panel
		windows.Properties = panel
	end
			
end