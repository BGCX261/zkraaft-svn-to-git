local PANEL = vgui.Register( "PACBrowser", { }, "DListView" )

function PANEL:Init()
	self:PopulateFromClient()
	self:AddColumn("Name")
	self:AddColumn("Author")
	self:AddColumn("KB")
	self:AddColumn("Date")
	self:FixColumnsLayout()
			
	concommand.Add("pac_refresh_files", function()
		if PAC.ServerBrowserSelected then
			self:PopulateFromServer()
		else
			self:PopulateFromClient()
		end
		RunConsoleCommand("pac_get_server_outfits")
	end)
end

function PANEL:AddClientServer()
	self.server = self:AddLine("SERVER", "", -1, "")
	serverbrowser = self.server
	self.server.PaintOver = function(self)
		draw.RoundedBox( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 100, 255, 100 ) )
	end
	self.server.OnSelect = function()
		self:PopulateFromServer()
		PAC.ServerBrowserSelected = true
	end
	
	self.client = self:AddLine("CLIENT", "", -1, "")
	self.client.PaintOver = function(self)
		draw.RoundedBox( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 255, 255, 100, 100 ) )
	end
	self.client.OnSelect = function()
		self:PopulateFromClient()
		PAC.ServerBrowserSelected = false
	end
end

local function OnMousePressed(self, mcode)

	if ( mcode == MOUSE_RIGHT ) then

		self:GetListView():OnRowRightClick( self:GetID(), self )
		
	elseif mcode == MOUSE_LEFT then

		self:GetListView():OnClickLine( self, true )
		self:OnSelect()
		
	end
end

function PANEL:AddOutfits( folder, callback )
	file.TFind("data/"..folder.."*", function(path, folders, files)
		for i, name in ipairs(folders) do			
			local realname = file.Read(folder..name.."/name.txt")
			local outfit = folder..name.."/outfit.txt"
			if file.Exists(outfit) then
				local filenode = self:AddLine( 
					realname or name, 
					LocalPlayer():Nick(),
					math.Round(file.Size(folder..name.."/outfit.txt")/1000), 
					os.date("%m/%d/%Y %H:%M", file.Time(outfit))
				)
				filenode.name = realname or name
				filenode.FileName = name
				filenode.OnSelect = callback
				filenode.OnMousePressed = OnMousePressed
				filenode.allowed = true
				filenode.isclient = true
			end
		end
	end)
end

function PANEL:PopulateFromClient( )
	
	self:Clear()
	self:AddClientServer()
	
	self:AddOutfits( "pac2_outfits/"..LocalPlayer( ):UniqueID( ).."/", function( node )
		
		PAC.Editor.FileBar:SetFileName(node.name)
		PAC.WearConfigFromFile( node.FileName );
		PAC.ReApplyConfig( );
		
	end)
		
end

function PANEL:PopulateFromServer()

	self:Clear()
	self:AddClientServer()
	
	if not PAC.ServerFileList then return end
	
	for key, outfits in pairs(PAC.ServerFileList) do
		local temp = string.Explode("|", key)
		local owner = temp[1]
		local uniqueid = temp[2]
		for key, value in pairs(outfits) do
			local filenode = self:AddLine(
				value.name, 
				owner,
				math.Round(value.size/1000),
				os.date("%m/%d/%Y %H:%M", value.time)
			)
			filenode.OnSelect = function()
				RunConsoleCommand("pac_load_config_sv", key, uniqueid)
			end
			filenode.allowed = LocalPlayer():IsAdmin() or LocalPlayer():UniqueID() == uniqueid or false
			filenode.uniqueid = uniqueid
			filenode.name = value.name
			filenode.FileName = key
			filenode.OnMousePressed = OnMousePressed
		end
	end
end

function PANEL:OnRowRightClick( id, line )
	if not line.allowed then return end
	local menu = DermaMenu()
	menu:SetPos(gui.MouseX(),gui.MouseY())
	menu:MakePopup()
	menu:AddOption("rename", function()
		Derma_StringRequest("Rename", "Type the new name:", line.name, function(text)
			if line.isclient then
				PAC.RenameConfig(line.FileName, text)
				self:PopulateFromClient()
			else
				RunConsoleCommand("pac_rename_config_sv", line.uniqueid, line.FileName, text)
			end
		end)
	end)
	menu:AddOption("delete", function()
		if line.isclient then
			PAC.DeleteConfig(line.FileName)
			self:PopulateFromClient()
		else
			RunConsoleCommand("pac_delete_config_sv", line.uniqueid, line.FileName)
		end
	end)
end