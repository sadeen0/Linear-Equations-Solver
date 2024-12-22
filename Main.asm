                      #                             Arciticture Project 1                             # 
                     ##            System of Linear Equations Solver besed on Carmesr's Rule          ##
                    ###       By:          Sadeen Khatib             &         Mohammad Omar          ###
                   ####       ID:             1212164                &            1212429             ####
                


####################################################    Data Section   ####################################################################
.data
# Define data segments for storing variables and messages

### Menu
HelloSystem: .asciiz  "\n-------------------------  Welcome to our System of Linear Equations Solver based on Cramers Rule  ------------------------- "
ReadEquationsFile: .asciiz  "\n\t -  Read equations from the file: "
InputFile: .asciiz "\n\n\tEnter the input File Path: "
FileName: .space 261  # Reserve 260 bytes for the string
ErrorFile: .asciiz "\nError: Failed to openning the file!"
ErrorReading: .asciiz "\nError: Unable to Open or Read the File.\n"
SuccessRead: .asciiz "\n ------- Sucessful Reading Equation from the file\n"

message: .asciiz "--------  Results :\n" 	# Message to write to the file
messageLength: .word 20            		# Length of the message (including newline)
outputFileName: .asciiz "C:\\Users\\sadee\\OneDrive\\Desktop\\Output.txt"
ErrorOutFile: .asciiz "\nError: Cannot open file for writing.\n"
ErrorWriting: .asciiz "\nError: Cannot write to file.\n"
float_buffer: .space 60    # Reserve space for the converted float string


buffer: .space 2000    # Buffer to store the contents of the file
Question:  .asciiz "\n\n--------  How you would like the results to be displayed?"
OutputFile:   .asciiz "\n\t\t 1. OutputFile:  Enter 'f' or 'F' to save results on the File."
OutputFileName: .asciiz "\n\t Enter the output File Name or Path: "
OnTheScreen: .asciiz "\n\t\t 2. On the screen: Enter 's' or 'S'."
Exit: .asciiz "\n--------  Enter 'e' or 'E' to Exit."
choice:  .asciiz "\n\t Enter your choice:\n"
InvalidChoice: .asciiz "\nInvalid choice! Please try again:"
ErrorMessage: .asciiz "\nInvalid choice!"
newline: .asciiz "\n" 
char: .space 2   # Buffer for 1 character + null terminator
Results: .asciiz "\n--------  Results On the Screen:"
result_x: .asciiz " \n\n\t\t x = "
result1: .asciiz "\n\n\t\t x = "
result2: .asciiz "\n\t\t y =  "
result_y: .asciiz " \n\t\t y = "
result_z: .asciiz " \n\t\t z = "
detA_zero: .asciiz "Determinant of A is zero. No solution exists.\n"
error_msg_x: .asciiz "Error in the first equation: There is a Multiple 'x' .\n"
error_msg_y: .asciiz "Error in the first equation: There is a Multiple 'y' .\n"
error_msg_eq: .asciiz "Error in the first equation: There is s Multiple '=' .\n"
newAttempt: .asciiz  "\nWrite the Equations Correctly to solve equations. \n\t You can reEnter the file Path" 


ok: .asciiz "\n OK"

#####################################################    Main   ####################################################################

.text
.globl main


main:


# Print welcome message
    li $v0, 4
    la $a0, HelloSystem
    syscall
    

#### Read file name or Path from the user
ReadFile:

 # Prompt user to enter file name
    li $v0, 4                #Print for user to enter file            
    la $a0, InputFile 
    syscall
    
 # Read user input for file name
    li $v0, 8               # System call for reading string
    la $a0, FileName        # Load address of file name buffer
    li $a1, 260             # Set the maximum number of characters to read
    syscall
 
 # Remove newline character from FileName
    la $t0, FileName       # Pointer to FileName buffer
    
remove_newline:
    lb $t1, 0($t0)         # Load byte at $t0
    beqz $t1, end_remove_newline    # If zero, end of string
    li $t2, 10             # ASCII code for newline '\n'
    beq $t1, $t2, replace_newline
    addi $t0, $t0, 1       # Move to next character
    j remove_newline
replace_newline:
    sb $zero, 0($t0)       # Replace '\n' with '\0'
    j end_remove_newline

end_remove_newline:
 
 # Open the file
    li $v0, 13              # Syscall to open file
    la $a0, FileName         
    li $a1, 0               # Read-only mode
    li $a2, 0               # Default permissions
    syscall
    
    #la $t0, FileName
    move $t0, $v0           
    
    bltz $t0, file_open_error   # If file descriptor < 0, jump to error
    
 
