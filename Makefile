all:
	touch duck_hunt/players.db
	touch duck_hunt/high_scores.db

clean:
	rm duck_hunt/players.db duck_hunt/high_scores.db
	rm duck_hunt/*py.class
