#/*********************************************************************

#*               SAN DIEGO STATE UNIVERSITY                           *

#*                   DUC M LE 132485155

#*              44 55 43 20 4D 49 4E 48 20 4C 45 0A

#*              31 33 32 34 38 35 31 35 35 0A                         *

#**********************************************************************

.data
#**********************************************************************
    
#*                  SETUP BOARD PLAYER
    
#**********************************************************************
    
    board:        .space 64        # 8x8 grid
    
    rows:         .word 8          # Number of rows
    
    cols:         .word 8          # Number of columns
    
    players:      .byte 'x', 'o'   # Player 1 = 'x', Player 2 = 'o'
    
#**********************************************************************
    
#**********************************************************************
    
#*                  MESSAGE FEED BACK
    
#**********************************************************************
    
    welcome_msg:  .asciiz "=======================================================\n      WELCOME TO CONNECT 4 TRAPWORMHOLE!               \n=======================================================\n"
    
    wormhole_msg:     .asciiz "Wormhole activated! Disc teleported.\n"
    
    trap_msg:         .asciiz "Trap activated! Opponent's disc trapped.\n"
    
    win_msg:          .asciiz " wins! Game Over.\n"
    
    invalid_msg:  .asciiz "Invalid choice. Please enter 1 or 2.\n"
    
    exit_msg:     .asciiz "Exiting the program. Goodbye!\n"
    
    invalid_col:  .asciiz "Invalid column number! Try again.\n"
    
#**********************************************************************
    
#**********************************************************************
    
#*                  PROMPT USER 
    
#**********************************************************************
    
    menu_prompt:  .asciiz "Menu:\n  1) Start Game\n  2) Exit\n"
    
    player_prompt:.asciiz "Player "
    
    enter_col:    .asciiz ", enter column (0-7) to drop your disc, or 'e' to quit: "
    
    get_userinput:.asciiz "Please enter number to start game: "
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                  FLIPPING COIN RESULT
    
    #**********************************************************************
    
    heads_result: .asciiz "Heads! Player 1 goes first.\n"
    
    tails_result: .asciiz "Tails! Player 2 goes first.\n"
        
    #**********************************************************************
    
    #**********************************************************************
    
    #*                 ROW AND COL SPACING
    
    #**********************************************************************
    
    newline:      .asciiz "\n"
    
    space:        .asciiz "    "  # 4 spaces for wider spacing
    
    space_two:    .asciiz "     " # 5 spaces for centering header numbers
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                TRAP AND WORMHOLE POSITION
    
    #**********************************************************************
    
    wormhole1_entry:  .word 2, 3  # Row 2, Col 3
    
    wormhole1_exit:   .word 5, 3  # Row 5, Col 3
    
    wormhole2_entry:  .word 1, 5  # Row 1, Col 5
    
    wormhole2_exit:   .word 6, 2  # Row 6, Col 2
    
    wormhole3_entry:  .word 4, 1  # Row 4, Col 1
    
    wormhole3_exit:   .word 3, 6  # Row 3, Col 6
    
    trap_pos:         .word 3, 4  # Row 3, Col 4
    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                MISC MESSAGE
    
    #**********************************************************************
    
    debug_msg:    .asciiz "DEBUG: Checking win at position (row,col): "
    
    comma_msg:    .asciiz ","
    
    debug_rand:   .asciiz "DEBUG: Random value = "
    
    buffer:       .space 10        # Input buffer
    
    trap_used: .word 0      # Flag to track if trap has been used (0 = not used, 1 = used)
    
    debug_msg_t0_init: .asciiz "DEBUG: $t0 after initialization: "
     
    debug_msg_t0_loop: .asciiz "DEBUG: $t0 in find_spot_loop: "
     
    debug_msg_t0_after_wormhole: .asciiz "DEBUG: $t0 after checkWormholesAndTrap: "
     
    debug_msg_a3: .asciiz "DEBUG: $a3 value: "

    
    #**********************************************************************
    
    #**********************************************************************
    
    #*                BIT MAP CONSTANTS  
    
    #**********************************************************************

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
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)   
    la $a0, board
    lw $a1, rows
    lw $a2, cols
    la $a3, players
    move $s4, $a3       
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
    addu $t2, $s4, $s1   
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
    addu $t4, $s4, $s1  
    lb $t4, 0($t4)       # Load player symbol
    sb $t4, 0($t2)       # Place disc
    move $s3, $t0        # Save row in $s3
    move $a0, $t0        # Row
    move $a1, $s2        # Column
    move $a2, $t4        # Player's piece
    jal checkWormholesAndTrap
    beq $v0, 1, wormhole_handled
    beq $v0, 2, trap_handled

    
   # jal displayBoard          #from this
   # li $v0, 4
   # la $a0, newline
   # syscall
   # li $v0, 4               
   # la $a0, debug_msg
   # syscall
   # li $v0, 1
   # move $a0, $s3    
   # syscall                # the commend part is for debug purposes 
   # li $v0, 4
   # la $a0, comma_msg
   # syscall
   # li $v0, 1
   # move $a0, $s2
   # syscall                    
   # li $v0, 4
   # la $a0, newline
   # syscall           #To This

    move $a0, $s3        
    move $a1, $s2
    jal checkWinner
    beqz $v0, continue_game
    jal displayBoard     # Display the final board state
    li $v0, 4
    la $a0, player_prompt
    syscall
    li $v0, 1
    move $a0, $v1        # Winning player number
    syscall
    li $v0, 11
    addu $t2, $s4, $s1  
    lb $a0, 0($t2)       # Winning player symbol
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, win_msg
    syscall
    play_victory_tune  #sound for the winner declare 
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
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
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
#*               CHECK WORMHOLE AND TRAP PROCEDURE 
#*  Inputs:
#*    $a0: Row of the move
#*    $a1: Column of the move
#*    $a2: Player's piece ('x' or 'o')
#*  Outputs:
#*    $v0: 0 (no special action), 1 (wormhole activated), 2 (trap activated)
#**********************************************************************

