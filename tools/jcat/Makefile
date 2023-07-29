ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

jcat: main.cpp
	g++ -o jcat main.cpp -Wall -std=c++11 -I./include

all: jcat

.PHONY: install clean

clean: 
	rm -f jcat

install: jcat
	install -d $(PREFIX)/bin
	install -m 755 jcat $(PREFIX)/bin/
