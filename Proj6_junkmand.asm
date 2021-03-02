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
;---------------------------------------------------------
; Name: mGetString
;
; Prompts user to enter a signed integer
; Uses Irvine's ReadString procedure to gather the number
; Number is stored in memory as a string
; Number of bytes read is also stored in memory
;
; Preconditions: Do not use EAX, EBX, ECX, EDX as arguments
;
; Receives:
;   direction: address of string prompt to display to user
;   memLoc: memory address where string will be written
;   maxLength: max number of bytes to read
;   amtRead: memory location to store actual bytes read
;
; returns: Number string and bytes read are stored in memory
;---------------------------------------------------------
mGetString  MACRO   direction, memLoc, maxLength, amtRead
    
    ; preserve registers
    push    EDX
    push    ECX
    push    EAX
    push    EBX

    ; prompt user to enter a number
    mov     EDX, direction
    call    WriteString

    ; get number from the user
    mov     EDX, memLoc
    mov     ECX, maxLength
    call    ReadString

    ; store bytes read in memory
    mov     EBX, amtRead
    mov     [EBX], EAX

    ; preserve registers
    pop     EBX
    pop     EAX
    pop     ECX
    pop     EDX

ENDM

INTS_TO_READ = 10
MAXSTRING = 32

.data

    ; Strings
    titleAndName    BYTE    "A Low-Level I/O Program by Dakota Junkman",13,10,13,10,0
    directions      BYTE    "Please enter 10 signed decimal integers.",13,10,0
    explanation     BYTE    "The number must fit in a 32 bit register. Once you have entered in 10 numbers I will",13,10
                    BYTE    "display the numbers, their sum, and their rounded average.",13,10,13,10,0
    askForNumber    BYTE    "Please enter a signed integer: ",0
    errorString     BYTE    "ERROR: The number was too big/small or not a number at all!",13,10,0
    goodbye         BYTE    "Thanks for using the program! Goodbye!",13,10,0

    ; Arrays
    inputString     BYTE    MAXSTRING DUP(0)
    numberArray     SDWORD  INTS_TO_READ DUP(?)

    ; numbers
    bytesRead       DWORD   0
    multiplier      SDWORD  ?
    average         SDWORD  ?
    sum             SDWORD  ?

.code
main PROC

    push    OFFSET titleAndName
    push    OFFSET directions
    push    OFFSET explanation
    call    intro

    push    OFFSET multiplier
    push    OFFSET errorString
    push    OFFSET askForNumber
    push    OFFSET inputString
    push    MAXSTRING
    push    OFFSET bytesRead
    push    OFFSET numberArray
    push    INTS_TO_READ
    call    readVal

    push    INTS_TO_READ
    push    OFFSET average
    push    OFFSET sum
    push    OFFSET numberArray
    call    doMath 

    push    OFFSET goodbye
    call    farewell



    Invoke ExitProcess,0	; exit to operating system
main ENDP

;---------------------------------------------------------
; Name: intro
;
; Displays program title and name of programmer
; Explains program and gives directions to the user
;
; Preconditions: None
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   [EBP+8] = Address of explanation string
;   [EBP+12] = Address of directions string
;   [EBP+16] = Address of title and name string
;
; returns: Title, name, directions, and explanation are displayed to output
;---------------------------------------------------------
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

;---------------------------------------------------------
; Name: readVal
;
; Utilizes mGetString macro to read a signed integer input by the user
; Ensures that the entry is a valid number
; When entry is invalid, displays error and prompts user to try again
; Converts string number to actual numeric value and stores in an array
;
; Preconditions: 
;   mGetString macro must exist
;   Number storage array must be type SDWORD
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   [EBP+8] = Number of integers to gather
;   [EBP+12] = Address of array to store the numbers
;   [EBP+16] = Address of number of bytes entered by user
;   [EBP+20] = Max amount of bytes that can be read
;   [EBP+24] = Address of user input string
;   [EBP+28] = Address of string prompting user to enter a number
;   [EBP+32] = Address of error message string
;   [EBP+36] = Address that holds whether number is negative or positive
;
; returns: String entries are converted to numbers and stored in memory array
;---------------------------------------------------------
readVal     PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    EBX
    push    ECX
    push    EDX
    push    EDI
    push    ESI

    ; set up loop counter for getting input
    mov     ECX, [EBP+8]

_inputLoop:
    ; use macro to get string input from user
    mGetString [EBP+28], [EBP+24], [EBP+20], [EBP+16]
    mov     ESI, [EBP+24]
    xor     EAX, EAX

    ; check that first character is a sign or numeric
    cld
    lodsb
    cmp     AL, '-'
    je      _negNum
    cmp     AL, '+'
    je      _posNum
    cmp     AL, 48
    jl      _invalidInput
    cmp     AL, 57
    jle     _noSign                                 ; anything else is invalid and will carry through

