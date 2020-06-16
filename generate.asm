#
# FILE:			$File$
# AUTHOR:		Chris Heist
#
# DESCRIPTION:
#	This program takes in two arays, and their grid size, and the wind 
#	 direction to generate a new array that implements a forest fire dsplay
#
# ARGUMENTS:
#	$a0 = grid size, generations, wind, old array, and new array
#
# Numeric Constants
#


PRINT_STRING = 4
READ_INT = 5
READ_STRING = 8
PRINT_INT = 1

TREE = 116
GRASS = 46
BURN = 66

#
# Code Begins Here
#

generate:
	# reserve space on the stack
	addi	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

getparams:
	lw	$s0, 0($a0)	# store the grid size in s0
	lw	$s1, 4($a0)	# stroe the # of generations in s1
	lb	$s2, 8($a0)	# store the wind dir. in s2
	lw	$s3, 12($a0)	# store the addr of old forest
	lw	$s4, 16($a0)	# store the addr of new forest

wind:
	li	$t0, 69
	beq	$t0, $s2, start_loop_east
	li	$t0, 87
	beq	$t0, $s2, start_loop_west
	li	$t0, 83
	beq	$t0, $s2, start_loop_south
	li	$t0, 78
	beq	$t0, $s2, start_loop_north

# NORTH NORTH NORTH NORTH NORTH NORTH NORTH NORTH NORTH NORTH 

start_loop_north:
	addi	$t0, $s0, -1

	li	$t1, 0		# row index
	li	$t2, 116	# ascii value for t
	li	$t4, 66		# ascii value for B

	move	$t5, $s3	
	mul	$t6, $s0, $t0
	add	$t5, $t5, $t6	# Set the old forest ptr to the bottom left

	move	$t6, $s4
	mul	$t7, $s0, $t0
	add	$t6, $t6, $t7	# Set the new fort ptr to the bottom left

	li	$t7, 0
	li	$t9, -1


generate_loop_north:
	beq	$t0, $t9, generate_column_done_north	# if at the end, go to 
							#  generate_row_done
	beq	$t7, $t2, last_was_tree_north	# if a tree is not found
							#  go to not_tree

	lb	$t7, 0($t5)

	bne	$t7, $t2, not_tree_north

#	bne	$t7, $t4, make_grass	
	sb	$t7, 0($t6)				# place a tree from 
							#  current spot

	sub	$t5, $t5, $s0
	sub	$t6, $t6, $s0
	addi	$t0, $t0, -1

	j	generate_loop_north

last_was_tree_north:	# if the last looked at char was a tree, make sure this 
			#  one is now a tree
	
	sb	$t2, 0($t6)
	lb	$t7, 0($t5)

	sub	$t5, $t5, $s0
	sub	$t6, $t6, $s0
	addi	$t0, $t0, -1

	j	generate_loop_north

not_tree_north:		# if the current isn't a tree
	sb	$t7, 0($t6)

	sub	$t5, $t5, $s0
	sub	$t6, $t6, $s0
	addi	$t0, $t0, -1

	j	generate_loop_north

generate_column_done_north:	# increments the row, instead of the column
	add	$t0, $s0, -1	# index for column
	addi	$t1, $t1, 1	# index for row

	mul	$t7, $s0, $s0
	add	$t5, $t5, $t7
	addi	$t5, $t5, 1

	mul	$t7, $s0, $s0
	add	$t6, $t6, $t7
	addi	$t6, $t6, 1	

	beq	$t1, $s0, burn
	li	$t7, 0

	j	generate_loop_north

# SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH SOUTH

start_loop_south:
	li	$t0, 0		# column indes
	li	$t1, 0		# row index
	li	$t2, 116	# ascii value for t
	li	$t4, 66		# ascii value for B
	move	$t5, $s3	
	move	$t6, $s4
	li	$t7, 0
	li	$t8, 46
	addi	$t9, $s0, -1