# Read file content
    li $v0, 14               # Syscall to read file
    move $a0, $t0            
    la $a1, buffer           # Buffer to store content
    li $a2, 1000             # Maximum bytes to read
    syscall
    move $s5, $v0           
    
    beqz $s5, ErrorReading   # If no bytes read, jump to message error 


 # Print the file content for debugging
    li $v0, 4
    la $a0,  SuccessRead
    syscall

    li $v0, 4
    la $a0, buffer
    syscall
    
    
    # Close the file
    li $v0, 16                 # Syscall to close file
    move $a0, $t0            
    syscall
    
    la $t1, buffer       
    jal parse_line_first_line  # Parse the first line with special check
    # Now $s0, $s1, $s2, $s3 contain the parsed values from the first line
    # Check if s3 is zero
    beqz $s3, is_2x2_system
    # s3 is non-zero (3x3 system)
    # Proceed to parse lines 2 and 3, store lines 1-3 in $f0 to $f11
    li $s6, 0            # Flag for 3x3 system
    # Store first line coefficients
    li $s4, 1            # Line counter
    jal convert_to_float
    # Move to next line
    jal move_to_next_line
    # Parse line 2
    jal parse_line
    li $s4, 2
    jal convert_to_float
    # Move to next line
    jal move_to_next_line
    # Parse line 3
    jal parse_line
    li $s4, 3
    jal convert_to_float
    # Move to next line (Skip line 4)
    jal move_to_next_line
    # Move to next line (Now at line 5)
    jal move_to_next_line
    # Parse line 5
    jal parse_line
    li $s4, 4
    jal convert_to_float
    # Move to next line
    jal move_to_next_line
    # Parse line 6
    jal parse_line
    li $s4, 5
    jal convert_to_float
    # Jump to finish_phrasing instead of directly ending

    jal finish_phrasing  # NEW: Call finish_phrasing after parsing
    

####################################################    Calculate   ####################################################################
calculate:
    jal calculate_det_A
    jal calculate_det_A1
    jal calculate_det_A2
    jal calculate_det_A3
    #jal ResultsOnScreen       

    jr $ra

is_2x2_system:
    # s3 is zero (2x2 system)
    li $s6, 1            # Flag for 2x2 system

    # Store first line coefficients
    li $s4, 1            # Line counter
    jal convert_to_float

    # Move to next line
    jal move_to_next_line

    # Parse line 2
    jal parse_line
    li $s4, 2
    jal convert_to_float

    # Move to next line (Skip line 3)
    jal move_to_next_line

    # Move to next line (Now at line 4)
    jal move_to_next_line

    # Parse line 4
    jal parse_line
    li $s4, 3
    jal convert_to_float

    # Move to next line
    jal move_to_next_line

    # Parse line 5
    jal parse_line
    li $s4, 4
    jal convert_to_float

    # Move to next line
    jal move_to_next_line

    # Parse line 6
    jal parse_line
    li $s4, 5
    jal convert_to_float

    # Jump to finish_phrasing instead of directly ending
    jal finish_phrasing  # NEW: Call finish_phrasing after parsing

finish_phrasing:
    # Call the calculate subroutine
   jal calculate



file_open_error:
    # Print the error message
    la $a0, ErrorFile # Use the specific error message
    li $v0, 4
    syscall
    # Terminate the program gracefully
   # j finish_phrasing  # NEW: Redirect to finish_phrasing instead of jumping to end_parse
   j ReadFile   # Allow user to re-enter the filename

convert_to_float:
    beq $s6, 1, s3_zero_convert    # If s3 is zero (2x2 system), go to s3_zero_convert

    # s3 is non-zero (3x3 system)
    # Store coefficients based on line number s4
    beq $s4, 1, store_in_f0_f3     # Line 1
    beq $s4, 2, store_in_f4_f7     # Line 2
    beq $s4, 3, store_in_f8_f11    # Line 3
    beq $s4, 4, store_in_f26_f28   # Line 5
    beq $s4, 5, store_in_f29_f31   # Line 6
    jr $ra

s3_zero_convert:
    # s3 is zero (2x2 system)
    # Store coefficients based on line number s4
    beq $s4, 1, store_in_f26_f28   # Line 1
    beq $s4, 2, store_in_f29_f31   # Line 2
    beq $s4, 3, store_in_f0_f3     # Line 4
    beq $s4, 4, store_in_f4_f7     # Line 5
    beq $s4, 5, store_in_f8_f11    # Line 6
    jr $ra

