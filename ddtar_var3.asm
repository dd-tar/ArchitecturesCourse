; Daria Tarasova, 197 group, variant 3

format PE console
entry start
include 'win32a.inc'
;***************************************************************************
section '.code' code readable executable
start:
;  input of source array
        call InputArr

;  get array of summs
        call GetArrOfSums

        push endl
        call [printf]
        push strFirstArr
        call [printf]

;  source array out
        call PrintArr

        push endl
        call [printf]
        push strSecondArr
        call [printf]

;  result array out
        call PrintSecondArr

finish:
        push endl
        call [printf]
        push strExit
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
;***********************************************************************
GetArrOfSums:
        mov [arr2_size], 0     ; counter of the second array size
        xor ecx, ecx                 ; ecx = 0 (zeroing  counter-reg-value)
        mov ebx, vec                 ; ebx = &vec
        mov [i], 0                   ; current index in the first array
        mov [j], 0                   ; current index in the second array
 
sumItemsLoop:
        mov eax, [j]
        cmp eax, [arr_size]          ; if the end of the first array
        je endSumItems               ; jump to the end of loop


        ; getting of the first element to the sum
        mov eax, [i]
        mov ebx, [vec + eax*4]
        mov [sum], ebx

        ; offset in the first arr
        inc eax
        mov [i], eax
 
        ; getting of the second element to the tmp
        mov ebx, [vec + eax*4]
        mov [tmp], ebx

        ; add tmp to the sum
        mov ecx, [sum]
        add ecx, [tmp]
        mov [sum], ecx
 
        ; put sum into second array element
        mov ebx, [j]
        inc ebx
        mov [j], ebx
        mov eax, [j]
        mov ebx, [sum]
        mov [arr2 + eax*4], ebx
        jmp sumItemsLoop
 
endSumItems:
        mov eax, [j]
        mov [arr2_size], eax
        xor eax, eax
        ret
;***********************************************************************
InputArr:
        push strArrSize
        call [printf]
        add esp, 4
 
        push arr_size
        push strVal
        call [scanf]
        add esp, 8
 
        ; check if size <= 100
        mov eax, [arr_size]
        cmp eax, 100
        jle  checkBottom
 
wrongSize:
        push arr_size
        push strSizeInfo
        call [printf]
        call finish

; check if size > 0
checkBottom:
        mov eax, [arr_size]
        cmp eax, 0
        jg  getArr
        jmp wrongSize

getArr:
        xor ecx, ecx             ; ecx = 0
        mov ebx, vec             ; ebx = &vec
 
getArrLoop:
        mov [tmp], ebx           ; put ebx value into tmp
        cmp ecx, [arr_size]      ; if counter-reg-value is equal to vector size
        jge endInputVector       ; jump to the end of loop
 
        ; print current index.to_string()
        mov [i], ecx             ; save counter-reg-value into i
        push ecx                 ; push counter-reg-value into stack
        push strCurrIndex
        call [printf]            ; print current index.to_string()
        add esp, 8               ; move to the next cell of stack
 
        ; input element
        push ebx                 ; put the following item from register(where array is) to stack
        push strVal
        call [scanf]
        add esp, 8               ; move to the next cell of stack

        mov ecx, [i]             ; put index into ecx
        inc ecx                  ; increment index
        mov ebx, [tmp]           ; put current element into ebx
        add ebx, 4               ; move to the next cell of ebx

        ;catching input errors
        cmp eax, 1
        jne wrongInput

        jmp getArrLoop           ; go to the new iteration

wrongInput:
        push strWrongInput
        call [printf]
        call finish

endInputVector:
        ret
;***********************************************************************
PrintSecondArr:
        mov [tmpStack2], esp
        xor ecx, ecx
        mov ebx, 1
        mov eax, 0
        mov [iter], 0
 
putVecLoop2:
        push [arr2 + ebx*4]
        ;push ebx
        push [iter];
        push strArrEl2
        call [printf]
        add esp, 12
        inc ebx
        inc [iter];
        cmp ebx, [arr2_size]
        jl  putVecLoop2

endOutputVector2:
        mov esp, [tmpStack2]
        ret
;***********************************************************************
PrintArr:
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, vec

putVecLoop:
        mov [tmp], ebx
        cmp ecx, [arr_size]
        je endOutputVector
        mov [i], ecx
 
        ; output element
        push dword [ebx]
        push ecx
        push strArrEl
        call [printf]
 
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop

endOutputVector:
        mov esp, [tmpStack]
        ret
;***********************************************************************
section '.data' data readable writable

        strArrSize       db 'Enter size of array: ', 0
        strSizeInfo      db 'Wrong input: Size should be an integer from 1 to 100.', 0
        strWrongInput    db 'Wrong input: Values should be double. Separator according to the locale.', 0
        strExit          db 'Press any key to exit...', 10, 0
        strCurrIndex     db '  arr[%d] is ', 0
        strVal           db '%d', 0
        strArrEl    db '    arr[%d] = %d', 10, 0
        strArrEl2   db '    arr_s[%d] = %d', 10, 0
        strFirstArr      db 'Sourse array: ',10,0
        strSecondArr     db 'Array of sums: ',10,0
        endl             db 10,0

        arr_size         dd 0
        sum              dd 0
        arr2_size        dd 0
        arr2             rd 100
        i                dd ?
        j                dd ?
        iter             dd ?
        tmp              dd ?
        tmpStack         dd ?
        tmpStack2        dd ?
        vec              rd 100
;***********************************************************************
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'
 
include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'