generate_loop_south:
	beq	$t0, $s0, generate_column_done_south	# if at the end, go to 
							#  generate_row_done

	beq	$t7, $t2, last_was_tree_south	# if a tree is not found
							#  go to not_tree

	lb	$t7, 0($t5)

	bne	$t7, $t2, not_tree_south
	
	sb	$t7, 0($t6)				# place a tree from 
							#  current spot

	add	$t5, $t5, $s0
	add	$t6, $t6, $s0
	addi	$t0, $t0, 1

	j	generate_loop_south

last_was_tree_south:
	sb	$t2, 0($t6)
	lb	$t7, 0($t5)

	add	$t5, $t5, $s0
	add	$t6, $t6, $s0
	addi	$t0, $t0, 1

	j	generate_loop_south

not_tree_south:
	sb	$t7, 0($t6)

	add	$t5, $t5, $s0
	add	$t6, $t6, $s0
	addi	$t0, $t0, 1

	j	generate_loop_south

generate_column_done_south:
	li	$t0, 0	# index for column
	addi	$t1, $t1, 1	# index for row

	#addi	$t7, $s0, -1
	mul	$t7, $s0, $s0

	sub	$t5, $t5, $t7
	addi	$t5, $t5, 1

	sub	$t6, $t6, $t7
	addi	$t6, $t6, 1

	beq	$t1, $s0, burn
	li	$t7, 0

	j	generate_loop_south


# WEST WEST WEST WEST WEST WEST WEST WEST WEST WEST 

start_loop_west:
	addi	$t0, $s0, -1	# row indes
	li	$t1, 0		# column index
	li	$t2, 116	# ascii value for t
	li	$t4, 66		# ascii value for B
	move	$t5, $s3	
	move	$t6, $s4
	add	$t5, $t5, $t0
	add	$t6, $t6, $t0 
	li	$t7, 0
	li	$t8, 46
	li	$t9, -1

generate_loop_west:
	beq	$t0, $t9, generate_row_done_west	# if at the end, go to 
							#  generate_row_done

	beq	$t7, $t2, last_was_tree_west	# if a tree is not found
							#  go to not_tree

	lb	$t7, 0($t5)

	bne	$t7, $t2, not_tree_west
	
	sb	$t7, 0($t6)				# place a tree from 
							#  current spot

	addi	$t5, $t5, -1
	addi	$t6, $t6, -1
	addi	$t0, $t0, -1

	j	generate_loop_west

last_was_tree_west:
	sb	$t2, 0($t6)
	lb	$t7, 0($t5)

	addi	$t5, $t5, -1
	addi	$t6, $t6, -1
	addi	$t0, $t0, -1

	j	generate_loop_west

not_tree_west:
	sb	$t7, 0($t6)

	addi	$t5, $t5, -1
	addi	$t6, $t6, -1
	addi	$t0, $t0, -1

	j	generate_loop_west

generate_row_done_west:
	addi	$t0, $s0, -1		# index for row
	addi	$t1, $t1, 1	# index for column

	add	$t5, $t5, $s0
	add	$t5, $t5, $s0
	add	$t6, $t6, $s0
	add	$t6, $t6, $s0

	beq	$t1, $s0, burn
	li	$t7, 0

	j	generate_loop_west


# EAST EAST EAST EAST EAST EAST EAST EAST EAST EAST EAST 

start_loop_east:
	li	$t0, 0
	li	$t1, 0
	li	$t2, 116
	li	$t4, 66
	move	$t5, $s3
	move	$t6, $s4
	li	$t7, 0
	li	$t8, 46

generate_loop_east:
	beq	$t0, $s0, generate_row_done_east	# if at the end, go to 
							#  generate_row_done

	beq	$t7, $t2, last_was_tree_east		# if a tree is not found
							#  go to not_tree

	lb	$t7, 0($t5)

	bne	$t7, $t2, not_tree_east

	
	sb	$t7, 0($t6)				# place a tree from 
							#  current spot

	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	addi	$t0, $t0, 1

	j	generate_loop_east

