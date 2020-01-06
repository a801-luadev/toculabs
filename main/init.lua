tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableMortCommand(true)
tfm.exec.newGame(7642505)
tfm.exec.setGameTime(99999)

onEvent("NewPlayer", function(player)
	tfm.exec.respawnPlayer(player)

	translatedChatMessage(
		"welcome",
		player,
		github_link,
		featured_rooms[math.random(#featured_rooms)]
	)
end)

onEvent("PlayerDied", tfm.exec.respawnPlayer)