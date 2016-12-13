#	Lexathon Project
#	Authors:        Ali Hader, Derek Bellanca, Calvin Lones, Joshua Mills
#	Section:        CS 3340.001
#	Compiler:       MARS 4.5
#	Date:           12/04/2016
	
.data

#----------------------------------------------------------------------------------------------------------#
#                                      	       Data                                                   #
#----------------------------------------------------------------------------------------------------------#
	
startMessage: 	.asciiz 	"\n\n\n\t\t\t\tWelcome to Lexathon!\n\n Use the letters below to create words. The words must be between 4-9 characters long,\n and the word must contain the middle character. You will be given 120 seconds initially\n and will get 30 seconds added to your time when you score. Every correct word will add \n 10 points to your score. \n\n Good luck!\n"

rightAns:	.asciiz	"\n That's a CORRECT answer! You got 10 points!\n!"
wrongAns:	.asciiz	"\n That's a WRONG answer! You get 0 points!\n"
input: 	.space 	10

alphabet:	.word 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # space for integer array of size 26 representing count of each letter
flag:	.space 	4 			#space for result of checking letters
letters: 	.space 	10			#allocating memory for 9 random letters

file: 	.asciiz 	"DictionaryLong.txt"		#storing file name
buffer: 	.space 	745770			#space for reading from file
usedWords: 	.space 	5000			#space for storing used words

unusedCounter: .word 	0
validString: 	.word 	1

inputPrompt: 	.asciiz 	" Enter the word (press 0 to exit game): "
invalidInp:	.asciiz 	"\n Please make sure your input consists of a 4-9 letter word comprised of the lowercase letters provided above and includes the middle letter.\nTry again.\n"

pointsDisplay: .asciiz 	" Total Points: "
points: 	.word 	0

lineSize: 	.word 	3
match_0: 	.word 	0
match_1: 	.word 	0
match_2: 	.word 	0
match_3: 	.word 	0
match_Mid: 	.word 	0
match_5: 	.word	0
match_6: 	.word 	0
match_7: 	.word	0
match_8: 	.word 	0

startTime: 	.word 	0
totalTime: 	.word 	120
getTime:  	.asciiz	"\n\n Time Remaining (in seconds): "
outofTime: 	.asciiz 	"\n You're out of time!\n\n"

vowels: 	.asciiz 	"aeiou"
consonants: 	.asciiz 	"bcdfghjkllmnprrssstt"

tab: 	.asciiz 	"\t"			#tab character
endl: 	.asciiz 	"\n"			#new line character

.text
	

#----------------------------------------------------------------------------------------------------------#
#                                     START GAME SUBROUTINE                                                #
#----------------------------------------------------------------------------------------------------------#	
			
start: 	#This function begins the dictionary read, prints a welcome and start message, starts the timer
	#and jumps to the main gameplay function
	
	jal readFile			#Jump and link to read_file
	
	la $a0, startMessage		#Load address for startmessage
	li $v0, 4			#System call for print string
	syscall			#Print startmessage
	
	li  $v0, 30			#System call for system time 
	syscall			
	sw $a0, startTime  		#Store starttime(0) in $a0
		
	add $s0, $zero, 0		#Initialize counter to zero
	jal random			#Jump and link to rando
	j main			#Jump to start game
	
############################################################################################################
############################################################################################################
#                                      START SUBROUTINES                                                   #
############################################################################################################
############################################################################################################
	
#----------------------------------------------------------------------------------------------------------#
#                                      READ FILE SUBROUTINE        (CALLED FROM START)                     #
#----------------------------------------------------------------------------------------------------------#	
	
readFile:	###Method opens and reads the dictionary file, and creates a buffer where read strings will be stored. 
	
	li $v0, 13			#syscode for opening file
	la $a0, file			#passing file name as argument
	li $a1, 0			#code for opening file in read only mode
	li $a2, 0			
	syscall
	move $s0, $v0			#storing file descriptor
	
	li $v0, 14			#syscode for file input
	move $a0, $s0 			#loading file descriptor into $a0
	la $a1, buffer			#address of space where read strings will be stored
	li $a2, 745770			#number of bytes/characters to read
	syscall
	
	li $v0, 16			#syscode for closing file
	move $a0, $s0			#loading file descriptor
	syscall
	jr $ra			#Jump back to MAIN
	
