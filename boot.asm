ORG 0
BITS 16

_start:
    jmp short start
    nop

times 33 db 0 ; because some bioses temper data so we are just creating fake one

start:
    jmp 0x7c0:step2

handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret ; return from interrupt

handle_one:
    mov ah, 0eh
    mov al, 'V'
    mov bx, 0x00
    int 0x10
    iret ; return from interrupt

step2:
    cli ; Clear Interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts

    mov word[ss:0x00], handle_zero
    mov word[ss:0x02], 0x7c0

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    int 1 ; triggers interrput one

    mov ax, 0x00
    div ax ; divided (0/0), this will trigger interrput 0x0

    mov si, message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message: db 'Hello World!', 0

; we need to fill atleast 510 bytes of data
; so basically it's like padding with 0 to fill to the 510 bytes
times 510-($ - $$) db 0
; put this signature word
dw 0xAA55 