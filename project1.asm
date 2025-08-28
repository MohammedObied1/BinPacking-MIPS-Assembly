# project one Bin Packing Problem Solution Using MIPS Assembly
# mohammed obied 1210093
# mostafa rimawi 1220084
.data
input: .asciiz "C:\\Users\\moham\\OneDrive\\Desktop\\ark\\in.txt"
output: .asciiz "C:\\Users\\moham\\OneDrive\\Desktop\\ark\\out.txt"
newline: .asciiz "\n"
Content: .space 2048
errorMsg: .asciiz "Error opening file.\n"
invalidCharMsg: .asciiz "Error: Invalid character found in file!\n"
outOfRangeMsg: .asciiz "Error: Item size out of range\n"
totalBinsMsg: .asciiz "\nTotal number of bins needed: "
fileNewline: .asciiz "\n"
intBuffer: .space 8      
numBuffer:      .space 16
numBufferEnd:   .space 1
ascii_zero: .byte '0'
dot_char: .byte '.'
outputFD: .word 0
menu:       .asciiz "\n=== Main Menu ===\n1. First Fit \n2. Best Fit \n3. Exit\nEnter your choice: "
invalid:    .asciiz "\nInvalid choice. Please try again.\n"
output_name:  .asciiz "C:\\Users\\moham\\OneDrive\\Desktop\\ark\\out.txt"  # Path to output file
space:      .asciiz " "
bin_msg:    .asciiz "Bin "
bin_content: .asciiz " contains: "
float_zero: .float 0.0
float_one:  .float 1.0


item_count: .word 100
num_bins:   .word 0
.align 2
items: .space 400    
.align 2
bins: .space 400     
binCount: .word 0     
itemToBin: .space 100 


.text
.globl main
main:
    # Open file in read mode
    li $v0, 13
    la $a0, input           # Address of the input file name
    li $a1, 0               # Flags = read
    li $a2, 0               # Mode = default
    syscall
    bltz $v0, file_error    # If file couldn't be opened, jump to error
    move $s6, $v0           # Save file descriptor

    # Read contents of file
    li $v0, 14
    move $a0, $s6
    la $a1, Content         # Buffer to store file content
    li $a2, 1024            # Number of bytes to read
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s6
    syscall

    # Initialize pointers and flags
    la $t1, Content
    li $t9, 0               # first digit seen flag
    li $t8, 0               # dot seen flag

validate:
    lb $t2, 0($t1)          # Load next character
    beqz $t2, finalInsert   # If null terminator, end of validation

    # Skip newline, carriage return, and space characters
    li $t3, '\n'
    beq $t2, $t3, insertDot
    li $t3, '\r'
    beq $t2, $t3, insertDot
    li $t3, ' '
    beq $t2, $t3, insertDot

    beqz $t9, firstChar     # If no first char yet, validate first char

    # Check for dot or digit
    li $t3, '.'
    beq $t2, $t3, checkDot

    # Validate digit
    li $t3, '0'
    li $t4, '9'
    blt $t2, $t3, invalidChar
    bgt $t2, $t4, invalidChar
    j continueChar

firstChar:
    # First char must be 0 or 1
    li $t3, '0'
    li $t4, '1'
    li $t5, '9'
    blt $t2, $t3, invalidChar
    bgt $t2, $t5, invalidChar
    bgt $t2, $t4, outRange
    beq $t2, $t3, firsZero
    beq $t2, $t4, firstOne
    j invalidChar

firsZero:
    li $t9, 1
    lb $t5, 1($t1)
    li $t6, '\n'
    beq $t5, $t6, dotZero
    li $t6, '\r'
    beq $t5, $t6, dotZero
    li $t6, ' '
    beq $t5, $t6, dotZero
    beqz $t5, dotZero
    j continueChar

firstOne:
    li $t9, 1
    lb $t5, 1($t1)
    li $t6, '\n'
    beq $t5, $t6, dotZero
    li $t6, '\r'
    beq $t5, $t6, dotZero
    li $t6, ' '
    beq $t5, $t6, dotZero
    beqz $t5, dotZero
    j outRange

insertDot:
    # Reset flags after reaching separator
    beqz $t9, skipDot
    beqz $t8, dotZero
    li $t9, 0
    li $t8, 0
    addi $t1, $t1, 1
    j validate

