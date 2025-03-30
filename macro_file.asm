#/*********************************************************************

#*               SAN DIEGO STATE UNIVERISTY                           *

#*                   DUC M LE 132485155

#*              44 55 43 20 4D 49 4E 48 20 4C 45 0A

#*              31 33 32 34 38 35 31 35 35 0A                         *

#**********************************************************************

.macro print_str_reg (%reg)
    li $v0, 4
    move $a0, %reg
    syscall
.end_macro

.macro print_newline
    li $v0, 4
    la $a0, newline
    syscall
.end_macro




.macro read_int (%reg)
    li $v0, 5
    syscall
    move %reg, $v0
.end_macro

.macro delay (%time)
    li $t2, %time
delay_loop:
    addi $t2, $t2, -1
    bnez $t2, delay_loop
.end_macro

.macro draw_pixel (%x, %y, %color)
    add $a0, $0, %x
    add $a1, $0, %y
    add $a2, $0, %color
    mul $t9, $a1, 32    # y * width (32 for 256x256 with 8x8 pixels)
    add $t9, $t9, $a0
    mul $t9, $t9, 4
    add $t9, $t9, $gp
    sw $a2, ($t9)
.end_macro
