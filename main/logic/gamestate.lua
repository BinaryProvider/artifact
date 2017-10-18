local GameState = {
	LEVEL = 1,
	WELCOME = true,
	GAME_OVER = false,
	GAME_WON = false,
	PORTAL_OPEN = false,
	TIME_LEFT = 0,
	TIME_PER_LEVEL = 8,
	SCORE = 0
}

function GameState:reset()
	GameState.PORTAL_OPEN = false
	GameState.GAME_OVER = false
end

return GameState
