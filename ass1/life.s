# board.s ... Game of Life on a 10x10 grid

   .data
   .align 2
N: .word 15  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225
# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Lean Lynn Oh, August 2017

   .data
msg1: 
   .asciiz "# Iterations: "
msg2: 
   .asciiz "=== After iteration "
msg3:   
   .asciiz " ===\n" 

   .data
   .align 2

maxiters:
   .space 4

nn: 
   .space 4

main_ret_save: 
   .space 4

   .text
   .globl main

main:
   sw   $ra, main_ret_save
   
   la $a0, msg1
   li $v0, 4
   syscall

   li $v0, 5
   syscall 
   move $t0, $v0               #t0 = maxiters
   sw $v0, maxiters
   #lw $t0, maxiters
    
   li $t1, 1  		           #n = 1
   lw $t2, N  		           #t2 = N
   #la $a2, board
   
loop:
   bgt $t1, $t0, end_main     #if n > maxiters
   li  $a1, 0                 #i = 0

loop1:
   bge $a1, $t2, end2         #j >= N
   li  $a2, 0                 #j = 0

loop2:
   bge $a2, $t2, end1
   jal neighbour              #nn = neighbour(i,j)
   nop
   move $s0, $v0
   sw $s0, nn

   #board[i][j]
   mul $t3, $a1, $t2          #multiply base address with row index by array width  
   li  $t4, 1
   mul $t4, $a2, $t4            #multiply j with 1 byte becoz of char only takes 1 byte
   add $t3, $t3, $t4     
   lb  $t4, board($t3)
   li  $t5, 1                 #t5 =1

if:
   bne $t4, $t5, elseif       #t4 != 1, goto elseif
   li  $t5, 2

if_1:
   bge $s0, $t5, elseif_1     #nn >= 2
   sb  $zero, newBoard($t3)   #newboard[i][j] = 0;
   j end

elseif_1:
    bne $s0, $t5, Or          #nn != 2
    li  $t6, 1
    sb  $t6, newBoard($t3)    #newboard[i][j] = 1;
    j end

Or:
   li $t5, 3
   bne $s0, $t5, else_1       #nn != 3
   li  $t6, 1
   sb  $t6, newBoard($t3)     #newboard[i][j] = 1;
   j end

else_1:
   sb  $zero, newBoard($t3)   #newboard[i][j] = 0;
   j end

elseif:
   li $t5, 3
   bne $s0, $t5, else         #nn !=3
   li  $t6, 1
   sb  $t6, newBoard($t3)    #newboard[i][j] = 1;
   j end

else:
   sb  $zero, newBoard($t3)   #newboard[i][j] = 0;
   j end

end:
   addi $a2, $a2, 1           #j++
   j  loop2 

end1:
  addi $a1, $a1, 1            #i++
  j  loop1

end2:
   la $a0, msg2		          # === After iteration
   li $v0, 4
   syscall

   move $a0, $t1		      # n
   li $v0, 1
   syscall

   la $a0, msg3		          # ===\n
   li $v0, 4
   syscall

   jal copyBackAndShow
   nop

   addi $t1, $t1, 1           #n++
   j  loop


end_main:
   lw   $ra, main_ret_save
   jr   $ra

#neighbour() function
   
  .data
  .align 2

   .text

neighbour:
   #prologue
   addi $sp, $sp, -4
   sw $fp, ($sp)
   move $fp, $sp
   addi $sp, $sp, -4
   sw $ra, ($sp)
   addi $sp, $sp, -4
   sw $s0, ($sp)    		    #save i
   addi $sp, $sp, -4
   sw $s1, ($sp)    		    #save j
   addi $sp, $sp, -4
   sw $t0, ($sp)
   addi $sp, $sp, -4
   sw $t1, ($sp)
   addi $sp, $sp, -4
   sw $t2, ($sp)

   move $s0, $a1   		         #i
   move $s1, $a2   		         #j
 
   li $t0, 0 			         #nn = 0
   li $t1, 1  			         #t1 = 1
   li $t2, -1 			         #x = -1
   
   