#----------------------------------------------------------------------------------------------------------#
#                                      PRINT TOTAL POINT SUBROUTINE        (CALLED FROM START)             #
#----------------------------------------------------------------------------------------------------------#	

printPoints:	###Method prints total points

	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall
	
	li $v0, 4			#System call for print string
	la $a0, pointsDisplay		#Load pointsDisplay into $a0
	syscall			#Print pointsDisplay
	
	li $v0, 1			#System call for print integer
	lw $t1, points			#Load points into $t1
	move $a0, $t1			#Move points into $a0
	syscall			#Print points
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall
	
	jr $ra			#JUMP BACK TO MAIN
		
#----------------------------------------------------------------------------------------------------------#
#                                      GENERATE MATRIX LETTERS SUBROUTINE      (CALLED FROM START)         #
#----------------------------------------------------------------------------------------------------------#	
	
random:	###Method generates a random letter character, and stores random character in $t0. 
	
	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 26			#range for random integer
	syscall			#generates a random number between 0 and 25 inclusive
	
	addiu $t0, $a0, 97		#converting to lowercase ASCII letters 
	
	la $s1, letters		#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1		#Increment counter by 1 (Number of letters in row)
	bne $s0, 3, random		#If $s0 is not equal to 3, jump to random
	j randomVowel			#Jump to random_vowel
	
randomVowel:	###Method generates a random vowel, and stores the random vowel in $t0
	
	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 5			#range for random integer
	syscall			#generates a random number between 0 and 25 inclusive
	
	la $s3, vowels			#Load address for vowels into $s3
	add $t0, $zero, $a0		#Add zero to $a0 and store in $t0
	add $s3, $s3, $t0		#Add $s3 to $t0 and store in $s3
	lb $t0, ($s3)
	
	la $s1, letters		#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1		#Increment $s0 by 1
	bne $s0, 6, randomVowel		#exit loop if counter = 9					
	j randomConsonant		#Jump to random_consonant
	
randomConsonant:###Method generates a random consonant, and store the random consonant in $t0

	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 20			#range for random integer
	syscall			#generates a random number between 0 and 25 inclusive
	
	la $s3, consonants		#Load address of consonants into $s3
	add $t0, $zero, $a0		#Add zero to $a0 and store in $t0
	add $s3, $s3, $t0		#Add $s3 to $t0 and store in $s3
	lb $t0, ($s3)			#Load byte from $s3 into $t0
	
	la $s1, letters		#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1		#Increment $s0 by 1	
	bne $s0, 9, randomConsonant		#exit loop if counter = 9					
	
	jr $ra			#JUMP BACK TO START

#----------------------------------------------------------------------------------------------------------#
#                                      PRINT 3x3 MATRIX SUBROUTINE      (CALLED FROM START)                #
#----------------------------------------------------------------------------------------------------------#	
			
printMatrix:	###Method prints the 3x3 matrix of randomly selected vowels, consonants, including the center character as a vowel

	la $a1, letters		#Contains the base address
	lw $a2, lineSize			#Contains the lineSize (3)
	subi $sp, $sp, 4		#Subtract 4 from stackpointer	
	sw $ra, ($sp)			#Store contents of stackpointer in $ra
	
	jal step1		#JUMP AND LINK TO INITIALIZE
		
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
		
step1:	###Part of printMatrix

	add $t1, $a1, $zero		#$t1 recieves base address of letters
	li $t2, 0			#Initialize $t2 to 0
	
while_1:	###Part of printMatrix

	li $v1, 0			#$v1 gets loaded with 0
	slt $t3, $t2, $a2		#if i > lineSize(3)
	beq $t3, $zero, END		#If i is zero, branch to endMatrix
	li $t4, 0			#set j = 0
	
while_2: 	###Part of printMatrix

	slt $t3, $t4, $a2		#
	beq $t3, $zero, next_line
	add $t5, $t2, $t2		# Keeps the track of address as 3*i + j
	add $t5, $t5, $t2
	add $t5, $t5, $t4
	add $t6, $t5, $a1		#Gets the address of letter
	lb $a0, 0($t6)
	beq $t5, 4, mid_letter
