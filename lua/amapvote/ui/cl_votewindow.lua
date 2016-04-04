local FRAME = {}

local DRAG_MARGIN = 15
local SWAP_SPEED = 10
local WIDTH = 400

surface.CreateFont("Trebuchet28", {font = "Trebuchet", size = 28})
surface.CreateFont("Trebuchet36", {font = "Trebuchet", size = 36})

AccessorFunc(FRAME, "_bgcol", "BackgroundColor")
AccessorFunc(FRAME, "_endTime", "EndTime")

function FRAME:Init()
	self._choices = {}
	self._endTime = CurTime() + 30
	
	self:SetWide(WIDTH)
	self:SetBackgroundColor(Color(20, 20, 20))
	
	self._title = vgui.Create("DLabel", self)
	self._title:SetFont("Trebuchet36")
	self._title:SetTextColor(Color(250, 250, 250))
	self._title:SetText("Mapvote")
	self._title:SetPos(4, 2)
	self._title:SizeToContents()
	
	self._timer = vgui.Create("DLabel", self)
	self._timer:SetFont("Trebuchet28")
	self._timer:SetTextColor(Color(250, 250, 250))
	self._timer:SetText("0:00")
	self._timer:SizeToContents()
	
	self._choiceContainer = vgui.Create("Panel", self)
	self._choiceContainer:SetPos(5, 40)
	self._choiceContainer:SetSize(WIDTH - 10, 0)
	
	self._hint = vgui.Create("DLabel", self)
	self._hint:SetTextColor(Color(225, 225, 225))
	self._hint:SetFont("DermaDefault")
	self._hint:SetText("Click and drag to rank the maps from best to worst")
	self._hint:SizeToContents()
	
	gui.EnableScreenClicker(true)
	
end

function FRAME:AddChoice(text)
	local choice = vgui.Create("amapvote_VoteBox", self._choiceContainer)
	choice:SetWindow(self)
	choice:SetText(text)
	choice:SetOrder(#self._choices)
	table.insert(self._choices, choice)
end

function FRAME:StartDrag(choice)
	for _, otherChoice in pairs(self._choices) do
		if otherChoice != choice then
			otherChoice:Style_Default()
		end
	end
	--self:ShowMap(choice)
end

function FRAME:FinishDrag(choice)
	self:TransmitVote()
end

function FRAME:TransmitVote()
	local votes = {}
	for _,choice  in pairs(self._choices) do
		votes[choice:GetText()] = #self._choices - choice:GetOrder()
	end
	
	net.Start(amapvote.NetString)
	net.WriteTable(votes)
	net.SendToServer()
end

function FRAME:UpdateDrag(choice)
	local x, y = choice:GetMouseDragDelta()
	if y < -DRAG_MARGIN then
		self:MoveUp(choice)
	elseif y > choice:GetTall() + DRAG_MARGIN then
		self:MoveDown(choice)
	end
end

function FRAME:MoveUp(choice)
	oldOrder = choice:GetOrder()
	for _, otherChoice in pairs(self._choices) do
		if (otherChoice:GetOrder() == oldOrder - 1) then
			otherChoice:SetOrder(oldOrder)
			choice:SetOrder(oldOrder - 1)
			choice:IncreaseSpeed()
			otherChoice:IncreaseSpeed()
			self:InvalidateLayout()
			break
		end
	end
end

function FRAME:MoveDown(choice)
	oldOrder = choice:GetOrder()
	for _, otherChoice in pairs(self._choices) do
		if (otherChoice:GetOrder() == oldOrder + 1) then
			otherChoice:SetOrder(oldOrder)
			choice:SetOrder(oldOrder + 1)
			choice:IncreaseSpeed()
			otherChoice:IncreaseSpeed()
			self:InvalidateLayout()
			break
		end
	end
end


function FRAME:Think()
	local h = 2
	self._title:SetPos(4, h)
	self:Update_Timer(h)
	h = h + self._title:GetTall() + 5
	h = h + 3
	self._choiceContainer:SetPos(5, h)
	h = h + self:Update_Choices()
	h = h + 2
	self._hint:SetPos(4, h)
	h = h + self._hint:GetTall()
	h = h + 3
	self:SetTall(h)
	self:SetPos(ScrW() / 10, ScrH() - self:GetTall() - 100)
end

function FRAME:Update_Timer(h)
	local timeLeft = self:GetEndTime() - CurTime()
	if timeLeft < 0 then self:Remove() end
	timeLeft = math.Round(timeLeft)
	local minutes = math.Round(timeLeft / 60)
	local seconds = timeLeft % 60
	local text
	if minutes > 0 then
		text = minutes .. ":" .. seconds
	else
		text = seconds
	end
	self._timer:SetText(text)
	if (timeLeft > 10) then
		self._timer:SetTextColor(Color(250, 250, 250))
	else
		self._timer:SetTextColor(Color(250, 50, 50))
	end
	self._timer:SizeToContents()
	self._timer:SetPos(WIDTH - self._timer:GetWide() - 8, h + 4)
end

function FRAME:Update_Choices()
	local h = 0
	for _, choice in pairs(self._choices) do
		local _, y = choice:GetPos()
		local targetY = choice:GetOrder() * (choice:GetTall() + 10)
		choice:SetDragOrigin(targetY)
		local delta = targetY - y
		local speed = choice:GetSpeed()
		
		if (delta > 0) then
			y = math.min(y + SWAP_SPEED * speed, targetY)
		elseif (delta < 0) then
			y = math.max(y - SWAP_SPEED * speed, targetY)
		else
			choice._speed = 0
		end
		choice:SetPos(0, y)
		choice:SetWidth(choice:GetParent():GetWide())
		h = h + choice:GetTall() + 10
	end
	h = h - 10
	self._choiceContainer:SetTall(h)
	return h
end

function FRAME:Paint(w, h)
	local col = self:GetBackgroundColor() or Color(255, 255, 255)
	surface.SetDrawColor(col.r, col.g, col.b)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("amapvote_VoteWindow", FRAME, "Panel")

concommand.Add("test_ui", function()
	if IsValid(lastPanel) then lastPanel:Remove() end
	lastPanel = vgui.Create("amapvote_VoteWindow")
	
	lastPanel:AddChoice("ttt_hello_world_c35v")
	lastPanel:AddChoice("ttt_minecraft_5b")
	lastPanel:AddChoice("ttt_someshitty_map")
	lastPanel:AddChoice("ttt_awp_yea")
	lastPanel:AddChoice("ttt_the_last_map")
	
end)

