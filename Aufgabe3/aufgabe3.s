# v171215

#########################################
# Vorgabe: read_email
#########################################
# $a0: buffer
# $v0: number of characters read

read_email:
    move $t0, $a0

    # read mail from disk
    li $v0, 13
    la $a0, input_file
    li $a1, 0
    li $a2, 0
    syscall

    # save fd
    move $t1, $v0

    # read to buffer
    li $v0, 14
    move $a0, $t1
    move $a1, $t0 # address of buffer
    li $a2, 4096
    syscall

    move $t0, $v0

    # close file
    li $v0, 16
    move $a0, $t1 # fd
    syscall

    move $v0, $t0

    jr $ra

#########################################
# Vorgabe: write_email
#########################################
# $a0: buffer
# $a1: number of characters to write
# $a2: truncate file

write_email:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s0, $a0
    move $s1, $a1

    # open file
    li $v0, 13
    la $a0, output_file

    bne $zero, $a2, write_email_trunc
    j write_email_notrunc
    write_email_trunc:
    li $a1, 0x241       # mode O_WRONLY | O_CREAT | O_TRUNC
    j write_email_else

    write_email_notrunc:
    li $a1, 0x441       # mode O_WRONLY | O_CREAT | O_APPEND

    write_email_else:
    li $a2, 0x1a4
    syscall             # fd in $v0

    move $s2, $v0       # save fd

    li $v0, 15          # write to file
    move $a0, $s2
    move $a1, $s0
    move $a2, $s1
    syscall

    # close file
    li $v0, 16
    move $a0, $s2
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra


#########################################
# Aufgabe 3: Ausgabe
#########################################
# a0: buffer
# a1: buffer length
# a2: relative position of subject
# a3: spam flag

print_email:
	addi 	$sp, $sp, -12		
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)

	move 	$s0, $a1		#$s0 = length of email
	move	$s1, $a2 		#$s1 = pos of subject

	li	$t5, 1			#$t5 = 1
	beq 	$a3, $t5, write_spam	#goto write_spam if spamflag set

	add 	$a2, $zero, $zero	#$a2 = truncate = false
	jal 	write_email
	j	end

write_spam:
	la 	$a0, email_buffer	#$a0 = address of email
	add	$a1, $zero, $s1		#$a1 = len until subject
	add 	$a2, $zero, $zero	#$a2 = truncate = false
	jal	write_email		#write upto subject

	la	$a0, spam_flag		#$a0 = address of spamflag
	lw	$a1, spam_flag_length	#$a1 = length of spamflag
	add 	$a2, $zero, $zero	#$a2 = truncate = false
	jal	write_email		#write from subject to spamflag end

	sub	$s0, $s0, $s1		#$s0 = length after subject

	la	$a0, email_buffer	#$a0 = address of email
	add	$a0, $a0, $s1		#$a0 = address of email + pos of subject
	move	$a1, $s0		#$a1 = length after subject
	add 	$a2, $zero, $zero	#$a2 = truncate=false
	jal	write_email
	
end:
	lw 	$ra, 0($sp)		
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	addi 	$sp, $sp, 12

	jr 	$ra

#########################################
#

#
# data
#

.data

input_file: .asciiz "/home/ashiven/Documents/Programmieren/Projects/Assembler/Hausaufgabe-20180110/email1"
output_file: .asciiz "/home/ashiven/Documents/Programmieren/Projects/Assembler/Hausaufgabe-20180110/output"
email_buffer: .space 4096

spam_flag: .asciiz "[SPAM] "
spam_flag_length: .word 7

#
# main
#

.text
.globl main

main:
    # Register sichern
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # E-Mail einlesen
    la $a0, email_buffer
    jal read_email

    la $a0, email_buffer

    # Groesse
    move $a1, $v0

    # Position des Subjekts
    li $a2, 292

    # Spam
    li $a3, 1

    # E-Mail ausgeben
    jal print_email

    # Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#
# end main
#