ret_1:
	li $v0, 11
	syscall
	
	li $v0, 4
	la $a0, tab
	syscall
	
	addi $t4, $t4, 1
	j while_2
	
mid_letter:	###Part of printMatrix

	#subi $a0, $a0, 32  ### this makes the middle letter uppercase
	j ret_1
	
next_line:	###Part of printMatrix

	li $v0, 4
	la $a0, endl
	syscall
	
	addi $t2, $t2, 1		# i++
	j while_1
	
END:	###Part of printMatrix

	jr $ra			##Jump back to start
	
############################################################################################################
############################################################################################################
#                                      END OF START SUBROUTINES                                            #
############################################################################################################
############################################################################################################

#----------------------------------------------------------------------------------------------------------#
#                                      MAIN METHOD SUBROUTINE    (JUMP TABLE)                              #
#----------------------------------------------------------------------------------------------------------#	
			
main:	###Method calls all other methods in order of the game
	
	jal printPoints		#Prints out the score
	jal printMatrix		#Prints out the character matrix 
	jal getInput			#Gets the input from user
	jal exitCondition		#Checks the exit condition
	jal validate 			#Validates user entered string
	jal rightAnswer		#Updates points, time, Outputs points and time
	
	j main			#Restarts loop so user can enter another word
	
#----------------------------------------------------------------------------------------------------------#
#                                      RECIEVE INPUT SUBROUTINE  (CALLED FROM MAIN)                        #
#----------------------------------------------------------------------------------------------------------#	
	
getInput:	#This function receives the input from the user

	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall			#Print newline

	subi $sp, $sp, 4		#Subtract 4 from stackpointer
	sw $ra, ($sp)			#Store contents of stackpointer in $ra
	
	la $a0, inputPrompt      		#prompts user for the input
	li $v0, 4			
	syscall			#Print input prompt
	
	la $a0, input			#Calls read method
	li $a1, 9			#Load 9 in $a1
	la $a2, letters		#Load address for letters
		
	jal Read			###JUMP AND LINK TO READ
	
	addi $s0, $s0, 1		#Add 1 to $s0 (counter)
		
	lw $ra, ($sp)			#Load contents of stack pointer into $ra
	
	jr $ra			#Jump back to start
	
#----------------------------------------------------------------------------------------------------------#
#                                      EXIT CONDITION SUBROUTINE                                           #
#----------------------------------------------------------------------------------------------------------#	
    	
exitCondition:
	la $s0, input			#Load address for input
	lb $t0, ($s0)			#Load input into $t0
	bne $t0, 48, else		#If input is not equal to ASCII 0, branch to else (Jump to return address)	
	j exit			#Jump to EXIT (USER HAS CHOSEN TO QUIT)
	
#----------------------------------------------------------------------------------------------------------#
#                                      INPUT VALIDATION SUBROUTINE      (CALLED FROM MAIN)                 #
#----------------------------------------------------------------------------------------------------------#	
	
validate:
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
	jal checkMiddleLetter
	add $t9, $zero, $v0
	
	#add $a0, $v0, $zero
	#li $v0, 1
	#syscall
	
	jal check			# calling check subprocedure
	and $t9, $t9, $v0
	
	#move $a0, $v0			# puts the returned value into $a0 
	#li $v0, 1			# syscode for printing integer
	#syscall

	jal check_length
	and $t9, $t9, $v0
	
	#move $a0, $v0			# puts the returned value into $a0 
	#li $v0, 1			# syscode for printing integer
	#syscall

	la $s0, validString
	lw $t9, ($s0)
	beq $t9, $0, EndValidation
	
	#move $a0, $t9			# puts the returned value into $a0 
	#li $v0, 1			# syscode for printing integer
	#syscall

	la $a0, input
	la $a1, buffer
	li $a2, 0
	li $a3, 74577
	jal Search
	
	#sw $v0, validString
	beq $v0, $0, EndValidation
	la $t0, usedWords
	add $t1, $0, $0
	lw $t2, unusedCounter
	
UsedWordsLoop:				#Checks if the entered word has been used so far; if not adds it
	bge $t1, $t2, EndUsedWordsLoop
	
	la $t3, input
	add $t4, $0, $t0
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	
	sw $0, validString
	j EndValidation
	
