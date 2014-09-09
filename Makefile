
BIN ?= batsh
PREFIX ?= /usr/local

$(BIN): install
	@:

install:
	install batsh.sh $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)

