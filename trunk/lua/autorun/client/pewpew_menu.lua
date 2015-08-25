-- PewPew Use Menu

local pewpew_frame
local pewpew_list

-- Use Menu
local function CreateMenu()
	pewpew_frame = vgui.Create("DFrame")
	pewpew_frame:SetPos( ScrW()/2+100,ScrH()/2-420/2 )
	pewpew_frame:SetSize( 600, 420 )
	pewpew_frame:SetTitle( "PewPew Cannon Information" )
	pewpew_frame:SetVisible( false )
	pewpew_frame:SetDraggable( true )
	pewpew_frame:ShowCloseButton( true )
	pewpew_frame:SetDeleteOnClose( false )
	pewpew_frame:SetScreenLock( true )
	pewpew_frame:MakePopup()
	
	pewpew_list = vgui.Create( "DPanelList", pewpew_frame )
	pewpew_list:StretchToParent( 2, 23, 2, 2 )
	pewpew_list:SetSpacing( 2 )
	pewpew_list:EnableHorizontal( true )
	pewpew_list:EnableVerticalScrollbar( true )
end
timer.Simple( 2, CreateMenu )

local list = {}		
local function SetTable( Bullet )
	local rld = Bullet.Reloadtime
	if (!rld or rld == 0) then rld = 1 end
	list[1] = 	{"Name", 				Bullet.Name}
	list[2] = 	{"Author", 				Bullet.Author}
	list[3] = 	{"Description", 		Bullet.Description}
	list[4] = 	{"Category", 			Bullet.Category }
	list[5] = 	{"Damage Type",			Bullet.DamageType}
	list[6] = 	{"Damage",	 			Bullet.Damage}
	list[7] = 	{"DPS",					(Bullet.Damage or 0) * (1/rld)}
	list[8] = 	{"Radius", 				Bullet.Radius}
	list[9] = 	{"PlayerDamage", 		Bullet.PlayerDamage}
	list[10] = 	{"PlayerDamageRadius", 	Bullet.PlayerDamageRadius}
	list[11] = 	{"Speed", 				Bullet.Speed}
	list[12] = 	{"Gravity", 			Bullet.Gravity}
	list[13] =	{"RecoilForce", 		Bullet.RecoilForce}
	list[14] = 	{"Spread",				Bullet.Spread}
	list[15] = 	{"Reloadtime", 			Bullet.Reloadtime}
	list[16] = 	{"Ammo", 				Bullet.Ammo}
	list[17] = 	{"AmmoReloadtime", 		Bullet.AmmoReloadtime}
	list[18] = 	{"EnergyPerShot",		Bullet.EnergyPerShot}
end

local function OpenUseMenu( bulletname )
	local Bullet = pewpew:GetBullet( bulletname )
	if (Bullet) then
		pewpew_list:Clear()
		SetTable( Bullet )
		for _, value in ipairs( list ) do
			local pnl = vgui.Create("DPanel")
			pnl:SetSize( 594, 20 )
			--function pnl:Paint() return true end
		
			local label = vgui.Create("DLabel",pnl)
			label:SetPos( 4, 4 )
			label:SetText( value[1] )
			label:SizeToContents()
			
			local box = vgui.Create("DTextEntry",pnl)
			box:SetPos( 135, 0 )
			box:SetText( tostring(value[2] or "- none -") or "- none -" )
			box:SetWidth( 592 )
			box:SetMultiline( false )
			
			pewpew_list:AddItem( pnl )
		end
		pewpew_frame:SetVisible( true )
	else
		LocalPlayer():ChatPrint("Bullet not found!")
	end
end

concommand.Add("PewPew_UseMenu", function( ply, cmd, arg )
	OpenUseMenu( table.concat(arg, " ") )
end)

local pewpew_weaponframe

-- Weapons Menu
local function CreateMenu2()
	-- Main frame
	pewpew_weaponframe = vgui.Create("DFrame")
	pewpew_weaponframe:SetPos( ScrW()-300,ScrH()/2-450/2 )
	pewpew_weaponframe:SetSize( 250, 450 )
	pewpew_weaponframe:SetTitle( "PewPew Weapons" )
	pewpew_weaponframe:SetVisible( false )
	pewpew_weaponframe:SetDraggable( true )
	pewpew_weaponframe:ShowCloseButton( true )
	pewpew_weaponframe:SetDeleteOnClose( false )
	pewpew_weaponframe:SetScreenLock( true )
	pewpew_weaponframe:MakePopup()
	
	local label = vgui.Create("DLabel", pewpew_weaponframe)
	label:SetText("Left click to select, right click for info.")
	label:SetPos( 6, 23 )
	label:SizeToContents()
	
	-- Panel List 1
	local list1 = vgui.Create("DPanelList", pewpew_weaponframe)
	list1:StretchToParent( 4, 40, 4, 4 )
	list1:SetAutoSize( false )
	list1:SetSpacing( 1 )
	list1:EnableHorizontal( false ) 
	list1:EnableVerticalScrollbar( true )

	-- Loop through all categories
	pewpew.CategoryControls = {}
	for key, value in pairs( pewpew.Categories ) do
		-- Create a Collapsible Category for each
		local cat = vgui.Create( "DCollapsibleCategory" )
		cat:SetSize( 146, 50 )
		cat:SetExpanded( 0 )
		cat:SetLabel( key )
		
		-- Create a list inside each collapsible category
		local list = vgui.Create("DPanelList")
		list:SetAutoSize( true )
		list:SetSpacing( 2 )
		list:EnableHorizontal( false ) 
		list:EnableVerticalScrollbar( true )
		
		-- Loop through all weapons in each category
		for key2, value2 in pairs( pewpew.Categories[key] ) do
			-- Create a button for each list
			local btn = vgui.Create("DButton")
			btn:SetSize( 48, 20 )
			btn:SetText( value2 )
			-- Set bullet, change weapon, and close menu
			btn.DoClick = function()
				RunConsoleCommand("pewpew_bulletname", value2)
				RunConsoleCommand("gmod_tool", "pewpew")
				pewpew_weaponframe:SetVisible( false )
				pewpew_frame:SetVisible( false )
			end
			btn.DoRightClick = function()
				RunConsoleCommand("PewPew_UseMenu", value2)
			end
			list:AddItem( btn )
		end
		
		cat:SetContents( list )
		function cat.Header:OnMousePressed()
			for k,v in ipairs( pewpew.CategoryControls ) do
				if ( v:GetExpanded() and v.Header != self ) then v:Toggle() end
				if (!v:GetExpanded() and v.Header == self ) then v:Toggle() end
			end
		end
		table.insert( pewpew.CategoryControls, cat )
		list1:AddItem( cat )
	end
end
timer.Simple(0.5, CreateMenu2)

concommand.Add("PewPew_WeaponMenu", function( ply, cmd, arg )
	-- Open weapons menu
	pewpew_weaponframe:SetVisible( true )	
end)

concommand.Add("+PewPew_WeaponMenu", function( ply, cmd, arg )
	-- Open weapons menu
	pewpew_weaponframe:SetVisible( true )
end)

concommand.Add("-PewPew_WeaponMenu", function( ply, cmd, arg )
	-- Open weapons menu
	pewpew_weaponframe:SetVisible( false )
end)