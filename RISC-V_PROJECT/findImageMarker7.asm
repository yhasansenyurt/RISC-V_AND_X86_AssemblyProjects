#-------------------------------------------------------------------------------
#author: Hasan Senyurt
#date : 2021.05.31
#description : The input BMP image (24-bit RGB) contains markers. The image may
#	       contain other elements. The task is to detect all markers of given type. 
#	       Project No: 3.22 - Marker 7
#-------------------------------------------------------------------------------


#only 24-bits 320x240 pixels BMP files are supported
.eqv BMP_FILE_SIZE 230454
.eqv BYTES_PER_ROW 960 

	.data
#space for the 320x240px 24-bits bmp image
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE

msg1:	.asciz ","
msg2:	.asciz ").\n"
msg3:	.asciz "The marker 7 is found in ("

fileError:	.asciz "File cannot be opened."
fileSuccess:	.asciz "File is opened succesfully.\n"
formatError:	.asciz "File format is not supported."
sizeError:	.asciz "Size of the input image is not correct. It must be 320x240."

fname:	.asciz "source.bmp"
	.text
main:
	jal	read_bmp

	li 	a4,0 		#x
	li 	a3,-1 		#y
	li	s10,320		#max x
	li	s11,240		#max y
	li	s9, 0x00000000	#black color
	li	s8,0		#x
			
loop:
	addi	a3,a3,1		#y++
	li	a4,0		#x=0
	bne 	a3,s11,loop2	#if y!=240
	beq	a3,s11,exit	#if y==240
			
loop2:
	li	s5,0		#height
	li	s4,0		#width
	li	a5,0		#upper_right
	li	a7,0		#right_upper
	
	beq 	a4,s10,loop	#if x==320
	
	mv	a0,a4		#x
	mv	a1,a3		#y
	jal     get_pixel
	mv 	a6, a0          #color will be stored in a6 register.	    	
	
	beq	a6,s9,detected_black	#black color detect.
	
	addi	a4,a4,1		#column++
	j	loop2

detected_black:
	mv	s8,a4		#s8=x
	addi	s8,s8,-1	#s8--
	
	mv	a0,s8		#get color
	mv	a1,a3
	jal	get_pixel
	mv	s8,a0
	
	bne	s8,s9,detected_left	#checking (x-1) is not black. (to find corner of marker.)
	
	addi	a4,a4,1		#column++
	j	loop2

detected_left:
	mv	s8,a4
	addi	s8,s8,+1	#x++
	
	mv	a0,s8		#get color
	mv	a1,a3
	jal	get_pixel
	mv	s8,a0
	
	beq	s8,s9,detected_right	#checking (x+1) is black. (to find corner of marker.)
	addi	a4,a4,1		#column++
	j	loop2
	
detected_right:
	mv	s8,a3
	addi	s8,s8,-1	#y--
	
	mv	a0,a4		#get color
	mv	a1,s8
	jal	get_pixel	
	mv	s8,a0
	
	bne	s8,s9,detected_down	#checking (y-1) is not black. (to find corner of marker.)
	addi	a4,a4,1		#column++
	j	loop2
	
detected_down:
	mv	s8,a3
	addi	s8,s8,+1	#y++
	
	mv	a0,a4		#get color
	mv	a1,s8
	jal	get_pixel	
	mv	s8,a0
	
	beq	s8,s9,detected_up		#checking (y+1) is black. (to find corner of marker.)
	addi	a4,a4,1		#column++
	j	loop2
	
detected_up:
	#then it is a corner. Now we have to calculate width, height and some lines to be sure that it is
	#marker 7.
	mv	s7,a4		#s7=x (corner point)
	mv	s6,a3		#s6=y (corner point)
	j	count_height

count_height:

	mv	a0,s7
	mv	a1,s6
	jal	get_pixel
	mv	s8,a0			#get color
	
	bne	s8,s9,y_minus_one	#calculating height, if the pixel is not black then we will ...
					#calculate right side of the point that is the top of the height.
					#to compare the right up side of width.
					
	addi	s5,s5,1			#height++
	addi	s6,s6,1			#y++
	
	j	count_height
	
y_minus_one:
	#coming back to top point of the height.
	addi	s6,s6,-1
	mv	s7,a4
	j	count_upper_right

