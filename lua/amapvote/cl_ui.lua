function amapvote.ShowVote(options, endTime)
	local window = vgui.Create("amapvote_VoteWindow")
	window:SetEndTime(endTime)
	for _, map in pairs(options) do
		window:AddChoice(map)
	end
end

function amapvote.ShowResult(map)
	chat.AddText("The option \"" .. map .. "\" has won the vote");
end

function amapvote.GetMapImages(map)
	
end



