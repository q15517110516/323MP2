.data
newline:.asciiz "\n"		# useful for printing commands
star:	.asciiz "*"
board1: .word 128 511 511 16 511 511 4 2 511 64 511 4 1 511 511 8 511 511 1 2 511 511 511 256 511 511 128 32 16 511 511 256 4 511 128 511 511 256 511 511 511 511 511 1 511 511 128 511 32 2 511 511 256 4 2 511 511 8 511 511 511 32 64 511 511 32 511 511 128 1 511 2 511 64 8 511 511 32 511 511 16
board2: .word 128 8 256 16 32 64 4 2 1 64 32 4 1 128 2 8 16 256 1 2 16 4 8 256 32 64 128 32 16 1 64 256 4 2 128 8 4 256 2 128 16 8 64 1 32 8 128 64 32 2 1 16 256 4 2 1 128 8 4 16 256 32 64 16 4 32 256 64 128 1 8 2 256 64 8 2 1 32 128 4 16
.text
# main function
main:
	sub  	$sp, $sp, 4
	sw   	$ra, 0($sp) # save $ra on stack

	# test singleton (true case)
	li	$a0, 0x010
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1

	# test singleton (false case)
	li	$a0, 0x10b
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# test get_singleton 
	li	$a0, 0x010
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 4

	# test get_singleton 
	li	$a0, 0x008
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 3

	# test board_done (true case)
	la	$a0, board2
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1
	
	# test board_done (false case)
	la	$a0, board1
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# print a newline
	li	$v0, 4
	la	$a0, newline
	syscall	

	# test print_board
	la	$a0, board1
	jal	print_board

	# should print the following:
	# 8**5**32*
	# 7*31**4**
	# 12***9**8
	# 65**93*8*
	# *9*****1*
	# *8*62**93
	# 2**4***67
	# **6**81*2
	# *74**6**5

	lw   	$ra, 0($sp) 	# restore $ra from stack
	add  	$sp, $sp, 4
	jr	$ra

print_int_and_space:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element

	li   	$a0, 32        	# print a black space (ASCII 32)
	li   	$v0, 11        	# load the syscall option for printing chars
	syscall              	# print the char
	
	jr      $ra          	# return to the calling procedure

print_newline:
	li	$v0, 4		# at the end of a line, print a newline char.
	la	$a0, newline
	syscall	    
	jr	$ra

print_star:
	li	$v0, 4		# print a "*"
	la	$a0, star
	syscall
	jr	$ra
	
	
# ALL your code goes below this line.
#
# We will delete EVERYTHING above the line; DO NOT delete 
# the line.
#
# ---------------------------------------------------------------------
	
## bool singleton(int value) {  // This function checks whether
##   return (value != 0) && !(value & (value - 1));
## }
singleton:
	sub $sp,$sp,8
	sw $s2,($sp)
	sw $s3,4($sp)
	li $v0,0
	sub $s2,$a0,1  ##$a0=value, $s2=value-1
	bne $a0,0,Then
	j Exit
Then:
	and $s3,$a0,$s2
	bne $s3,0,Exit
	li $v0,1
	 
Exit:
	lw $s2,($sp)
	lw $s3,4($sp)
	addi $sp,$sp,8
	jr	 $ra


## int get_singleton(int value) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 if (value == (1<<i)) {
## 		return i;
## 	 }
##   }
##   return 0;
## }
get_singleton:
	sub $sp,$sp,12
	sw $s0,($sp)
	sw $s1,4($sp)
	sw $s4,8($sp)
	li $v0,0
	li $s0,0      ##$s0=i=0  
	li $s1,1      ##$s1 =1
	 
Loop:
	sll $s4,$s1,$s0
	beq $a0,$s4,Exit1
	addi $s0,$s0,1
	blt $s0,9,Loop
	j Exit2
Exit1:
	move $v0,$s0
Exit2:
	lw $s0,($sp)
	lw $s1,4($sp)
	lw $s4,8($sp)
	addi $sp,$sp,12
	jr $ra


## bool
## board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		if (!singleton(board[i][j])) {
## 		  return false;
## 		}
## 	 }
##   }
##   return true;
## }

board_done:
	
	# $t1=i, $t2=j, $s1=GRID_SQUARED
	sub $sp,$sp,44
	sw $s0,($sp)
	sw $s1,4($sp)
	sw $s2,8($sp)
	sw $s3,12($sp)
	sw $s4,16($sp)
	sw $s5,20($sp)
	sw $s6,24($sp)
	sw $ra,28($sp)
	sw $a0,32($sp)
	sw $v0,36($sp)
	move $s2,$a0
	li  $s0,0  #$s0=i
	li  $s1,0  #$s1=j
	li $s3,36
	li $s4,4
Loop1:
	li $s1,0
	

Loop2:
	mul $s5,$s3,$s0
	mul $s6,$s1,$s4
	add $a0,$s6,$s5
	add $a0,$a0,$s2
	jal singleton
	beq $v0,0,Exit3
	lw $v0,36($sp)
	li $v0,0
	sw $v0,40($sp)
	addi $s1,$s1,1
	blt $s1,9,Loop2
	addi $s0,$s0,1
	blt $s0,9,Loop1
	
Exit3:
	lw $v0,40($sp)
	li $v0,1
	lw $s0,($sp)
	lw $s1,4($sp)
	lw $s2,8($sp)
	lw $s3,12($sp)
	lw $s4,16($sp)
	lw $s5,20($sp)
	lw $s6,24($sp)
	lw $ra,28($sp)
	lw $a0,32($sp)
	lw $v0,36($sp)
	addi $sp,$sp,44
	
	jr  $ra
	
## void
## print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		int value = board[i][j];
## 		char c = '*';
## 		if (singleton(value)) {
## 		  c = get_singleton(value) + '1';
## 		}
## 		printf("%c", c);
## 	 }
## 	 printf("\n");
##   }
## }

print_board:
	sub $sp,$sp,36
	sw $s0,($sp)
	sw $s1,4($sp)
	sw $s2,8($sp)
	sw $s3,12($sp)
	sw $s4,16($sp)
	sw $s5,20($sp)
	sw $s6,24($sp)
	sw $ra,28($sp)
	sw $a0,32($sp)
	move $s2,$a0
	li  $s0,0  #$s0=i
	li  $s1,0  #$s1=j
	li $s3,36
	li $s4,4
Loop3:
	li $s1,0
	

Loop4:
	mul $s5,$s3,$s0
	mul $s6,$s1,$s4
	add $a0,$s6,$s5
	add $a0,$a0,$s2
	
	jal 
	
	jal singleton
	
	

	
	Exit4:
	lw $s0,($sp)
	lw $s1,4($sp)
	lw $s2,8($sp)
	lw $s3,12($sp)
	lw $s4,16($sp)
	lw $s5,20($sp)
	lw $s6,24($sp)
	lw $ra,28($sp)
	lw $a0,32($sp)
	addi $sp,$sp,36
	jr	$ra

