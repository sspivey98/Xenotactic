local lib = {}

function lib.drawNav(game)
    --draw top bar
	love.graphics.rectangle("line", 0, 0, game.screen.w, 50)
	love.graphics.print("Level: " .. game.level, 30, 15)
	love.graphics.print("Round: " .. game.round, 120, 15)
	love.graphics.print("Cash: " .. game.money, game.screen.w - 100, 15)

	--draw turret info section
	love.graphics.rectangle("line", 600, 50, 200, game.screen.h - 50)

	--draw selected turret title block
	love.graphics.rectangle("line", 625, 62.5, 150, 50)

	--reset color
	love.graphics.setColor(255,255,255)

	--draw turret selected stat window
	love.graphics.rectangle("line", 625, 300, 150, 225)

end

return lib