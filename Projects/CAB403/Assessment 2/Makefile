# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -pthread

# Targets
TARGETS = car controller call internal safety

# Default target
all: $(TARGETS)

# Build car component
car: car.c car.h
	$(CC) $(CFLAGS) car.c -o car

# Build controller component
controller: controller.c
	$(CC) $(CFLAGS) controller.c -o controller

# Build call pad component
call: call.c
	$(CC) $(CFLAGS) call.c -o call

# Build internal controls component
internal: internal.c car.h
	$(CC) $(CFLAGS) internal.c -o internal

# Build safety critical component
safety: safety.c car.h
	$(CC) $(CFLAGS) safety.c -o safety

# Clean up
clean:
	rm -f $(TARGETS)
