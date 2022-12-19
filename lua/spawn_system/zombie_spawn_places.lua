local places = ZSS.SPAWN_PLACES
places.__index = places
places.PLACES_LIST = places.PLACES_LIST or {}

function places:new(name)
	local place = {
		name = name,
		coords = {min=nil, max=nil},
		triggerCoords = {min=nil, max=nil},
		coordsDistance = 0,
		zombieGroup = nil,
		zombiesCount = 0,
		maxZombiesCount = 0,
		zombies = {},
		nextActionTimestamp = 0,
		respawnTimerAfterKill = 0,
	}
	setmetatable(place, self)
	
	table.insert(places.PLACES_LIST, place)
	return place
end

function places:getAllPlaces()
	return places.PLACES_LIST
end

function places:setZombieGroup(name)
	self.zombieGroup = ZSS.ZOMBIES_GROUPS:getGroupByName(name)
	return self
end

function places:setCoords(coord1, coord2)
	local minx, maxx = coord1.x, coord1.x
	local miny, maxy = coord1.y, coord1.y
	local minz, maxz = coord1.z, coord1.z
	if coord2.x < minx then
		minx = coord2.x
	end
	if coord2.x > maxx then
		maxx = coord2.x
	end
	if coord2.y < miny then
		miny = coord2.y
	end
	if coord2.y > maxy then
		maxy = coord2.y
	end
	if coord2.z < minz then
		minz = coord2.z
	end
	if coord2.z > maxz then
		maxz = coord2.z
	end

	self.coords = {min=Vector(minx, miny, minz), max=Vector(maxx, maxy, maxz)}
	self.coordsDistance = self.coords.min:Distance(self.coords.max)


	local additionalBoxSize = Vector(ZSS.ADDITIONAL_PLAYER_DETECTION_RADIUS, ZSS.ADDITIONAL_PLAYER_DETECTION_RADIUS, ZSS.ADDITIONAL_PLAYER_DETECTION_RADIUS)
	self.triggerCoords = {min=self.coords.min - additionalBoxSize, max=self.coords.max + additionalBoxSize}

	return self
end


function places:setMaxZombiesCount(maxZombiesCount)
	self.maxZombiesCount = maxZombiesCount

	return self
end

function places:setZombieRespawnTime(respawnTimerAfterKill)
	self.respawnTimerAfterKill = respawnTimerAfterKill

	return self
end

function places:getZombiesCount() 
	return self.zombiesCount
end

function places:isCooldownPassed()
	return self.nextActionTimestamp < CurTime()
end

function places:canSpawnNewZombie()
	if not self:isCooldownPassed() then return false end
	if self:getZombiesCount() >= self.maxZombiesCount then return false end
	return true
end

function places:getRandomPointIn()
	local spawnPoint = Vector(
		math.Rand(self.coords.min[1], self.coords.max[1]),
		math.Rand(self.coords.min[2], self.coords.max[2]),
		math.Rand(self.coords.min[3], self.coords.max[3])
	)
	return spawnPoint
end

function places:isInPlace(vector)
	if vector.x < self.coords.min[1] then return false end
	if vector.x > self.coords.max[1] then return false end
	if vector.y < self.coords.min[2] then return false end
	if vector.y > self.coords.max[2] then return false end
	if vector.z < self.coords.min[3] then return false end
	if vector.z > self.coords.max[3] then return false end

	return true
end

function places:isInTrigger(vector)
	if vector.x < self.triggerCoords.min[1] then return false end
	if vector.x > self.triggerCoords.max[1] then return false end
	if vector.y < self.triggerCoords.min[2] then return false end
	if vector.y > self.triggerCoords.max[2] then return false end
	if vector.z < self.triggerCoords.min[3] then return false end
	if vector.z > self.triggerCoords.max[3] then return false end

	return true
end

function places:isPlayerInTrigger(ply)
	return self:isInTrigger(ply:GetPos())
end

function places:countPlayersInside()
	local playersCount = 0
	for _, ply in pairs(player.GetAll()) do
		if not self:isPlayerInTrigger(ply) then continue end
		playersCount = playersCount + 1
	end

	return playersCount
end

function places:canSpawnHere(vector)
    local tr = {
        start = vector,
        endpos = vector,
        mins = Vector(-18, -18, 0), -- draw a 3d box of the player hull size
        maxs = Vector(18, 18, 73)
    }

    local hullTrace = util.TraceHull(tr)

    if (hullTrace.Hit) then
        return false
    end

    return true
end

-- Используется полярная система координат. Математика - хуета, но тут конечно ебет
function places:getZombieSpawnPoint(ply)
	local maxTries = 30
	local tries = 0

	while tries < maxTries do
		local circeCenter = ply:GetPos()
		local maxRadius = math.min(ZSS.MAX_PLAYER_DISTANCE_TO_SPAWN, self.coordsDistance)
		local minRadiusNormalized = ZSS.MIN_PLAYER_DISTANCE_TO_SPAWN / ZSS.MAX_PLAYER_DISTANCE_TO_SPAWN

		local r = maxRadius * math.sqrt(math.Rand(minRadiusNormalized, 1))
		local theta = math.Rand(0, 1) * 2 * math.pi

		local x = circeCenter.x + r * math.cos(theta)
		local y = circeCenter.y + r * math.sin(theta)
		local z = math.Rand(self.coords.min[3], self.coords.max[3])

		local spawnPoint = Vector(x, y, z)
		if self:isInPlace(spawnPoint) and util.IsInWorld(spawnPoint) and self:canSpawnHere(spawnPoint) then
			return spawnPoint
		end

		tries = tries + 1
	end
end

function places:chooseZombieToSpawn() 
	return self.zombieGroup:chooseZombieToSpawn()
end

function places:updateTimestamp()
	self.nextActionTimestamp = CurTime() + 0.5
end

function places:spawnZombieForPlayer(spawnPos)
	local zombieId = self:chooseZombieToSpawn()

	local zombie = ents.Create( zombieId )
	zombie:SetPos( spawnPos )
	zombie:DropToFloor()
	zombie:Activate()
	zombie:Spawn()

	zombie.zssSpawnPlace = self
	self.zombies[zombie:GetCreationID()] = zombie
	self.zombiesCount = self.zombiesCount + 1

	self:updateTimestamp()
end

function places:removeRandomZombieIfExists()
	for _, zombie in RandomPairs(self.zombies) do
		if not IsValid(zombie) then continue end
		zombie:Remove()
		break
	end

	self:updateTimestamp()
end

function places:clearZombieData(zombie)
	self:clearZombieDataById(zombie:GetCreationID())
end

function places:clearZombieDataById(zombieID)
	self.zombiesCount = self.zombiesCount - 1
	self.zombies[zombieID] = nil
end



hook.Add("EntityRemoved", "ZSS_UpdateTablesOnZombieRemove", function(ent)
	if not ent.zssSpawnPlace or ent.preventEntityRemovedEvent then return end
	ent.zssSpawnPlace:clearZombieData(ent)
end)


hook.Add( "OnNPCKilled", "ZSS_DeleteKilledZombieFromTable", function(ent)
	if not ent.zssSpawnPlace then return end
	ent.preventEntityRemovedEvent = true
	
	local spawnPlace = ent.zssSpawnPlace
	local zombieID = ent:GetCreationID()
	timer.Simple(spawnPlace.respawnTimerAfterKill, function() 
		spawnPlace:clearZombieDataById(zombieID)
	end)
end )