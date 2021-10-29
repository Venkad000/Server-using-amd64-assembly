# Server-using-amd64-assembly

A simple server written in assembly language as part of my Assembly language course using nasm
 
#### To compile using nasm in linux:

``` bash
nasm -f elf64 server.asm
ld server.o -o server
./server
```
  
#### Running the server:
  
```bash
localhost:8888
```
