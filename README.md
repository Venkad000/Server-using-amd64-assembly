# Server-using-amd64-assembly

A simple server written in assembly language as part of my Assembly language course using nasm for educational purposes.




#### To compile using nasm in linux:

#### To compile:

```make
make
```
#### To compile run the server:

```make
make run
```

#### or


``` bash
nasm -f elf64 server.asm
ld server.o -o server
./server
```
  

  
```bash
localhost:8888
```