for:
   bgt $t2,$t1,exit1
   li $t3, -1   		         #y = -1

for1:
   bgt $t3, $t1, exit 			 #x > 1
   lw $t4, N  			         #t4 = N
   add $s0, $a1, $t2  	         #i+x
   add $s1, $a2, $t3  	         #j+x
   addi $t4, $t4, -1   	         #t4=N-1

If:
   bge $s0, $zero, OR            #i+x >= 0
   j continue

OR:
   ble $s0, $t4, If1             #i+x <= N-1
   j continue   

If1:
   bge $s1, $zero, or1           #j+y >= 0
   j continue

or1:   
   ble $s1, $t4, If2             #j+y <= N-1
   j continue

If2:                              #if (x == 0 && y == 0) continue;
   bne $t2,$zero, If3             #x!=0
   j AND 

AND:                  
  bne $t3,$zero, If3              #y != 0
  j continue
 	
If3:                              #if (board[i+x][j+y] == 1)
  lw $t4, N
  mul $t4, $s0, $t4
  li  $t5, 1
  mul $t5, $s1, $t5
  add $t4, $t4, $t5
  lb  $t4, board($t4)   
  li  $t5, 1
  bne $t4, $t5, continue
  addi $t0, $t0, 1                  #nn++
  j continue 

continue:  
   addi $t3, $t3, 1		            #y++
   j for1

exit:
   addi $t2, $t2, 1		            #x++
   j for

exit1:
   move $v0, $t0

end_neighbour:
   # epilogue
   
   lw   $t2, ($sp)
   addi $sp, $sp, 4
   lw   $t1, ($sp)
   addi $sp, $sp, 4
   lw   $t0, ($sp)
   addi $sp, $sp, 4
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   jr   $ra
   
#copyBackAndShow() function
  .data 

msg4:      
  .asciiz "."
msg5:
  .asciiz "#"
eol:
   .asciiz "\n"

  .data
  .align 2

   .text

copyBackAndShow:
  #prologue
   addi $sp, $sp, -4
   sw $fp, ($sp)
   move $fp, $sp
   addi $sp, $sp, -4
   sw $ra, ($sp)
   addi $sp, $sp, -4
   sw $t0, ($sp)
   addi $sp, $sp, -4
   sw $t1, ($sp)
   addi $sp, $sp, -4
   sw $t2, ($sp)    
   addi $sp, $sp, -4
   sw $t3, ($sp)
   addi $sp, $sp, -4
   sw $t4, ($sp)
   addi $sp, $sp, -4
   sw $t5, ($sp) 
  

   lw $t0, N                      #t0 = N
   #la $t1, newboard
   li $t1, 0                      #i = 0

LOOP:
   bge $t1, $t0, end_copy         #i >= N
   li  $t2, 0                     #j = 0
LOOP1:
   bge $t2, $t0, END1             #j >= N
   mul $t3, $t1, $t0 
   li  $t4, 1	
   mul $t4, $t2, $t4	 	
   add $t3, $t4, $t3
   lb  $t4, newBoard($t3)
   sb  $t4, board($t3) 
   li  $t5, 0
IF:
   bne $t4, $t5, THEN             #board[i][j] != 0
   la $a0, msg4                   #putchar('.');
   li $v0, 4
   syscall
   j END
THEN:
   la $a0, msg5                   #putchar('#');
   li $v0, 4
   syscall
   j END

END:
   addi $t2, $t2, 1               #j++
   j  LOOP1  
     
END1:
   la $a0, eol                    #putchar('\n');
   li $v0, 4
   syscall
   addi $t1, $t1, 1               #i++ 
   j  LOOP 

end_copy:
   # epilogue
   
   lw $t5, ($sp)
   addi $sp, $sp, 4
   lw $t4, ($sp)
   addi $sp, $sp, 4
   lw $t3, ($sp)
   addi $sp, $sp, 4
   lw $t2, ($sp)
   addi $sp, $sp, 4
   lw $t1, ($sp)
   addi $sp, $sp, 4
   lw $t0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   jr   $ra
   

# The other functions go here
