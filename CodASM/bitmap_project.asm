
	# Name : Surapa Phrompha
	# Program name : under the sea game
	# Purpose : create the game that apply the concept of bitmap display and Keyboard
	
	
	# #############################################################################################################
	
	.eqv 	BASE_ADDRESS 0x10008000
	.eqv 	fish_pos 	$s0 	
	.eqv 	fish_col 	$s1
	.eqv 	timer 		$s3
	.eqv 	timer_bar 	$s4
	.eqv 	score 		$s5
	.eqv 	damaged 	$s6
	.eqv 	SLEEP 		80
	.eqv   time_length 	45 
	
	# #############################################################################################################

					.data

	#----------------------#
	# Element in the game
	#----------------------#
	
	# 1) Fish
	
	fish_colors:	.word 	0x483D8B, 0xFFD700, 0xFFD700,			# color of the fish
				0x483D8B,0xFFD700,0x000000,0xFF4500,
				0x483D8B,0xFFD700,0xFFD700
	fish_coord: 	.word 	0,8,12,						# co-ordination of the fish
				132,136,140,144,		
				256,264,268
				
	# 2) Jelly fish
	jellyfish_colors: .word 0xFF69B4,0xFF69B4,0xDAA520,			# color of the jelly fish
				0xFF69B4,0xFF69B4,
					0xFF69B4,0xFF69B4
	jellyfish_coord: .word 	0,4,8,						# co-ordination of the jelly fish fish
		  		132,136,
             			256,264
	jellyfish_pos: 	.word 	0, 100, 300, 1500				# there are 4 jellyfish swiming in each frame (iteration)
										# at the following position 

	# 3) Seaweed
	
	seaweed_colors: .word 	0x2E8B57,0x2E8B57,0x2E8B57		       # color of the seaweed
	seaweed_coord: 	.word 	0,128,132				       # co-ordination of the seaweed
	seaweed_pos: 	.word 	1000					       # at each iteeratin, there is 1 seaweed


	# 4) socre bar posirion 
	scoreBar_final: .word 	3960						# score tab at max position 
	
	# 5) Star
	stars_coord: 	.word 	4,128,132,136,260				# star coordinade
	stars_pos: 		1684,1700,1716,1732,1748			# star position 

	# #############################################################################################################
							
					.text

	.globl main
	main:
	
	# #############################################################################################################
	
	# --------------------------------#
	#   This is initailisation part
	#---------------------------------#
	
	# Keep track socre
	li 	score,		20		# initialise the score * please read the report for how to keep track socore
	li 	damaged,	0		# initialise damaged to be 0 to count the damage score to reduce the score
	
	# Fish
	li 	fish_pos, 	1800		# initialise the position of the fish at coord (1,14)
	la 	fish_col, 	fish_colors 	# store fish colour in the coordinate address
	
	# Time Bar
	li 	timer,		0		# initialise the timer
	li 	timer_bar,	3892		# initialise to dispaly the full time
			
	# Score Bar
	li 	$t0, 		3960		# initialise socre bar tab
	sw 	$t0,		scoreBar_final
	
	# #############################################################################################################

	
	# ------------------------------------#
	#  This is setting up of score board
	#-------------------------------------#
	
	jal setUpScoreBar

	
	# ############################################################################################################

	# -----------------#
	#    Game Begin
	# -----------------#
	
	game_begin:
	
	# ------------------------------------------------------------------------------#
	
	# -------------------------------- #
	# Change the screen backgroud
	# -------------------------------- #
	
	# purpose : this is the used of the loop to change the screen of the black bitmap background
	#	    to blue back ground from the top of the moritor to the above of the score bar
	#         : change from pixel position (0,0) to (32,29)
	
	li 	$t0,	0x40E0D0 			# sea blue color
	li 	$t1, 	0 				# this is coordinator (0,0)
	li 	$t2, 	3712 				# this is coordinator (32,29)
	seaBlueScreen:
	sw 	$t0, 	BASE_ADDRESS($t1)		# score the color in that location address
	addi 	$t1,	$t1,	4			# increment to the next pixel
	bne 	$t1,	$t2,	seaBlueScreen		# fill until reach the position (32,29)
	
	
	# #############################################################################################################
	
	# -------------------------------------------#
	#   Call the function for moving object
	# -------------------------------------------#

	# 1) call function check_input
	# purpose : to move the fish
	
	jal input_direction
	
	# 2) call the function to make objects in the game move leftward
	
	# 2.1 call function swimLeft_jelly
	# purpose : jelly can swing leftward at speed 1 pixel, from pixel 0-26
	
	jal move_jellyfish
	
	# 2.2 call function swimLeft_seaweed
	# purpose : seaweed can move leftward at speed 1 pixel, from pixel 0-26
	
	jal move_seaweed
	
	# #####################################################################

	# -------------------------------------------#
	#   Call the function for displaying object
	# -------------------------------------------#

	# purpose : call the function to display fish,jellyfish,seaweed and score bar
	#	    according to the current criteria
	
	
	jal displaying_fish
	
	jal displaying_jellyfish 
	
	jal displaying_seaweed
	
	jal displaying_scoreBar
	
	
	
	# #############################################################################################################
	
	#---------------#
	# sleep service
	#---------------#
	li 	$v0, 	32 		# loading sleep service
	li 	$a0, 	SLEEP 		# the length of time to sleep in milliseconds.
	syscall
	
	# #############################################################################################################
	
	# ------------#
	#   Timer Bar
	# ------------ #
	
	# Purpose : to decrement the timer count
	
	addi 	timer,	timer,	1 			# increment timer
	blt 	timer,	time_length,	game_begin 	# check if 60 frames have passed
	li 	timer, 	0 				# reset timer
	sw 	$zero, 	BASE_ADDRESS(timer_bar)		# reduce timer on timer_bar,do not display the blue colour
							# at that position
	addi 	timer_bar,	timer_bar,	-4 	# decrement timer_bar address

	beq 	timer_bar,	3840, 	game_over	# if all of timer bar is decremented, goto game over:
	
	
	
	
	j game_begin					# jump to the game until there is score, or time left
	
	# out of  the game_begin
	
	# #############################################################################################################

	#---------------------#
	#    Finish Game
	#---------------------#
	
	
	game_over:
	
	#----------------------#
	# Clear the screen
	#----------------------#
	
	# purpose : to print the seangreen background
	li 	$t0,	0x20B2AA 	# sea green
	li 	$t1, 	0 		# coordinate (0,0)
	li 	$t2, 	3712 		# coordiante (32,29)
	
	green_screen:
	sw 	$t0, 	BASE_ADDRESS($t1)	# store the color in that location 
	addi 	$t1,	$t1,	4		# increment to the next pixel
	li 	$v0, 	32 			# loading sleep service
	li 	$a0, 	5 			# wait to create an effect
	syscall
	bne 	$t1,	$t2,	green_screen	# keep changing the screen until reaching coord (32,29)

	
	# #############################################################################################################
	
	# ------------------ #
	# Print the score
	# ------------------ #
	
	# after game over
	
	# Purpose : to print the socore earn in the game
	# Note	: please read the report to see how to cont the socore
	
	li 	$t8,	16 			# loop counter to print star (there are 5 max star can earn)
	
	move 	$t0, 	score			# move the player's earn score to $t0
	addi 	$t0,	$t0,	-4		# decrement the socroe by 4 
	
	next_star:
	lw 	$t1, 	stars_pos($t8) 		# get star position
	addi 	$t1,	$t1,	BASE_ADDRESS 	# get absolute position of the star into $t1
	blt 	$t8,	$t0, 	gold 		# if star number if less than number of gold, then load gold
	li 	$t2,	0x607d8b 		# load grey color (for the unearn score)
	j print_star
	gold:
	li 	$t2,	0xffeb3b 		# load gold color (for the earn socre)
	
	
	
	# print each pixel of the star
	print_star:
	sw 	$t2, 	4($t1)
	sw 	$t2, 	128($t1)
	sw 	$t2, 	132($t1)
	sw 	$t2, 	136($t1)
	sw 	$t2, 	260($t1)		# this is the complete fill of the fill 1 star earn
	addi 	$t8,	$t8,	-4
	bgez 	$t8,	next_star		# if there is socrore left, print the next star
	
	
	# #############################################################################################################
	
	resetting:
	li 	$v0, 	32
	li 	$a0, 	80 			# Wait one second (1000 milliseconds)
	syscall
	
	li 	$t9, 	0xffff0000 		# load address to check MMIO event
	lw 	$t8, 	0($t9) 			# load value of MMIO event
	bne 	$t8, 	1, 	resetting 	# jump if not keystoke
	lw 	$t0, 	4($t9) 			# get ASCII value of key stroke into $t0
	beq 	$t0, 	112, 	pressed_p
	j resetting
	
	
	
	# #############################################################################################################
	
	# ------------------ #
	# End of the program
	# ------------------ #
	
	li 	$v0, 	10 			
	syscall
		
	# ###################################################################################################################
	
	
	# --------------------------------------- #
	# This is helper function in main method
	#---------------------------------------- #
	
	
	# ------------------------ #
	# Setting up score bar:
	# ------------------------ #
	# Purpose : to create the socore bar to cont time and score
	
	setUpScoreBar :
	
	#------------#
	# Socore Bar
	#------------#
	
	# Purpose : Store brown color as the base of score bar
	
	li 	$t0 	0xCD853F 	# brown colour
	li 	$t1, 	3712 		# start from (0,29) 
	li 	$t2, 	4092 		# this is coordinate (31,31) last position in the game frame
	
	brownScore_screen:
	sw 	$t0, 	BASE_ADDRESS($t1)		# store yellow color in the pixel at coord (0,29) 
	addi 	$t1,	$t1,	4			# increment to the next pixel
	ble	$t1,	$t2,	brownScore_screen	# store until reach position (31,31)
 
 	
 	#--------------#
	# Score Count
	#--------------#
 
	# Score bar
	li 	$t0 	0x00ff00 			# light green color
	li 	$t1, 	3908 				# start from coord (17,30)
	li 	$t2, 	3960 				# coorat (30,30)
	
	score_bar:			
	sw 	$t0, 	BASE_ADDRESS	($t1)
	addi 	$t1,	$t1,	4
	ble 	$t1,	$t2,	score_bar	

	#--------------#
	# Timer Count
	#--------------#
	
	# making timer bar
	li 	$t0 	0xFFFF00			# yellow
	li 	$t1, 	3844 				# start from (1,30)
	li 	$t2, 	3892 				# till end  (13,30)
	
	clock_bar: 			
	sw 	$t0, 	BASE_ADDRESS($t1)
	addi 	$t1,	$t1,	4
	ble 	$t1,	$t2,	clock_bar		# fill the color are 13 pixel
	

	#--------------#
	#    Red dot
	#--------------#
	
	li 	$t0 	0xd50000 			# red color
	li 	$t1, 	3900				# this is in cordinate (16,30)
	sw 	$t0, 	BASE_ADDRESS($t1)		# store red corlor in that address
	jr 	$ra
	
	# #############################################################################################################
	
	# ----------------------------------- #
	# 	Display the score bar
	# ----------------------------------- #
	
	# purpose : to display score bar according to the socore earn
	# 	    decrement every time by one byte there is a damage
	#	    after that contine to the game
	#	    if there is no score,game over
	
			
	displaying_scoreBar:
	
	bne 	damaged,1,	noDamage 		# check if damage from collision with fellyfish or seaweed
							# if no damage, goto no damage
	addi 	score,	score,	-1 			# if there is damage, decrement the score
	lw 	$t0, 	scoreBar_final($zero) 			# loads current address of score bar
	sw 	$zero, BASE_ADDRESS($t0) 		# blacks out the score tab, by not displaying the color
	addi 	$t0,	$t0,	-4 			# decrements the score bar current address
	sw 	$t0, 	scoreBar_final				# updates the the current score bar address
	beq 	$t0, 	3904, 	game_over 		# checks if there is no score left, game over
	li 	damaged,	0			# make the damage to zero
	j	score_sleep
	
	noDamage:
	
	# Sleep service
	score_sleep:
	li 	$v0, 	32 				# loading sleep service
	li 	$a0, 	80 				# wait
	syscall
	
	socoreBar_end:

	jr $ra						# end of score bar
	
	# #############################################################################################################
	
	input_direction : 	
	
	# Purpose : to check the input buffer, and move the fish according to the input buffer
	# Note that : the fish cannot move out of the frame
	# The bound is 0-26 for left and right bound
	# The bound is 0-29 for up and down bound
		
		
	li 	$t9, 	0xffff0000 		# load address to check MMIO event
	lw 	$t8, 	0($t9)			# load value of MMIO event
	bne 	$t8, 	1, 	input_end
	lw 	$t0, 	4($t9) 			# get ASCII value of key stroke into $t0
	
	beq 	$t0, 	97, 	move_left	# a
	beq 	$t0, 	100, 	move_right	# d
	beq 	$t0, 	119, 	move_up		# w
	beq 	$t0, 	115, 	move_down	# s
	beq 	$t0, 	112, 	pressed_p	# p = go to main 
	
	j input_end
	
	#-------------
	# Move left
	#-------------
	
	move_left: 				
	sll 	$t1, 	fish_pos, 25 			# check if the picter is out of bounds
	beq 	$t1,	$zero, 	input_end 		# x = 0, then ship is at left bound of map, cannot go beyond that
	
	addi 	fish_pos,	fish_pos,	-4	# if not,moves fish to the left to 1 pixel
	j 	input_end					# jump to input end
	
	#-------------
	# Move right
	#-------------
	
	move_right: 
	addi 	$t1, 	fish_pos,	-104		# 104/4 = 26 pixel = this is the right bound
	sll 	$t1, 	$t1, 	25 			# check if the picter is out of bounds
	beq 	$t1, 	$zero,	input_end 		# if x-104 = 0, ship is at right bound on the frame
	
	addi 	fish_pos,	fish_pos,	4 	# if not, moves position to right one pixel
	j 	input_end
	
	#-------------
	# Move up
	#-------------
	
	move_up:				
	srl 	$t1, 	fish_pos, 	7 		# check if out of bounds:
	beq 	$t1, 	$zero,	input_end 		# if y coord ==0, ship is at upper bound, cannot go up
	
	li 	$t1,	1 				# to move 1 pixel up
	sll 	$t1,	$t1,	7 			# since y coord starts after 7th bit
	
	sub 	fish_pos, 	fish_pos, 	$t1 	# move fish downward 1 position
	j input_end
	
	#-------------
	# Move down
	#-------------
	
	move_down: 
	srl 	$t1, 	fish_pos, 7 			# check if out of bounds
	addi 	$t1,	$t1, 	-26
	beq 	$t1, 	$zero,	input_end 		# if y-29==0, ship is out of bounds and goto input_end
	
	li 	$t1,	1 				# load 1 to move 1 pixel down
	sll 	$t1,	$t1,	7 			# since y coord starts after 7th bit
	add 	fish_pos, fish_pos, $t1 		# move fish 1 pixel downard
	j input_end
	
	pressed_p:					# jump back to the main method
	j main
	
	input_end:					# jump back to the caller
	jr $ra
	
	# #############################################################################################################
	
	
	displaying_fish:
	
	# Purpose : to color the ship according to coordiination and color given
	
	addi $t1, fish_pos,BASE_ADDRESS		# get absolute  position of fish
	
	
	# color of the fish
	li $t7, 0x483D8B # purple
	li $t8,	0xFFD700 # gold
	li $t4, 0x000000 # black
	li $t9, 0xFF4500 # orange red
	
	# store color in the fish
	# according to coord of the fish
	
	sw $t7, 0($t1) 
	sw $t8, 8($t1) 
	sw $t8, 12($t1) 
	
	sw $t7, 132($t1) 
	sw $t8, 136($t1) 
	sw $t4, 140($t1)
	sw $t9, 144($t1) 
	
	sw $t7, 256($t1) 
	sw $t8, 264($t1) 
	sw $t8, 268($t1) 
	
	jr $ra
	# ----------------- #
	
	
	# #############################################################################################################
	
	#----------------#
	# Move jelly fish
	#----------------#
	
	# purpose : to move jelly fish left at speed 1 pixel, from pixel 0-26 (left - right bound)
	
	move_jellyfish : 
	
	li 	$t2,	12 			# loop counter to loop over 4 jelly fish
	
	nextIter_jellyfish:
	
	la 	$t0, 	jellyfish_pos($t2) 	# load address of each jelly fish to $t0
	lw 	$t0, 	0($t0) 			# $t0 =  jelly fish position 
	
	# Check right bound
	sll 	$t1, 	$t0,	25 		# gets x coordinate 
	beqz 	$t1, 	getRandomPosition 	# checks if x ==0, then get random pos
	
	
	# Compute next position for jelly fish
	# in this iteration
	addi 	$t0, 	$t0, 	-4 		# move left at speed of 1 pixel
	j update_jellyfish			# jump to update_jelly fish
	
	
	# Get new random number 
	# in case where y position out of bound
	getRandomPosition:
	li 	$v0, 	42 			# load service number 26 = generate the random number
	li 	$a0, 	0 			# from 0
	li 	$a1, 	26		 	# to 26
	syscall
	
	# setting y coord:
	move 	$t0,	$a0
	sll 	$t0,	$t0,	7 		# shift $t0 left 7
	addi 	$t0, 	$t0,	-12		# decrent by 12
	
	update_jellyfish:			# to update next jelly fish location
	sw 	$t0,	jellyfish_pos($t2) 	# store the current value in $t9
	addi 	$t2,	$t2,	-4		# decremen the current value by one word
	bgez 	$t2,	nextIter_jellyfish	# move jelly fish 
						# until 4 of the jelly fish is move
	jr 	$ra
	
	
	# #############################################################################################################
	
	#------------------#
	# Display jelly fish
	#------------------#
	
	# Purpose : to display the jelly fish
	# Note : there is special case for jellyfish and fish collision
	
	displaying_jellyfish :
	
	li 	$t4,	12 			# counter to loop vairable over the 4 jellyfish
	
	display_next_jellyfish:
	la 	$t1, 	jellyfish_pos($t4) 	# load adress of jellyfish position to $t1
	lw 	$t1, 	0($t1) 			# load that positon into $t1
	addi 	$t1, 	$t1,	BASE_ADDRESS	# get absolute position of jellyfish
	li 	$t3,	24 			# counter to loop vairable over all of the pixel in the fish
	
	render_jellyfish:
	
	#--------------------
	# Getting color pixel
	#--------------------
	
	la 	$t5, 	jellyfish_colors	# load address of jelly fish color
	add 	$t5, 	$t5, 	$t3 		# get address of xth colour is into $t5
	lw 	$t5, 	0($t5)			# load color positoin into $t5
	
	#----------------------
	# Getting pixel address
	#----------------------
	
	lw 	$t0, 	jellyfish_coord($t3) 	# load relative address of xth pixel of jellyfish
	add 	$t0,	$t0,	$t1		# now $t0 is absolute address of xth pixel
	
	#----------------------------------
	# check for collision with th fish
	#----------------------------------
	
	lw 	$t2, 	0($t0) 			# load absolute addres into $t2 to check the collision
	
	
	# checks if cuurent absolute address  is fish colors
	# in other word the fish overlaop with the jelly fish
	# go to jellyfish_collision_detected
	beq 	$t2, 	0x483D8B, 	jellyfish_collision_detected
	beq 	$t2, 	0xFFD700, 	jellyfish_collision_detected
	beq 	$t2, 	0xFF4500, 	jellyfish_collision_detected
	beq 	$t2, 	0x000000, 	jellyfish_collision_detected
	j 	jellyfish_col_end
	
	#-------------------#
	# Collision detect
	#-------------------#
	
	jellyfish_collision_detected:
	
	# damage couot for each collision
	# if there is collisoin, jellyfish disappear
	
	li 	damaged, 	1 		# damage count
	li 	$t2,	0 			# $t2 = 0 to reset position jelly fish
	sw 	$t2, 	jellyfish_pos($t4)	# store 0 into that position to make the collaspse disappear
	j 	jellyfish_end			# stop displaying # print the next jelly fish insttead
	
	
	jellyfish_col_end:
	
	#-----------------------
	# Displaying pixel color
	#-----------------------
	# in case of no colison
	
	sw 	$t5, 	0($t0) 			# store colour on framebuffer
	addi 	$t3,	$t3,	-4		# decrement counter of the jelly fish pixel
	bgez 	$t3, 	render_jellyfish	# loop until printin all of the pixel in one jelly fish
	
	
	
	# in case of colision
	# incase of printing all of the pixel in one jelly fish
	
	jellyfish_end:
	addi 	$t4,	$t4,	-4		# decrement the couter number of the jelly fish to print
	bgez 	$t4,	display_next_jellyfish	# print all of the fish
	jr 	$ra
	
	
	# #####################################################################
	
	#---------------#
	# Move seaweed
	#---------------#
	# purpose :  move seaweed  left-down at rate (-2,1)
	
	
	move_seaweed :

	lw 	$t0, 	seaweed_pos 		# $t0 holds value seaweed position
	
	#-------------------------------------
	# Check whether it out of bound or not
	#-------------------------------------
	
	# x coordinate
	sll 	$t1, 	$t0,	25 		# gets x coordinate in upper bound
	beqz 	$t1, 	seaweed_NewPosition	# checks whether x is  out of bound or not (if x=0 out bound)
	
	# y coordinate
	srl 	$t1, 	$t0,	7 		# gets y coordinate to lower bits
	beqz 	$t1, 	seaweed_NewPosition	# checks whether y is  out of bound or not (if y=0 out bound)
	addi 	$t1,	$t1,	-27 		# compute y-27

	beqz 	$t1, 	seaweed_NewPosition 	# if y-30 == 0 ,it out of bound
	
	
	#----------------------
	# Compute next position
	#----------------------
	
	addi 	$t0, 	$t0, 	-8 		# move left by 2 pixel # speed can be changed here
	li 	$t1,	1 			# to move 1 pixel down
	sll 	$t1,	$t1,	7
	add 	$t0,	$t0,	$t1 		# move down by 1 pixel
	j seaweed_update
	
	
	#----------------------
	# Call random number
	#----------------------
	
	seaweed_NewPosition:
	li 	$v0, 	42 			# load service number to generate random number
	li 	$a0, 	0 			# from number 0
	li 	$a1, 	25 			# to number 25
	syscall
	
	# setting y coord:
	addi 	$t0,	$a0,	1 		# increment the number by 1 to get number from 1-26
	sll 	$t0,	$t0,	7 		# shift $t0 left 7
	addi 	$t0, 	$t0,	-8 		# square off with right side
	
	seaweed_update:
	sw 	$t0,	seaweed_pos		# update seaweed position in memory
	jr $ra
	
	# #############################################################################################################
	
	#--------------------#
	# Diaplaying seaweed
	#--------------------#
	
	# purpose : to display the seaweed
	
	displaying_seaweed: 
	
	lw 	$t1, 	seaweed_pos 		# load value of seaweed position
	addi 	$t1, 	$t1,	BASE_ADDRESS	# get absolute position where the seaweed start
	li 	$t4,	8 			# loop counter for printing 3 pixels of the seaweed

	render_seaweed:
	
	#--------------------#
	# Getting pixel color
	#--------------------#
	lw 	$t5, 	seaweed_colors($t4)	# load color into $t5
	
	#----------------------#
	# getting pixel address
	#----------------------#
	
	lw 	$t0, 	seaweed_coord($t4) 	# load address of the seaweed
	add 	$t0,	$t0,	$t1		# get absolute addres 
	
	#----------------------#
	# check for collision:
	#----------------------#
	lw 	$t2, 	0($t0) 			# load absolute address to $t2 to check for collision
	
	# if the $t2 = any color of the ship
	# there is colision
	# the socrore is decremtn
	
	beq 	$t2, 	0x483D8B, 	seaweed_collision
	beq 	$t2, 	0xFFD700, 	seaweed_collision
	beq 	$t2, 	0xFF4500, 	seaweed_collision
	beq 	$t2, 	0x000000, 	seaweed_collision
	
	# if there is no collisoin, display the pixel of seaweed 
	j seaweed_display
	
	# if there is a case of colison
	# do not print that seaweed
	
	seaweed_collision:
	li 	damaged, 	1 		# increment to damage count
	li 	$t2,0 				# 0 for non-print
	sw 	$t2, 	seaweed_pos($zero)
	j 	seaweed_end			# do not print that that pixel of seaweed
	
	
	#-----------------------#
	# Displaying pixel color 
	#-----------------------#
	# diaplay that pixel of color it it not collide
	
	seaweed_display:
	sw 	$t5, 	0($t0) 			# store color on framebuffer
	addi 	$t4,	$t4,	-4		# decrement counter of the pixel of the seaweed
	bgez 	$t4, 	render_seaweed		# print until all of the seaweed pixel is print (if no colision)
	
	seaweed_end:
	jr $ra					# back to caller
	
					
	# #############################################################################################################		
					
					# --------This is the end of the program ------------------#
	


