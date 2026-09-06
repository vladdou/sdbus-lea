CC = gcc
PKG_CFLAGS = $(shell pkg-config --cflags libsystemd)
PKG_LIBS   = $(shell pkg-config --libs libsystemd)

all: bus-service bus-client

bus-service: bus-service.c
	$(CC) $(PKG_CFLAGS) $< -o $@ $(PKG_LIBS)

bus-client: bus-client.c
	$(CC) $(PKG_CFLAGS) $< -o $@ $(PKG_LIBS)

clean:
	rm -f bus-service bus-client
