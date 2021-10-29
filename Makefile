server:
	nasm -f elf64 server.asm
	ld server.o -o server

run:
	nasm -f elf64 server.asm
	ld server.o -o server
	./server

clean:
	rm server.o server