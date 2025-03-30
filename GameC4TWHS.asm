#/*********************************************************************

#*               SAN DIEGO STATE UNIVERISTY                           *

#*                   DUC M LE 132485155

#*              44 55 43 20 4D 49 4E 48 20 4C 45 0A

#*              31 33 32 34 38 35 31 35 35 0A                         *

#**********************************************************************

.data
    #**********************************************************************
    
    #*                  SETUP  BOARD PLAYER
    
    board:        .space 64        # 8x8 grid
    
    rows:         .word 8          # Number of rows
    
    cols:         .word 8          # Number of columns
    
    players:      .byte 'x', 'o'   # Player 1 = 'x', Player 2 = 'o'
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                  MESSAGE FEED BACK
    
    welcome_msg:  .asciiz "=======================================================\n      WELCOME TO CONNECT 4 TRAPWORMHOLE!               \n=======================================================\n"
    
    wormhole_msg:     .asciiz "Wormhole activated! Disc teleported.\n"
    
    trap_msg:         .asciiz "Trap activated! Opponent's disc trapped.\n"
    
    win_msg:          .asciiz " wins! Game Over.\n"
    
    invalid_msg:  .asciiz "Invalid choice. Please enter 1 or 2.\n"
    
    exit_msg:     .asciiz "Exiting the program. Goodbye!\n"
    
    invalid_col:  .asciiz "Invalid column number! Try again.\n"
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                  PROMT USER 
    
    menu_prompt:  .asciiz "Menu:\n  1) Start Game\n  2) Exit\n"
    
    player_prompt:.asciiz "Player "
    
    enter_col:    .asciiz ", enter column (0-7) to drop your disc, or 'e' to quit: "
    
    get_userinput:.asciiz "Please enter number to start game: "
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                  FILLIPING COUN RESULT
    
    heads_result: .asciiz "Heads! Player 1 goes first.\n"
    
    tails_result: .asciiz "Tails! Player 2 goes first.\n"
        
    #**********************************************************************
    
    
    #**********************************************************************
    
    #*                 ROW AND COL SPACING
    
    newline:      .asciiz "\n"
    
    space:        .asciiz "    "  # 4 spaces for wider spacing
    
    space_two:    .asciiz "     " # 5 spaces for centering header numbers
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                TRAP AND WORMHOLE POSITION
    
    wormhole1_entry:  .word 2, 3  # Row 2, Col 3
    
    wormhole1_exit:   .word 5, 3  # Row 5, Col 3
    
    wormhole2_entry:  .word 1, 5  # Row 1, Col 5
    
    wormhole2_exit:   .word 6, 2  # Row 6, Col 2
    
    wormhole3_entry:  .word 4, 1  # Row 4, Col 1
    
    wormhole3_exit:   .word 3, 6  # Row 3, Col 6
    
    trap_pos:         .word 3, 4  # Row 3, Col 4
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                MISC 
    
    debug_rand:   .asciiz "DEBUG: Random value = "
    
    buffer:       .space 10        # Input buffer
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                BIT MAP CONSTANTS  

    # Bitmap constants
    .eqv WIDTH 32    # 256 / 8 = 32 pixels wide
    .eqv HEIGHT 32   # 256 / 8 = 32 pixels high
    .eqv BLACK  0x00000000
    .eqv YELLOW 0x00FFFF00  # For coin edge and flipping states
    .eqv SILVER 0x00C0C0C0  # For coin face
    .eqv RED    0x00FF0000  # For 'H'
    .eqv GREEN  0x0000FF00  # For 'T'
    
     #**********************************************************************
     
     #**********************************************************************
    
     #*                INCLUDE FILES

    .include "macro_file.asm"      # Coin flip and utility macros
    .include "MIDImacro_file.asm"  # MIDI out macro
    #.include "Snake_macro_file.asm" #snake uncomment this to work 
    
    #**********************************************************************
    
    #**********************************************************************
    
  

