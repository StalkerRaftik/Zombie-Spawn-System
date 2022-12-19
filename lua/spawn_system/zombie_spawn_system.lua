ZOMBIE_SPAWN_SYSTEM = ZOMBIE_SPAWN_SYSTEM or {}
ZSS = ZOMBIE_SPAWN_SYSTEM
ZSS.ZOMBIES_GROUPS = ZSS.ZOMBIES_GROUPS or {}
ZSS.SPAWN_PLACES = ZSS.SPAWN_PLACES or {}


function ZSS:createZombiesGroup(name)
	return ZSS.ZOMBIES_GROUPS:new(name)
end 

function ZSS:createSpawnPlace(name)
	return ZSS.SPAWN_PLACES:new(name)
end
