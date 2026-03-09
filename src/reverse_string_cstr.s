.data
.org 0x0
str:            .byte 0

.data
.org 0x50
null_sym:       .word '\n' ; sub between word and byte broken?
str_length:     .byte 0


.text
.org 0x100
_start:
    read_line_loop:
        ; get next symbol of string
        load_addr 0x80
        store_ind str_length
        sub null_sym
        beqz reverse_str_loop
        
        ; increment string length value
        load_imm 1
        add str_length
        store_addr str_length
        
        ; check if string is longer than buffer size
        load_imm 0x20
        sub str_length
        bgt read_line_loop
        load_imm -1
        store_addr 0x84
        halt

    reverse_str_loop:
        load_addr str_length
        store_addr 0x84
        halt