NotUsed:				#Adds word if not used
	addi $t0, $t0, 10
	addi $t1, $t1, 1
	j UsedWordsLoop

EndUsedWordsLoop:			#If used, clears memory used for input and sets the valid_string word to false
	la $t2, input
	lb $t1, ($t2)
	sb $t1, ($t0)
	addi $t1, $t1, 1
	lb $t1, 1($t2)
	sb $t1, 1($t0)
	addi $t1, $t1, 1
	lb $t1, 2($t2)
	sb $t1, 2($t0)
	addi $t1, $t1, 1
	lb $t1, 3($t2)
	sb $t1, 3($t0)
	addi $t1, $t1, 1
	lb $t1, 4($t2)
	sb $t1, 4($t0)
	addi $t1, $t1, 1
	lb $t1, 5($t2)
	sb $t1, 5($t0)
	addi $t1, $t1, 1
	lb $t1, 6($t2)
	sb $t1, 6($t0)
	addi $t1, $t1, 1
	lb $t1, 7($t2)
	sb $t1, 7($t0)
	addi $t1, $t1, 1
	lb $t1, 8($t2)
	sb $t1, 8($t0)
	addi $t1, $t1, 1
	lb $t1, 9($t2)
	sb $t1, 9($t0)
	lw $t0, unusedCounter
	addi $t0, $t0, 1
	sw $t0, unusedCounter
	
EndValidation:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

check_length:
	la $s0, input
	li $t0, 0			#Length counter
	
	subi $sp, $sp, 4
	sw $ra, ($sp)
	jal calculate_length
	addi $v0, $v0, -1
		
	slti $t0, $v0, 10
	sgt $t1, $v0, 3
	and $v0, $t0, $t1
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
calculate_length:
	add $s1, $s0, $t0
	lb $t1, ($s1)
	beq $t1, $zero, exit_loop
	addi $t0, $t0, 1
	j calculate_length
	
exit_loop:
	add $v0, $t0, $zero
	jr $ra
	
	
#----------------------------------------------------------------------------------------------------------#
#                                      WORD COMPARISON SUBROUTINE     (CALLED FROM getInput)               #
#----------------------------------------------------------------------------------------------------------#	


###Method that matches user entered word with library????

Read:	
	subi $sp, $sp, 12		#Subtract 12 from stackpointer
	sw $a0, ($sp)			#Store contents into $a0
	sw $a1, 4($sp)			#Store next contents into $a1
	sw $ra, 8($sp)			#Store next contents into $ra

ReadLoop:		
	li  $v0, 12			#Reads in the entered character
    	syscall			#Read
    	
    	addi $t0, $0, 0x0000000a	#Add 1 to $t0
    	beq $v0, $t0, DoneReading		#If the entered character is an "Enter", then exits loop
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------#  

middleChar:				
    	lb $t0, 4($a2)			#Checks if entered characters are in the randomly generated character list.
    	bne $v0, $t0, char0		#Each time, if the character isn't the first time matched to a character in the matrix, then throws an invalid input message

        	jal matchMid
        	
matchMid:	#Checks if the character at index 4 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_Mid
	lw $t2, ($t1)
	beq $t2, $t0, AlreadyMid
	sw $t0, ($t1)
	j HasLetters
AlreadyMid:
	jr $ra
        	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------#   
      	
char0:
    	lb $t0, ($a2)
    	bne $v0, $t0, char1
    	jal match0
    	
match0:	#Checks if the character at index 0 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_0
	lw $t2, ($t1)
	beq $t2, $t0, Already0
	sw $t0, ($t1)
	j HasLetters	
	
Already0:
	jr $ra

#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 
	
char1:    	
    	lb $t0, 1($a2)
    	bne $v0, $t0, char2
    	jal match1
    	
match1:	#Checks if the character at index 1 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_1
	lw $t2, ($t1)
	beq $t2, $t0, Already1
	sw $t0, ($t1)
	j HasLetters
Already1:
	jr $ra
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char2:    	
    	lb $t0, 2($a2)
    	bne $v0, $t0, char3
    	jal match2
    	
match2:	#Checks if the character at index 2 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_2
	lw $t2, ($t1)
	beq $t2, $t0, Already2
	sw $t0, ($t1)
	j HasLetters