.text
 #**********************************************************************
 
 #*                MAIN FUNCTION 
 
    main:
        jal ShowMenu              # jump a link into ShowMenu
        li $v0, 10
        syscall
        
 #**********************************************************************     

 #**********************************************************************
 
 #*                SHOW MENU PROCEDURE 
 
 #**********************************************************************
    ShowMenu:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
           
    show_menu_loop:
        li $v0, 4
        la $a0, welcome_msg
        syscall
        li $v0, 4
        la $a0, menu_prompt
        syscall
        li $v0, 4
        la $a0, get_userinput
        syscall
        li $v0, 5
        syscall
        move $t0, $v0
        beq $t0, 1, start_game
        beq $t0, 2, exit_program
        li $v0, 4
        la $a0, invalid_msg
        syscall
        j show_menu_loop

    start_game:
        # Initialize board
        la $t1, board
        li $t2, 64
        li $t3, ' '
        
    init_board_loop:
        sb $t3, 0($t1)
        addi $t1, $t1, 1
        addi $t2, $t2, -1
        bnez $t2, init_board_loop

        jal coinFlipAnimation
        move $s0, $v0  # $s0 holds starting player (1 for Player 1, 2 for Player 2)
        jal MainGame
        j end_show_menu

    exit_program:
        li $v0, 4
        la $a0, exit_msg
        syscall
        li $v0, 10
        syscall

    end_show_menu:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        
        
 #**********************************************************************      
  
 #**********************************************************************
 
 #*                COIN FLIP ANIMATION PROCEDURE 
 
 #**********************************************************************
    coinFlipAnimation:
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        li $v0, 30
        syscall
        move $a1, $a0
        li $v0, 40
        li $a0, 1
        syscall
        li $s0, 5
        
    flip_loop:
        li $v0, 42
        li $a0, 1
        li $a1, 2
        syscall
        move $t1, $a0
        beqz $t1, draw_tails_loop
        jal drawHeads
        j flip_continue
        
    draw_tails_loop:
        jal drawTails
        
    flip_continue:
        delay(500000)
        jal drawEdgeVertical
        delay(500000)
        jal drawTails
        delay(500000)
        jal drawEdgeHorizontal
        delay(500000)
        jal drawHeads
        delay(500000)
        addi $s0, $s0, -1
        bnez $s0, flip_loop
        li $v0, 30
        syscall
        move $a1, $a0
        li $v0, 40
        li $a0, 1
        syscall
        li $v0, 42
        li $a0, 1
        li $a1, 2
        syscall
        move $t1, $a0
        beqz $t1, final_tails
        jal drawHeads
        li $v0, 4
        la $a0, heads_result
        syscall
        li $v0, 1
        j end_coin_flip
        
    final_tails:
        jal drawTails
        li $v0, 4
        la $a0, tails_result
        syscall
        li $v0, 2
        
    end_coin_flip:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        addi $sp, $sp, 8
        jr $ra
        
        
 #**********************************************************************      
   
   
 #**********************************************************************
 
 #*                MAIN GAME PROCEDURE 
 
 #**********************************************************************
    MainGame:
        addi $sp, $sp, -16
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        la $a0, board
        lw $a1, rows
        lw $a2, cols
        la $a3, players
        move $s1, $s0        # $s1 = current player (1 or 2)
        subi $s1, $s1, 1     # Adjust to 0-based index for player array
        
    game_loop:
        jal displayBoard
        li $v0, 4
        la $a0, player_prompt
        syscall
        li $v0, 1
        addi $a0, $s1, 1     # Display player number (1 or 2)
        syscall
        li $v0, 11
        addu $t2, $a3, $s1
        lb $a0, 0($t2)       # Display player symbol ('x' or 'o')
        syscall
        li $v0, 4
        la $a0, enter_col
        syscall
        li $v0, 8
        la $a0, buffer
        li $a1, 10
        syscall
        lb $t0, buffer
        beq $t0, 'e', end_game
        subi $t0, $t0, '0'
        blt $t0, 0, invalid_input
        bge $t0, 8, invalid_input
        move $s2, $t0        # $s2 = column
        li $t0, 7            # Start from bottom row
        
    find_spot_loop:
        mul $t1, $t0, 8
        add $t1, $t1, $s2
        la $t2, board
        add $t2, $t2, $t1
        lb $t3, 0($t2)
        beq $t3, ' ', place_disc
        addi $t0, $t0, -1
        bgez $t0, find_spot_loop
        j invalid_input
        
    place_disc:
        addu $t4, $a3, $s1
        lb $t4, 0($t4)       # Load player symbol
        sb $t4, 0($t2)       # Place disc
        move $a0, $t0        # Row
        move $a1, $s2        # Column
        jal checkWormholesAndTrap
        beq $v0, 1, wormhole_handled
        beq $v0, 2, trap_handled
        move $a0, $t0
        move $a1, $s2
        jal checkWinner
        beqz $v0, continue_game
        li $v0, 4
        la $a0, player_prompt
        syscall
        li $v0, 1
        move $a0, $v1        # Winning player number
        syscall
        li $v0, 11
        lb $a0, 0($t2)       # Winning player symbol
        syscall
        li $v0, 4
        la $a0, newline
        syscall
        li $v0, 4
        la $a0, win_msg
        syscall
        # Play victory MIDI tone: pitch 72 (C5), 1000ms, trumpet (56), volume 100
        play_victory_tune
        j end_game
        
    continue_game:
        addi $s1, $s1, 1
        andi $s1, $s1, 1     # Toggle between 0 and 1
        j game_loop
        
    wormhole_handled:
        addi $s1, $s1, 1
        andi $s1, $s1, 1
        j game_loop
        
    trap_handled:
        addi $s1, $s1, 1
        andi $s1, $s1, 1
        j game_loop
        
    invalid_input:
        li $v0, 4
        la $a0, invalid_col
        syscall
        j game_loop
        
    end_game:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        addi $sp, $sp, 16
        jr $ra
        
 #**********************************************************************
   
 #**********************************************************************
 
 #*                DISPLAY BOARD PROCEDURE 
 
 #**********************************************************************
  
    displayBoard:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $t0, 0
        
    col_header_loop:
        li $v0, 4
        la $a0, space_two
        syscall
        li $v0, 1
        move $a0, $t0
        syscall
        li $v0, 4
        la $a0, space
        syscall
        addi $t0, $t0, 1
        blt $t0, 8, col_header_loop
        li $v0, 4
        la $a0, newline
        syscall
        li $t0, 0
        
    row_loop:
        li $v0, 1
        move $a0, $t0
        syscall
        li $v0, 11
        li $a0, '|'
        syscall
        li $t1, 0
        
    col_loop:
        li $v0, 4
        la $a0, space
        syscall
        mul $t2, $t0, 8
        add $t2, $t2, $t1
        la $t3, board
        add $t3, $t3, $t2
        lb $a0, 0($t3)
        li $v0, 11
        syscall
        li $v0, 4
        la $a0, space
        syscall
        li $v0, 11
        li $a0, '|'
        syscall
        addi $t1, $t1, 1
        blt $t1, 8, col_loop
        li $v0, 4
        la $a0, newline
        syscall
        addi $t0, $t0, 1
        blt $t0, 8, row_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        
 #**********************************************************************
   
 #**********************************************************************
 
 #*                CHECK WORMHOLE AND TRAP PROCEDURE 

 #**********************************************************************
 
    checkWormholesAndTrap:
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        move $s0, $a0
        move $s1, $a1
        lw $t0, wormhole1_entry
        lw $t1, wormhole1_entry+4
        beq $a0, $t0, check_w1_col
        j check_wormhole2
        
    check_w1_col:
        beq $a1, $t1, wormhole1_activate
        j check_wormhole2
        
    wormhole1_activate:
        la $a0, wormhole1_exit
        jal handleWormhole
        li $v0, 1
        j end_check_wormholes
        
    check_wormhole2:
        lw $t0, wormhole2_entry
        lw $t1, wormhole2_entry+4
        beq $a0, $t0, check_w2_col
        j check_wormhole3
        
    check_w2_col:
        beq $a1, $t1, wormhole2_activate
        j check_wormhole3
        
    wormhole2_activate:
        la $a0, wormhole2_exit
        jal handleWormhole
        li $v0, 1
        j end_check_wormholes
        
    check_wormhole3:
        lw $t0, wormhole3_entry
        lw $t1, wormhole3_entry+4
        beq $a0, $t0, check_w3_col
        j check_trap
        
    check_w3_col:
        beq $a1, $t1, wormhole3_activate
        j check_trap
        
    wormhole3_activate:
        la $a0, wormhole3_exit
        jal handleWormhole
        li $v0, 1
        j end_check_wormholes
        
    check_trap:
        lw $t0, trap_pos
        lw $t1, trap_pos+4
        beq $a0, $t0, check_trap_col
        j no_special
        
    check_trap_col:
        beq $a1, $t1, trap_activate
        j no_special
        
    trap_activate:
        jal handleTrap
        li $v0, 2
        j end_check_wormholes
        
    no_special:
        li $v0, 0
        
    end_check_wormholes:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        addi $sp, $sp, 12
        jr $ra
        
 #**********************************************************************       

 #**********************************************************************
 
 #*               HANDLE WORMHOLE AND TRAP PROCEDURE 
 
 #**********************************************************************
    handleWormhole:
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        mul $t1, $s0, 8
        add $t1, $t1, $s1
        la $t2, board
        add $t2, $t2, $t1
        lb $t7, 0($t2)
        lw $t3, 0($a0)
        lw $t4, 4($a0)
        mul $t5, $t3, 8
        add $t5, $t5, $t4
        la $t6, board
        add $t6, $t6, $t5
        lb $t8, 0($t6)
        bne $t8, ' ', skip_teleport
        sb $t7, 0($t6)
        li $v0, 4
        la $a0, wormhole_msg
        syscall
        
    skip_teleport:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        addi $sp, $sp, 8
        jr $ra

    # handleTrap procedure 
    handleTrap:
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        move $s0, $a0
        move $s1, $a1
        mul $t1, $s0, 8
        add $t1, $t1, $s1
        la $t2, board
        add $t2, $t2, $t1
        lb $t7, 0($t2)
        li $t8, 'x'
        beq $t7, 'o', set_opponent_x
        li $t8, 'o'
        j start_trap_logic
        
    set_opponent_x:
        li $t8, 'x'
        
    start_trap_logic:
        li $v0, 4
        la $a0, trap_msg
        syscall
        li $t0, 0
        
    trap_col_loop:
        li $t1, 0
        li $t9, 0
        
    check_col_for_opponent:
        mul $t2, $t1, 8
        add $t2, $t2, $t0
        la $t3, board
        add $t3, $t3, $t2
        lb $t4, 0($t3)
        beq $t4, $t8, found_opponent
        addi $t1, $t1, 1
        blt $t1, 8, check_col_for_opponent
        j trap_next_col
        
    found_opponent:
        li $t9, 1
        li $t1, 0
        
    trap_row_loop:
        mul $t2, $t1, 8
        add $t2, $t2, $t0
        la $t3, board
        add $t3, $t3, $t2
        lb $t4, 0($t3)
        bne $t4, $t8, skip_trap
        blt $t1, 7, check_above_trap
        j check_below_trap
        
    check_above_trap:
        addi $t5, $t1, 1
        mul $t6, $t5, 8
        add $t6, $t6, $t0
        la $t9, board
        add $t9, $t9, $t6
        lb $t5, 0($t9)
        bne $t5, ' ', check_below_trap
        sb $t7, 0($t9)
        
    check_below_trap:
        ble $t1, 0, skip_trap
        subi $t5, $t1, 1
        mul $t6, $t5, 8
        add $t6, $t6, $t0
        la $t9, board
        add $t9, $t9, $t6
        lb $t5, 0($t9)
        bne $t5, ' ', skip_trap
        sb $t7, 0($t9)
        
    skip_trap:
        addi $t1, $t1, 1
        blt $t1, 8, trap_row_loop
        
    trap_next_col:
        addi $t0, $t0, 1
        blt $t0, 8, trap_col_loop
        
    end_trap:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        addi $sp, $sp, 12
        jr $ra
        
 
 #**********************************************************************       

 #**********************************************************************
 
 #*               CHECK WINNER PROCEDURE 

 #**********************************************************************

   checkWinner:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $t0, 12($sp)
    move $s0, $a0        # Row of the placed disc
    move $s1, $a1        # Column of the placed disc
    la $t0, board
    mul $t2, $s0, 8
    add $t2, $t2, $s1
    add $t2, $t2, $t0
    lb $t4, 0($t2)       # Load the symbol at the placed position ('x' or 'o')
    beq $t4, ' ', no_win
    li $t3, 0            # Counter for matching pieces
    move $t1, $s1        # Column iterator for horizontal check

   horizontal_loop:
    blt $t1, 0, horizontal_left_loop_start
    bge $t1, 8, horizontal_done
    mul $t6, $s0, 8
    add $t6, $t6, $t1
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, horizontal_left_loop_start
    addi $t3, $t3, 1
    bge $t3, 4, win_detected
    addi $t1, $t1, 1
    j horizontal_loop

   horizontal_left_loop_start:
    move $t1, $s1
    subi $t1, $t1, 1

   horizontal_left_loop:
    blt $t1, 0, horizontal_done
    bge $t1, 8, horizontal_done
    mul $t6, $s0, 8
    add $t6, $t6, $t1
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, horizontal_done
    addi $t3, $t3, 1
    bge $t3, 4, win_detected
    subi $t1, $t1, 1
    j horizontal_left_loop

   horizontal_done:
    li $t3, 0
    move $t1, $s0        # Row iterator for vertical check

   vertical_up_loop:
    blt $t1, 0, vertical_down_start
    mul $t6, $t1, 8
    add $t6, $t6, $s1
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, vertical_down_start
    addi $t3, $t3, 1
    bge $t3, 4, win_detected
    addi $t1, $t1, -1
    j vertical_up_loop

   vertical_down_start:
    move $t1, $s0
    addi $t1, $t1, 1

   vertical_down_loop:
    bge $t1, 8, vertical_done
    mul $t6, $t1, 8
    add $t6, $t6, $s1
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, vertical_done
    addi $t3, $t3, 1
    bge $t3, 4, win_detected
    addi $t1, $t1, 1
    j vertical_down_loop

   vertical_done:
    li $t3, 0
    move $t1, $s0
    move $t5, $s1

