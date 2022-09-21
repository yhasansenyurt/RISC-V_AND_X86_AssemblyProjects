#-------------------------------------------------------------------------------
#author       : Hasan Senyurt
#date         : 26-04-2022
#description  : RISC-V - Lab task page 12 5f 
#-------------------------------------------------------------------------------

	.data #global vars.
input:	.space 80
result: .space 80
prompt:	.asciz "\nSource > "
msg1:	.asciz "\nReults > "
msg2:	.asciz "\nReturn Value: "

	.text #program instructions
# ============================================================================
main:
#display the input prompt
    li a7, 4		#system call for print_string, li= load immediate, loads 4 to a7 system call number 4!!! print string
    la a0, prompt	#address of string, la= load address, first bit of promp to a0. 
    ecall	 	# os function. to system call

#read the input string
    li a7, 8		#system call for read_string; system call number 8!!! Read string
    la a0, input	#address of buffer    
    li a1, 80		#max length of string.
    #.......	    #max length
    ecall

#modify your string here
#...

#int control = 0 -> t1
#string=input -> t2
#string=new -> t4
#while(*string != '\0') {
#	if(*string == '[')
#	   control =1
#       
#       if control    copy string
#
#
#       if *string == ']'   control =0;
#
#       
#}
#
    li a5,0
    li t1, 0 #control
    li a7,1
    la t2, input #string first bit of #src pointer           src
    la t5, result # new string
    li t0, '['
    li t6, ']'
    
loop:
    lbu t3, (t2) #*t2
    beqz t3, loop_exit #if t3 is eq 0, exit loop.
    beq t3,t0, control #checks '['
    beq t3,t6, control2 # checks ']'
    beq t1,a7,copy  #copy inside of square brackets
    addi t2,t2,1 # t2=t2+1 (address)
    j loop

    
control:
    li t1,1
    j copy

control2:
    beq t1,a7,loop_exit #if control is 1, then exit loop -> []
    li t1,0    
    addi t2,t2,1 # t2=t2+1 (address)
    j loop
    
                
copy:
    addi a5,a5,1
    lb t4,(t2)
    sb t4,(t5)
    
    addi t2,t2,1 # t2=t2+1 (address)
    addi t5,t5,1 # t2=t2+1 (address)
    j loop
    
loop_exit:
    
    sb t6,(t5)
    addi a5,a5,1
#display the output prompt and the string
    li a7, 4		#system call for print_string
    la a0, msg1		#address of string 
    ecall
    
    li a7, 4		#system call for print_string
    la a0, result	#address of string 
    ecall
    
    li a7, 4		#system call for print_string
    la a0, msg2	#address of string 
    ecall
    
    li a7, 1
    mv a0,a5
    ecall 
    

exit:	
    li 	a7,10	#Terminate the program
    ecall
	
# ============================================================================
#end of file	