store_in_f0_f3:
    mtc1 $s0, $f0
    cvt.s.w $f0, $f0
    mtc1 $s1, $f1
    cvt.s.w $f1, $f1
    mtc1 $s3, $f2
    cvt.s.w $f2, $f2
    mtc1 $s2, $f3
    cvt.s.w $f3, $f3
    jr $ra

store_in_f4_f7:
    mtc1 $s0, $f4
    cvt.s.w $f4, $f4
    mtc1 $s1, $f5
    cvt.s.w $f5, $f5
    mtc1 $s3, $f6
    cvt.s.w $f6, $f6
    mtc1 $s2, $f7
    cvt.s.w $f7, $f7
    jr $ra

store_in_f8_f11:
    mtc1 $s0, $f8
    cvt.s.w $f8, $f8
    mtc1 $s1, $f9
    cvt.s.w $f9, $f9
    mtc1 $s3, $f10
    cvt.s.w $f10, $f10
    mtc1 $s2, $f11
    cvt.s.w $f11, $f11
    jr $ra

store_in_f26_f28:
    mtc1 $s0, $f26
    cvt.s.w $f26, $f26
    mtc1 $s1, $f27
    cvt.s.w $f27, $f27
    mtc1 $s2, $f28
    cvt.s.w $f28, $f28
    jr $ra

store_in_f29_f31:
    mtc1 $s0, $f29
    cvt.s.w $f29, $f29
    mtc1 $s1, $f30
    cvt.s.w $f30, $f30
    mtc1 $s2, $f31
    cvt.s.w $f31, $f31
    jr $ra

# Modify parse_line to parse_line_first_line with extra checks for multiple 'x', 'y', '='

parse_line_first_line:
    # Initialize temporary variables
    li $s0, 0                # Coefficient of x
    li $s1, 0                # Coefficient of y
    li $s3, 0                # Coefficient of z
    li $s2, 0                # Right-hand side value
    li $t2, 0                # Accumulator for digits
    li $t3, 1                # Sign (1 for positive, -1 for negative)
    li $t4, 0                # Mode (0: coefficient, 3: result)
    li $t8, 0                # Counter for 'x' occurrences
    li $t9, 0                # Counter for 'y' occurrences
    li $s7, 0                # Counter for '=' occurrences

parse_char_first_line:
    lb $t5, 0($t1)           
    beqz $t5, parse_done_first_line     

    li $t6, '\n'
    beq $t5, $t6, parse_done_first_line

    li $t6, ' '
    beq $t5, $t6, next_char_first_line
    li $t6, '+'
    beq $t5, $t6, next_char_first_line
    li $t6, '-'
    beq $t5, $t6, set_negative_first_line

    li $t6, '0'
    li $t7, '9'
    bge $t5, $t6, check_digit_first_line
    j handle_non_digit_first_line

check_digit_first_line:
    ble $t5, $t7, accumulate_digit_first_line
    j handle_non_digit_first_line

accumulate_digit_first_line:
    sub $t5, $t5, $t6        # Convert ASCII to integer
    mul $t2, $t2, 10
    add $t2, $t2, $t5
    j next_char_first_line

handle_non_digit_first_line:
    li $t6, 'x'
    beq $t5, $t6, store_x_first_line

    li $t6, 'y'
    beq $t5, $t6, store_y_first_line

    li $t6, 'z'
    beq $t5, $t6, store_z_first_line

    li $t6, '='
    beq $t5, $t6, handle_equal_first_line

    j parse_done_first_line

store_x_first_line:
    # Increment 'x' counter
    addi $t8, $t8, 1
    # Check if 'x' has occurred more than once
    bgt $t8, 1, error_multiple_x
    mul $s0, $t2, $t3       # s0 = coefficient of x
    j reset_temp_first_line

store_y_first_line:
    # Increment 'y' counter
    addi $t9, $t9, 1
    # Check if 'y' has occurred more than once
    bgt $t9, 1, error_multiple_y
    mul $s1, $t2, $t3       # s1 = coefficient of y
    j reset_temp_first_line

store_z_first_line:
    mul $s3, $t2, $t3       # s3 = coefficient of z
    j reset_temp_first_line

handle_equal_first_line:
    # Increment '=' counter
    addi $s7, $s7, 1
    # Check if '=' has occurred more than once
    bgt $s7, 1, error_multiple_eq

    li $t3, 1               # Reset sign to positive
    li $t4, 3               # Set mode to result
    j reset_temp_first_line