# Forward diagonal (top-left to bottom-right)
   diagonal_forward_start:
    li $t3, 0           # Reset counter
    move $t1, $s0       # Row
    move $t5, $s1       # Column

   diagonal_forward_up_left:
    blt $t1, 0, diagonal_forward_count_start
    blt $t5, 0, diagonal_forward_count_start
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, diagonal_forward_count_start
    addi $t3, $t3, 1
    addi $t1, $t1, -1   # Move up
    addi $t5, $t5, -1   # Move left
    j diagonal_forward_up_left

   diagonal_forward_count_start:
    move $t1, $s0       # Reset to starting row
    move $t5, $s1       # Reset to starting column
    addi $t3, $t3, -1   # Adjust counter since starting position was counted

   diagonal_forward_down_right:
    bge $t1, 8, diagonal_backward_start
    bge $t5, 8, diagonal_backward_start
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, diagonal_backward_start
    addi $t3, $t3, 1
    bge $t3, 4, win_detected
    addi $t1, $t1, 1    # Move down
    addi $t5, $t5, 1    # Move right
    j diagonal_forward_down_right

# Backward diagonal (top-right to bottom-left)
   diagonal_backward_start:
    li $t3, 0           # Reset counter
    move $t1, $s0       # Row
    move $t5, $s1       # Column

   diagonal_backward_up_right:
    blt $t1, 0, diagonal_backward_count_start
    bge $t5, 8, diagonal_backward_count_start
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, diagonal_backward_count_start
    addi $t3, $t3, 1    # Count this position
    addi $t1, $t1, -1   # Move up
    addi $t5, $t5, 1    # Move right
    j diagonal_backward_up_right

   diagonal_backward_count_start:
    move $t1, $s0       # Reset to starting row
    move $t5, $s1       # Reset to starting column
    addi $t3, $t3, -1   # Adjust counter since starting position was counted

   diagonal_backward_down_left:
    blt $t1, 0, no_win
    blt $t5, 0, no_win
    bge $t1, 8, no_win
    bge $t5, 8, no_win
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $t0
    lb $t7, 0($t6)
    bne $t7, $t4, no_win
    addi $t3, $t3, 1    # Count this position
    bge $t3, 4, win_detected
    addi $t1, $t1, 1    # Move down
    addi $t5, $t5, -1   # Move left
    j diagonal_backward_down_left

   no_win:
    li $v0, 0
    li $v1, 0
    j end_check_winner

   win_detected:
    li $v0, 1
    beq $t4, 'x', player_1_win
    li $v1, 2
    j end_check_winner

   player_1_win:
    li $v1, 1

   end_check_winner:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $t0, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
    
 #**********************************************************************  