skipDot:
    li $t9, 0
    li $t8, 0
    addi $t1, $t1, 1
    j validate

finalInsert:
    beqz $t9, validateDone
    beqz $t8, dotZero
    j validateDone

dotZero:
    # Append ".0" if only whole number found
    lb $t5, 1($t1)        
    beqz $t5, FinalChars

    move $t2, $t1
    li $t3, 0
countRemaining:
    lb $t4, 0($t2)
    beqz $t4, doneCount
    addi $t2, $t2, 1
    addi $t3, $t3, 1
    j countRemaining

doneCount:
    addi $t2, $t2, 2
shifBack:
    beqz $t3, insertChars
    addi $t2, $t2, -1
    lb $t4, -2($t2)
    sb $t4, 0($t2)
    addi $t3, $t3, -1
    j shifBack

insertChars:
    li $t4, '.'
    sb $t4, 1($t1)
    li $t4, '0'
    sb $t4, 2($t1)
    li $t9, 0
    li $t8, 0
    addi $t1, $t1, 3
    j validate

FinalChars:
    # Insert ".0" at the end of string
    li $t4, '.'
    sb $t4, 1($t1)
    li $t4, '0'
    sb $t4, 2($t1)
    li $t9, 0
    li $t8, 0
    j validateDone

checkDot:
    beqz $t8, dotSeen
    j invalidChar

dotSeen:
    li $t8, 1
    j continueChar

continueChar:
    addi $t1, $t1, 1
    j validate

invalidChar:
    # Print invalid char message and exit
    li $v0, 4
    la $a0, invalidCharMsg
    syscall
    j exit

outRange:
    # Print out of range message and exit
    li $v0, 4
    la $a0, outOfRangeMsg
    syscall
    j exit

validateDone:
    # Print validated content
    li $v0, 4           
    la $a0, Content      
    syscall 

    # Parse validated content into float array
    la $t1, Content    
    la $t2, items          
    li $s0, 0               

parseLoop:
    lb $t0, 0($t1)
    beqz $t0, parseDone

    li $t3, '\n'
    beq $t0, $t3, char
    li $t3, '\r'
    beq $t0, $t3, char
    li $t3, ' '
    beq $t0, $t3, char

    move $a0, $t1
    li $t6, 0               # Integer value accumulator

copyIntValue:
    lb $t1, 0($a0)
    addiu $a0, $a0, 1
    li $t3, '.'
    beq $t1, $t3, doneCopyIntValue
    subiu $t1, $t1, 48
    mul $t6, $t6, 10
    addu $t6, $t6, $t1
    j copyIntValue

doneCopyIntValue:
    # Setup for float fraction
    li $t5, 10
    mtc1 $t5, $f3
    cvt.s.w $f3, $f3

    li $t8, 0
    mtc1 $t8, $f2
    cvt.s.w $f2, $f2

copyFloatValue:
    lb $t1, 0($a0)
    beqz $t1, doneCopyFloatValue
    addiu $a0, $a0, 1
    li $t3, '\n'
    beq $t1, $t3, doneCopyFloatValue
    li $t3, '\r'
    beq $t1, $t3, doneCopyFloatValue
    li $t3, ' '
    beq $t1, $t3, doneCopyFloatValue
    subiu $t1, $t1, 48
    mtc1 $t1, $f1
    cvt.s.w $f1, $f1
    div.s $f1, $f1, $f3
    add.s $f2, $f2, $f1
    li $t4, 10
    mtc1 $t4, $f0
    cvt.s.w $f0, $f0
    mul.s $f3, $f3, $f0
    j copyFloatValue

doneCopyFloatValue:
    mtc1 $t6, $f1
    cvt.s.w $f1, $f1
    add.s $f4, $f1, $f2
    swc1 $f4, 0($t2)
    addi $t2, $t2, 4
    addi $s0, $s0, 1
    j scanNext

char:
    addi $t1, $t1, 1
    j parseLoop

scanNext:
    lb $t0, 0($a0)
    beqz $t0, parseDone
    li $t3, '\n'
    beq $t0, $t3, step
    li $t3, '\r'
    beq $t0, $t3, step
    li $t3, ' '
    beq $t0, $t3, step
    j scanNext

step:
    addiu $a0, $a0, 1
    move $t1, $a0
    j parseLoop