Already2:
	jr $ra
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char3:    	
    	lb $t0, 3($a2)
    	bne $v0, $t0, char5
    	jal match3
    	
match3:	#Checks if the character at index 3 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_3
	lw $t2, ($t1)
	beq $t2, $t0, Already3
	sw $t0, ($t1)
	j HasLetters
Already3:
	jr $ra
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char5:    	
    	lb $t0, 5($a2)
    	bne $v0, $t0, char6
    	jal match5
    	
match5:	#Checks if the character at index 5 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_5
	lw $t2, ($t1)
	beq $t2, $t0, Already5
	sw $t0, ($t1)
	j HasLetters
Already5:
	jr $ra
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char6:    	
    	lb $t0, 6($a2)
    	bne $v0, $t0, char7
    	jal match6
    	
match6:	#Checks if the character at index 6 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_6
	lw $t2, ($t1)
	beq $t2, $t0, Already6
	sw $t0, ($t1)
	j HasLetters
Already6:
	jr $ra
    	
##-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char7:    	
    	lb $t0, 7($a2)
    	bne $v0, $t0, char8
    	jal match7
    	
match7:	#Checks if the character at index 7 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_7
	lw $t2, ($t1)
	beq $t2, $t0, Already7
	sw $t0, ($t1)
	j HasLetters
Already7:
	jr $ra
    	
#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 

char8:    	
    	lb $t0, 8($a2)
    	bne $v0, $t0, EndChecking
    	jal match8
    	
match8:	#Checks if the character at index 8 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	
	li $t0, 0x00000001
	la $t1, match_8
	lw $t2, ($t1)
	beq $t2, $t0, Already8
	sw $t0, ($t1)
	j HasLetters
Already8:
	jr $ra

#-----------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------# 
    	
HasLetters:    				
    	sb $v0, ($a0)			#Saves the character to the memory space for the string
    	addi $a0, $a0, 1
    	subi $a1, $a1, 1
    	
    	beq $a1, $0, DoneReading	
    	
    	j ReadLoop

DoneReading:
	la $t0, match_Mid		#Makes sure middle character is present before progressing
	lw $t1, ($t0)
	beq $t1, 0, InvalidInput
	li $t0, 5
	bgt $a1, $t0, InvalidInput
	addi $a1, $a1, 1
	
AddNulls:
	sb $0, ($a0)			#Adds nulls to the end of the entered string
	addi $a0, $a0, 1
    	subi $a1, $a1, 1
    	
    	beq $a1, $0, FinishedAddingNulls
    	j AddNulls
	
FinishedAddingNulls:

	#Resets all the words that keep track of how many times each letter has been entered
	
	la $t0, match_Mid
	sw $0, ($t0)
	la $t0, match_0
	sw $0, ($t0)
	la $t0, match_1
	sw $0, ($t0)
	la $t0, match_2
	sw $0, ($t0)
	la $t0, match_3
	sw $0, ($t0)
	la $t0, match_5
	sw $0, ($t0)
	la $t0, match_6
	sw $0, ($t0)
	la $t0, match_7
	sw $0, ($t0)
    	la $t0, match_8
	sw $0, ($t0)
	
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
EndChecking:
    	li $t0, 0x00000030		#If a 0 was entered, quits program
    	beq $v0, $t0, exit
    	j InvalidInput
		
InvalidInput:				#In the case of invalid input, resets everything and returns error message.
	li $v0, 55
    	la $a0, invalidInp
    	li $a1, 1		
    	syscall
    	
	li $v0, 4
    	la $a0, endl		
    	syscall
    	
    	lw $a0, ($sp)
    	lw $a1, 4($sp)
    	sb $0, ($a0)
    	sb $0, 1($a0)
    	sb $0, 2($a0)
    	sb $0, 3($a0)
    	sb $0, 4($a0)
    	sb $0, 5($a0)
    	sb $0, 6($a0)
    	sb $0, 7($a0)
    	sb $0, 8($a0)
    	sb $0, 9($a0)
    	
    	la $t0, match_Mid
	sw $0, ($t0)
	la $t0, match_0
	sw $0, ($t0)
	la $t0, match_1
	sw $0, ($t0)
	la $t0, match_2
	sw $0, ($t0)
	la $t0, match_3
	sw $0, ($t0)
	la $t0, match_5
	sw $0, ($t0)
	la $t0, match_6
	sw $0, ($t0)
	la $t0, match_7
	sw $0, ($t0)
    	la $t0, match_8
	sw $0, ($t0)
	
    	j ReadLoop

