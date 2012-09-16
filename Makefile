all:
	touch game/players.db
	touch game/high_scores.db

clean:
	rm game/players.db game/high_scores.db
	rm game/*py.class
