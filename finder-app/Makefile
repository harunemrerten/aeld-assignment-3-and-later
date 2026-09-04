# we show our toolchain aarch64-none-gnu- gcc ass (cross_compile)
CC = $(CROSS_COMPILE)gcc
CFLAGS ?= -Wall -Wextra

# our final executable
all: writer

# build the executable from the source file
writer: writer.c
	$(CC) $(CFLAGS) -o writer writer.c

clean:
	rm -f writer *.o

