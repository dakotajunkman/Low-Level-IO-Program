TITLE String Primitives and Macros

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
    mDisplayString  direction

    ; get number from the user
    mov     EDX, memLoc
    mov     ECX, maxLength
    call    ReadString

    ; store bytes read in memory
    mov     EBX, amtRead
    mov     [EBX], EAX

    ; restore registers
    pop     EBX
    pop     EAX
    pop     ECX
    pop     EDX

ENDM

;---------------------------------------------------------
; Name: mDisplayString
;
; Uses Irvine's WriteString procedure to display a string to output
;
; Preconditions: Do not use EDX as an argument
;
; Receives:
;   number: address of string to display
;
; returns: string is displayed to output
;---------------------------------------------------------
mDisplayString  MACRO   number

    ; preserve registers
    push    EDX

    ; display the string to output
    mov     EDX, number
    call    WriteString

    ; restore registers
    pop     EDX

ENDM

    ; constants
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
    numbersString   BYTE    13,10,"You entered the following numbers:",13,10,0
    sumString       BYTE    13,10,13,10,"The sum of these numbers is: ",0
    averageString   BYTE    13,10,13,10,"The rounded average is: ",0
    commaSpace      BYTE    ", ",0
    goodbye         BYTE    13,10,13,10,"Thanks for using the program! Goodbye!",13,10,0

    ; Arrays
    inputString     BYTE    MAXSTRING DUP(0)
    numberArray     SDWORD  INTS_TO_READ DUP(?)
    outputString    BYTE    MAXSTRING DUP(0)

    ; numbers
    bytesRead       DWORD   0
    multiplier      SDWORD  ?
    average         SDWORD  ?
    sum             SDWORD  ?

.code

;---------------------------------------------------------
; Name: main
;
; A test procedure to test that mGetString, mDisplayString, readVal, and writeVal work
; calls intro to introduce the program to the user
; sets up a loop and calls readVal to gather the necessary number of integers
; calls doMath to calculate the sum and average
; sets up a loop and calls writeVal to write the integers, average, and sum
; calls farewell to exit the program
;
; Preconditions: None
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   INTS_TO_READ is a constant
;   numberArray is a global 
;   numbersString is a global
;   sumString is a global
;   averageString is a global
;
; returns: Nothing
;---------------------------------------------------------
main PROC

    ; preserve used registers
    push    EAX
    push    ECX
    push    EDI

    ; introduce the program to the user
    push    OFFSET titleAndName
    push    OFFSET directions
    push    OFFSET explanation
    call    intro

    ; set up loop to gather integers from the user
    mov     ECX, INTS_TO_READ
    mov     EDI, OFFSET numberArray

_gatherLoop:
    ; push arguments to call readVal
    push    EDI                                     ; address to write the number
    push    INTS_TO_READ
    push    OFFSET askForNumber
    push    OFFSET inputString
    push    MAXSTRING
    push    OFFSET bytesRead
    push    OFFSET errorString
    push    OFFSET multiplier
    call    readVal

    ; loop back to top for next number
    add     EDI, 4
    loop    _gatherLoop

    ; calculate sum and average
    push    INTS_TO_READ
    push    OFFSET average
    push    OFFSET sum
    push    OFFSET numberArray
    call    doMath 

    ; display string to show output of entered numbers
    mDisplayString  OFFSET numbersString

    ; set up loop to display the numbers and point EDI at the array
    mov     ECX, INTS_TO_READ
    mov     EDI, OFFSET numberArray

_convertLoop:
    ; loop through array and convert numbers to ASCII byte strings and display them to output
    push    [EDI]
    push    OFFSET outputString
    call    writeVal

    ; update EDI address and check if comma and space need to be written
    add     EDI, TYPE numberArray
    cmp     ECX, 1
    je      _endLoop

    ; write a comma and space
    mDisplayString  OFFSET commaSpace

_endLoop:
    ; loop back to top to convert next number
    loop    _convertLoop

    ; display the sum to output
    mDisplayString  OFFSET sumString

    ; convert sum to ASCII string and write to output
    push    sum
    push    OFFSET outputString
    call    writeVal

    ; display average to output
    mDisplayString  OFFSET averageString

    ; convert average to ASCII string and write to output
    push    average
    push    OFFSET outputString
    call    writeVal

    ; say goodbye to the user
    push    OFFSET goodbye
    call    farewell

    ; restore used registers
    pop     EDI
    pop     ECX
    pop     EAX

    Invoke ExitProcess,0	; exit to operating system
main ENDP

;---------------------------------------------------------
; Name: intro
;
; Displays program title and name of programmer
; Explains program and gives directions to the user
;
; Preconditions: mGetString macro must exist
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

    ; display title and directions to the user
    mDisplayString  [EBP+16]
    mDisplayString  [EBP+12]
    mDisplayString  [EBP+8]

    ; restore registers and return to calling procedure
    pop     EBP
    ret     12
