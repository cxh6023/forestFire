#
# FILE:         $File$
# AUTHOR:       Chris heist
#
# DESCRIPTION:
#       This program is an implementation of a modified forest fire generation 
#	 display in MIPS assembly.
#
# ARGUMENTS:
#       None
#
# INPUT:
#       Three lines of one char long data. The first of which represents grid
#	 size. Second represents the amount of generations to create. Third 
#	 shows the wind direction(N, S, E, W). Lastly is the layout of the 
#	 grid.
#
# OUTPUT:
#       A list of generations of a forest grid that represent a similar version
#	 of a buyrnign forest simulation.

#-------------------------------

#
# Numeric Constants
#

PRINT_STRING = 4
READ_INT = 5
READ_STRING = 8
PRINT_INT = 1

TREE = 116
BURN = 66
GRASS = 46

#
# DATA AREAS
#
	.data
params:	.space 20

old_forest:	.space 900

new_forest:	.space 900

buffer:	.space 900

north:
	.byte 78
south:
	.byte 83
east:
	.byte 69
west:
	.byte 87

#.align 	1		# number data must be on number boundaries

null:
	.byte 0

plus_newline_end:
	.asciiz "+\n\n"

plus_newline:
	.asciiz "+\n"

plus:
	.asciiz "+"

dash:
	.asciiz "-"

newline:
	.asciiz "\n"

banner_line1_text:
	.asciiz "+-------------+\n"
	
banner_line2_text:
	.asciiz "| FOREST FIRE |\n"

before_generation_text:
	.asciiz "==== #"

after_generation_text:
	.asciiz " ====\n"

grid_border_big:
	.asciiz "+-----+\n"

grid_border_small:
	.asciiz "|"

grid_border_small_end:
	.asciiz "|\n"

size_error:
	.asciiz "ERROR: invalid grid size\n"

generation_error:
	.asciiz "ERROR: invalid number of generations\n"

wind_error:
	.asciiz "ERROR: invalid wind direction\n"

character_error:
	.asciiz	"ERROR: invalid character in grid\n"

#-------------------------------

#
# CODE AREAS
#
	.text			# this is program  code
	.align	2		# instructions must be on word boundaries

	.globl generate

#
# EXECUTION BEGINS HERE
#
main:
	addi	$sp, $sp, -12	# allocate space for the return address
	sw	$ra, 8($sp)	# store the ra on the stack
	sw	$s1, 4($sp)	# open up s1
	sw	$s0, 0($sp)	# open up s0

	la	$s0, params
print_banner:			# Prints the starting banner

	li	$v0, PRINT_STRING
	la	$a0, banner_line1_text
	syscall

	li	$v0, PRINT_STRING	
	la	$a0, banner_line2_text
	syscall

	li	$v0, PRINT_STRING
	la	$a0, banner_line1_text
	syscall

	li	$v0, PRINT_STRING
	la	$a0, newline
	syscall	

get_grid_size:
	# GET GRID SIZE
	li	$v0, READ_INT
	syscall

	li	$t0, 30
	slt	$t1, $t0, $v0
	bne	$t1, $zero, invalid_size	# if grid > 30, call error

	li	$t0, 4 
	slt	$t1, $v0, $t0
	bne	$t1, $zero, invalid_size	# if grid < 4, call error

	sw	$v0, 0($s0)			# stores word into s0

get_generations:				# counts how many generations are
						#  to be shown
	li	$v0, READ_INT
	syscall

	li	$t0, 20
	slt	$t1, $t0, $v0
	bne	$t1, $zero, invalid_generation	# if grid > 20, call error

	li	$t0, 0
	slt	$t1, $v0, $t0
	bne	$t1, $zero, invalid_generation	# if grid < 0, call error

	sw	$v0, 4($s0)	

get_wind:
	li	$v0, READ_STRING
	syscall
	
	la	$t1, buffer
	move	$t1, $v0
	lb	$t2, 0($t1)

	sb	$t2, 8($s0)		# stores before error checking to
					#  prevent a memory access error

	lb	$s2, north
	beq	$t2, $s2, get_grid

	lb	$s2, south
	beq	$t2, $s2, get_grid

	lb	$s2, east
	beq	$t2, $s2, get_grid

	lb	$s2, west
	bne	$t2, $s2, invalid_wind	# calls error if the input is none of 
					#  them

	li	$t2, 0
	sb	$t2, 0($t1)

get_grid:				# setup the grid loop variables
	li	$t0, 0	# column counter	
	li	$t4, 0	# row counter
	lw	$t1, 0($s0)
	la	$t2, old_forest
	addi	$t3, $t1, 1
		
get_grid_loop:
	beq	$t0, $t1, get_grid_loop_done 	# done if i==n

	move	$a0, $t2	
	li	$v0, READ_STRING
	syscall
	
	li	$t6, 0
	move	$t7, $v0	


check_chars:	
	lb	$t8, 0($t7)

check_tree:	# Verifies a tree character
	li	$t9, TREE
	bne	$t9, $t8, check_grass
	j	end_check

check_grass:	# Verifies a grass character
	li	$t9, GRASS
	bne	$t9, $t8, check_burn
	j	end_check

check_burn:	# Verifies a burn character
	li	$t9, BURN
	bne	$t9, $t8, invalid_character

end_check:	# Increments checking all of the input
	addi	$t6, $t6, 1
	addi	$t7, $t7, 1	

	bne	$t6, $t1, check_chars

	addi	$t0, $t0, 1
	add	$t2, $t2, $t1
	j	get_grid_loop