#----------------------------------------------------------------------------------------------------------#
#                                      CENTER LETTER CHECK SUBROUTINE   (CALLED FROM VALIDATE)             #
#----------------------------------------------------------------------------------------------------------#

# Function to check if the middle letter is included
checkMiddleLetter:
	la $s0, letters
	lb $a0, 4($s0) 		# $t7 contains the central letter
	la $a1, input
	li $t0, 0
	j loop_1
	
loop_1:
      	add $s0, $a1, $t0
      	lb $t1, ($s0)
      	beq $t1, $zero, notFound
        	beq $a0, $t1, found 		# go to NoMiddleLetter subroutine. # $t1 = middle letter #t5 = the current letter
        	addi $t0, $t0, 1 		#increment regardless of the outcome
	j loop_1

notFound:
	li $v0, 0
	jr $ra

found:
	li $v0, 1 			#returns 1
        	jr $ra


check:	move $s6, $ra			# storing the return address into a seperate register
	li $t0, 0			# i = 0
	jal loop1			# begin loop
	li $t0, 0		
	jal loop2
	li $t0, 0
	li $v0, 1
	jal loop3
	la $s0, flag
	sw $v0, ($s0)
	move $ra, $s6
	jr $ra
	
loop1:	slti $t1, $t0, 10		# stores 1 in $t1 if i < 10
	la $s0, letters		# storing address of letters in $s0
	add $s0, $s0, $t0		# adding offset to address of letters
	lb $t3, ($s0)			# loading byte at the given address
	sne $t2, $t3, $zero		# assigns 1 to $t2 if the charcter read is not NULL
	and $t1, $t1, $t2		# checks if both the conditions are true
	beq $t1, $zero, else 		# if they are false then exit loop
	subi $t3, $t3, 97		# subtracts 'a' from character read
	la $s1, alphabet		# loading address of array storing count of each alphabet
	sll $t3, $t3, 2		# multiplying the offset by 4
	add $s1, $s1, $t3		# adding offset to base address
	lw $t3, ($s1)			# loading count of the alphabet read
	addi $t3, $t3, 1		# incrementing the count by 1
	sw $t3, ($s1)			# storing the incremented value back
	add $t0, $t0, 1		# incrementing the counter
	j loop1
	
else: 
	jr $ra			# jumps back to the return address/exits loop

loop2:	slti $t1, $t0, 10		# stores 1 in $t1 if i < 10
	la $s0, input			# storing address of input in $s0
	add $s0, $s0, $t0		# adding offset to address of input
	lb $t3, ($s0)			# loading byte at the given address
	sne $t2, $t3, $zero		# assigns 1 to $t2 if the charcter read is not NULL
	and $t1, $t1, $t2		# checks if both the conditions are true
	beq $t1, $zero, else 		# if they are false then exit loop
	subi $t3, $t3, 97		# subtracts 'a' from character read
	la $s1, alphabet		# loading address of array storing count of each alphabet
	sll $t3, $t3, 2		# multiplying the offset by 4
	add $s1, $s1, $t3		# adding offset to base address
	lw $t3, ($s1)			# loading count of the alphabet read
	subi $t3, $t3, 1		# decrementing the count by 1
	sw $t3, ($s1)			# storing the updated value back
	add $t0, $t0, 1		# incrementing the counter
	j loop2

loop3:	slti $t1, $t0, 26		# $t1 = 0 if  i < 26
	beq $t1, 0, else		# branch if $t1 = 0
	la $s1, alphabet		# loads the address of alphabet to $s1
	sll $t2, $t0, 2		# multiplying the counter by 4
	add $s1, $s1, $t2		# adding the offset to the base address
	lw $t3, ($s1)			# loading the value at the given address
	blt $t3, $zero, else2		# exit loop the value is negative
	add $t0, $t0, 1		# incrementging counter
	j loop3
	