intro       ENDP

;---------------------------------------------------------
; Name: readVal
;
; Utilizes mGetString macro get a user-input signed integer in to memory
; Ensures that the entry is a valid number
; When entry is invalid, displays error and prompts user to try again
; Converts string number to actual numeric value and stores in memory
; Can convert both negative and positive numbers
;
; Preconditions: 
;   mGetString macro must exist
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   [EBP+8] = Address that holds whether number is negative or positive
;   [EBP+12] = Address of error message string
;   [EBP+16] = Address of number of bytes entered by user
;   [EBP+20] = Max amount of bytes that can be read
;   [EBP+24] = Address of user input string
;   [EBP+28] = Address of string prompting user to enter a number
;   [EBP+32] = Number of integers to gather
;   [EBP+36] = Address to write the number
;
; returns: String entry is converted to number and stored in memory
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

_getString:
    ; use macro to get string input from user
    mGetString [EBP+28], [EBP+24], [EBP+20], [EBP+16]

    ; get string address in ESI and prepare EAX to receive bytes
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
    mov     EDX, [EBP+12]
    call    WriteString
    jmp     _getString                              ; allow user to input new string

_negNum:
    ; move a -1 in to memory for usage later
    mov     EBX, [EBP+8]
    mov     EAX, -1
    mov     [EBX], EAX
    jmp     _oneChar

_posNum:
    ; move a 1 in to memory for usage later
    mov     EBX, [EBP+8]
    mov     EAX, 1
    mov     [EBX], EAX

_oneChar:
    ; check if sign is only character
    mov     EBX, [EBP+16]
    mov     EAX, [EBX]
    cmp     EAX, 1
    je      _invalidInput                           ; avoids single + or - being read as valid

_zeroConvert:
    ; convert sign to '0' so it doesn't show as bad input
    mov     EDI, [EBP+24]
    mov     AL, '0'
    stosb
    jmp     _onlyNumeric

_noSign:
    ; move a 1 in to memory for usage later
    mov     EBX, [EBP+8]
    mov     EAX, 1
    mov     [EBX], EAX

_onlyNumeric:
    ; set up loop counter to check that input contains only numbers
    mov     EAX, [EBP+16]
    mov     ECX, [EAX]                              ; number of bytes input will be the counter
    mov     ESI, [EBP+24]
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
            jmp     _invalidInput

        _nextNum:
            ; character is a number, check the next one
            loop    _numericLoop

    ; point EDI at correct array index for writing
    mov     EDI, [EBP+36]

    ; prepare for looping through string and converting to number
    mov     ESI, [EBP+24]
    mov     EAX, [EBP+16]
    mov     ECX, [EAX]                              ; number of bytes read is the counter
    xor     EBX, EBX                                ; EBX will be accumulator since EAX will hold byte
    cld                                             ; move forward through string

    ; determine whether to accumulate as negative or positive
    mov     EAX, [EBP+8]
    mov     EDX, [EAX]                              ; will be 1 or -1, depending on sign
    cmp     EDX, 1                                  
    je      _numConvertPos                          ; negative num will carry through

        _numConvertNeg:
            ; move byte in to AL and convert to numeric value
            lodsb
            sub     AL, 48
            imul    EBX, 10
            jo      _tooSmall
            movsx   EDX, AL
            sub     EBX, EDX
            jno     _nextByteNeg                    ; check that register hasn't overflowed

        _tooSmall:
            ; number is too large for 32-bit register, show error message
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
            jno     _nextBytePos                    ; check that register hasn't overflowed

        _tooBig:
            ; number is too large for 32-bit register, show error message
            jmp     _invalidInput
        
        _nextBytePos:
            ; loop to next byte
            loop    _numConvertPos

_writeArray:
    ; write number to array
    mov     [EDI], EBX

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

;---------------------------------------------------------
; Name: doMath
;
; Loops through number array and calculates sum and average of the numbers
; Average is calculated using floor division
;
; Preconditions: Number array must be type SDWORD and contain only numbers
;
; Postconditions: None, all used registers are preserved and array remains intact
;
; Receives:
;   [EBP+8] = address of number array
;   [EBP+12] = address to store the sum
;   [EBP+16] = address to store the average
;   [EBP+20] = amount of numbers in the array
;
; returns: Average and sum of the array are stored in memory
;---------------------------------------------------------
doMath      PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    EBX
    push    ECX
    push    EDX                                     ; not visible, but used in idiv
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

    ; save sum in memory
    mov     EBX, [EBP+12]
    mov     [EBX], EAX                              ; sum is stored in memory

    ; calculate average
    mov     EBX, [EBP+20]
    cdq
    idiv    EBX

    ; check if number is negative
    cmp     EAX, 0
    jl      _negative
    jmp     _storeAvg