checkWormholesAndTrap:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2      
    lw $t4, wormhole1_entry
    lw $t5, wormhole1_entry+4
    beq $a0, $t4, check_w1_col
    j check_wormhole2
        
check_w1_col:
    beq $a1, $t5, wormhole1_activate
    j check_wormhole2
        
wormhole1_activate:
    la $a0, wormhole1_exit
    jal handleWormhole
    beq $v0, 1, win_detected_special  
    li $v0, 1
    j end_check_wormholes
        
check_wormhole2:
    lw $t4, wormhole2_entry
    lw $t5, wormhole2_entry+4
    beq $a0, $t4, check_w2_col
    j check_wormhole3
        
check_w2_col:
    beq $a1, $t5, wormhole2_activate
    j check_wormhole3
        
wormhole2_activate:
    la $a0, wormhole2_exit
    jal handleWormhole
    beq $v0, 1, win_detected_special  
    li $v0, 1
    j end_check_wormholes
        
check_wormhole3:
    lw $t4, wormhole3_entry
    lw $t5, wormhole3_entry+4
    beq $a0, $t4, check_w3_col
    j check_trap
        
check_w3_col:
    beq $a1, $t5, wormhole3_activate
    j check_trap
        
wormhole3_activate:
    la $a0, wormhole3_exit
    jal handleWormhole
    beq $v0, 1, win_detected_special  
    li $v0, 1
    j end_check_wormholes
        
check_trap:
    lw $t4, trap_pos
    lw $t5, trap_pos+4
    beq $a0, $t4, check_trap_col
    j no_special
        
check_trap_col:
    beq $a1, $t5, trap_activate
    j no_special
        
trap_activate:
    # Call removeTrapDisc to remove the disc at the trap position
    move $a0, $s0       # Row of the move
    move $a1, $s1       # Column of the move
    jal removeTrapDisc

    # Check if the trap was activated
    beq $v0, $zero, no_special  # If $v0 == 0, trap wasn't activated

    # Call trapOpponentDiscs to trap opponent discs
    move $a0, $s2       # Player's piece
    jal trapOpponentDiscs

    # Set return value to indicate trap activation
    li $v0, 2
    j end_check_wormholes
        
no_special:
    li $v0, 0
        
win_detected_special: 
    j end_check_wormholes
        
end_check_wormholes:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
 #**********************************************************************       

 #**********************************************************************
 
 #*               HANDLE WORMHOLE PROCEDURE 
 
 #**********************************************************************
 
   handleWormhole:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
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
    li $t9, ' '
    sb $t9, 0($t2)
    sb $t7, 0($t6)
    li $v0, 4
    la $a0, wormhole_msg
    syscall
    move $a0, $t3
    move $a1, $t4
    jal checkWinner
    beq $v0, 1, win_detected_wormhole
        
skip_teleport:
    j end_handle_wormhole

win_detected_wormhole:
    j end_handle_wormhole

end_handle_wormhole:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
    
#*********************************************************************

#**********************************************************************
#*               REMOVE TRAP DISC PROCEDURE 
#**********************************************************************

