local PANEL = {}

AccessorFunc(PANEL, "_order", "Order")
AccessorFunc(PANEL, "_speed", "Speed")
AccessorFunc(PANEL, "_dragOrigin", "DragOrigin")

function PANEL:Init()
	self._label = vgui.Create("DLabel", self)
	self._label:SetFont("Trebuchet24")
	self._label:SetTextColor(Color(0, 0, 0))
	self._text = "" 
	self._order = 0
	self._speed = 1
	self:SetCursor("hand")
	self:SetPaintBackground(false)
	self:Style_Default()
end

function PANEL:IncreaseSpeed()
	self:SetSpeed(1 + self:GetSpeed())
end

function PANEL:GetText()
	return self._text
end

function PANEL:SetText(text)
	self._text = text
	self._label:SetText((self._order + 1) .. ": " .. text)
	self:InvalidateLayout()
end

function PANEL:GetOrder()
	return self._order
end

function PANEL:SetOrder(value)
	self._order = value
	self:SetText(self._text)
end

function PANEL:SetWindow(window)
	self._window = window
end

function PANEL:PerformLayout(w, h)
	self._label:SetPos(40, 10)
	self._label:SizeToContents()
	self:SetTall(self._label:GetTall() + 20)
end

function PANEL:OnMousePressed(code)
	if code != MOUSE_LEFT then return end
	self:MouseCapture(true)
	self._dragging = true
	self._window:StartDrag(self)
	self:Style_Dragging()
end

function PANEL:OnCursorMoved(x, y)
	if not self._dragging then return end
	self._window:UpdateDrag(self)
end

function PANEL:OnMouseReleased(code)
	if code != MOUSE_LEFT then return end
	if not self._dragging then return end
	self:MouseCapture(false)
	self._dragging = false
	self._window:FinishDrag(self)
	self:Style_Selected()
end

function PANEL:GetMouseDragDelta()
	local mouseX, mouseY = self:GetParent():ScreenToLocal(gui.MousePos())
	mouseY = mouseY - self._dragOrigin
	return mouseX, mouseY
end

function PANEL:Style_Default()
	self:SetBackgroundColor(Color(50, 50, 50))
end

function PANEL:Style_Dragging()
	self:SetBackgroundColor(Color(70, 70, 70))
end

function PANEL:Style_Selected()
	self:SetBackgroundColor(Color(65, 65, 65))
end

function PANEL:Think()
	local order = self:GetOrder()
	if (order == 0) then
		self._label:SetColor(Color(255, 220, 20))
	else
		local col = math.max(100, 255 * (1 - (order / 7)))
		self._label:SetColor(Color(col, col, col))
	end
end

function PANEL:Paint(w, h)
	local col = self:GetBackgroundColor() or Color(255, 255, 255)
	surface.SetDrawColor(col.r, col.g, col.b, 255)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("amapvote_VoteBox", PANEL, "DPanel")