_negative:
    ; see if number needs to be floor rounded
    cmp     EDX, 0
    je      _storeAvg
    dec     EAX                                     ; remainder means a round down is necessary

_storeAvg:
    ; store average in memory
    mov     EBX, [EBP+16]
    mov     [EBX], EAX                              ; average stored in memory

    ; restore registers and return to calling procedure
    pop     EDI
    pop     EDX
    pop     ECX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     16
doMath      ENDP

;---------------------------------------------------------
; Name: writeVal
;
; Converts a number to its ASCII string representation
; Utilizes mDisplayString macro to display the string to output
; Can convert both negative and positive numbers to ASCII strings
;
; Preconditions: mDisplayString macro must exist
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   [EBP+8] = Address to write string to
;   [EBP+12] = Number to convert
;
; Returns:
;   Number is converted to ASCII string and stored in memory
;   ASCII string is displayed to output
;---------------------------------------------------------
writeVal    PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    EBX
    push    EDX
    push    EDI

    ; get string address in EDI and number in EBX and EAX
    mov     EDI, [EBP+8]
    mov     EBX, [EBP+12]
    mov     EAX, EBX                                ; make copy of number to take absolute value

    ; determine if number is negative
    cmp     EBX, 0
    jge     _checkSize
    inc     EDI                                     ; make room to write negative sign
    imul    EAX, -1                                 ; get absolute value

_checkSize:
    ; determine how many characters are needed
    cmp     EAX, 10
    jl      _writeOne
    cmp     EAX, 100
    jl      _writeTwo
    cmp     EAX, 1000
    jl      _writeThree
    cmp     EAX, 10000
    jl      _writeFour
    cmp     EAX, 100000
    jl      _writeFive
    cmp     EAX, 1000000
    jl      _writeSix
    cmp     EAX, 10000000
    jl      _writeSeven
    cmp     EAX, 100000000
    jl      _writeEight
    cmp     EAX, 1000000000
    jl      _writeNine                              ; anything larger will get 10

    ; add 10 to EDI to make space to write bytes
    add     EDI, 10
    jmp     _convertPrep

_writeNine:
    ; add 9 to EDI to make space to write bytes
    add     EDI, 9
    jmp     _convertPrep

_writeEight:
    ; add 8 to EDI to make space to write bytes
    add     EDI, 8
    jmp     _convertPrep

_writeSeven:
    ; add 7 to EDI to make space to write bytes
    add     EDI, 7
    jmp     _convertPrep

_writeSix:
    ; add 6 to EDI to make space to write bytes
    add     EDI, 6
    jmp     _convertPrep

_writeFive:
    ; add 5 to EDI to make space to write bytes
    add     EDI, 5
    jmp     _convertPrep

_writeFour:
    ; add 4 to EDI to make space to write bytes
    add     EDI, 4
    jmp     _convertPrep

_writeThree:
    ; add 3 to EDI to make space to write bytes
    add     EDI, 3
    jmp     _convertPrep

_writeTwo:
    ; add 2 to EDI to make space to write bytes
    add     EDI, 2
    jmp     _convertPrep

_writeOne:
    ; add 1 to EDI to make space to write bytes
    add     EDI, 1

_convertPrep:
    ; prepare to convert number to ASCII
    push    EBX                                     ; preserve EBX value
    std                                             ; move backward when writing
    push    EAX                                     ; preserve EAX value for division
    mov     AL, 0
    stosb                                           ; null terminate the string
    pop     EAX                                     ; restore EAX for division
    
_convertToString:
    ; convert from number to string representation of number
    mov     EBX, 10
    cdq
    idiv    EBX
    add     EDX, 48
    push    EAX                                     ; preserve EAX value
    mov     AL, DL
    stosb                                           ; write ASCII char to memory
    pop     EAX                                     ; restore EAX value
    cmp     EAX, 0
    je      _endConvert
    jmp     _convertToString

_endConvert:
    ; write sign if necessary
    pop     EBX                                     ; restore EBX value
    cmp     EBX, 0
    jge     _displayString
    mov     AL, '-'
    stosb                                           ; write negative sign when needed

_displayString:
    ; use macro to write string to output
    mDisplayString  [EBP+8]

    ; restore registers and return control to calling procedure
    pop     EDI
    pop     EDX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     8
writeVal    ENDP

;---------------------------------------------------------
; Name: farewell
;
; Thanks user for using the program and says goodbye
;
; Preconditions: mDisplayString macro must exist
;
; Postconditions: None, all used registers are preserved
;
; Receives:
;   [EBP+8] = Address of goodbye string
;
; returns: Farewell message displayed to output
;---------------------------------------------------------
farewell    PROC

    ; preserve registers and set base pointer
    push    EBP
    mov     EBP, ESP
    push    EDX

    ; display farewell message to user
    mDisplayString  [EBP+8]

    ; restore registers and return to calling procedure
    pop     EDX
    pop     EBP
    ret     4
farewell    ENDP

END main
