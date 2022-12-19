local zombiesGroups = ZSS.ZOMBIES_GROUPS
zombiesGroups.__index = zombiesGroups
zombiesGroups.GROUPS_LIST = zombiesGroups.GROUPS_LIST or {}

function zombiesGroups:new(name)
	local group = {
		name=name,
		zombies={},
		summaryRatio=0,
	}
	setmetatable(group, self)
	
	table.insert(zombiesGroups.GROUPS_LIST, group)
	return group
end

function zombiesGroups:getAllGroups()
	return zombiesGroups.GROUPS_LIST
end

function zombiesGroups:getGroupByName(name)
	for _, group in pairs(self.getAllGroups()) do
		if group.name == name then
			return group
		end
	end
	error('Группа' .. name .. 'не найдена!')
end

function zombiesGroups:addZombie(npc_id, spawn_ratio)
	table.insert(self.zombies, {ratioLimit=self.summaryRatio+spawn_ratio, npc=npc_id})
	self.summaryRatio = self.summaryRatio + spawn_ratio

	return self
end

function zombiesGroups:getSummarySpawnRatio()
	return self.summaryRatio
end

function zombiesGroups:chooseZombieToSpawn() 
	local randNumber = math.random(1, self.summaryRatio)
	for _, zombieData in pairs(self.zombies) do
		if randNumber > zombieData.ratioLimit then continue end
		return zombieData.npc
	end
end
