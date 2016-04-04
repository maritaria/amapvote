net.Receive(amapvote.NetString, function() amapvote.ReceiveVoteStart() end)

function amapvote.ReceiveVoteStart()
	local tbl = net.ReadTable()
	amapvote.ShowVote(tbl.options, tbl.endTime)
end

net.Receive(amapvote.ShowWinnerString, function() amapvote.ReceiveVoteResults() end)

function amapvote.ReceiveVoteResults()
	local map = net.ReadString()
	amapvote.ShowResult(map)
end