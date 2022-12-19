local function zombieSpawnCoroutine()
	local spawnPlaces = ZSS.SPAWN_PLACES:getAllPlaces()
	while true do
		coroutine.yield()

		local players = player.GetAll()
		if not next( players ) then 
			coroutine.yield()
		else
			for _, ply in ipairs( players ) do
				coroutine.yield() 
				
				if not IsValid( ply ) then continue end
				
				for _, place in pairs(spawnPlaces) do
					coroutine.yield()

					if not place:canSpawnNewZombie() then continue end

					if place:isPlayerInTrigger(ply) then
						local spawnPos = place:getZombieSpawnPoint(ply)
						if not spawnPos then continue end
						place:spawnZombieForPlayer(spawnPos)
					end
				end
			end
		end
	end
end


local function zombieDespawnCoroutine()
	local spawnPlaces = ZSS.SPAWN_PLACES:getAllPlaces()
	while true do
		coroutine.yield()
		for _, place in pairs(spawnPlaces) do
			coroutine.yield()
			if not place:isCooldownPassed() then continue end 
			if place:countPlayersInside() ~= 0 then continue end
			place:removeRandomZombieIfExists()
		end
	end
end

local function removeDesertedZombiesCoroutine()
	local spawnPlaces = ZSS.SPAWN_PLACES:getAllPlaces()
	while true do
		coroutine.yield()
		for _, place in pairs(spawnPlaces) do
			coroutine.yield()
			for _, zombie in pairs(place.zombies) do
				coroutine.yield()
				if not IsValid(zombie) then continue end

				local distanceToNearbyPlayerSqr = math.huge
				local zombiePos = zombie:GetPos()
				for _, ply in pairs(player.GetAll()) do
					coroutine.yield()
					local distanceToPly = zombiePos:DistToSqr(ply:GetPos())
					if distanceToPly < distanceToNearbyPlayerSqr then
						distanceToNearbyPlayerSqr = distanceToPly
					end
				end

				coroutine.yield()
				if distanceToNearbyPlayerSqr < math.pow(ZSS.MIN_ZOMBIE_DISTANCE_TO_PLAYERS_TO_DESPAWN, 2) then
					continue
				end

				if not IsValid(zombie) then continue end
				PrintMessage(HUD_PRINTTALK, "Ремуваем загулявшего" .. zombie:GetCreationID())
				zombie:Remove()
			end  
		end
	end
end


function ZSS:globalCoroutine() 
	local zombieSpawnRoutine = coroutine.create(zombieSpawnCoroutine)
	local zombieDespawnRoutine = coroutine.create(zombieDespawnCoroutine)
	local removeDesertedRoutine = coroutine.create(removeDesertedZombiesCoroutine)
	while true do
		coroutine.yield()
		coroutine.resume(zombieSpawnRoutine)
		coroutine.yield()
		coroutine.resume(zombieDespawnRoutine)
		coroutine.yield()
		coroutine.resume(removeDesertedRoutine)
	end
end
	

ZSS._COROUTINE = ZSS._COROUTINE or nil
hook.Add( "Think", "ZSS_MAIN_LOOP", function()
	if not ZSS._COROUTINE or not coroutine.resume( ZSS._COROUTINE ) then
		if ZSS._COROUTINE then
			print(coroutine.resume( ZSS._COROUTINE ))
		end
		ZSS._COROUTINE = coroutine.create( ZSS.globalCoroutine )
		coroutine.resume( ZSS._COROUTINE )
	end
end )