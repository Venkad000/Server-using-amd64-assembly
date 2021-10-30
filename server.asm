
; defining for sockets

%define AF_INET           2 
%define SOCK_STREAM       1

; defining syscalls

%define SYS_WRITE         1
%define SYS_OPEN          2 
%define SYS_CLOSE         3 

%define SYS_SENDFILE     40 
%define SYS_SOCKET       41
%define SYS_ACCEPT       43
%define SYS_BIND         49

%define SYS_EXIT         60 
%define SYS_LISTEN       50

; macros to push to stack in order to save values

%macro pushToStack 0
    push rdi 
    push rsi
    push rdx
    push r10
    push r8
    push r9
    push rbx
    push rcx
%endmacro

; macros to pop from stack in order to get back the pushed values

%macro popStack 0
    pop rcs
    pop rbx
    pop r9
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
%endmacro

; data section

section .data

    ; struct for the sockaddr_in

    struc sockaddr_in
        .sin_family resw 1
        .sin_port resw 1
        .sin_addr resd 1
        .sin_zero resb 8
    endstruc

    buffer:  times 2048 db 0    ; The max size which can be read from the html file
    variable_number: times 3 db 0

    ; always reads from index.html

    file_path db "index.html",0 
    file_read_error_message db "Error reading the file", 0x0a,0
    file_read_error_message_len equ $  - file_read_error_message
    
    ; messages

    socket_error_message db "Failed to open socket", 0x0a,0
    socket_error_message_len equ $ - socket_error_message

    binding_error_message db "Error on binding", 0x0a, 0
    binding_error_message_len equ $ - binding_error_message

    help_message db "The port is open on 8888. See localhost::8888", 0
    help_message_len equ $ - help_message

    http_200 db "HTTP/1.1 200 OK",0x0d,0x0a, 0
    http_200_len equ $ - http_200

    contentType db "Content-Type: text/html; charset=utf-8",0x0d,0x0a, 0
    contentType_len equ $ - contentType

    contentLength db "Content-Length: "
    contentLength_len equ $ - contentLength

    connection db "Connection: close",0x0d,0x0a, 0
    connection_len equ $ - connection

    serv istruc sockaddr_in
        at sockaddr_in.sin_family, dw 2
        at sockaddr_in.sin_port, dw 0xb822
        at sockaddr_in.sin_addr, dd 0
        at sockaddr_in.sin_zero, dd 0, 0
    iend

    sockaddr_in_len     equ $- serv

section .bss

    html resb 2048
    sock_descr  resb 2
    client_descr    resb 2

section .text

    global _start


    _start:

        ; read the file
        call read_file

        ; initialise the socket
        call init_socket
        ; listen for connections
        call listen

        .mainloop:
            call accept;
            call return_html
        
            mov rdi, [client_descr]
            call close_sock
            mov word [client_descr], 0
        jmp .mainloop

        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

    ; reading the file

    read_file:
        mov rax, SYS_OPEN
        mov rdi, file_path
        xor rsi, rsi
        mov rdx, 0
        
        syscall

        cmp rax, 0
        jle file_read_err

        mov rdi, rax
        xor rax, rax
        mov rsi, html
        mov rdx, 2048
        
        syscall

        cmp rax, 0
        jle file_read_err
        mov rax, SYS_CLOSE

        syscall

        ret

    ; displays error message if failed to read the file "index.html"

    file_read_err:

        mov rsi, file_read_error_message;
        mov rdx, file_read_error_message_len

        mov rax, SYS_WRITE
        mov rdi, SYS_WRITE
        syscall

        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

    ; displays error message if failed to open socket

    socket_err:
        mov rsi, socket_error_message
        mov rdx, socket_error_message_len
        
        mov rax, SYS_WRITE
        mov rdi, SYS_WRITE
        syscall

        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

    ; shows help message

    show_help:
        mov rsi, help_message
        mov rdx, help_message_len

        mov rax, SYS_WRITE
        mov rdi, SYS_WRITE
        syscall

    ; displays error message if there is an error in binding

    binding_err:

        mov rsi, binding_error_message
        mov rdx, binding_error_message_len
        
        mov rax, SYS_WRITE
        mov rdi, SYS_WRITE
        syscall

        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

    ; returns the html file

    return_html:

        mov rax, SYS_WRITE
        mov rdi, [client_descr]
        mov rsi, html
        mov rdx, 2048
        syscall
        ret

    ; to initialise the socket

    init_socket:

        mov rax, SYS_SOCKET
        mov rdi, AF_INET
        mov rsi, SOCK_STREAM
        mov rdx, 0
        syscall

        cmp rax, 0
        jle socket_err

        mov [sock_descr], rax
        ret

    ; listening

    listen:

        mov rax, SYS_BIND
        mov rdi, [sock_descr]
        mov rsi, serv
        mov rdx, sockaddr_in_len
        syscall

        cmp rax, 0
        jl socket_err

        mov rax, SYS_LISTEN
        mov rsi, 1
        syscall

        cmp rax, 0
        jl socket_err

        ret

    ; the accept the incomming connection

    accept:

        mov rax, SYS_ACCEPT
        mov rdi, [sock_descr]
        mov rsi, 0
        mov rdx, 0
        syscall

        cmp rax, 0
        jl socket_err

        mov [client_descr], rax

        ret

    ; close the socket   

    close_sock:

        mov rax, SYS_CLOSE
        syscall
        ret
        
