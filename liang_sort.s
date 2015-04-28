##############################################################################
# File: sort.s
# Skeleton for ECE 154A, Project 1
##############################################################################

	.data
student:
	.asciiz "Justin Liang:\n" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciiz "\n"
	.globl nl
sort_print:
	.asciiz "[Info] Sorted values\n"
	.globl sort_print
initial_print:
	.asciiz "[Info] Initial values\n"
	.globl initial_print
read_msg: 
	.asciiz "[Info] Reading input data\n"
	.globl read_msg
code_start_msg:
	.asciiz "[Info] Entering your section of code\n"
	.globl code_start_msg

arg1:	.word 6				# Provide the number of inputs
arg2:	.word 268632064			# Provide the base address of array where data will be stored (Assuming 0x10030000 as base address)
#arg3:	.word 1				# logradix
#arg4:	.word 32			# wordwidth

## Specify your input data-set in any order you like. I'll change the data set to verify
data1:	.word 3
data2:	.word 2
data3:	.word 8
data4:	.word 5
data5:	.word 6
data6:	.word 2

	.text

	.globl main
main:					# main has to be a global label
	addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address
			
	li	$v0, 4			# print_str (system call 4)
	la	$a0, student		# takes the address of string as an argument 
	syscall	

	jal process_arguments
	jal read_data			# Read the input data

	j	ready

process_arguments:
	la	$t0, arg1
	lw	$a0, 0($t0)		# Load N to $a0
	la	$t0, arg2
	lw	$a1, 0($t0)		# Load base address of array to $a1
#	la	$t0, arg3
#	lw	$a2, 0($t0)		# Load logradix to $a2
#	la	$t0, arg4
#	lw	$a3, 0($t0)		# Load width of word to $a3
	jr	$ra

### This instructions will make sure you read the data correctly
read_data:
	move $t1, $a0
	li $v0, 4
	la $a0, read_msg
	syscall
	move $a0, $t1

	la $t0, data1
	lw $t4, 0($t0)
	sw $t4, 0($a1)
	la $t0, data2
	lw $t4, 0($t0)
	sw $t4, 4($a1)
	la $t0, data3
	lw $t4, 0($t0)
	sw $t4, 8($a1)
	la $t0, data4
	lw $t4, 0($t0)
	sw $t4, 12($a1)
	la $t0, data5
	lw $t4, 0($t0)
	sw $t4, 16($a1)
	la $t0, data6
	lw $t4, 0($t0)
	sw $t4, 20($a1)

	jr	$ra


radix_sort:
######################### 
## your code goes here ##
#########################

# $a0 = size of the array N
# $a1 = base address of array
# $a2 = logradix
# $a3 = wordwidth
# $s0 = i
# $s1 = j
# $s2 = k
# $s3 = radixmask
# $s4 = baseaddr(arraytemp)
# $s5 = baseaddr(count)
# $s6 = baseaddr(abspos)


initialize:
	addi $s0, $0, 0		# i = 0
	addi $s1, $0, 0		# j = 0
	addi $s2, $0, 0		# k = 0
	addi $t0, $0, 1		# $t0 = 1
	sllv $s7, $t0, $a2	# radixmask = 2^logradix
	addi $s3, $s7, -1	# radixmask = radixmask - 1	
	
	sll $t0, $a0, 2		# $t0 = N * 4
	addi $t0, $t0, 4	# $t0 = $t0 + 4
	add $s4, $a1, $t0	# baseaddr(arraytemp) = baseaddr(array) + N * 4 + 4
	add $s5, $s4, $t0	# baseaddr(count) = baseaddr(arraytemp) + N * 4 + 4
	addi $t1, $s3, 1	# $t1 = radixmask + 1 (same as 2^logradix)
	sll $t1, $t1, 2		# $t1 = 2^logradix * 4
	addi $t1, $t1, 4	# $t1 = 2^logradix * 4 + 4
	add $s6, $s5, $t1	# baseaddr(abspos) = baseaddr(count) + 2^logradix * 4 + 4

bigloop:
	addi $s0, $0, 0		# i = 0
	addi $s2, $0, 0		# k = 0
	
				# beginning of loop1a
	addi $t5, $s5, 0	# $t5 = baseaddr(count)
	
loop1a:
	sw $0, 0($t5)		# count[k] = 0
	addi $t5, $t5, 4	# addr(count) = addr(count) + 4
	addi $s2, $s2, 1	# k = k + 1
	slt $t1, $s2, $s7	# if(k < 2^logradix), $t1 = 1, else $t1 = 0
	bne $t1, $0, loop1a	# if($t1 != 0), go to loop1a	
				
				# beginning of loop1b
	addi $t3, $a1, 0	# $t3 = addr(array)
	
loop1b:
	lw $t0, 0($t3)		# $t0 = array[addr]
	srlv $t0, $t0, $s1	# $t0 = $t0 >> j
	and $t0, $t0, $s3	# $t0 = ($t0 >> j) & radixmask
	sll $t0, $t0, 2		# $t0 = (($t0 >> j) & radixmask) * 4
	add $t0, $t0, $s5	# $t0 = ((($t0 >> j) & radixmask) * 4) + baseaddr(count)
	lw $t1, 0($t0)		# $t1 = count[$t0]
	addi $t1, $t1, 1	# $t1 = $t1 + 1
	sw $t1, 0($t0)		# array[$t0] = $t1 + 1
	addi $t3, $t3, 4	# addr(array) = addr(array) + 4
	addi $s0, $s0, 1	# i = i + 1
	slt $t1, $s0, $a0	# if(i < N), $t1 = 1, else $t1 = 0
	bne $t1, $0, loop1b	# if($t1 != 0), go to loop1b
				
				# beginning of loop2
	addi $t5, $s5, 0	# $t5 = baseaddr(count)
	addi $t6, $s6, 0	# $t6 = baseaddr(abspos)
	sw $0, 0($s6)		# abspos[$s6] = 0
	addi $s2, $0, 0		# k = 0