get_grid_loop_done:	# Finishes checking the loop
	la	$t0, old_forest
	sw	$t0, 12($s0)
	la	$t0, new_forest
	sw	$t0, 16($s0)
	move	$a0, $s0

	lw	$a1, 16($s0)
	lw	$a0, 12($s0)
	lw	$a2, 0($s0)

	jal	copyarray	# Copies the old array into the new array
				#  this makes the generate.asm file only have 
				#  to edit minor changes

loop_generations_setup:		# Sets up the starting variables for displaying 
				#  the generations
	lw	$s3, 4($s0)
	li	$s4, -1

loop_generations:		# Call show_generations, when ready, copy when 
				#  finished, and regenerate the next one
	beq	$s3, $s4, main_done
	addi	$s4, $s4, 1

	lw	$a0, 16($s0)
	lw	$a1, 12($s0)
	lw	$a2, 0($s0)

	jal	copyarray	# Copy new to old
	move	$a0, $s0
	
	beq	$s4, $zero, show_generation

	jal	generate	# Generate the old array into a new array

show_generation:	# Display the contents of the newly generated new array
	li	$s1, 0	# Counter for rows

	li	$v0, PRINT_STRING
	la	$a0, before_generation_text
	syscall

	li	$v0, PRINT_INT
	move	$a0, $s4
	syscall

	li	$v0, PRINT_STRING
	la	$a0, after_generation_text
	syscall

	j	draw_border_setup_start	# This displays the borders correctly

	li	$v0, PRINT_STRING
	la	$a0, newline
	syscall
	
start:	# Starts the row displaying process
	li	$v0, PRINT_STRING
	la	$a0, plus_newline
	syscall

	li	$v0, PRINT_STRING
	la	$a0, grid_border_small
	syscall

setup_row_loop:
	li	$t0, 0		# setup row counter
	lw	$t1, 0($s0)	
	lw	$t2, 16($s0)
	li	$t5, 0		# setup column counter
	
show_row_loop:	
	beq	$t0, $t1, show_row_done
	lb	$t3, 0($t2)
	la	$t4, buffer
	sb	$t3, buffer
	
	li	$v0, PRINT_STRING	# Print the # generation currently 
					#  being displayed
	move	$a0, $t4
	syscall

	addi	$t2, $t2, 1
	addi	$t0, $t0, 1

	j	show_row_loop

show_row_done:	# Finishes the row output with a row border
	li	$v0, PRINT_STRING
	la	$a0, grid_border_small_end
	syscall

	addi	$t5, $t5, 1

	li	$t0, 0
	
	beq	$t1, $t5, draw_border_setup_end	

	#addi	$t2, $t2, 1

	li	$v0, PRINT_STRING
	la	$a0, grid_border_small
	syscall

	j	show_row_loop

main_done:

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12	# deallocate stack space
	jr	$ra

invalid_size:	# Displays invalid grid size error
	li	$v0, PRINT_STRING
	la	$a0, size_error
	syscall
	j	main_done

invalid_generation:	# Displays invalid generations size error
	li	$v0, PRINT_STRING
	la	$a0, generation_error
	syscall
	j	main_done

invalid_wind:		# Displays invalid wind directions error
	li	$v0, PRINT_STRING
	la	$a0, wind_error
	syscall
	j	main_done

invalid_character:	# Displays invalid character erro
	li	$v0, PRINT_STRING
	la	$a0, character_error
	syscall
	j	main_done

# Having seperate methods ofr the start and end borders fix a formatting error
draw_border_setup_start:
	li	$t0, 0
	li	$v0, PRINT_STRING
	la	$a0, plus
	syscall	

	lw	$t9, 0($s0)

draw_border_start:
	beq	$t0, $t9, start
	
	li	$v0, PRINT_STRING
	la	$a0, dash
	syscall

	addi	$t0, $t0, 1
	
	j	draw_border_start 

draw_border_setup_end:
	li	$t0, 0
	li	$v0, PRINT_STRING
	la	$a0, plus
	syscall	

	lw	$t9, 0($s0)

draw_border_end:
	beq	$t0, $t9, draw_border_finish
	
	li	$v0, PRINT_STRING
	la	$a0, dash
	syscall

	addi	$t0, $t0, 1
	
	j	draw_border_end 

draw_border_finish:
	li	$v0, PRINT_STRING
	la	$a0, plus_newline_end
	syscall

	j	loop_generations

#-------------------------------

# Name: 	copyarray
# Description:  copyarray copies an array of bytes
# Arguments:	a0:	the address of the source array
#		a1: 	the address of the destination array
#		a2: 	the max number of elements in the array
# Returns	none
# Destroys:	t0, t1, t2, t3
#

copyarray:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	

	li	$t3, 0
	move	$t1, $a0
	move	$t2, $a1

ca_column_loop:
	beq	$t3, $a2, ca_done
	li	$t0, 0
	addi	$t3, $t3, 1

ca_row_loop:
	beq	$t0, $a2, ca_column_loop	# done if i==n
	
	lb	$t4, 0($t1)
	sb	$t4, 0($t2)
	
	addi	$t1, $t1, 1		# update pointer
	addi	$t2, $t2, 1 
	addi	$t0, $t0, 1		# and count
	j	ca_row_loop

ca_done:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4

	jr	$ra

