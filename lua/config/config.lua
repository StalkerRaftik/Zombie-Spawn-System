-- Минимальное расстояние до спавна.
-- 0 - может заспавнить впритык
ZSS.MIN_PLAYER_DISTANCE_TO_SPAWN = 1500

-- Максимальное расстояние до спавна.
-- Слишком большое расстояние ставить не надо
ZSS.MAX_PLAYER_DISTANCE_TO_SPAWN = 3500

-- Дополнительный радиус обнаружения игрока. 
-- Если поставить 0 - будет респавнить только если игрок внутри координат. 
-- Если больше - будет спавнить еще до того, как игрок зашел внутрь территории
-- Всегда должно быть меньше MAX_PLAYER_DISTANCE_TO_SPAWN
ZSS.ADDITIONAL_PLAYER_DETECTION_RADIUS = 1200

-- Как далеко зомби должен быть от каждого из игроков, чтобы его удалить
ZSS.MIN_ZOMBIE_DISTANCE_TO_PLAYERS_TO_DESPAWN = 4000
