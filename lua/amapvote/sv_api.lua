function amapvote.StartMapVote(options, duration)
	assert(not amapvote.currentvote, "vote already started")
	duration = duration or 30
	amapvote.currentvote = amapvote.CreateVote()
	for _, map in pairs(options) do
		amapvote.currentvote:AddChoice(map)
	end
	amapvote.currentvote:SetDuration(duration)
	amapvote.currentvote:Start()
end

function amapvote.GenerateMapVote(numberOfOptions, duration)
	
end

function amapvote.test()
	amapvote.StartMapVote({
		"ttt_minecraft_b5",
		"ttt_some_shitty_map",
		"ttt_i_hate_this_map",
		"ttt_rooftops",
		"ttt_asia_2016_final",
		
		}, 10)
	end