removeTrapDisc:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Move arguments to saved registers
    move $s0, $a0       # Row of the current move
    move $s1, $a1       # Column of the current move

    # Check if trap has already been used
    lw $t0, trap_used
    bne $t0, $zero, end_remove_trap  # If trap_used != 0, skip trap logic

    # Check if the current move is at the trap position (row 3, col 4)
    la $t1, trap_pos
    lw $t2, 0($t1)      # Load trap row (3)
    lw $t3, 4($t1)      # Load trap col (4)
    bne $s0, $t2, end_remove_trap  # If current row != trap row, skip
    bne $s1, $t3, end_remove_trap  # If current col != trap col, skip

    # Load the player's piece at the trap position (for reference)
    mul $t1, $s0, 8
    add $t1, $t1, $s1
    la $t2, board
    add $t2, $t2, $t1
    lb $t7, 0($t2)      # Load player's piece ('x' or 'o')

    # Remove the disc at the trap position
    li $t5, ' '
    sb $t5, 0($t2)      # Set the trap position to space

    # Mark the trap as used
    li $t0, 1
    sw $t0, trap_used   # Mark trap as used

    # Return 1 to indicate the trap was activated
    li $v0, 1
    j end_remove_trap

end_remove_trap:
    # If trap wasn't activated, return 0
    beq $v0, 1, skip_return_zero
    li $v0, 0

skip_return_zero:
    # Restore registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#**********************************************************************    

#**********************************************************************
#*               TRAP OPPONENT DISCS PROCEDURE 
#*  Scans the entire board (row by row, column by column) and traps
#*  every opponent disc found by placing the current player's disc
#*  above or below (if there's an empty space), without removing the opponent's disc.
#*  Inputs:
#*    $a0: Player's piece ('x' or 'o')
#*  Outputs:
#*    None (modifies the board directly)
#**********************************************************************

trapOpponentDiscs:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Store player's piece
    move $s0, $a0       # $s0 = player's piece ('x' or 'o')

    # Determine opponent's piece
    li $s1, 'x'         # $s1 = opponent's piece
    beq $s0, 'o', opponent_set
    li $s1, 'o'

opponent_set:
    # Print trap activation message
    li $v0, 4
    la $a0, trap_msg
    syscall

    # Initialize row counter
    li $t0, 0           # $t0 = row counter

trap_row_loop:
    li $t1, 0           # $t1 = column counter

trap_col_loop:
    # Calculate board index: (row * 8) + col
    mul $t2, $t0, 8
    add $t2, $t2, $t1
    la $t3, board
    add $t3, $t3, $t2   # $t3 = address of board[row][col]
    lb $t4, 0($t3)      # $t4 = piece at board[row][col]

    # Check if the piece is the opponent's
    bne $t4, $s1, skip_trap  # If not opponent's piece, skip

    # Found an opponent's disc, try to trap it by placing player's disc above or below
    # First, try to place player's disc above (row - 1)
    blt $t0, 1, try_below  # If row == 0, can't place above, try below

    # Check the spot above (row - 1, col)
    subi $t5, $t0, 1    # $t5 = row - 1
    mul $t6, $t5, 8
    add $t6, $t6, $t1
    la $t7, board
    add $t7, $t7, $t6   # $t7 = address of board[row-1][col]
    lb $t8, 0($t7)      # $t8 = piece at board[row-1][col]
    beq $t8, ' ', place_above  # If spot above is empty, place player's disc

try_below:
    # If can't place above, try below (row + 1)
    bge $t0, 7, skip_trap  # If row == 7, can't place below, skip

    # Check the spot below (row + 1, col)
    addi $t5, $t0, 1    # $t5 = row + 1
    mul $t6, $t5, 8
    add $t6, $t6, $t1
    la $t7, board
    add $t7, $t7, $t6   # $t7 = address of board[row+1][col]
    lb $t8, 0($t7)      # $t8 = piece at board[row+1][col]
    beq $t8, ' ', place_below  # If spot below is empty, place player's disc
    j skip_trap         # If neither above nor below is empty, skip

place_above:
    # Place player's disc above
    sb $s0, 0($t7)      # Place player's piece at board[row-1][col]
    j skip_trap

place_below:
    # Place player's disc below
    sb $s0, 0($t7)      # Place player's piece at board[row+1][col]

skip_trap:
    # Move to the next column
    addi $t1, $t1, 1
    blt $t1, 8, trap_col_loop

    # Move to the next row
    addi $t0, $t0, 1
    blt $t0, 8, trap_row_loop

end_trap_opponents:
    # Restore registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
#**********************************************************************


#**********************************************************************
#*               CHECK WINNER PROCEDURE 
#*  Checks for a win after placing a disc. Declares a win if the placed
#*  disc results in exactly 4 consecutive matching pieces in any direction
#*  (horizontal, vertical, forward diagonal, backward diagonal).
#*  Inputs:
#*    $a0: Row of the placed disc
#*    $a1: Column of the placed disc
#*  Outputs:
#*    $v0: 1 if a win is detected, 0 otherwise
#*    $v1: 1 if Player 1 ('x') wins, 2 if Player 2 ('o') wins, 0 if no win
#**********************************************************************
checkWinner:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    move $s0, $a0        # Row of the placed disc
    move $s1, $a1        # Column of the placed disc
    la $s2, board        # Base address of the board
    mul $t2, $s0, 8
    add $t2, $t2, $s1
    add $t2, $t2, $s2
    lb $s3, 0($t2)       # Load the symbol at the placed position ('x' or 'o')
    beq $s3, ' ', no_win # If the position is empty, no win possible

    # Horizontal Check
    li $t3, 1            # Total count (start with the placed disc)
    move $t1, $s1        # Column iterator for left
    move $t5, $s1        # Column iterator for right