count_upper_right:
	
	mv	a0,s7
	mv	a1,s6
	jal	get_pixel
	mv	s8,a0		#get color
	
	bne	s8,s9,back_to_position	#after calculation, we have to go back the marker position (corner of arm intersection.)
	
	addi	a5,a5,1		#upper right side of the height++
	addi	s7,s7,1		#x++
	
	j	count_upper_right
	
back_to_position:
	#back to corner.
	mv	s7,a4
	mv	s6,a3
	j	count_width	
	
count_width:
	mv	s6,a3		#s6=y
	
	mv	a0,s7
	mv	a1,s6
	jal	get_pixel
	mv	s8,a0		#get color
	
	bne	s8,s9,calculate_width_height	#after calculation, now we have to measure W/H.
	
	addi	s4,s4,1		#width++
	addi	s7,s7,1		#x++
	
	j	count_width
		
calculate_width_height:
	li	s3,2
	mul	s5,s5,s3	#height = height *2
  	
	beq	s5,s4,x_minus_one	#if width = 2*height (marker 7 condition), going to calculate right upper
					#side of width.
					
	addi	a4,a4,1		#column++
	j	loop2

x_minus_one:
	addi	s7,s7,-1	#x--
	mv	s6,a3
	j	count_right_upper
		
count_right_upper:
	
	mv	a0,s7
	mv	a1,s6
	jal	get_pixel
	mv	s8,a0		#get color
	
	bne	s8,s9,check_sides	#going to check if right upper side of width and upper right side of
					#height is the same.(one of the marker 7 condition.)
	
	addi	a7,a7,1		#right upper side of width++
	addi	s6,s6,1		#y++
	
	j	count_right_upper
	
check_sides:
	beq	a5,a7,found	#if right upper = upper right, then other condition is ok. We found marker 7.
	addi	a4,a4,1		#column++
	j	loop2
	
found:
	li	t6,239		#making the Y = 0 on upper left corner.
	sub	s6,t6,a3
	
	li 	a7, 4		#system call for print_string
    	la 	a0, msg3	
    	ecall
    	
    	li a7, 1		#system call for print_int
    	mv a0,a4 		#height
    	ecall
    	
    	li 	a7, 4		#system call for print_string
    	la 	a0, msg1	
    	ecall
    	
    	li a7, 1		#system call for print_int
    	mv a0,s6 		#width
    	ecall
    	
    	li 	a7, 4		#system call for print_string
    	la 	a0, msg2	
    	ecall
    	
    	addi	a4,a4,1		#column++
    	j	loop2
    		
exit:	    	
	li 	a7,10		#Terminate the program
	ecall
	

file_error:
	
	li 	a7, 4		#system call for print_string
    	la 	a0, fileError	
    	ecall
    	
    	j exit
    	
format_error:
	li 	a7, 4		#system call for print_string
    	la 	a0, formatError	
    	ecall
    	
    	j exit
    	
size_error:
	li 	a7, 4		#system call for print_string
    	la 	a0, sizeError	
    	ecall
    	
    	j exit
    	
    	
# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
	
		
#ERROR CHECK: checking if the file is opened correctly or not.	
	li t5,-1 	#if file descriptor == -1, then it gives an error.
	beq s1,t5,file_error
	
	li a7, 4		#system call for print_string
    	la a0, fileSuccess	
    	ecall
	
#read file
	li a7, 63
	mv a0, s1		#the file descriptor
	la a1, image		#Address of the space to copy the file header (address of the buffer)
	li a2, BMP_FILE_SIZE 	#no of the bits (max length)
	ecall
	
#ERROR CHECK: checking the format of the file. bmp header must be '42 4D'.
	
	la	t0, image	
	lb	t1, 0(t0)	#first byte of bmp file must be 42
	lb	t2, 1(t0)	#second byte of bmp file must be 4D
	
	li	s7,0x42
	li	s8,0x4D
	
	bne	t1,s7,format_error
	bne	t2,s8,format_error

#ERROR CHECK: size checking, it must be 320x240. ( 00 00 01 40 x 00 00 00 F0)
	lw	t1, 18(t0)	#effective memory address to t1 and t2.
	lw	t2, 22(t0)

	li	s7, 0x00000140
	li	s8, 0x000000F0
    	
    	bne	t1,s7,size_error
    	bne	t2,s8,size_error	
	
#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra

get_pixel:
#description: 
#	returns color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - 0RGB - pixel color

	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1		#pixel address 
	
	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1
					
	jr ra

# ============================================================================