else2: 	li $v0, 0			# assigns 0 to return value
	jr $ra			# going back to statement after function call
	
#----------------------------------------------------------------------------------------------------------#
#                                      MAIN SEARCH SUBROUTINE       (CALLED FROM VALIDATE)                 #
#----------------------------------------------------------------------------------------------------------#

#This is the main search method.  It takes in 4 parameters.  $a0 is the memory address of the search value.
#$a2 is the memory address of the array.  $a3 is the lowest index (0) and $a4 is the highest index (74577, 
#or whatever the # of words is).  It returns a 1 if the value is found in the array and a 0 if it is not.

Search:
	subi $sp, $sp, 24		#Clear space on stack to store variables
	sw $a0, ($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $a3, 12($sp)
	sw $ra, 16($sp)

Search2:
	lw $t0, 8($sp)			#Load lowest and highest indexes from stack
	lw $t1, 12($sp)		
	bgt $t0, $t1, SearchNotFound		#If lowest index higher than highest, end subroutine and go to NotFound
	add $t4, $t1, $t0		#Calculate middle index
	div $t4, $t4, 2
	sw $t4, 20($sp)		#Store middle index
	li $t0, 10
	lw $a0, ($sp)			#Load search value address and array address
	lw $a1, 4($sp)
	mul $t4, $t4, 10		#Multiple middle index by 10 since each string has 10 characters (this gives displacement from lowest index value)
	add $a1, $a1, $t4		#Add middle index value to lowest index value
	jal CompareBytes		#Compare string at middle index and search value string
	li $t8, 1	
	beq $v0, $t8, LessT		#If search value less than, go to LessT
	li $t9, 2			
	beq $v0, $t9, GreaterT		#If search value greater than, go to GreaterT
	j SearchFound			#Else if equal, go end subroutine and go to Found
LessT:
	lw $t0, 20($sp)		#Load middle index
	subi $t1, $t0, 1		#Subtract 1 from middle index
	sw $t1, 12($sp)		#Store that as new highest index
	j Search2			#Run binary search again with new params
GreaterT:
	lw $t0, 20($sp)		#Load middle index
	addi $t1, $t0, 1		#Add 1 to middle index
	sw $t1, 8($sp)			#Store that as new lowest index
	j Search2

SearchNotFound:	
	li $v0, 0x00000000		#Load 0 into $v0, indicates search value not found
	lw $ra, 16($sp)		#Load return address from stack
	addi $sp, $sp, 24		#Reset stack pointer
	jr $ra			#Return to return address
SearchFound:	
	li $v0, 0x00000001		#Load 1 into $v0, indicates search value found
	lw $ra, 16($sp)		#Load return address from stack
	addi $sp, $sp, 24		#Reset stack pointer
	jr $ra			#Return to return address
	
CompareBytes:				
	li $t9, 0x00000000		#Null termintaing character stored in $t9's last byte###########################################################

CompareBytesLoop:	
	lb $t0, ($a0)			#Load bytes from string paramters
	lb $t1, ($a1)
	blt $t0, $t1, NotMatchLess		#If search value byte is lesser, go to NotMatchLess
	bgt $t0, $t1, NotMatchMore		#If search value byte is greater, go to NotMatchMore
	beq $t0, $t9, Match		#If search value byte is equal and equals Nul, go to Match
	addi $a0, $a0, 1		#Jumps to next byte on each string
	addi $a1, $a1, 1
	j CompareBytesLoop		#Restarts loop until final match or nonmatch reached
Match:	
	add $v0, $0, $0		#Load 0 into $v0, signifies match
	jr $ra			#Return to return address
NotMatchLess:	
	addi $v0, $0, 1		#Load 1 into $v0, signifies non-match where srch value is less
	jr $ra			#Return to return address
NotMatchMore:	
	addi $v0, $0, 2		#Load 2 into $v0, signifies non-match where srch value is more
	jr $ra			#Return to return address
	
#----------------------------------------------------------------------------------------------------------#
#                                      OUTPUT RESULTS SUBROUTINE   (CALLED FROM MAIN)                      #
#----------------------------------------------------------------------------------------------------------#

rightAnswer:	###Method updates points, prints points, updates time, prints time

	lw $t0, points			#Load "points" into $t0
	lw $t1, validString		#Load validString into $t1
	beq $t1, $zero, NOTrightAnswer	#If validString is equal to 0, branch to NotrightAnswer
	addi $t0, $t0, 10		#Add 10 to points
	sw $t0, points			#Store updated points back into "points"
	
	li $v0, 4			#System call for print string
	la $a0, rightAns		#Load rightAns into $a0
	syscall			#Print rightAns
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall
	
	li $v0, 4			#System call for print string
	la $a0, pointsDisplay		#Load pointsDisplay into $a0
	syscall			#Print pointsDisplay
	
	li $v0, 1			#System call for print integer
	lw $t1, points			#Load points into $t1
	move $a0, $t1			#Move points into $a0
	syscall			#Print points
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall

	li $v0, 30			#System call for system time
	lw $t0, startTime		#Load time elapsed into $t0
	syscall
	sub $t0, $a0, $t0		#Subtract time 
	div $t0, $t0, 1000		#Divide time(milliseconds) by 1000 to get seconds
	lw $t1, totalTime		#Load 120 seconds into $t1
	addi $t1, $t1, 30		#Adds 30 seconds to time left
	sw $t1, totalTime		#Store updated totalTime back in $t1
	bge $t0, $t1, outofTime		#If time elapsed is greater than or equal to totalTime, branch to outofTime
	
	sub $t1, $t1, $t0		#Subtract time from 120 and put in $t1

	li $v0, 4			#System call for print string
	la $a0, getTime		#Load getTime into $a0
	syscall			#Print getTime
	
	li $v0, 1			#System call for print integer
	move $a0, $t1			#Put $t1(time) into $a0
	syscall			#Print time

	jr $ra			#Jump back

NOTrightAnswer:###Method prints wrong answer prompt, prints points, prints time, if time is out, branch to outoftime.

	li $v0, 4			#System call for print string
	la $a0, wrongAns		#Load wrongAns into $a0
	syscall			#print wrongAns
	
	#li $v0, 4			#System call for print string
	#la $a0, endl			#Load newline character
	#syscall
	
	li $v0, 4			#System call for print string
	la $a0, pointsDisplay		#Load pointsDisplay into $a0
	syscall			#Print pointsDisplay
	
	li $v0, 1			#System call for print integer
	lw $t1, points			#Load points into $t1
	move $a0, $t1			#Move points into $a0
	syscall			#Print points
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall
	
	li $v0, 30			#System call for system time
	lw $t0, startTime		#Load startTime into $t0
	syscall
	sub $t0, $a0, $t0		#Subtract time 
	div $t0, $t0, 1000		#Divide time(milliseconds) by 1000 to get seconds
	lw $t1, totalTime		#Store updated totalTime back in $t1
	bge $t0, $t1, outofTime		#If time elapsed is greater than or equal to totalTime, branch to outofTime

	sub $t1, $t1, $t0		#Subtract time from 120 and put in $t1
	
	li $v0, 4			#System call for print string
	la $a0, getTime		#Load getTime into $a0
	syscall			#Print getTime
	
	li $v0, 1			#System call for print integer
	move $a0, $t1			#Put $t1(time) into $a0
	syscall			#Print time
	jr $ra			#Jump back
	
#----------------------------------------------------------------------------------------------------------#
#                                      EXIT PROGRAM SUBROUTINE    (CALLED FROM RIGHTANSWER, EXITCONDITION) #
#----------------------------------------------------------------------------------------------------------#

outOfTime:	###Method prints outofTime

	la $v0, 4			#System call for print string
	la $a0, outofTime		#Load outofTime into $a0
	syscall			#Print outofTime
	
exit:	###Exit program. Print points

	la $a0, endl			#Print newline
	li $v0, 4
	syscall
	
	li $v0, 4			#System call for print string
	la $a0, pointsDisplay		#Load pointsDisplay into $a0
	syscall			#Print pointsDisplay
	
	li $v0, 1			#System call for print integer
	lw $t1, points			#Load points into $t1
	move $a0, $t1			#Move points into $a0
	syscall			#Print points
	
	li $v0, 4			#System call for print string
	la $a0, endl			#Load newline character
	syscall			#Print newline character

	li $v0, 10			#System call for exit program
	syscall			#Exit program
