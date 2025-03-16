section .data

    SYS_read        equ 0
    SYS_write       equ 1
    SYS_open        equ 2
    SYS_close       equ 3
    SYS_exit        equ 60
    SYS_creat       equ 85

    O_WRONLY        equ 1
    O_CREAT         equ 64
    O_TRUNC         equ 512

    STDIN           equ 0
    STDOUT          equ 1

    LF              equ 10
    msgEnterOutput  db "Enter output file name: ", 0
    
    sample_buffer   db 0x0b, 0x65, 0x6c, 0x6c, 0x0e, 0x77
    buffer_size     equ $ - sample_buffer

section .bss
    outputFD        resq 1
    output_filename resb 256

section .text
    global _start

_start:
    ; ===== แสดงข้อความขอชื่อไฟล์ =====
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, msgEnterOutput
    mov rdx, 25
    syscall

    ; ===== รับชื่อไฟล์จากผู้ใช้ =====
    mov rax, SYS_read
    mov rdi, STDIN
    mov rsi, output_filename
    mov rdx, 256
    syscall

    ; ===== ลบ newline ออกจาก input =====
    mov rsi, output_filename
    call strip_newline

    ; ===== สร้างและเปิด output file =====
    mov rax, SYS_creat
    mov rdi, output_filename    ; ชื่อไฟล์ที่รับมา
    mov rsi, 0644o              ; permission: rw-r--r--
    syscall
    cmp rax, 0
    js exit_error
    mov [outputFD], rax

    ; ===== เขียน sample_buffer ลง output file =====
    mov rax, SYS_write
    mov rdi, [outputFD]
    mov rsi, sample_buffer
    mov rdx, buffer_size
    syscall
    cmp rax, 0
    jl exit_error

    ; ===== ปิด output file =====
    mov rax, SYS_close
    mov rdi, [outputFD]
    syscall

    ; ===== ออกจากโปรแกรม =====
    mov rax, SYS_exit
    xor rdi, rdi
    syscall

exit_error:
    mov rax, SYS_exit
    mov rdi, 1
    syscall

; ===== ฟังก์ชัน strip_newline =====
strip_newline:
    push rsi
.loop:
    mov al, [rsi]
    cmp al, LF
    je .found
    cmp al, 0
    je .done
    inc rsi
    jmp .loop
.found:
    mov byte [rsi], 0
.done:
    pop rsi
    ret
