1. Work begin


## Build
On Arch Linux with pkgconf and systemd development files installed, build both examples with:

```bash
make
```

Alternatively compile manually:

```bash
gcc $(pkg-config --cflags --libs libsystemd) bus-service.c -o bus-service
gcc $(pkg-config --cflags --libs libsystemd) bus-client.c -o bus-client
```

## Run
- Start the Calculator service (user bus):

```bash
./bus-service &
```

- Call the Calculator from the included client (calls the user-bus Calculator by default):

```bash
# usage: ./bus-client [x] [y]
./bus-client 6 7
```

- The repo also contains an example systemd user unit in `contrib/net-poettering-calculator.service` — edit the ExecStart path if needed and enable it with:

```bash
# copy the unit to the user systemd directory
mkdir -p ~/.config/systemd/user
cp contrib/net-poettering-calculator.service ~/.config/systemd/user/

# reload and enable
systemctl --user daemon-reload
systemctl --user enable --now net-poettering-calculator.service
```

## Run with run.sh (convenience)
A convenience script `run.sh` is included to build both examples, start the service in the background, wait for it to register on the session D-Bus, run the client, then stop the server the script started.

Usage:

```bash
chmod +x run.sh      # once
./run.sh             # uses defaults: 6 7
./run.sh 8 9         # run client with 8 and 9
```

Notes:
- If another process or a systemd user unit already holds the `net.poettering.Calculator` name on the session bus, `run.sh` may time out waiting for registration. Stop the existing service or change the well-known name in `bus-service.c` for testing.
- For persistent management, use the provided systemd user unit in `contrib/`.

## Notes
- `bus-service` registers `net.poettering.Calculator` on the *user* bus and implements Multiply/Divide.
- `bus-client` now calls that Calculator on the *user* bus (you can pass two integers as arguments).
- Binaries are ignored by `.gitignore`; rebuild locally after pulling.