set_negative_first_line:
    li $t3, -1              # Set sign to negative
    j next_char_first_line

reset_temp_first_line:
    li $t2, 0               # Reset accumulator
    li $t3, 1               # Reset sign to positive
    addi $t1, $t1, 1        # Move to next character
    j parse_char_first_line

next_char_first_line:
    addi $t1, $t1, 1        # Move to next character
    j parse_char_first_line

parse_done_first_line:
    # If in result mode, store the accumulated value into s2
    beq $t4, 3, store_result_first_line
    # Else, store the last accumulated value into s2 (in case the line ends)
    mul $s2, $t2, $t3
    jr $ra

store_result_first_line:
    mul $s2, $t2, $t3
    jr $ra

error_multiple_x:
    # Print error message and end the program
    la $a0, error_msg_x
    li $v0, 4
    syscall
   
   la $a0, newAttempt
   li $v0, 4
   syscall
   
   j ReadFile      

error_multiple_y:
    # Print error message and end the program
    la $a0, error_msg_y
    li $v0, 4
    syscall
    
    la $a0, newAttempt
    li $v0, 4
    syscall  
   
   j ReadFile  

error_multiple_eq:
    # Print error message and end the program
    la $a0, error_msg_eq
    li $v0, 4
    syscall
    
    la $a0, newAttempt
   li $v0, 4
   syscall  
   
   j ReadFile   

parse_line:
    # Original parse_line subroutine (without the special checks)
    # Initialize temporary variables
    li $s0, 0                # Coefficient of x
    li $s1, 0                # Coefficient of y
    li $s3, 0                # Coefficient of z
    li $s2, 0                # Right-hand side value
    li $t2, 0                # Accumulator for digits
    li $t3, 1                # Sign (1 for positive, -1 for negative)
    li $t4, 0                # Mode (0: coefficient, 3: result)

parse_char:
    lb $t5, 0($t1)           # Load character from buffer
    beqz $t5, parse_done     # If end of buffer, done

    li $t6, '\n'
    beq $t5, $t6, parse_done

    li $t6, ' '
    beq $t5, $t6, next_char
    li $t6, '+'
    beq $t5, $t6, next_char
    li $t6, '-'
    beq $t5, $t6, set_negative

    li $t6, '0'
    li $t7, '9'
    bge $t5, $t6, check_digit
    j handle_non_digit

check_digit:
    ble $t5, $t7, accumulate_digit
    j handle_non_digit

accumulate_digit:
    sub $t5, $t5, $t6        # Convert ASCII to integer
    mul $t2, $t2, 10
    add $t2, $t2, $t5
    j next_char

handle_non_digit:
    li $t6, 'x'
    beq $t5, $t6, store_x

    li $t6, 'y'
    beq $t5, $t6, store_y

    li $t6, 'z'
    beq $t5, $t6, store_z

    li $t6, '='
    beq $t5, $t6, prepare_result
    j parse_done

store_x:
    mul $s0, $t2, $t3       # s0 = coefficient of x
    j reset_temp

store_y:
    mul $s1, $t2, $t3       # s1 = coefficient of y
    j reset_temp

store_z:
    mul $s3, $t2, $t3       # s3 = coefficient of z
    j reset_temp

prepare_result:
    li $t3, 1               # Reset sign to positive
    li $t4, 3               # Set mode to result
    j reset_temp

set_negative:
    li $t3, -1              # Set sign to negative
    j next_char

reset_temp:
    li $t2, 0               # Reset accumulator
    li $t3, 1               # Reset sign to positive
    addi $t1, $t1, 1        # Move to next character
    j parse_char

next_char:
    addi $t1, $t1, 1        # Move to next character
    j parse_char

parse_done:
    # If in result mode, store the accumulated value into s2
    beq $t4, 3, store_result
    # Else, store the last accumulated value into s2 (in case the line ends)
    mul $s2, $t2, $t3
    jr $ra

store_result:
    mul $s2, $t2, $t3
    jr $ra

move_to_next_line:
move_next_char:
    lb $t5, 0($t1)
    beqz $t5, move_end       # If end of buffer, end
    li $t6, '\n'
    beq $t5, $t6, move_end 
    addi $t1, $t1, 1
    j move_next_char
move_end:
    addi $t1, $t1, 1         # Move past the newline character
    jr $ra