last_was_tree_east:
	sb	$t2, 0($t6)
	lb	$t7, 0($t5)

	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	addi	$t0, $t0, 1

	j	generate_loop_east

not_tree_east:
	sb	$t7, 0($t6)

	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	addi	$t0, $t0, 1

	j	generate_loop_east

generate_row_done_east:
	li	$t0, 0		# index for row
	addi	$t1, $t1, 1	# index for column

	beq	$t1, $s0, burn
	li	$t7, 0

	j	generate_loop_east

burn:	# This method updates the burning mechanic 
	li	$t0, 0	# row counter
	li	$t1, 0	# column coutner
	move	$t6, $s3
	move	$t8, $s0
	li	$t5, BURN
	li	$t4, GRASS
	li	$t3, TREE
	li	$t2, 42	# Trees that wil be caught on fire are marked with a 
			#  *(42 in ascii) to the be later scanned through and 
			#  changed to a B. THis prevents overeading chars that 
			#  just recently became B's and have not already been B's.
	li	$t9, -1
	
	
burn_loop:	# Loops through the old forest and new forest tracking what needs to be burned and updatin the new array.
	beq	$t1, $s0, copy_burned

	lb	$t7, 0($t6)
	
	beq	$t7, $t5, fire

	addi	$t0, $t0, 1
	addi	$t6, $t6, 1
	beq	$t0, $s0, new_row
	
	j	burn_loop

fire:
	#sb	$t4, 0($t6)

# These just check up, down, left, and right to if any of those four spots need
#  need to be turned into a Burning tree	
right:
	addi	$t0, $t0, 1
	addi	$t6, $t6, 1
	
	lb	$t7, 0($t6)
	beq	$t0, $s0, left
	bne	$t7, $t3, left
	sb	$t2, 0($t6)

left:
	addi	$t0, $t0, -1
	addi	$t6, $t6, -1	# RESET

	addi	$t0, $t0, -1
	addi	$t6, $t6, -1

	lb	$t7, 0($t6)
	beq	$t0, $t9, down
	bne	$t7, $t3, down
	sb	$t2, 0($t6)

down:
	addi	$t0, $t0, 1
	addi	$t6, $t6, 1	# RESET

	addi	$t1, $t1, 1
	add	$t6, $t6, $s0

	lb	$t7, 0($t6)
	beq	$t1, $s0, up
	bne	$t7, $t3, up
	sb	$t2, 0($t6)

up:
	addi	$t1, $t1, -1
	sub	$t6, $t6, $s0	# RESET

	addi	$t1, $t1, -1
	sub	$t6, $t6, $s0
	
	lb	$t7, 0($t6)	
	beq	$t1, $t9, increment
	bne	$t7, $t3, increment
	sb	$t2, 0($t6)

increment:
	addi	$t1, $t1, 1
	add	$t6, $t6, $s0	# RESET

	addi	$t0, $t0, 1
	addi	$t6, $t6, 1
	beq	$t0, $s0, new_row
	j	burn_loop

new_row:
	addi	$t1, $t1, 1
	li	$t0, 0
	j	burn_loop

copy_burned: # This method goes through the array and changes any *'s to B's

	li	$t0, 0
	mul	$t1, $s0, $s0
	li	$t2, BURN
	li	$t3, GRASS
	li	$t4, 42
	move	$t5, $s3
	move	$t6, $s4

copy_loop:
	beq	$t0, $t1, generate_done
	
	lb	$t7, 0($t5)
	beq	$t7, $t4, found_burn
	lb	$t7, 0($t5)
	beq	$t7, $t2, found_burned
	addi	$t0, $t0, 1
	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	j	copy_loop 	

found_burn:
	sb	$t2, 0($t6)

	addi	$t0, $t0, 1
	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	j	copy_loop 	

found_burned:
	sb	$t3, 0($t6)

	addi	$t0, $t0, 1
	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	j	copy_loop 	

generate_done:

	# empty the reserved space on the stack
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addi	$sp, $sp, 24

	jr	$ra
