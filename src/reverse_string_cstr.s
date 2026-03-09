.data
.org 0x0
str:                .byte '________________________________'

.data
.org 0x50
null_sym:           .word '\n'
str_length:         .word 0
char_mask:          .word 0xFF
underscore_fill:    .word 0x5F5F5F00
left_ptr:           .word 0
right_ptr:          .word 0
temp_swap:          .word 0
temp_remainder:     .word 0
remainder_mask:     .word 0xFFFFFF00
i:                  .word 0

.text
.org 0x100
_start:
    read_line_loop:
        ; get next symbol of string
        load_addr 0x80
        or underscore_fill
        store_ind str_length
        and char_mask
        sub null_sym
        beqz reverse_str
        
        ; increment string length value & set next char pointer
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

    reverse_str:
        ; replace \n symbol with \0
        load_imm 0
        or underscore_fill
        store_ind str_length

        ; set index of last symbol
        load_imm -1
        add str_length
        store_addr right_ptr

        reverse_str_loop:
            ; save symbol from the right
            load_addr right_ptr
            load_acc
            and char_mask
            store_addr temp_swap

            ; save remainder from the right
            load_addr right_ptr
            load_acc
            and remainder_mask
            store_addr temp_remainder

            ; get symbol from the left, concat with right remainder and save to the right 
            load_addr left_ptr
            load_acc
            and char_mask
            or temp_remainder
            store_ind right_ptr

            ; get remainder from the left, concat with right symbol (from temp_swap) and save to the left
            load_addr left_ptr
            load_acc
            and remainder_mask
            or temp_swap
            store_ind left_ptr

            ; increment left pointer
            load_imm 1
            add left_ptr
            store_addr left_ptr
            
            ; decrement right pointer
            load_imm -1
            add right_ptr
            store_addr right_ptr

            ; if left pointer >= right pointer, we reversed string
            sub left_ptr
            bgt reverse_str_loop

        print_reversed_str:
            ; get i-th symbol
            load_addr i
            load_acc
            and char_mask
            store_addr 0x84

            ; increment index
            load_imm 1
            add i
            store_addr i

            ; if i < string length, continue
            sub str_length
            ble print_reversed_str

        halt