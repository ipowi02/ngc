DCOMPILER ?= ldc2

main: nonowning.d maybe.d
	$(DCOMPILER) -c nonowning.d -of=nonowning.o maybe.d -of=maybe.o
clean:
	rm nonowning.o maybe.o