parseDone:
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Print number of float items
    move $a0, $s0
    li $v0, 1
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Print all float items one by one
    la $t2, items
    move $t3, $s0

printitems:
    beqz $t3, mainLoop
    lwc1 $f12, 0($t2)
    li $v0, 2
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t2, $t2, 4
    addi $t3, $t3, -1
    j printitems


mainLoop:
    li $v0, 4
    la $a0, menu          # Print menu prompt
    syscall

    li $v0, 5
    syscall               # Read user input (menu choice)
    move $t0, $v0         # Store input in $t0

    li $t1, 1
    beq $t0, $t1, option_one  # If input is 1, go to First Fit

    li $t1, 2
    beq $t0, $t1, option_two  # If input is 2, go to Best Fit

    li $t1, 3
    beq $t0, $t1, exit        # If input is 3, exit

    li $v0, 4
    la $a0, invalid       # If invalid input, print error message
    syscall
    j mainLoop            # Return to main menu

# First Fit Implementation 
option_one:
    la $t0, items         # Address of items array
    lw $t1, item_count    # Total number of items
    li $t2, 0             # Item index
    li $s1, 0             # Number of bins used
    li $s2, 0             # Address of first bin block (initially 0)

    # Open output file for writing
    li $v0, 13
    la $a0, output_name
    li $a1, 577
    li $a2, 0666
    syscall
    move $t9, $v0         # File descriptor

item_loop:
    beq $t2, $t1, done_ff     # Loop until all items are packed
    sll $t3, $t2, 2
    add $t4, $t0, $t3
    l.s $f4, 0($t4)           # Load current float item

    li $t5, 0                 # Bin index
    li $t6, 0                 # Fit flag

try_bins:
    bge $t5, $s1, check_new_bin  # If no fit found, create new bin

    sll $t7, $t5, 2
    add $t8, $s2, $t7
    l.s $f6, 0($t8)           # Load current bin value
    add.s $f8, $f6, $f4       # Try placing item in bin
    l.s $f10, float_one
    c.le.s $f8, $f10          # Check if sum <= 1.0
    bc1f next_bin

    s.s $f8, 0($t8)           # Store updated bin
    li $t6, 1                 # Mark item as placed
    j item_done

next_bin:
    addi $t5, $t5, 1
    j try_bins

check_new_bin:
    beq $t6, 1, item_done     # If already placed, skip

    # Allocate memory for new bin
    li $v0, 9
    li $a0, 4
    syscall
    move $t8, $v0

    s.s $f4, 0($t8)           # Store item in new bin
    addi $s1, $s1, 1          # Increment bin count

    beqz $s2, store_first_bin
    j item_done

store_first_bin:
    move $s2, $t8             # Save base address of bins

item_done:
    addi $t2, $t2, 1
    j item_loop

done_ff:
    # Display total number of bins used
    li $v0, 4
    la $a0, bin_msg
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $t5, 0
print_bins:
    bge $t5, $s1, exit1       # Print each bin value
    sll $t7, $t5, 2
    add $t8, $s2, $t7
    l.s $f6, 0($t8)

    li $v0, 4
    la $a0, bin_msg
    syscall
    li $v0, 1
    move $a0, $t5
    syscall

    li $v0, 4
    la $a0, bin_content
    syscall

    li $v0, 2
    mov.s $f12, $f6
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t5, $t5, 1
    j print_bins

exit1:
    move $s0, $t5         # Store total bins for file writing
    jal write_output_file
    j mainLoop

#  Best Fit Implementation 
option_two:
    la $t0, items
    lw $t1, item_count
    li $t2, 0
    li $s1, 0
    li $s2, 0

    # Open output file
    li $v0, 13
    la $a0, output_name
    li $a1, 577
    li $a2, 0666
    syscall
    move $t9, $v0

item_loop1:
    beq $t2, $t1, done_bf
    sll $t3, $t2, 2
    add $t4, $t0, $t3
    l.s $f4, 0($t4)       # Load current item

    li $t5, 0
    li $t7, -1            # Best fit bin index
    la $t6, float_one
    l.s $f16, 0($t6)      # Best remaining space initialized to 1.0

