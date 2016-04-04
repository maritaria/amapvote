local voteClass = {}
voteClass.__index = voteClass

function amapvote.CreateVote()
	local instance = {}
	setmetatable(instance, voteClass)
	instance:ctor()
	return instance
end

function voteClass:ctor()
	self._options = {}
	self._votes = {}
	self._started = false
	self._duration = 30
	self._startTime = 0
end

function voteClass:GetDuration()
	return self._duration
end

function voteClass:SetDuration(dur)
	assert(not self._started, "vote already started")
	self._duration = dur
end

function voteClass:AddChoice(map)
	assert(not self._started, "vote already started")
	table.insert(self._options, map)
end

function voteClass:Start()
	assert(not self._started, "vote already started")
	assert(#self._options > 0, "No totalVotes given")
	print("Mapvote started")
	self._startTime = CurTime()
	self._endTime = self._startTime + self._duration
	self._started = true
	
	net.Start(amapvote.NetString)
	
	net.WriteTable({
		options = self._options,
		endTime = self._endTime,
	})
	
	net.Broadcast()	
end

function voteClass:UpdatePlayerVote(ply, ballet)
	self._votes[ply] = ballet
end

function voteClass:Finish()
	print("Mapvote finished")
	self:FindWinner()
	self:OnComplete(self._winner)
end

function voteClass:FindWinner()
	local totalVotes = {}
	
	if table.Count(self._votes) == 0 then
		return self:PickRandom()
	end
	
	for _, ballet in pairs(self._votes) do
		for map, score in pairs(ballet) do
			totalVotes[map] = (totalVotes[map] or 0) + score
		end
	end
		
	local highest = false
	local highestScore = -1
	print("totalvotes:")
	PrintTable(totalVotes)
	for map, score in pairs(totalVotes) do
		print(map, score, highestScore)
		if score > highestScore then
			highestScore = score
			highest = map
		end
	end
	
	self._winner = highest
end

function voteClass:PickRandom()
	return table.Random(self._options)
end

function voteClass:OnComplete(map)
	--Add your code here :D
	print("Winning map:", map)
	self._started = false
	self:AnnounceWinner(map)
	self:ChangeMap(map)
end

function voteClass:AnnounceWinner(map)
	net.Start(amapvote.ShowWinnerString)
	net.WriteString(map)
	net.Broadcast()
end

function voteClass:ChangeMap(map)
	timer.Simple(5, function()
		RunConsoleCommand("changelevel", map)
	end)
end