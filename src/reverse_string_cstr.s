; TODO: decrease memory waste by removing empty spaces between sections

    .data
.org             0x0
str:             .byte  '________________________________'



    .data
.org             0x100
buffer_size:     .word  0x20
input_addr:      .word  0x80
output_addr:     .word  0x84
str_length:      .word  0                  ; also pointer for next char
char_mask:       .word  0xFF
underscore_fill: .word  0x5F5F5F00         ; '___0'
null_term_idx:   .word  -1
new_line_char:   .word  '\n'
left_ptr:        .word  0
right_ptr:       .word  0
temp_swap:       .word  0
temp_remainder:  .word  0
remainder_mask:  .word  0xFFFFFF00
i:               .word  0



    .text
.org             0x200
_start:
read_line_loop:
    ; load next char from input
    load         input_addr
    load_acc
    ; keep only char value and fill remainder with underscores
    and          char_mask
    or           underscore_fill
    ; store char in buffer
    store_ind    str_length
    and          char_mask

check_null_char:
    ; if not \0, jump to check for \n
    bnez         check_new_line
    ; if already found \0 before then incorrect string
    load         null_term_idx
    bgt          incorrect_input
    ; save index of \0
    load         str_length
    store        null_term_idx
    jmp          read_line_condition

check_new_line:
    sub          new_line_char
    beqz         reverse_string

read_line_condition:
    ; increment string length value
    load_imm     1
    add          str_length
    store        str_length

    ; check if next char will overflow buffer size
    load         buffer_size
    sub          str_length
    bgt          read_line_loop
    jmp          buffer_overflow



reverse_string:
    ; replace \n with \0
    load_imm     0
    or           underscore_fill
    store_ind    str_length

    ; if \0 was in string, then take chars only until its index
    load_addr    null_term_idx
    ble          init_right_ptr
    store        str_length

init_right_ptr:
    ; set value of right pointer as index of last char
    load_imm     -1
    add          str_length
    ble          exit
    store        right_ptr

reverse_str_loop:
    ; save char from the right
    load_addr    right_ptr
    load_acc
    and          char_mask
    store        temp_swap

    ; save remainder from the right
    load_addr    right_ptr
    load_acc
    and          remainder_mask
    store        temp_remainder

    ; get char from the left, concat with right remainder and save to the right
    load_addr    left_ptr
    load_acc
    and          char_mask
    or           temp_remainder
    store_ind    right_ptr

    ; get remainder from the left, concat with right char (from temp_swap) and save to the left
    load_addr    left_ptr
    load_acc
    and          remainder_mask
    or           temp_swap
    store_ind    left_ptr

    ; increment left pointer
    load_imm     1
    add          left_ptr
    store        left_ptr

    ; decrement right pointer
    load_imm     -1
    add          right_ptr
    store        right_ptr

    ; if left pointer >= right pointer, we reversed string
    sub          left_ptr
    bgt          reverse_str_loop



print_reversed_str:
    ; get i-th symbol
    load         i
    load_acc
    and          char_mask
    store_ind    output_addr

    ; increment index
    load_imm     1
    add          i
    store        i

    ; if i < string length, continue
    sub          str_length
    ble          print_reversed_str

exit:
    halt

buffer_overflow:
    load_imm     0xCCCCCCCC
    jmp          error_exit

incorrect_input:
    load_imm     -1

error_exit:
    store_ind    output_addr
    jmp          exit
