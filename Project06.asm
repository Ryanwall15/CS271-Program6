TITLE Project06(Option A)     (Project06.asm)

; Author: Ryan Wallerius
; Course / Project ID   CS 271              Date: 6/8/17
; Description: I need to have the user provide 10 unsigned decimal ints. They have
; to fit in a 32 bit register. After they enter it in I need to display the list of ints
; their sum, and their average value

INCLUDE Irvine32.inc

MAX = 10			;Max number of inputs the user can have

myWriteString	MACRO	buffer	
	push edx
	mov edx, buffer
	call WriteString
	pop edx
ENDM

myGetString		MACRO	StringBuffer, MaxString, LengthString		
	push ecx
	push edx
	push eax

	mov edx, StringBuffer
	mov ecx, MaxString
	call ReadString
	mov LengthString, eax
	
	pop eax
	pop edx
	pop ecx

ENDM

.data

Introduction	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
Introduction1	BYTE	"Written by: Ryan Wallerius", 0
Directions		BYTE	"Heres what I need you to do for me:", 0
Directions1		BYTE	"		1) Please provide 10 unsigned decimal integers", 0
Directions2		BYTE	"		2) Each number needs to be small enough to fit inside a 32 bit register", 0
Directions3		BYTE	"After you have finished inputting the raw numbers I will display a list of the ints, their sum, and their average value", 0
Prompt			BYTE	"Please enter an unsigned number: ", 0
PromptError		BYTE	"You can't do that! Enter again: ", 0
numbers			BYTE	"You entered: ", 0
Comma			BYTE	", ", 0
sum				BYTE	"The sum: ", 0
average			BYTE	"The average: ", 0
bye				BYTE	"GoodBye!", 0

NumAverage		DWORD	0					;place to store average
NumSum			DWORD	0					;place to store sum

;For the ReadVal parameters/what it needs:
;Already have prompt and error prompt declared
NumArray		DWORD	10 DUP(?)			;array where we need to store numbers
String			BYTE	21 DUP(?)			;String
StringCount		DWORD	?					;how many characters are in the string itself (well use SIZEOF to figure that out)



.code
main PROC

	push OFFSET Introduction		;28
	push OFFSET Introduction1		;24	
	push OFFSET Directions			;20
	push OFFSET Directions1			;16
	push OFFSET Directions2			;12
	push OFFSET Directions3			;8
	call Intro

	push OFFSET Prompt				;28
	push OFFSET PromptError			;24
	push OFFSET numArray			;20
	push OFFSET String				;16
	push SIZEOF String				;12
	push OFFSET StringCount			;8
	call ReadVal

	push OFFSET Comma				;16
	push OFFSET NumArray			;12
	push OFFSET numbers				;8
	call WriteVal

	call CrLf
	push OFFSET NumSum				;16
	push OFFSET NumArray			;12
	push OFFSET sum					;8
	call DisplaySum

	push OFFSET average				;12
	push OFFSET NumSum				;8
	call DisplayAvg

	push OFFSET bye					;8
	call GoodBye

	exit	; exit to operating system
main ENDP

Intro PROC
	push ebp
	mov  ebp, esp					;set up the stack

	myWriteString[ebp+28]			;Based on comments on where it is in stack I put that num in next to ebp to go grab it off the stack
	call CrLf
	myWriteString[ebp+24]
	call CrLf
	call CrLf
	call CrLf

	myWriteString[ebp+20]
	call CrLf
	myWriteString[ebp+16]
	call CrLf
	myWriteString[ebp+12]
	call CrLf
	call CrLf
	myWriteString[ebp+8]
	call CrLf
	call CrLf

	pop ebp
	ret 24							;pop rest of stack off

Intro ENDP

ReadVal PROC

	push ebp
	mov ebp, esp					;set up the stack
	mov ecx, MAX					;Can't go longer than 10
	mov edi, [ebp+20]				;use destination index to store array which is stored at [edp+24]

	L1:
	push ecx						;save loop counter
	myWriteString [ebp+28]

	L2:
	myGetString	[ebp+16], [ebp+12], [ebp+8]		;pass paremeters that I set up back in the macro definition and how they were pushed on stack before
	mov ecx, [ebp+8]								;how big the string is
	mov esi, [ebp+16]								;the string itself
	cld

	L3:
	cmp ecx, 10										;can't enter more than 10 numbers
	JA wrong							

	L4:
	mov		eax, [edi]				;move current element of array (which is stored in edi) into eax 
	mov		ebx, 10					;From lecture 23 you mlultiply 10 by the array value at cur index
	mul		ebx						
	mov		[edi], eax				;put that back in edi				
	
									;this section is going to make sure its a valid input
	xor		eax, eax				;I could either put a clear string in here but xor reg reg does the same thing
	lodsb							;loads string byte 
	sub		al, 48					;Based on lecture 23 the value has to be between 48 and 57 then its a valid input from my understanding
	cmp		al, 0				
	JB		wrong					
	cmp		al, 57				
	JA		wrong					
	add		[edi], al				;if the input turns out to be valid add that to the array
	loop	L4						
	jmp		L5

	wrong:
	push eax						;save eax value
	xor eax, eax					;clearing eax register (like I did above)
	mov [edi], eax					;put into array
	pop eax							;restore value

	myWriteString [ebp+24]
	call CrLf
	myWriteString [ebp+28]
	jmp L2							
	
	L5:
	pop ecx
	mov eax, [edi]
	add edi, 4						;go to next element 
	loop L1


	pop ebp
	ret 28

ReadVal ENDP



WriteVal PROC
	push ebp
	mov ebp, esp
	mov edi, [ebp+12]				;move array into edi
	mov ecx, MAX					;get max into ecx for counter
	myWriteString [ebp+8]

	L1:
	mov eax, [edi]					;put current array element in eax
	call WriteDec					;print that value to the screen
	cmp ecx, 1						;check to see if we are at the last value. If we are we don't need the comma 
	je L2
	myWriteString [ebp+16]			
	add edi, 4						;go to the next element in edi

	L2:
	loop L1							;Repeat the process for the entire array/until ecx reaches 0

	pop ebp
	ret 8

WriteVal ENDP

DisplaySum	PROC
	push ebp
	mov ebp, esp
	mov edi, [ebp+12]				;putting array into edi
	mov ecx, MAX					;loop counter

	mov ebx, 0						;initializing ebx register

	L1:
	mov eax, [edi]					;get current element
	add ebx, eax					;add that with previous value (first run through it'll be 0)
	add edi, 4						;go to next element in array
	loop L1

	call CrLf
	myWriteString [ebp+8]
	mov eax, ebx					;retrieve that value
	call WriteDec					;print it to the screen
	call CrLf
	mov NumSum, ebx					;Store that in NumSum so I can use it for the average and pass that to it
	
	pop ebp
	ret 12

DisplaySum	ENDP

DisplayAvg	PROC
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]				;this should put the sum into eax 
	mov ebx, MAX					;what we would be dividing by because thats our number of terms
	mov edx, 0						;edx holds remainder

	cdq
	div ebx							;divide eax/ebx to get average

	call CrLf
	myWriteString [ebp+12]
	call WriteDec					;It should output the average but It's not working and I can't figure out why

	pop ebp
	ret 8

DisplayAvg	ENDP

GoodBye PROC
	push ebp
	mov ebp, esp
	call CrLf
	myWriteString [ebp+8]
	call CrLf

	pop ebp
	ret 4

GoodBye ENDP

END main
