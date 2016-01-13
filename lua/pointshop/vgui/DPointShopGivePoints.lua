local MjcBasicPS1SkinColor = {
	CloseButton = Color(52, 73, 94),
	CloseButtonHover = Color(79, 111, 143),
	SidePanel = Color(44, 62, 80),
	InfoPanel = Color(52, 73, 94),
	HeaderColor = Color(44, 62, 80),
	CatButtonColor = Color(44, 62, 80),
	CurrentActiveCat = Color(52, 73, 94),
	NotActiveCat = Color(79, 111, 143),
	GivePointsButton = Color(52, 73, 94),
	GivePointsButtonHover = Color(79, 111, 143),
	Background = Color(61,86,110),
}


local PANEL = {}

function PANEL:Init()
	self:SetTitle("")
	self:SetSize(300, 144)

	self:SetDeleteOnClose(true)
	self:SetBackgroundBlur(true)
	self:SetDrawOnTop(true)

	self.btnMaxim:SetVisible(false)
	self.btnMinim:SetVisible(false)

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
	closeButton:SetSize(40, 25)
	closeButton:SetPos(self:GetWide() - 41, 0)
	closeButton.DoClick = function()
		self:Remove()
	end



	local l1 = vgui.Create("DLabel", self)
	l1:SetText("Player:")
	l1:SetFont("PS_DefaultBold")
	l1:Dock(TOP)
	l1:DockMargin(4, 0, 4, 4)
	l1:SizeToContents()

	local pselect = vgui.Create("DComboBox", self)
	pselect:SetValue("Select A Player")
	pselect:SetTall(24)
	pselect:Dock(TOP)
	self.playerselect = pselect

	self:FillPlayers()

	local l2 = vgui.Create("DLabel", self)
	l2:SetText(PS.Config.PointsName..":")
	l2:SetFont("PS_DefaultBold")
	l2:Dock(TOP)
	l2:DockMargin(4, 2, 4, 4)
	l2:SizeToContents()

	local pointsselector = vgui.Create("DNumberWang", self)
	pointsselector:SetTextColor( Color(0, 0, 0, 255) )
	pointsselector:SetTall(24)
	pointsselector:Dock(TOP)
	self.pselector = pointsselector

	local btnlist = vgui.Create("DPanel", self)
	btnlist:SetDrawBackground(false)
	btnlist:DockMargin(0, 5, 0, 0)
	btnlist:Dock(BOTTOM)

	local cancel = vgui.Create('DButton', btnlist)
	cancel:SetText('Cancel')
	cancel:DockMargin(4, 0, 0, 0)
	cancel:SetTextColor(color_white)
	cancel:SetFont("PS_DefaultBold")
cancel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
			if cancel.Hovered then
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButtonHover)
			else
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
			end
	end
	cancel.OnCursorEntered = function()
		cancel.Hovered = true
	end
	cancel.OnCursorExited = function()
		cancel.Hovered = false
	end
	cancel:Dock(RIGHT)
	self.cancel = cancel

	local done = vgui.Create('DButton', btnlist)
	done:SetText('Send')
	done:SetDisabled(true)
	done:SetTextColor(color_white)
	done:SetFont("PS_DefaultBold")
	done:DockMargin(0, 0, 4, 0)
	done.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
			if done.Hovered then
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButtonHover)
			else
				draw.RoundedBox(0,0,0,w,h,MjcBasicPS1SkinColor.GivePointsButton)
			end
	end
	done.OnCursorEntered = function()
		done.Hovered = true
	end
	done.OnCursorExited = function()
		done.Hovered = false
	end
	done:Dock(RIGHT)
	self.submit = done

	self.selected_uid = nil
	pselect.OnSelect = function( s, idx, val, data )
		if data then self.selected_uid = data end

		self:Update()
	end

	pointsselector.OnValueChanged = function()
		self:Update()
	end

	done.DoClick = function()
		self:Submit()
		self:Close()
	end

	cancel.DoClick = function()
		self:Close()
	end

	self:Center()
	self:MakePopup()
end

function PANEL:FillPlayers()
	for _, ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then continue end

		self.playerselect:AddChoice(ply:Nick(), ply:UniqueID())
	end
end

function PANEL:Submit()
	local other = false

	for _, ply in pairs(player.GetAll()) do
		if tonumber(ply:UniqueID()) == tonumber(self.selected_uid) then
			other = ply
		end
	end

	if not other then return end -- player could have left

	net.Start('PS_SendPoints')
		net.WriteEntity(other)
		net.WriteInt(tonumber(self.pselector:GetValue()), 32)
	net.SendToServer()
end

function PANEL:Update()
	local disabled = false

	if not self.selected_uid then disabled = true end

	if (self.pselector:GetValue() < 1) or (self.pselector:GetValue() > LocalPlayer():PS_GetPoints()) then
		disabled = true
		self.pselector:SetTextColor(Color(180, 0, 0, 255))
	else
		self.pselector:SetTextColor(Color(0, 0, 0, 255))
	end

	self.submit:SetDisabled(disabled)
end

function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,25,MjcBasicPS1SkinColor.HeaderColor)
    draw.RoundedBox(0,0,25,w,h,MjcBasicPS1SkinColor.Background)
		draw.SimpleText("PointShop Give "..PS.Config.PointsName, 'PS_DefaultBold', 4, 5, color_white)
end

vgui.Register('DPointShopGivePoints', PANEL, 'DFrame')
