surface.CreateFont('PS_Heading', { font = 'coolvetica', size = 64 })
surface.CreateFont('PS_Heading2', { font = 'coolvetica', size = 24 })
surface.CreateFont('PS_Heading3', { font = 'coolvetica', size = 19 })

MjPoint_ClientUseRGB = CreateClientConVar("mjps_rgb_use", 1, true, false)
MjPoint_ClientR = CreateClientConVar("mjps_rgb_r", 44, true, false)
MjPoint_ClientG = CreateClientConVar("mjps_rgb_g", 62, true, false)
MjPoint_ClientB = CreateClientConVar("mjps_rgb_b", 80, true, false)

surface.CreateFont( "PS_Default", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 13, weight = 500, antialias = true,
})

surface.CreateFont( "PS_DefaultBold", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 13, weight = 800, antialias = true,
})

surface.CreateFont( "PS_Heading1", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 18, weight = 500, antialias = true,
})

surface.CreateFont( "PS_Heading1Bold", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 18, weight = 800, antialias = true,
})

surface.CreateFont( "PS_ButtonText1", {
	font = "Roboto",
	size = 22, weight = 700, antialias = true,
})

surface.CreateFont( "PS_ItemText", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 11, weight = 500, antialias = true,
})

surface.CreateFont( "PS_LargeTitle", {
	font = "Roboto",
	size = 32, weight = 500, antialias = true,
})
surface.CreateFont( "PS_MainCommunityHeading", {
	font = "Roboto",
	size = 25, weight = 500, antialias = true,
})

	local MjcBasicPS1SkinColor = {
		CloseButton = Color(52, 73, 94),
		CloseButtonHover = Color(79, 111, 143),
		SidePanel = Color(44, 62, 80),
		InfoPanel = Color(52, 73, 94),
		HeaderColor = Color(44, 62, 82),
		CatButtonColor = Color(44, 62, 80),
		CurrentActiveCat = Color(52, 73, 94),
		NotActiveCat = Color(79, 111, 143),
		GivePointsButton = Color(52, 73, 94),
		GivePointsButtonHover = Color(79, 111, 143)
	}
MjPointshop = {}

MjPointshop.UseInventory = true

local ShowInventory = true
local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3


local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:PS_GetItems()

	for category_id, CATEGORY in pairs(PS.Categories) do

		local catmenu = menu:AddSubMenu(CATEGORY.Name)

		table.SortByMember(PS.Items, PS.Config.SortItemsBy, function(a, b) return a > b end)

		for item_id, ITEM in pairs(PS.Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetSize( math.Clamp( 1100, 0, ScrW() ), math.Clamp( 780, 0, ScrH() ) )
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
	if MjPointshop.UseCustomClieintColours then
		local clientColoursBut = vgui.Create('DButton', self)
		clientColoursBut:SetFont('PS_Default')
		clientColoursBut:SetText('')
		clientColoursBut:SetPos(self:GetWide() - 65, 3)
		clientColoursBut:SetIcon("icon16/user.png")
		clientColoursBut.Paint = function(s, w, h) end

		clientColoursBut.DoClick = function()
			MjPS_ColourChoose()
		end

		function MjPS_ColourChoose()
			local clientcolour = vgui.Create("DFrame")
			clientcolour:SetSize(300, 200)
			clientcolour:Center()
			local mixer = vgui.Create("DColorMixer",clientcolour)
			mixer:Dock(FILL)
			mixer:SetColor(Color(MjPoint_ClientR:GetInt(), MjPoint_ClientG:GetInt(), MjPoint_ClientB:GetInt()))
			mixer:SetConVarR("mjps_rgb_r")
			mixer:SetConVarG("mjps_rgb_g")
			mixer:SetConVarB("mjps_rgb_b")
			local submit = vgui.Create("DButton",clientcolour)
			submit:Dock(BOTTOM)
		end
	end
	-- close button
	local closeButton = vgui.Create('DButton', self)
	closeButton:SetFont('marlett')
	closeButton:SetText('r')
	closeButton.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.CloseButton)
	end
	closeButton.OnCursorEntered = function()
		closeButton.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.CloseButtonHover)
		end
	end
	closeButton.OnCursorExited = function()
		closeButton.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.CloseButton)
		end
	end
	closeButton:SetColor(Color(255, 255, 255))
	closeButton:SetSize(40, 30)
	closeButton:SetPos(self:GetWide() - 41, 0)
	closeButton.DoClick = function()
		PS:ToggleMenu()
	end

	local SidePanel = vgui.Create("DPanel", self)
	SidePanel:SetWide(250)
	SidePanel:Dock(LEFT)
	SidePanel:DockMargin(0, 30, 0, 0)
	SidePanel.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.SidePanel)
	end

	local buttonContainer = vgui.Create("DPanelList", SidePanel)
	buttonContainer:SetWide(250)
	buttonContainer:SetHeight(500)
	buttonContainer:Dock(TOP)
	buttonContainer:DockMargin(0, 0, 0, 0)

	if MjPointshop.UseInventory then
		function InventoryMenu()
			InventoryTab = vgui.Create('DPanel', self)
			InventoryTab:Dock(FILL)
			InventoryTab:DockMargin(0, 30, 0, 0)

			InventoryTab.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(233, 233, 2333))
				draw.DrawText("Inventory", "PS_Heading2", InventoryTab:GetWide() / 2, 15, Color(33, 19, 191), TEXT_ALIGN_CENTER)
			end

			local DScrollPanel = vgui.Create('DScrollPanel', InventoryTab)
			DScrollPanel:Dock(FILL)
			DScrollPanel:DockMargin(0, 35, 0, 10)
			DScrollPanel:GetVBar().Paint = function() end