#Working on snake portion of the code need to fix it since it is should be include the snake macro file.

    # drawHeads procedure 
    drawHeads:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    clear_heads_loop:
        li $t3, 0
        
    clear_heads_col:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        draw_pixel($t4, $t5, BLACK)
        addi $t3, $t3, 1
        blt $t3, 8, clear_heads_col
        addi $t2, $t2, 1
        blt $t2, 8, clear_heads_loop
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    heads_row_loop:
        li $t3, 0
        
    heads_col_loop:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        subi $t6, $t4, 15
        subi $t7, $t5, 15
        mul $t6, $t6, $t6
        mul $t7, $t7, $t7
        add $t8, $t6, $t7
        li $t9, 12
        bgt $t8, $t9, heads_next_col
        beq $t8, $t9, heads_edge
        beq $t2, 4, heads_h
        draw_pixel($t4, $t5, SILVER)
        j heads_next_col
        
    heads_edge:
        draw_pixel($t4, $t5, YELLOW)
        j heads_next_col
        
    heads_h:
        beq $t3, 3, heads_h_draw
        beq $t3, 4, heads_h_draw
        draw_pixel($t4, $t5, SILVER)
        j heads_next_col
        
    heads_h_draw:
        draw_pixel($t4, $t5, RED)
        
    heads_next_col:
        addi $t3, $t3, 1
        blt $t3, 8, heads_col_loop
        addi $t2, $t2, 1
        blt $t2, 8, heads_row_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    # drawTails procedure
    drawTails:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    clear_tails_loop:
        li $t3, 0
        
    clear_tails_col:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        draw_pixel($t4, $t5, BLACK)
        addi $t3, $t3, 1
        blt $t3, 8, clear_tails_col
        addi $t2, $t2, 1
        blt $t2, 8, clear_tails_loop
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    tails_row_loop:
        li $t3, 0
        
    tails_col_loop:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        subi $t6, $t4, 15
        subi $t7, $t5, 15
        mul $t6, $t6, $t6
        mul $t7, $t7, $t7
        add $t8, $t6, $t7
        li $t9, 12
        bgt $t8, $t9, tails_next_col
        beq $t8, $t9, tails_edge
        beq $t2, 4, tails_t
        draw_pixel($t4, $t5, SILVER)
        j tails_next_col
        
    tails_edge:
        draw_pixel($t4, $t5, YELLOW)
        j tails_next_col
        
    tails_t:
        beq $t3, 3, tails_t_draw
        draw_pixel($t4, $t5, SILVER)
        j tails_next_col
        
    tails_t_draw:
        draw_pixel($t4, $t5, GREEN)
        
    tails_next_col:
        addi $t3, $t3, 1
        blt $t3, 8, tails_col_loop
        addi $t2, $t2, 1
        blt $t2, 8, tails_row_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    # drawEdgeVertical procedure 
    drawEdgeVertical:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    clear_edge_v_loop:
        li $t3, 0
        
    clear_edge_v_col:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        draw_pixel($t4, $t5, BLACK)
        addi $t3, $t3, 1
        blt $t3, 8, clear_edge_v_col
        addi $t2, $t2, 1
        blt $t2, 8, clear_edge_v_loop
        li $t0, 15
        li $t1, 12
        li $t2, 0
        
    edge_v_loop:
        add $t5, $t1, $t2
        draw_pixel($t0, $t5, YELLOW)
        addi $t2, $t2, 1
        blt $t2, 8, edge_v_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    # drawEdgeHorizontal procedure 
    drawEdgeHorizontal:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $t0, 12
        li $t1, 12
        li $t2, 0
        
    clear_edge_h_loop:
        li $t3, 0
        
    clear_edge_h_col:
        add $t4, $t0, $t3
        add $t5, $t1, $t2
        draw_pixel($t4, $t5, BLACK)
        addi $t3, $t3, 1
        blt $t3, 8, clear_edge_h_col
        addi $t2, $t2, 1
        blt $t2, 8, clear_edge_h_loop
        li $t0, 12
        li $t1, 15
        li $t2, 0
        
    edge_h_loop:
        add $t4, $t0, $t2
        draw_pixel($t4, $t1, YELLOW)
        addi $t2, $t2, 1
        blt $t2, 8, edge_h_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