horizontal_loop:
    # Check left
    addi $t1, $t1, -1
    blt $t1, 0, check_right
    mul $t6, $s0, 8
    add $t6, $t6, $t1
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, check_right
    addi $t3, $t3, 1
    j horizontal_loop

check_right:
    # Check right
    addi $t5, $t5, 1
    bge $t5, 8, horizontal_done
    mul $t6, $s0, 8
    add $t6, $t6, $t5
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, horizontal_done
    addi $t3, $t3, 1
    j check_right

horizontal_done:
    beq $t3, 4, win_detected  # Win if exactly 4 pieces are found

    # Vertical Check
    li $t3, 1            # Total count (start with the placed disc)
    move $t1, $s0        # Row iterator for up
    move $t5, $s0        # Row iterator for down
vertical_loop:
    # Check up
    addi $t1, $t1, -1
    blt $t1, 0, check_down
    mul $t6, $t1, 8
    add $t6, $t6, $s1
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, check_down
    addi $t3, $t3, 1
    j vertical_loop

check_down:
    # Check down
    addi $t5, $t5, 1
    bge $t5, 8, vertical_done
    mul $t6, $t5, 8
    add $t6, $t6, $s1
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, vertical_done
    addi $t3, $t3, 1
    j check_down

vertical_done:
    beq $t3, 4, win_detected  # Win if exactly 4 pieces are found

    # Forward Diagonal (Top-Left to Bottom-Right)
    li $t3, 1            # Total count (start with the placed disc)
    move $t1, $s0        # Row iterator for up-left
    move $t5, $s1        # Column iterator for up-left
    move $t8, $s0        # Row iterator for down-right
    move $t9, $s1        # Column iterator for down-right
diagonal_forward_loop:
    # Check up-left
    addi $t1, $t1, -1
    addi $t5, $t5, -1
    blt $t1, 0, check_down_right
    blt $t5, 0, check_down_right
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, check_down_right
    addi $t3, $t3, 1
    j diagonal_forward_loop

check_down_right:
    # Check down-right
    addi $t8, $t8, 1
    addi $t9, $t9, 1
    bge $t8, 8, diagonal_forward_done
    bge $t9, 8, diagonal_forward_done
    mul $t6, $t8, 8
    add $t6, $t6, $t9
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, diagonal_forward_done
    addi $t3, $t3, 1
    j check_down_right

diagonal_forward_done:
    beq $t3, 4, win_detected  # Win if exactly 4 pieces are found

    # Backward Diagonal (Top-Right to Bottom-Left)
    li $t3, 1            # Total count (start with the placed disc)
    move $t1, $s0        # Row iterator for up-right
    move $t5, $s1        # Column iterator for up-right
    move $t8, $s0        # Row iterator for down-left
    move $t9, $s1        # Column iterator for down-left
diagonal_backward_loop:
    # Check up-right
    addi $t1, $t1, -1
    addi $t5, $t5, 1
    blt $t1, 0, check_down_left
    bge $t5, 8, check_down_left
    mul $t6, $t1, 8
    add $t6, $t6, $t5
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, check_down_left
    addi $t3, $t3, 1
    j diagonal_backward_loop

check_down_left:
    # Check down-left
    addi $t8, $t8, 1
    addi $t9, $t9, -1
    bge $t8, 8, diagonal_backward_done
    blt $t9, 0, diagonal_backward_done
    mul $t6, $t8, 8
    add $t6, $t6, $t9
    add $t6, $t6, $s2
    lb $t7, 0($t6)
    bne $t7, $s3, diagonal_backward_done
    addi $t3, $t3, 1
    j check_down_left

diagonal_backward_done:
    beq $t3, 4, win_detected  
    j no_win

no_win:
    li $v0, 0
    li $v1, 0
    j end_check_winner

win_detected:
    li $v0, 1
    beq $s3, 'x', player_1_win
    li $v1, 2
    j end_check_winner

player_1_win:
    li $v1, 1

end_check_winner:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
    
#**********************************************************************

#**********************************************************************
#*               DRAW COIN FLIP PROCEDURE 
#**********************************************************************

   
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
        li $t2,  0
        
    edge_v_loop:
        add $t5, $t1, $t2
        draw_pixel($t0, $t5, YELLOW)
        addi $t2, $t2, 1
        blt $t2, 8, edge_v_loop
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

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
        
#**********************************************************************