_invalidInput:
    ; handle invalid inputs
    mov     EDX, [EBP+32]
    call    WriteString
    jmp     _inputLoop

_negNum:
    ; move a -1 in to memory for usage later
    mov     EBX, [EBP+36]
    mov     EAX, -1
    mov     [EBX], EAX

    ; set first character of string to '0' so it does not appear as bad input
    mov     EDI, [EBP+24]
    mov     AL, '0'
    stosb
    jmp     _onlyNumeric

_posNum:
    ; move a 1 in to memory for usage later
    mov     EBX, [EBP+36]
    mov     EAX, 1
    mov     [EBX], EAX

    ; set first character of string to '0' so it does not appear as bad input
    mov     EDI, [EBP+24]
    mov     AL, '0'
    stosb
    jmp     _onlyNumeric

_noSign:
    ; move a 1 in to memory for usage later
    mov     EBX, [EBP+36]
    mov     EAX, 1
    mov     [EBX], EAX

_onlyNumeric:
    ; set up loop counter to check that input contains only numbers
    push    ECX
    mov     EAX, [EBP+16]
    mov     ECX, [EAX]                              ; number of bytes input will be the counter
    mov     ESI, [EBP+24]                           ; string address in ESI
    cld                                             ; ensure forward movement through string

        _numericLoop:
            ; loop through and compare input to ASCII values for numeric strings
            lodsb
            cmp     AL, 48
            jl      _nonNum
            cmp     AL, 57
            jle     _nextNum                        ; bad input will carry through to error

        _nonNum:
            ; input is invalid, display error message
            pop     ECX                             ; restore ECX before leaving the loop
            jmp     _invalidInput

        _nextNum:
            ; character is a number, check the next one
            loop    _numericLoop

    ; point EDI at correct array index for writing
    pop     ECX
    mov     EAX, [EBP+8]
    sub     EAX, ECX
    mov     EBX, 4
    mul     EBX
    mov     EBX, [EBP+12]
    add     EBX, EAX
    mov     EDI, EBX                                ; address to write to is now in EDI
    push    ECX                                     ; ECX will be counter, so original count must be preserved

    ; prepare for looping through string and converting to number
    mov     ESI, [EBP+24]
    mov     EAX, [EBP+16]
    mov     ECX, [EAX]
    xor     EBX, EBX                                ; EBX will be accumulator since EAX will hold byte
    cld                                         

    ; determine whether to accumulate as negative or positive
    mov     EAX, [EBP+36]
    mov     EDX, [EAX]
    cmp     EDX, 1
    je      _numConvertPos

        _numConvertNeg:
            ; move byte in to AL and convert to numeric value
            lodsb
            sub     AL, 48
            imul    EBX, 10
            jo      _tooSmall
            movsx   EDX, AL
            sub     EBX, EDX
            jno     _nextByteNeg

        _tooSmall:
            ; number is too large for 32-bit register, show error message
            pop     ECX
            jmp     _invalidInput

        _nextByteNeg:
            ; loop to next byte
            loop    _numConvertNeg
            jmp     _writeArray                     ; skip over positive number converter

        _numConvertPos:
            ; move byte in to AL and convert to numeric value
            lodsb
            sub     AL, 48
            imul    EBX, 10
            jo      _tooBig
            movsx   EDX, AL
            add     EBX, EDX
            jno     _nextBytePos

        _tooBig:
            ; number is too large for 32-bit register, show error message
            pop     ECX
            jmp     _invalidInput
        
        _nextBytePos:
            ; loop to next byte
            loop    _numConvertPos

_writeArray:
    ; write number to array
    mov     [EDI], EBX

_endLoop:
    ; loop back to the top to get the next string
    pop     ECX                                     ; restore ECX before starting loop again
    dec     ECX
    cmp     ECX, 0
    jg      _inputLoop

    ; restore registers and return control to calling procedure
    pop     ESI
    pop     EDI
    pop     EDX
    pop     ECX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     32
readVal     ENDP

doMath      PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    ECX
    push    EDI

    ; set up loop counter and point EDI at the array
    mov     ECX, [EBP+20]
    mov     EDI, [EBP+8]
    xor     EAX, EAX                                ; EAX will be accumulator

_sumLoop:
    ; loop through each number and accumulate
    add     EAX, [EDI]
    add     EDI, 4
    loop    _sumLoop


    pop     EDI
    pop     ECX
    pop     EAX
    pop     EBP
    ret     16
doMath      ENDP

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
