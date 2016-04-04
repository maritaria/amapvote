util.AddNetworkString(amapvote.NetString)
util.AddNetworkString(amapvote.ShowWinnerString)

net.Receive(amapvote.NetString, function(len, ply)
	if not IsValid(ply) then return end
	if not amapvote.currentvote then return end
	local votes = net.ReadTable()
	PrintTable(votes)
	amapvote.currentvote:UpdatePlayerVote(ply, votes)
end)

function amapvote.Think()
	if not amapvote.currentvote then return end
	if not amapvote.currentvote._started then return end
	if CurTime() < amapvote.currentvote._endTime then return end
	amapvote.currentvote:Finish()	
	amapvote.currentvote = nil
end

hook.Add("Think", "amapvote", amapvote.Think)