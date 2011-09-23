
ifndef PROJ
	$(error Need to define PROJ)
endif

ifeq ($(V),yes)
Q=
else
Q=@
endif

E=$(Q)echo
UR?=$(Q)urweb
DBMS?=sqlite

OUT=$(PROJ).exe
SQL=$(PROJ).sql

COMPFLAGS+= -output $(OUT)

ifeq ($(DBMS),sqlite)
DBNAME?=$(PROJ).db
else ifeq ($(DBMS),postgres)
DBNAME?=ur_$(PROJ)
else ifeq ($(DBMS),mysql)
DBNAME?=ur_$(PROJ)
endif

ifneq ($(DBMS),none)
COMPFLAGS+= -dbms $(DBMS) -sql $(SQL)
COMPFLAGS+= -db "dbname=$(DBNAME) $(DBOPTS)"
endif

ifeq ($(DEBUG),yes)
COMPFLAGS+= -debug
endif
ifeq ($(STATIC),yes)
COMPFLAGS+= -static
endif

all: build

build: createdb

createdb: compile
	$(E) Creating database...
ifeq ($(DBMS),sqlite)
	$(Q)sqlite3 $(DBNAME) < $(SQL)
	$(E) "pragma journal_mode=wal;" | sqlite3 $(DBNAME)
else ifeq ($(DBMS),postgres)
	$(Q)-dropdb $(DBNAME)
	$(Q)createdb $(DBNAME)
	psql -q -f $(SQL) $(DBNAME)
else ifeq ($(DBMS),mysql)
	-$(E) "drop database $(DBNAME);" | mysql
	-$(E) "create database $(DBNAME);" | mysql
	mysql $(DBNAME) < $(SQL)
endif

compile:
	$(E) Building...
	$(UR) $(COMPFLAGS) $(PROJ)
	$(E) Done compiling.

heroku:
	$(E) Creating Heroku files.
	$(E) You will need bundler installed!
	$(E) \'gem install bundler\' if you do not have it
	$(Q)touch Gemfile
	$(Q)bundle install && bundle show
	$(E) "web: ./$(OUT) -t 8 -p" '$$PORT' > Procfile
	$(E) Done. Now commit the Gemfile, Gemfile.lock and Procfile files

help:
	$(E) Simply running 'make' will compile your application
	$(E) and create a database for it based on the DBMS variable.
	$(E) Running 'heroku' will create some files you can use to
	$(E) start your app using 'foreman' and put it on Heroku.
	$(E) 
	$(E) Your .urp file should not need to mention any database
	$(E) options, and can be as simple as -
	$(E) 
	$(E) rewrite url /App/main
	$(E) 
	$(E) app

clean:
	rm -f *.exe *.db* *~ *.sql
