#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <inttypes.h>
#include <systemd/sd-bus.h>

int main(int argc, char *argv[]) {
  sd_bus_error error = SD_BUS_ERROR_NULL;
  sd_bus_message *m = NULL;
  sd_bus *bus = NULL;
  int64_t x = 6, y = 7;
  int64_t result = 0;
  int r;

  if (argc >= 3) {
    x = atoll(argv[1]);
    y = atoll(argv[2]);
  }

  /* Connect to the user bus */
  r = sd_bus_open_user(&bus);
  if (r < 0) {
    fprintf(stderr, "Failed to connect to user bus: %s\n", strerror(-r));
    goto finish;
  }

  /* Call the Calculator Multiply method */
  r = sd_bus_call_method(bus,
                         "net.poettering.Calculator",            /* service to contact */
                         "/net/poettering/Calculator",          /* object path */
                         "net.poettering.Calculator",           /* interface name */
                         "Multiply",                            /* method name */
                         &error,
                         &m,
                         "xx",                                  /* input signature */
                         x,
                         y);
  if (r < 0) {
    fprintf(stderr, "Failed to issue method call: %s\n", error.message ? error.message : strerror(-r));
    goto finish;
  }

  /* Parse the response message */
  r = sd_bus_message_read(m, "x", &result);
  if (r < 0) {
    fprintf(stderr, "Failed to parse response message: %s\n", strerror(-r));
    goto finish;
  }

  printf("Result: %" PRId64 "\n", result);

finish:
  sd_bus_error_free(&error);
  sd_bus_message_unref(m);
  sd_bus_unref(bus);

  return r < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