loop2:
	lw $t0, 0($t5)		# $t0 = count[addr]
	lw $t1, 0($t6)		# $t1 = abspos[addr]
	add $t3, $t0, $t1	# $t3 = count[addr] + abspos[addr]
	sw $t3, 4($t6)		# abspos[addr+4] = count[addr] + abspos[addr]
	addi $s2, $s2, 1	# k = k + 1
	addi $t5, $t5, 4	# addr(count) = addr(count) + 4
	addi $t6, $t6, 4	# addr(abspos) = addr(abspos) + 4
	slt $t4, $s2, $s3	# if(k < radixmask), $t4 = 1, else $t4 = 0
	bne $t4, $0, loop2	# if($t4 != 0), go to loop2
	
				# beginning of loop3
	addi $s0, $0, 0		# i = 0
	addi $t5, $a1, 0	# $t5 = baseaddr(array)
	

loop3:
	lw $t8, 0($t5)		# $t8 = array[addr]
	srlv $t0, $t8, $s1	# $t0 = $t8 >> j
	and $t0, $t0, $s3	# $t0 = $t0 & radixmask = curradix (1)
	sll $t0, $t0, 2		# $t0 = curradix * 4
	add $t1, $t0, $s6	# $t1 = curradix + addr(abspos)
	lw $t2, 0($t1)		# $t2 = abspos[curradix + addr] 
	addi $t9, $t2, 0	# $t9 = abspos[curradix]
	sll $t2, $t2, 2		# $t2 = abspos[curradix] * 4
	add $t3, $t2, $s4	# $t3 = $t2 + addr(arraytemp) = addr(arraytemp[abspos[curradix]])
	sw $t8, 0($t3)		# arraytemp[abspos[curradix]] = array[i] (2)
	addi $t9, $t9, 1	# $t9 = abspos[curradix]++
	sw $t9, 0($t1)		# store abspos[curradix]++
	addi $t5, $t5, 4	# addr(array) = addr(array) + 4
	addi $s0, $s0, 1	# i = i + 1
	slt $t7, $s0, $a0	# if(i < N), $t7 = 1, else $t7 = 0
	bne $t7, $0, loop3	# if($t7 != 0), go to loop3
	
				# beginning of loop4
	addi $s0, $0, 0		# i = 0
	addi $t4, $s4, 0 	# $t4 = baseaddr(arraytemp)
	addi $t5, $a1, 0	# $t5 = baseaddr(array)

loop4:
	lw $t0, 0($t4)		# $t0 = arraytemp[addr]
	sw $t0, 0($t5)		# array[addr] = $t0
	addi $s0, $s0, 1	# i = i + 1
	addi $t4, $t4, 4	# addr(arraytemp) = addr(arraytemp) + 4
	addi $t5, $t5, 4	# addr(array) = addr(array) + 4
	slt $t1, $s0, $a0	# if(i < N), $t1 = 1, else $t1 = 0
	bne $t1, $0, loop4	# if($t1 != 0), go to loop4

	
	
	add $s1, $s1, $a2	# j = j + logradix
	slt $t1, $s1, $a3	# if(j < wordwidth), $t1 = 1, else $t1 = 0
	bne $t1, $0, bigloop	# if($t1 != 0), go to bigloop

end:

#########################
 	jr $ra
#########################


##################################
#Dont modify code below this line
##################################
ready:
	jal	initial_values		# print operands to the console
	
	move 	$t2, $a0
	li 	$v0, 4
	la 	$a0, code_start_msg
	syscall
	move 	$a0, $t2

	jal	radix_sort		# call radix sort algorithm

	jal	sorted_list_print


				# Usual stuff at the end of the main
	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4
	jr	$ra			# return to the main program

print_results:
	add $t0, $0, $a0 # No of elements in the list
	add $t1, $0, $a1 # Base address of the array
	move $t2, $a0    # Save a0, which contains element count

loop:	
	beq $t0, $0, end_print
	addi, $t0, $t0, -1
	lw $t3, 0($t1)
	
	li $v0, 1
	move $a0, $t3
	syscall

	li $v0, 4
	la $a0, nl
	syscall

	addi $t1, $t1, 4
	j loop
end_print:
	move $a0, $t2 
	jr $ra	

initial_values: 
	move $t2, $a0
        addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address

	li $v0,4
	la $a0,initial_print
	syscall
	
	move $a0, $t2
	jal print_results
 	
	move $a0, $t2
	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4

	jr $ra

sorted_list_print:
	move $t2, $a0
	addi	$sp, $sp, -4		# Move the stack pointer
	sw 	$ra, 0($sp)		# save the return address

	li $v0,4
	la $a0,sort_print
	syscall
	
	move $a0, $t2
	jal print_results
	
	lw	$ra, 0($sp)		# restore the return address
	addi	$sp, $sp, 4	
	jr $ra