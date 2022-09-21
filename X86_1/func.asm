;=====================================================================
; ECOAR - example page 12 5f Intel x86 assembly program
;
; Author:      Hasan Senyurt
; Date:        2022-05-10
; Description: Write function remove which removes from the source string every character before the first occurrence of left
;              square bracket ([) and after the first following it occurrence of right square bracket (]). remove returns the
;              length of the resulting string.
;
; Notes:       Dear sir, I asked you should I use scanf function in the lab. You've said that it is not necessary because it causes
;              some problem (problem was about spaces between word.). So, input comes directly from main.cpp file. You can change
;              input in .cpp file.
;=====================================================================


section .text
global func

func:
        push ebp
        mov ebp, esp
        mov esi, DWORD [ebp+8]  ;address of string
        xor edi, edi            ;value for length of new string
        mov edx, 0              ;control value for square brackets detection


loop:
        mov bl,[esi]            ;while(*string!='\0')
        cmp bl,0
        je exit

        cmp bl,'['              ;checking for '['
        je control              ;makes control value 1 to start printing [***]
        cmp bl, ']'             ;checking for ']'
        je control2
        cmp edx, 1              ;If control value is 1, then it starts to print inside of square brackets.
        je copy

        inc esi                 ;increase address of string
        jmp loop

control:
        mov edx, 1              ;control value=1
        jmp copy                ;starts printing

control2:
        cmp edx, 1      ;if control is 1, exit loop = it means square bracket opened before and closed now. -> exit
        je exit

        mov edx, 0      ;control=0
        inc esi         ;address++
        jmp loop

copy:
        mov eax, 4      ; sys_write()
        mov ebx, 1      ; ... to STDOUT
        mov ecx, esi    ; ... using the following memory address
        mov edx, 1      ; ... and only print one character
        int 80h         ; SYSCALL

        inc edi         ;count++
        inc esi         ;address++
        jmp loop


exit:
        mov eax, 4      ; sys_write()
        mov ebx, 1      ; ... to STDOUT
        mov ecx, esi    ; ... using the following memory address
        mov edx, 1      ; ... and only print one character
        int 80h         ; SYSCALL

        inc edi         ;count++
        mov eax, edi    ;length of the string as return value
        pop ebp
        ret
