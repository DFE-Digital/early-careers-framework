flatten_queries: 
	mkdir -p /tmp/exports
	rm -f /tmp/exports/*.sql
	cat declarations.sql | tr --delete '\n' > /tmp/exports/declarations.sql
	cat participants.sql | tr --delete '\n' > /tmp/exports/participants.sql
	cat partnerships.sql | tr --delete '\n' > /tmp/exports/partnerships.sql
	cat schools.sql      | tr --delete '\n' > /tmp/exports/schools.sql