calculate_det_A:
   
    mul.s $f12, $f5, $f10    
    mul.s $f13, $f6, $f9      
    sub.s $f12, $f12, $f13    
    mul.s $f12, $f0, $f12    

    mul.s $f16, $f4, $f10     
    mul.s $f17, $f6, $f8     
    sub.s $f17, $f16, $f17   
    mul.s $f17, $f1, $f17    
    neg.s $f17, $f17          

    mul.s $f16, $f4, $f9      
    mul.s $f13, $f5, $f8      
    sub.s $f13, $f16, $f13  
    mul.s $f13, $f2, $f13   

    add.s $f16, $f12, $f17   
    add.s $f25, $f16, $f13    

    jr $ra

calculate_det_A1:
    
    mul.s $f12, $f5, $f10   
    mul.s $f13, $f6, $f9    
    sub.s $f14, $f12, $f13    
    mul.s $f14, $f3, $f14    
    mul.s $f12, $f7, $f10     
    mul.s $f13, $f6, $f11     
    sub.s $f13, $f12, $f13   
    mul.s $f13, $f1, $f13    
    neg.s $f13, $f13        

 
    mul.s $f12, $f7, $f9      
    mul.s $f15, $f5, $f11     
    sub.s $f12, $f12, $f15    
    mul.s $f12, $f2, $f12    

    add.s $f14, $f14, $f13   
    add.s $f24, $f14, $f12    

    jr $ra

calculate_det_A2:
    
    mul.s $f12, $f7, $f10     
    mul.s $f13, $f6, $f11     
    sub.s $f12, $f12, $f13    
    mul.s $f12, $f0, $f12     

    mul.s $f13, $f4, $f10     
    mul.s $f14, $f6, $f8      
    sub.s $f13, $f13, $f14    
    mul.s $f13, $f3, $f13     
    neg.s $f13, $f13          
    mul.s $f14, $f4, $f11     
    mul.s $f15, $f7, $f8      
    sub.s $f14, $f14, $f15   
    mul.s $f14, $f2, $f14   

    
    add.s $f12, $f12, $f13    
    add.s $f23, $f12, $f14    

    jr $ra

calculate_det_A3:
    
    mul.s $f12, $f5, $f11     
    mul.s $f13, $f7, $f9      
    sub.s $f12, $f12, $f13    
    mul.s $f12, $f0, $f12    

    mul.s $f13, $f4, $f11     
    mul.s $f14, $f7, $f8     
    sub.s $f13, $f13, $f14    
    mul.s $f13, $f1, $f13     
    neg.s $f13, $f13          
    mul.s $f14, $f4, $f9      
    mul.s $f15, $f5, $f8     
    sub.s $f14, $f14, $f15  
    mul.s $f14, $f3, $f14   
    add.s $f12, $f12, $f13    
    add.s $f22, $f12, $f14   
    
        # Results of 3x3 
    div.s $f24, $f24, $f25   # x
    div.s $f23, $f23, $f25   # y
    div.s $f22, $f22, $f25   # z
 
######### results


    mul.s $f12, $f26, $f30  
    mul.s $f13, $f29, $f27 
    sub.s $f21, $f12, $f13 
    mul.s $f12, $f28, $f30  
    mul.s $f13, $f31, $f27  
    sub.s $f20, $f12, $f13  
    mul.s $f13, $f26, $f31  
    mul.s $f14, $f29, $f28  
    sub.s $f19, $f13, $f14  
    
    # Results of 2x2
    div.s $f16, $f20, $f21 # x
    div.s $f17, $f19, $f21  # y


    j DisplayMenu            # Continue to menue 
 ####################################################    Menu   ####################################################################
DisplayMenu:
    # Print the Menu choices
    li $v0, 4
    la $a0, Question
    syscall
    
    li $v0, 4
    la $a0, OutputFile
    syscall
    
    li $v0, 4
    la $a0, OnTheScreen
    syscall
     
    li $v0, 4
    la $a0, Exit
    syscall
 
 ## Menu for user choice
    # print to choose
    li $v0, 4
    la $a0, choice
    syscall
 
# Read the user's input
    li $v0, 8           # Syscall to read string
    la $a0, char      # Address of buffer
    li $a1, 2           # Limit input to 2 bytes (1 character + '\0')
    syscall

# Load the first character into a register
    lb $t0, char        # Load first byte of input into $t0
    
    
