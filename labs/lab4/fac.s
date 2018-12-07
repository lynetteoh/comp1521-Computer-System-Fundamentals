# COMP1521 Lab 04 ... Simple MIPS assembler


### Global data

   .data
msg1:
   .asciiz "n: "
msg2:
   .asciiz "n! = "
eol:
   .asciiz "\n"
n:
   .space 4 
### main() function

   .data
   .align 2


main_ret_save:
   .word 4

   .text
   .globl main

main:
   sw   $ra, main_ret_save

   la $a0 ,msg1
   li $v0, 4
   syscall

   li, $v0, 5
   syscall 
   move $a1, $v0
   sw $a1, n

   #check user input
   #lw $a0, n
   #li $v0, 1
   #syscall   

   la $a0, msg2
   li $v0, 4
   syscall

   jal fac
   move $a0, $v0
   li $v0, 1
   syscall  

   la $a0, eol
   li $v0, 4
   syscall 
   
#  ... your code for main() goes here

   lw   $ra, main_ret_save
   jr   $ra           # return

### fac() function
   .data 
f: 
   .space 4
   
   .data
   .align 2

fac_ret_save:
   .space 4

   .text

fac:
   sw  $ra, fac_ret_save
   li $t0, 1
   li $t1, 1

loop:
   bgt  $t0, $a1, end  # if t0 == n we are done
   mul  $t1, $t1, $t0 
   addi $t0, $t0, 1    
   j  loop           # jump back to the top
end:
   
   #sw $t1, f	
   move $v0, $t1

   

#  ... your code for fac() goes here

   lw   $ra, fac_ret_save
   jr   $ra            # return ($v0)