best_fit_search1:
    bge $t5, $s1, check_new_bin1

    sll $t8, $t5, 2
    add $t9, $s2, $t8
    l.s $f6, 0($t9)
    add.s $f8, $f6, $f4
    la $t6, float_one
    l.s $f10, 0($t6)
    c.le.s $f8, $f10
    bc1f next_bin1

    sub.s $f18, $f10, $f8
    c.lt.s $f18, $f16
    bc1f next_bin1

    move $t7, $t5
    mov.s $f16, $f18

next_bin1:
    addi $t5, $t5, 1
    j best_fit_search1

check_new_bin1:
    bgez $t7, place_in_best_bin

    li $v0, 9
    li $a0, 4
    syscall
    move $t8, $v0
    s.s $f4, 0($t8)
    addi $s1, $s1, 1

    beqz $s2, store_first_bin1
    j item_done1

store_first_bin1:
    move $s2, $t8
    j item_done1

place_in_best_bin:
    sll $t8, $t7, 2
    add $t9, $s2, $t8
    l.s $f6, 0($t9)
    add.s $f8, $f6, $f4
    s.s $f8, 0($t9)

item_done1:
    addi $t2, $t2, 1
    j item_loop1

done_bf:
    li $v0, 4
    la $a0, bin_msg
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $t5, 0
print_bins1:
    bge $t5, $s1, exit2
    sll $t7, $t5, 2
    add $t8, $s2, $t7
    l.s $f6, 0($t8)

    li $v0, 4
    la $a0, bin_msg
    syscall
    li $v0, 1
    move $a0, $t5
    syscall

    li $v0, 4
    la $a0, bin_content
    syscall

    li $v0, 2
    mov.s $f12, $f6
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t5, $t5, 1
    j print_bins1

exit2:
    move $s0, $t5
    jal write_output_file
    j mainLoop

write_output_file:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Open the output file for writing
    li $v0, 13
    la $a0, output         # File name
    li $a1, 9              # Flags: write and create
    li $a2, 0              # Mode: ignored
    syscall
    move $s7, $v0          # Save file descriptor
    sw $s7, outputFD       # Store in memory

    # Write the "Total bins: " message to the file
    li $v0, 15
    move $a0, $s7
    la $a1, totalBinsMsg
    li $a2, 28             # Length of the message
    syscall

    # Convert number of bins (in $s0) to string and store in numBuffer
    move $a0, $s0
    la $a1, numBuffer
    jal int_to_string

    # Write the number of bins as a string to the file
    li $v0, 15
    move $a0, $s7
    la $a1, numBuffer
    move $a2, $t0          # Length of string in $t0
    syscall

    # Write a newline to the file
    li $v0, 15
    move $a0, $s7
    la $a1, fileNewline
    li $a2, 1              # One character newline
    syscall

    # Reset pointers for additional writing (if needed)
    li $t0, 0
    move $t1, $s2

close_output_file:
    # Close the output file
    li $v0, 16
    move $a0, $s7
    syscall

    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Converts integer in $a0 to null-terminated string at address $a1
int_to_string:
    li $t0, 0              # Character count
    la $t1, numBufferEnd   # Start from end of buffer

    # Special case for zero
    beqz $a0, zero_case

convert_loop:
    beqz $a0, end_convert  # Exit loop when $a0 is zero
    li $t2, 10
    div $a0, $t2
    mflo $a0               # Quotient
    mfhi $t2               # Remainder
    addi $t2, $t2, 48      # Convert digit to ASCII
    sb $t2, 0($t1)
    addi $t1, $t1, -1
    addi $t0, $t0, 1
    j convert_loop

zero_case:
    li $t2, 48             # ASCII for '0'
    sb $t2, 0($t1)
    li $t0, 1
    j end_convert

end_convert:
    addi $t1, $t1, 1       # Move pointer to start of digits
    move $t3, $a1          # Destination buffer
    move $t4, $t0          # Number of characters to copy

copy_loop:
    beqz $t4, done_copy
    lb $t2, 0($t1)
    sb $t2, 0($t3)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    addi $t4, $t4, -1
    j copy_loop

done_copy:
    sb $zero, 0($t3)       # Null terminator
    jr $ra                 # Return

# Displays error message and exits the program
file_error:
    li $v0, 4
    la $a0, errorMsg
    syscall
    j exit

exit:
    li $v0, 10             # Exit syscall
    syscall