## Branch based on user input

   # Save results to file     
    li $t1, 'f'    # Compare with 'f' (lowercase)
    beq $t0, $t1, SaveToOutputFile
    li $t1, 'F'    # Save results to file (uppercase)
    beq $t0, $t1, SaveToOutputFile
   
   #Show results on screen
    li $t1, 's'    # Compare with 's'
    beq $t0, $t1, ResultsOnScreen
    li $t1, 'S'    # Compare with 's' (uppercase)
    beq $t0, $t1, ResultsOnScreen

   # Exit system
    li $t1, 'e'         # Compare with 'e'
    beq $t0, $t1, ExitSystem
    li $t1, 'E'         # Compare with 'E'
    beq $t0, $t1, ExitSystem

    # Invalid input
    li $v0, 4
    la $a0, InvalidChoice  #Error Message
    syscall
    j DisplayMenu    # Repeat menu display
    
####################################################    Choices of Menu   ####################################################################  
    
ResultsOnScreen: #Done

    la $a0, Results
    li   $v0, 4
    syscall
    
    la   $a0, result1
    li   $v0, 4
    syscall
    mov.s $f12, $f16
    li   $v0, 2
    syscall


    la   $a0, result2
    li   $v0, 4
    syscall
    mov.s $f12, $f17
    li   $v0, 2
    syscall
    
    ######### results of 3x3
 # Value of X
    li $v0, 4   
    la $a0, result_x
    syscall
    
    mov.s $f12, $f24        
    li $v0, 2                
    syscall

# Value of y
    li $v0, 4                 
    la $a0, result_y
    syscall
    
    mov.s $f12, $f23        
    li $v0, 2                
    syscall

# Value of z
    li $v0, 4               
    la $a0, result_z
    syscall
    
    mov.s $f12, $f22      
    li $v0, 2                
    syscall
   # j end_parse
    
    j DisplayMenu  # Return to the Menu

SaveToOutputFile:  # do it
    
	j SaveToOutFile
	j DisplayMenu  # Return to the Menu
	
ExitSystem:
    # Close the file
    li $v0, 16        # System call for closing file
    move $a0, $s0     # File descriptor
    syscall

    # Exit the program
    li $v0, 10
    syscall
       
####################################################    Save to Output File   ####################################################################  

SaveToOutFile:
    # Open the file
    li $v0, 13              # Syscall to open file
    la $a0, outputFileName  # File path
    li $a1, 1               # Write-only mode
    li $a2, 0               # Default permissions
    syscall

    move $t0, $v0           # Save file descriptor
    bltz $t0, fileopen_error # Handle file open error if $v0 < 0

    # Write header message
    li $v0, 15               # Syscall to write
    move $a0, $t0            # File descriptor
    la $a1, message          # Header message
    li $a2, 20               # Length of the header message
    syscall
    bltz $v0, file_write_error # Handle write error

   

    # Write x = label
    li $v0, 15               # Syscall to write
    move $a0, $t0
    la $a1, result_x         # Label for x
    li $a2, 10               # Length of the label
    syscall
    bltz $v0, file_write_error

    # Write x value
    mov.s $f12, $f24         # Load result for x
    li $v0, 2                # Float to string syscall
    syscall
    la $a1, float_buffer     # Buffer for float
    li $a2, 10               # Length of float buffer
    li $v0, 15               # Write 
    syscall
    bltz $v0, file_write_error

    # Write y = label
    li $v0, 15               # Syscall to write
    move $a0, $t0
    la $a1, result_y         # Label for y
    li $a2, 10               # Length of the label
    syscall
    bltz $v0, file_write_error

    # Write y value
    mov.s $f12, $f23         # Load result for y
    li $v0, 2                # Float to string syscall
    syscall
    la $a1, float_buffer     # Buffer for float
    li $a2, 10               # Length of float buffer
    li $v0, 15               # Write 
    syscall
    bltz $v0, file_write_error

    # Write z = label (only for 3x3 systems)
    li $v0, 15
    move $a0, $t0
    la $a1, result_z         # Label for z
    li $a2, 10
    syscall
    bltz $v0, file_write_error

    # Write z value
    mov.s $f12, $f22         # Load result for z
    li $v0, 2
    syscall
    la $a1, float_buffer
    li $a2, 10
    li $v0, 15
    syscall
    bltz $v0, file_write_error

    # Close the file
    li $v0, 16               # Syscall to close file
    move $a0, $t0          
    syscall

    j DisplayMenu            # Return to menu

fileopen_error:
    li $v0, 4
    la $a0, ErrorOutFile
    syscall
    j DisplayMenu

file_write_error:
    li $v0, 4
    la $a0, ErrorWriting
    syscall
    li $v0, 16
    move $a0, $t0
    syscall
    j DisplayMenu
