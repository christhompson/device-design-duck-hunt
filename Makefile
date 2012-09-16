all:
	touch players.db
	touch high_scores.db

clean:
	rm players.db high_scores.db
	rm *py.class

