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

.macro draw_snake
    # Clear previous snake area (20x20 to 27x27)
    li $t0, 20           # Starting x
    li $t1, 20           # Starting y
    li $t2, 0            # Row counter
clear_snake_loop:
    li $t3, 0            # Col counter
clear_snake_col:
    add $t4, $t0, $t3
    add $t5, $t1, $t2
    draw_pixel($t4, $t5, 0x00000000)  # Black
    addi $t3, $t3, 1
    blt $t3, 8, clear_snake_col
    addi $t2, $t2, 1
    blt $t2, 8, clear_snake_loop

    # Draw snake (simple zigzag pattern in green)
    draw_pixel(20, 20, 0x0000FF00)  # Head
    draw_pixel(21, 21, 0x0000FF00)
    draw_pixel(22, 20, 0x0000FF00)
    draw_pixel(23, 21, 0x0000FF00)
    draw_pixel(24, 20, 0x0000FF00)
    draw_pixel(25, 21, 0x0000FF00)
    draw_pixel(26, 20, 0x0000FF00)
    draw_pixel(27, 21, 0x0000FF00)  # Tail

    # Display for 2 seconds
    delay(2000000)

    # Clear snake after display
    li $t0, 20
    li $t1, 20
    li $t2, 0
clear_snake_after_loop:
    li $t3, 0
clear_snake_after_col:
    add $t4, $t0, $t3
    add $t5, $t1, $t2
    draw_pixel($t4, $t5, 0x00000000)  # Black
    addi $t3, $t3, 1
    blt $t3, 8, clear_snake_after_col
    addi $t2, $t2, 1
    blt $t2, 8, clear_snake_after_loop
.end_macro