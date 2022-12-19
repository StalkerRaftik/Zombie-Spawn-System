# NPC Spawn System for Garry's Mod

Simple npc spawn system based on two entities: 
- Zombies groups - set of NPC with spawn chances
- Spawn places - some territory where zombies will spawn. It's given as two vectors - ends of cube diameters 

## Features: 

- Best performance - spawn system is fully based on coroutines 
- Simple configuration
- Flexible spawn distance configuration and spawn detection
- You can create one zombie group and use it multiple times in different spawn places
- Zombie respawn time(only if zombie killed by player)

## Usage:

1. Go to `lua/config` folder
2. Configure it!
