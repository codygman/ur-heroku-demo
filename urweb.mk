
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
ifeq ($(TC),yes)
COMPFLAGS+= -tc
endif

all: build

build: createdb

createdb: compile
ifneq ($(TC),yes)

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

endif

compile:
	$(E) Building...
	$(UR) $(COMPFLAGS) $(PROJ)
	$(E) Done compiling.

clean:
	rm -f *.exe *.db* *~ *.sql
