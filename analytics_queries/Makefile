flatten_queries:
	mkdir -p /tmp/exports
	rm -f /tmp/exports/*.sql
	cat declarations.sql     | tr --delete '\n' > /tmp/exports/declarations.sql
	cat participants.sql     | tr --delete '\n' > /tmp/exports/participants.sql
	cat induction_tutors.sql | tr --delete '\n' > /tmp/exports/induction_tutors.sql
	cat partnerships.sql     | tr --delete '\n' > /tmp/exports/partnerships.sql
	cat schools.sql          | tr --delete '\n' > /tmp/exports/schools.sql
