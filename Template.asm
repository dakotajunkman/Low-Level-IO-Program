TITLE String Primitives and Marcros     (Proj6_junkmand.asm)

; Author: Dakota Junkman
; Last Modified: 02/28/2021
; OSU email address: junkmand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 3/15/2021
; Description: This program prompts the user to enter 10 signed decimal integers. Each integer must fit in to a 32 bit
;              register. The program accepts the integers as strings and converts to signed integers for data validation. 
;              It displays the numbers to the user as strings, then displays the sum and rounded average to the user. 
;              It then says goodbye to the user. 

INCLUDE Irvine32.inc

mGetString  MACRO   direction, memLoc, maxLength, amtRead
    
    ; preserve registers
    push    EDX
    push    ECX
    push    EAX

    ; prompt user to enter a number
    mov     EDX, direction
    call    WriteString

    ; get number from the user
    mov     EDX, memLoc
    mov     ECX, maxLength
    call    ReadString

    ; store bytes read in memory
    mov     amtRead, EAX

    ; preserve registers
    pop     EAX
    pop     ECX
    pop     EDX

ENDM

INTS_TO_READ = 10
MAXSTRING = 11

.data

    ; Strings
    titleAndName    BYTE    "A Low-Level I/O Program by Dakota Junkman",13,10,13,10,0
    directions      BYTE    "Please enter 10 signed decimal integers.",13,10,0
    explanation     BYTE    "The number must fit in a 32 bit register. Once you have entered in 10 numbers I will",13,10
                    BYTE    "display the numbers, their sum, and their rounded average.",13,10,13,10,0
    askForNumber    BYTE    "Please enter a signed integer: ",0
    goodbye         BYTE    "Thanks for using the program! Goodbye!",13,10,0

    ; Arrays
    inputString     BYTE    11 DUP(0)
    numberArray     SDWORD  INTS_TO_READ DUP(?)

    ; numbers
    bytesRead       DWORD   0

.code
main PROC

    push    OFFSET titleAndName
    push    OFFSET directions
    push    OFFSET explanation
    call    intro

    

    push    OFFSET goodbye
    call    farewell



    Invoke ExitProcess,0	; exit to operating system
main ENDP

intro       PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EDX

    ; display title and directions to the user
    mov     EDX, [EBP+16]
    call    WriteString
    mov     EDX, [EBP+12]
    call    WriteString
    mov     EDX, [EBP+8]
    call    WriteString

    ; restore registers and return to calling procedure
    pop     EDX
    pop     EBP
    ret     12
intro       ENDP

readVal     PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP





    pop     EBP
    ret
readVal     ENDP

writeVal    PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP




    pop     EBP
    ret
writeVal    ENDP

farewell    PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EDX

    ; display farewell message to user
    mov     EDX, [EBP+8]
    call    WriteString

    ; restore registers and return to calling procedure
    pop     EDX
    pop     EBP
    ret     4
farewell    ENDP




END main
