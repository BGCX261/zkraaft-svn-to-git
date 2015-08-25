local PANEL = vgui.Register( "PACChoice", { }, "DMultiChoice" )

function PANEL:Init()
	DMultiChoice.Init(self)
	self.sorted = {}
	self.sortedmenus = {}
end

function PANEL:AddChoice(name)

	local new = PAC.RemoveClutterFromBoneName(name)
		
	local key = new:Left(1)
	
	self.sorted[key] = self.sorted[key] or {}
	self.sorted[key][name] = {name = new, original = name}
end

function PANEL:SetText(text)
	DMultiChoice.SetText(self, PAC.RemoveClutterFromBoneName(text))
end

function PANEL:Clear()
	self.sortedmenus = {}
	self.sorted = {}
end

function PANEL:OpenMenu(panel)
	if IsValid(self.Menu) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = DermaMenu()
		
	for name, table in SortedPairs(self.sorted) do
		if IsValid(self.sortedmenus[name]) then
			self.sortedmenus[name]:Remove()
		end
		for _, data in SortedPairs(table, true) do
			self.sortedmenus[name] = IsValid(self.sortedmenus[name]) and self.sortedmenus[name] or self.Menu:AddSubMenu(name:upper().."..")
			self.sortedmenus[name]:AddOption(data.name, function()
				self:OnSelect(data.original)
				self:SetText(data.name)
			end)
		end
	end
	local x, y = self:LocalToScreen( 0, self:GetTall() )
	
	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, false, self )	
end