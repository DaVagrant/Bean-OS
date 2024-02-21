section .data
    hello_message db 'Welcome to Bean OS a 64 bit operating system', 0

section .text
bits 64
global long_mode_start
extern kernel_main
extern handle_keypress
extern setup_idt_for_keyboard
extern display_char_on_screen

long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    lea rdi, [hello_message]
    call kernel_main
    hlt

section .text
bits 32
start:
    mov esp, stack_top

    call setup_idt_for_keyboard

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start

    hlt

handle_keypress:
    cmp al, 8
    je .backspace

    call display_char_on_screen

    jmp .end_handler

.backspace:
    ; Implement backspace functionality here

.end_handler:
    iret

setup_idt_for_keyboard:
    mov eax, handle_keypress
    mov word [idt_entry + 2], ax
    mov word [idt_entry + 4], dx

    lea edx, [idt]
    mov eax, [edx]
    lidt [eax]

    ret

display_char_on_screen:
    mov edi, 0xB8000
    movzx eax, al
    shl eax, 8
    movzx eax, byte [edi]
    mov word [edi], ax

    ret

section .bss
align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

section .rodata
gdt64:
    dq 0
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

idt:
    dw idt_end - idt - 1
    dd idt_start

idt_start:
    dd 0
    dw 0
idt_entry:
    dw 0
    dw 0
    db 0
    db 0x8E
    dw 0

idt_end:
    ; (Your existing code)