DScrollPanel:GetVBar().btnUp.Paint = function() end
DScrollPanel:GetVBar().btnDown.Paint = function() end
DScrollPanel:GetVBar().btnGrip.Paint = function() end
local vbar = DScrollPanel:GetVBar()
vbar:SetWide(0)
			local ItemLayout = vgui.Create('DIconLayout', DScrollPanel)
			ItemLayout:Dock(FILL)
			ItemLayout:DockMargin(20, 0, 0, 0)
			ItemLayout:SetBorder(8)
			ItemLayout:SetSpaceX(5)
			ItemLayout:SetSpaceY(10)

			for _, i in pairs(PS.Items) do
				if LocalPlayer():PS_HasItem(i.ID) then
					local model = vgui.Create('DPointShopItem')
					model:SetData(i)
					model:SetSize(120, 120)
					ItemLayout:Add(model)
				end
			end
		end
	end
	if (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin()) then
		function Admin_Tab()
			-- admin tab
			AdminTab = vgui.Create('DPanel',self)
			AdminTab:Dock(FILL)
			AdminTab:DockMargin(0, 30, 0, 0)
			AdminTab.Paint = function(s,w,h)
					draw.RoundedBox(0,0,0,w,h,Color(233, 233, 233))
			end
			local ClientsList = vgui.Create('DListView', AdminTab)
			ClientsList:DockMargin(10, 10, 10, 10)
			ClientsList:Dock(FILL)
			ClientsList:SetMultiSelect(false)
			ClientsList:AddColumn('Name')
			ClientsList:AddColumn('Points'):SetFixedWidth(60)
			ClientsList:AddColumn('Items'):SetFixedWidth(60)

			ClientsList.OnClickLine = function(parent, line, selected)
				local ply = line.Player
				local menu = DermaMenu()

				menu:AddOption('Set ' .. PS.Config.PointsName .. '...', function()
					Derma_StringRequest("Set " .. PS.Config.PointsName .. " for " .. ply:GetName(), "Set " .. PS.Config.PointsName .. " to...", "", function(str)
						if not str or not tonumber(str) then return end
						net.Start('PS_SetPoints')
						net.WriteEntity(ply)
						net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end)
				end)

				menu:AddOption('Give ' .. PS.Config.PointsName .. '...', function()
					Derma_StringRequest("Give " .. PS.Config.PointsName .. " to " .. ply:GetName(), "Give " .. PS.Config.PointsName .. "...", "", function(str)
						if not str or not tonumber(str) then return end
						net.Start('PS_GivePoints')
						net.WriteEntity(ply)
						net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end)
				end)

				menu:AddOption('Take ' .. PS.Config.PointsName .. '...', function()
					Derma_StringRequest("Take " .. PS.Config.PointsName .. " from " .. ply:GetName(), "Take " .. PS.Config.PointsName .. "...", "", function(str)
						if not str or not tonumber(str) then return end
						net.Start('PS_TakePoints')
						net.WriteEntity(ply)
						net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end)
				end)

				menu:AddSpacer()

				BuildItemMenu(menu:AddSubMenu('Give Item'), ply, UNOWNED_ITEMS, function(item_id)
					net.Start('PS_GiveItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
					net.SendToServer()
				end)

				BuildItemMenu(menu:AddSubMenu('Take Item'), ply, OWNED_ITEMS, function(item_id)
					net.Start('PS_TakeItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
					net.SendToServer()
				end)

				menu:Open()
			end

			self.ClientsList = ClientsList

			AdminTab.Think = function()
			if self.ClientsList then
				local lines = self.ClientsList:GetLines()

				for _, ply in pairs(player.GetAll()) do
					local found = false

					for _, line in pairs(lines) do
						if line.Player == ply then
							found = true
						end
					end

					if not found then
						self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
					end
				end

				for i, line in pairs(lines) do
					if IsValid(line.Player) then
						local ply = line.Player

						line:SetValue(1, ply:GetName())
						line:SetValue(2, ply:PS_GetPoints())
						line:SetValue(3, table.Count(ply:PS_GetItems()))
					else
						self.ClientsList:RemoveLine(i)
					end
				end
			end
			end
		end
	end
	if MjPointshop.UseInventory then
		local InventoryButton = vgui.Create('DButton', SidePanel)
		InventoryButton:Dock(BOTTOM)
		InventoryButton:SetFont('PS_Heading3')
		InventoryButton:SetText('Inventory')
		InventoryButton:SetIcon("icon16/user.png")
		InventoryButton:SetColor(Color(255, 255, 255))
		InventoryButton:SetSize(86, 30)

		--closeButton:SetPos(self:GetWide() - 160, 0)
		InventoryButton.DoClick = function()
			if IsValid(AdminTab) then
				AdminTab:Remove()
			end

			if IsValid(InventoryTab) then
				InventoryTab:Remove()
				InvActive = false
			elseif not IsValid(InventoryTab) then
				InventoryMenu()
				InvActive = true
			end
		end

		InventoryButton.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 0))
		end

		InventoryButton.OnCursorEntered = function()
			InventoryButton.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, MjcBasicPS1SkinColor.CloseButtonHover)
			end
		end

		InventoryButton.OnCursorExited = function()
			InventoryButton.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 0))
			end
		end
	end

	//Admin Button
	if (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin()) then
		local AdminButton = vgui.Create('DButton', SidePanel)
		AdminButton:Dock(BOTTOM)
		AdminButton:SetFont('PS_Heading3')
		AdminButton:SetText('Admin')
		AdminButton:SetIcon("icon16/shield.png")
		AdminButton:SetColor(Color(255, 255, 255))
		AdminButton:SetSize(86, 30)

		--closeButton:SetPos(self:GetWide() - 160, 0)
		AdminButton.DoClick = function()
			if IsValid(AdminTab) then
				AdminTab:Remove()
			elseif not IsValid(AdminTab) then
				Admin_Tab()
			end
		end

		AdminButton.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 0))
		end

		AdminButton.OnCursorEntered = function()
			AdminButton.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, MjcBasicPS1SkinColor.CloseButtonHover)
			end
		end

		AdminButton.OnCursorExited = function()
			AdminButton.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 0))
			end
		end
	end

	local InfoPanel = vgui.Create("DPanel", SidePanel)
	InfoPanel:SetSize(250,60)
	InfoPanel:Dock(BOTTOM)
	InfoPanel:DockMargin(0, 5, 0, 0)
	InfoPanel.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.InfoPanel)
		--draw.SimpleText(PS.Config.PointsName..": " .. LocalPlayer():PS_GetPoints() , 'PS_Heading3',173, 23, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
		--draw.SimpleText(LocalPlayer():Nick(), 'PS_Heading3', 175, 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
       surface.SetFont( "PS_Heading3" )
	   surface.SetTextColor( 255, 255, 255, 255 )
	   surface.SetTextPos(69,34)
	   surface.DrawText( PS.Config.PointsName..": " .. LocalPlayer():PS_GetPoints())
       surface.SetFont( "PS_Heading3" )
	   surface.SetTextColor( 255, 255, 255, 255 )
	   surface.SetTextPos(69,10)
	   surface.DrawText( LocalPlayer():Nick())
	end
	local avatr = vgui.Create("AvatarImage", InfoPanel)
	avatr:SetPlayer(LocalPlayer(),64)
	avatr:Dock(LEFT)

	--PrintTable(i)
	-- close button
	local container = vgui.Create("DPanel", self)

	if PS.Config.DisplayPreviewInMenu then
		container:DockMargin(0, 30, 0, 0)
	else
		container:DockMargin(0, 0, 0, 0)
	end
	container:Dock(FILL)

	local btns = {}
	local firstBtn = true
	local function createBtn(text, material, panel, align, description)
		panel:SetParent(container)
		panel:Dock(FILL)
		panel.Paint = function(pnl, w, h) surface.SetDrawColor(232, 232, 232, 255) surface.DrawRect(0, 0, w, h) end

		if firstBtn then
			panel:SetZPos(100)
			panel:SetVisible(true)
		else
			panel:SetZPos(1)
			panel:SetVisible(false)
		end

		local btn = vgui.Create("DButton", buttonContainer)
		btn:SetText(text)
		btn:SetFont("PS_DefaultBold")
		btn:SetImage(material)
		if description and description ~= '' then
			btn:SetToolTip(description)
		end

		btn.Paint = function(pnl, w, h)
			surface.SetDrawColor(218, 218, 218, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.CatButtonColor)
			if pnl:GetActive() then
				surface.SetDrawColor(MjcBasicPS1SkinColor.CurrentActiveCat)
				surface.DrawRect(0, 0, w, h)
			end
		end

		btn.UpdateColours = function(pnl)
			if pnl:GetActive() then return pnl:SetTextColor(color_white) end
			if pnl.Hovered then return pnl:SetTextColor(color_white) end
			pnl:SetTextColor(color_white)
		end

		btn.OnCursorEntered = function(pnl)

			if pnl:GetActive() then
					btn.Paint = function(s,w,h,pnl)
						surface.SetDrawColor(MjcBasicPS1SkinColor.CurrentActiveCat)
						surface.DrawRect(0, 0, w, h)
					end
			end

			if not pnl:GetActive() then
					btn.Paint = function(s,w,h)
						surface.SetDrawColor(MjcBasicPS1SkinColor.NotActiveCat)
						surface.DrawRect(0, 0, w, h)
					end
			end
		end

		btn.OnCursorExited = function(pnl)
			if pnl:GetActive() then
					btn.Paint = function(s,w,h,pnl)
						surface.SetDrawColor(MjcBasicPS1SkinColor.CurrentActiveCat)
						surface.DrawRect(0, 0, w, h)
					end
			end
			if not pnl:GetActive() then
					btn.Paint = function(s,w,h)
						surface.SetDrawColor(MjcBasicPS1SkinColor.CatButtonColor)
						surface.DrawRect(0, 0, w, h)
					end
			end
		end

		btn.PerformLayout = function(pnl)
			btn:Dock(TOP)
			btn:SetSize(buttonContainer:GetWide(),50)

			pnl.m_Image:SetSize(16, 16)
			pnl.m_Image:SetPos( 8, (pnl:GetTall() - pnl.m_Image:GetTall()) * 0.5 )
			pnl:SetContentAlignment(4)
			pnl:SetTextInset( pnl.m_Image:GetWide() + 16, 0 )
		end

		btn.GetActive = function(pnl) return pnl.Active or false end
		btn.SetActive = function(pnl, state) pnl.Active = state end

		if firstBtn then firstBtn = false; btn:SetActive(true) end

		btn.DoClick = function(pnl)
			if IsValid(InventoryTab) then InventoryTab:Remove() end
			if IsValid(AdminTab) then AdminTab:Remove() end
			for k, v in pairs(btns) do v:SetActive(false) v:OnDeactivate() end
			pnl:SetActive(true) pnl:OnActivate()
		end

		btn.OnDeactivate = function(pnl)
			panel:SetVisible(false)
			panel:SetZPos(1)
			if pnl:GetActive() then
					btn.Paint = function(s,w,h,pnl)
						surface.SetDrawColor(Color(52, 73, 94))
						surface.DrawRect(0, 0, w, h)
					end
			end
			if not pnl:GetActive() then
					btn.Paint = function(s,w,h)
						surface.SetDrawColor(Color(44, 62, 80))
						surface.DrawRect(0, 0, w, h)
					end
			end
		end
		btn.OnActivate = function(pnl)
			panel:SetVisible(true)
			panel:SetZPos(100)

			if pnl:GetActive() then
					btn.Paint = function(s,w,h,pnl)
						surface.SetDrawColor(Color(52, 73, 94))
						surface.DrawRect(0, 0, w, h)
					end
			end
			if not pnl:GetActive() then
					btn.Paint = function(s,w,h)
						surface.SetDrawColor(Color(44, 62, 80))
						surface.DrawRect(0, 0, w, h)
					end
			end
		end

		table.insert(btns, btn)

		return btn
	end



	-- sorting
	local categories = {}

	for _, i in pairs(PS.Categories) do
		table.insert(categories, i)
	end

	table.sort(categories, function(a, b)
		if a.Order == b.Order then
			return a.Name < b.Name
		else
			return a.Order < b.Order
		end
	end)


	local items = {}

	for _, i in pairs(PS.Items) do
		table.insert(items, i)
	end

	table.SortByMember(items, PS.Config.SortItemsBy, function(a, b) return a > b end)

	-- ready for the worst sorting ever??

	local tbl1 = {}
	local tbl2 = {}
	local tbl3 = {}

	for _, i in pairs(items) do
		local points = PS.Config.CalculateBuyPrice(LocalPlayer(), i)

		if 		( LocalPlayer():PS_HasItem(i.ID) ) then table.insert(tbl3, i)
		elseif	( LocalPlayer():PS_HasPoints(points) ) then table.insert(tbl1, i)
		else	table.insert(tbl2, i) end
	end

	items = {}

	for _, i in pairs(tbl1) do table.insert(items, i) end
	for _, i in pairs(tbl2) do table.insert(items, i) end
	for _, i in pairs(tbl3) do table.insert(items, i) end

	-- items
	for _, CATEGORY in pairs(categories) do
		if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
			if not table.HasValue(CATEGORY.AllowedUserGroups, LocalPlayer():PS_GetUsergroup()) then
				continue
			end
		end

		if CATEGORY.CanPlayerSee then
			if not CATEGORY:CanPlayerSee(LocalPlayer()) then
				continue
			end
		end

		--Allow addons to create custom Category display types
 		local ShopCategoryTab = hook.Run( "PS_CustomCategoryTab", CATEGORY )
		if IsValid( ShopCategoryTab ) then
			createBtn(CATEGORY.Name, 'icon16/' .. CATEGORY.Icon .. '.png', ShopCategoryTab, nil, CATEGORY.Description)
			continue
		else
			ShopCategoryTab = vgui.Create('DPanel')
		end

		local DScrollPanel = vgui.Create('DScrollPanel', ShopCategoryTab)
		DScrollPanel:Dock(FILL)

		local ShopCategoryTabLayout = vgui.Create('DIconLayout', DScrollPanel)
		ShopCategoryTabLayout:Dock(FILL)
		ShopCategoryTabLayout:DockMargin(20,0,0,0)

		ShopCategoryTabLayout:SetBorder(8)
		ShopCategoryTabLayout:SetSpaceX(5)
		ShopCategoryTabLayout:SetSpaceY(10)
		DScrollPanel:GetVBar().Paint = function() end
		DScrollPanel:GetVBar().btnUp.Paint = function() end
		DScrollPanel:GetVBar().btnDown.Paint = function() end
		DScrollPanel:GetVBar().btnGrip.Paint = function() end
		local vbar = DScrollPanel:GetVBar()
		vbar:SetWide(0)


		DScrollPanel:AddItem(ShopCategoryTabLayout)

		for _, ITEM in pairs(items) do
			if ITEM.Category == CATEGORY.Name then
				local model = vgui.Create('DPointShopItem')
				model:SetData(ITEM)
				model:SetSize(120, 120)

				ShopCategoryTabLayout:Add(model)
			end
		end

		if CATEGORY.ModifyTab then
			CATEGORY:ModifyTab(ShopCategoryTab)
		end

		createBtn(CATEGORY.Name, 'icon16/' .. CATEGORY.Icon .. '.png', ShopCategoryTab, nil, CATEGORY.Description)
	end

	-- preview panel

	local preview
	if PS.Config.DisplayPreviewInMenu then
		preview = vgui.Create('DPanel', self)

		preview:DockMargin(0, 30, 0, 0)
		preview:Dock(RIGHT)
		preview:SetSize(300,30)

		local previewpanel = vgui.Create('DPointShopPreview', preview)
		previewpanel:Dock(FILL)

		--- Drag Rotate
		previewpanel.Angles = Angle( 0, 0, 0 )

		function previewpanel:DragMousePress()
			self.PressX, self.PressY = gui.MousePos()
			self.Pressed = true
		end

		function previewpanel:DragMouseRelease()
			self.Pressed = false
			self.lastPressed = RealTime()
		end

		function previewpanel:LayoutEntity( thisEntity )
			if ( self.bAnimated ) then self:RunAnimation() end

			if ( self.Pressed ) then
				local mx, my = gui.MousePos()
				self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
				self.PressX, self.PressY = gui.MousePos()
			end

			if ( RealTime() - ( self.lastPressed or 0 ) ) < 4 or self.Pressed then
				thisEntity:SetAngles( self.Angles )
			else
				self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
				thisEntity:SetAngles( Angle( 0, self.Angles.y ,  0) )
			end

		end

	end

	-- give points button

	if PS.Config.CanPlayersGivePoints then
		local givebutton = vgui.Create('DButton', preview or self)
		givebutton:SetText("Give "..PS.Config.PointsName)
		givebutton:SetTextColor(color_white)
		givebutton:SetFont("PS_DefaultBold")
		if PS.Config.DisplayPreviewInMenu then
			givebutton:DockMargin(8, 8, 8, 8)
		else
			givebutton:DockMargin(8, 0, 8, 8)
		end
		givebutton:Dock(BOTTOM)
		givebutton.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
		end
		givebutton.DoClick = function()
			vgui.Create('DPointShopGivePoints')
		end
		givebutton.OnCursorEntered = function()
			givebutton.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButtonHover)
			end
		end
		givebutton.OnCursorExited = function()
			givebutton.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
			end
		end
	end
end

function PANEL:Think()
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self)

	surface.SetDrawColor(40, 40, 40, 255)
	surface.DrawRect(0, 0, w, h)

	--surface.SetDrawColor(60, 80, 104, 255)
	surface.SetDrawColor(MjcBasicPS1SkinColor.HeaderColor)
	surface.DrawRect(0, 0, w, 30)

	if PS.Config.CommunityName then
		draw.SimpleText(PS.Config.CommunityName, 'PS_MainCommunityHeading', 8, 2, color_white)
	else
		draw.SimpleText("PointShop", 'PS_LargeTitle', 16, 2, color_white)
	end



end

vgui.Register('DPointShopMenu', PANEL)
