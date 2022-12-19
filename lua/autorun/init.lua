if SERVER then
	include("spawn_system/zombie_spawn_system.lua")
	include("config/config.lua")
	
	include("spawn_system/zombies_groups.lua")
	include("spawn_system/zombie_spawn_places.lua")

	include("config/config_zombies_groups.lua")
	include("config/config_spawn_places.lua")
	

	include("spawn_system/zombie_main_loop.lua")

end