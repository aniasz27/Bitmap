.data
fileName: .asciz "barcode.bmp"
welcome: .asciz "\nThe message to encrypt:\n"
decrypt_new: .asciz "\nThe message after decryption:\n"
message: .asciz "The quick brown fox jumps over the lazy dogThe quick brown fox jumps over the lazy dogThe quick brown fox jumps over the lazy dog"
pattern: .asciz "8C4S2E414480"
barcode_pattern: .asciz "WWWWWWWWBBBBBBBBWWWWBBBBWWBBBWW"
char: .asciz "%c"
number: .asciz "%u"
new_message: .skip 3072
compression: .skip 3072
decrypted: .skip 3072
decrypted_new: .skip 3072
barcode: .skip 3072
new_barcode: .skip 3126
encrypted_barcode: .skip 3126

.text

.global main

main:
    #prologue
    pushq %rbp              #push the base pointer (and align the stack)
    movq %rsp, %rbp         #copy stack pointer value to base pointer

    #call encrypt            #call encrypt

    movq $pattern, %rdi
    call decrypt

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    movq $0, %rdi           #load program exit code
    call exit               #exit the program



encrypt:
    #prologue
    pushq %rbp              #push the base pointer (and align the stack)
    movq %rsp, %rbp         #copy stack pointer value to base pointer

    movq $pattern, %r13     #move the address of the pattern into R13
    movq $message, %r12     #move the address of the message into R12
    movq $new_message, %r14 #move the address of the new_message into R14
    movq $new_barcode, %r15 #move the address of the new_barcode into R15

#fileHeader
    movb $'B', (%r15)       #signature
    incq %r15
    movb $'M', (%r15)
    incq %r15

    movb $0x36, (%r15)      #file size
    incq %r15
    movb $0x0C, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x00, (%r15)      #reserved field
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x36, (%r15)      #offset of pixel data
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    #bitmapHeader
    movb $0x28, (%r15)      #header size
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x20, (%r15)      #width
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x20, (%r15)      #height
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x01, (%r15)      #reserved field
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x18, (%r15)      #bits per pixel
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x00, (%r15)      #compression method
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x00, (%r15)      #pixel data
    incq %r15
    movb $0x0C, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x13, (%r15)      #horizontal resolution
    incq %r15
    movb $0x0B, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x13, (%r15)      #vertical resolution
    incq %r15
    movb $0x0B, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x00, (%r15)      #colour palette information
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

    movb $0x00, (%r15)      #number of important colours
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15
    movb $0x00, (%r15)
    incq %r15

lead:
    movb (%r13), %r10b      #copy the number of times to print character into R10

    cmpq $0, %r10           #compare the value in R10 with 0
    je messagemove          #if equals jump to messagemove
    
    subq $48, %r10          #substract 48 from the number (ASCII)

    incq %r13               #increment R13
    movb (%r13), %r11b      #copy the character into R11

lloopy:
    movq %r11, (%r14)       #copy the character into R14
    incq %r14               #increment address in R14

    decq %r10               #decrement the number of times
    cmpq $0, %r10           #compare the number of times in R10 with 0
    jg lloopy               #if greater jump to lloopy

    incq %r13               #increment R13

    jmp lead                #jump to lead

messagemove:
    movq $pattern, %r13     #move the address of the pattern into R13 (will be useful for trail)
    movb (%r12), %r11b      #copy the character from R12 (message) into R11

    cmpq $0, %r11           #compare the character in R11 with 0
    je trail                #if equals jump to trail

    movq %r11, (%r14)       #copy the character into R14

    incq %r12               #increment R12 (message)
    incq %r14               #increment R14 (new_message)

    jmp messagemove         #jump to messagemove

trail:
    movb (%r13), %r10b      #copy the number of times to print character into R10     
    
    cmpq $0, %r10            #compare the value in R10 with 0
    je printnewmessage      #if equals jump to printnewmessage
    
    subq $48, %r10          #substract 48 from the number (ASCII)

    incq %r13               #increment R13
    movb (%r13), %r11b      #copy the character into R11

tloopy:
    movq %r11, (%r14)       #copy the character into R14
    incq %r14               #increment address in R14

    decq %r10               #decrement the number of times
    cmp $0, %r10            #compare the number of times in R10 with 0
    jg tloopy               #if greater jump to tloopy

    incq %r13               #increment R13

    jmp trail               #jump to trail

printnewmessage:
    movq $0, %rax           #move 0 into RAX
    movq $welcome, %rdi     #move welcome into RDI
    call printf             #call printf

    movq $new_message, %r14 #move the address of new_message into R14

amount1:
    movb (%r14), %sil       #move the byte from R14 into RSI to print it
    movq $0, %rax           #move 0 into RAX
    movq $char, %rdi        #move char into RDI
    call printf             #call printf

    incq %r14               #increment R14
    cmpq $0, (%r14)         #compare R14 with 0
    jne amount1             #if greater jump to amount1

    movq $'\n', %rsi        #move the character of newline into RSI
    movq $0, %rax           #move 0 into RAX
    movq $char, %rdi        #move char into RDI
    call printf             #call printf

rle:
    movq $new_message, %r14 #move the address of new_message into R14
    movq $compression, %r15 #move the address of compression into R15
    movq $0, %r12           #move 0 into R12 (counter of characters in compression)

loop:    
    movq $48, %r10          #move 48 into R10 (counter of characters)
    
loopy:
    incq %r10               #increment R10
    movb (%r14), %r11b      #copy the byte from R14 into R11
    incq %r14               #increment R14
    movb (%r14), %r9b       #copy the byte from R14 into R9

    cmpb %r11b, %r9b        #compare the characters in R11 and R9
    je loopy                #if equals jump to loopy

    movq %r10, (%r15)       #move the counter of characters from R10 into R15 (compression)
    incq %r15               #increment R15
    movq %r11, (%r15)       #move the character from R11 into R15 (compression)
    incq %r15               #increment R15
    addq $2, %r12           #add 2 to R12

    cmpq $0, %r9            #compare value in R9 with 0
    jne loop                #if not equals jump to loop

barcodes:
    movq $32, %r13          #move 32 into R13
    movq $barcode, %r14     #move the address of barcode (space) into R14
    movq $0, %r11           #move 0 into R11

bloop:
    movq $barcode_pattern, %r15     #move the address of barcode_pattern into R15

bloopy:
    movb (%r15), %r11b      #copy the character from barcode_pattern into R11

    cmpb $0, %r11b          #compare the character in R11 with 0
    je red                  #if equals jump to red

    cmpb $'B', %r11b        #compare the character in R11 with B
    je black                #if equals jump to black

    movb $255, (%r14)       #move 255 into R14 (red)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 255 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 255 into R14 (blue)
    incq %r14               #increment the address of barcode in R14

    incq %r15               #increment R15 (barcode_pattern)
    jmp bloopy              #jump to bloopy

black:
    movb $0, (%r14)         #move 0 into R14 (red)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (blue)
    incq %r14               #increment the address of barcode in R14

    incq %r15               #increment R15 (barcode_pattern)
    jmp bloopy              #jump to bloopy

red:
    movb $0, (%r14)         #move 255 into R14 (blue)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 0 into R14 (red)
    incq %r14               #increment the address of barcode in R14

    decq %r13               #decrement R13 (counter of lines)
    cmpq $0, %r13           #compare counter of lines in R13 with 0
    jne bloop               #if greater jump to bloop
    
xor:
    movq $compression, %r13 #move the address of compression (space) into R13
    movq $barcode, %r14     #move the address of barcode (space) into R14
    movq $new_barcode, %r15 #move the address of new_barcode (space) into R15
    addq $54, %r15          #add 54 to the address of new_barcode (R15)
    movq $3072, %r9         #move 3072 into R9 (counter of bytes)

xloop:
    movq $0, %r10           #move 0 into R10
    movq $0, %r11           #move 0 into R11

    movb (%r13), %r10b      #copy the byte from R13 (compression) into R10
    movb (%r14), %r11b      #copy the byte from R14 (barcode) into R11

    xorq %r10, %r11         #XOR on two characters in R10 and R11
    movb %r11b, (%r15)      #move the result of XOR from R11 into R15 (new_barcode)

    decq %r9                #decrement R9
    incq %r13               #increment R13
    incq %r14               #increment R14
    incq %r15               #increment R15
    cmpq $0, (%r13)         #compare 0 with value in RBX
    jne xloop               #if greater jump to xloop

copytherest:
    cmpq $0, %r9            #compare R9 (counter of bytes) with 0
    je file                 #if equals jump to file

    movb (%r14), %r11b      #copy the byte from R14 (barcode) into R11
    movb %r11b, (%r15)      #copy the byte from R11 into R15 (new_barcode)

    decq %r9                #decrement R9
    incq %r14               #increment R14
    incq %r15               #increment R15

    jmp copytherest         #jump to copytherest

file:
    #create and open a file
    movq $2, %rax
    movq $fileName, %rdi
    movq $578, %rsi
    movq $0666, %rdx
    syscall

    movq %rax, %r13

    # write to a file
    movq $1, %rax
    movq %r13, %rdi
    movq $new_barcode, %rsi
    movq $3126, %rdx
    syscall

    #close a file
    movq $3, %rax 
    movq %r13, %rdi
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret



decrypt:
    #prologue
    pushq %rbp              #push the base pointer (and align the stack)
    movq %rsp, %rbp         #copy stack pointer value to base pointer

    movq %rdi, %r8          #move the parameter (pattern) into R8

barcodes2:
    movq $32, %r13          #move 32 into R13
    movq $barcode, %r14     #move the address of barcode (space) into R14
    movq $0, %r11           #move 0 into R11

bloop2:
    movq $barcode_pattern, %r15     #move the address of barcode_pattern into R15

bloopy2:
    movb (%r15), %r11b      #copy the character from barcode_pattern into R11

    cmpb $0, %r11b          #compare the character in R11 with 0
    je red2                  #if equals jump to red2

    cmpb $'B', %r11b        #compare the character in R11 with B
    je black2                #if equals jump to black2

    movb $255, (%r14)       #move 255 into R14 (red)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 255 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 255 into R14 (blue)
    incq %r14               #increment the address of barcode in R14

    incq %r15               #increment R15 (barcode_pattern)
    jmp bloopy2             #jump to bloopy2

black2:
    movb $0, (%r14)         #move 0 into R14 (red)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (blue)
    incq %r14               #increment the address of barcode in R14

    incq %r15               #increment R15 (barcode_pattern)
    jmp bloopy2             #jump to bloopy2

red2:
    movb $0, (%r14)         #move 255 into R14 (blue)
    incq %r14               #increment the address of barcode in R14
    movb $0, (%r14)         #move 0 into R14 (green)
    incq %r14               #increment the address of barcode in R14
    movb $255, (%r14)       #move 0 into R14 (red)
    incq %r14               #increment the address of barcode in R14

    decq %r13               #decrement R13 (counter of lines)
    cmpq $0, %r13           #compare counter of lines in R13 with 0
    jne bloop2               #if greater jump to bloop2
    
    #open a file
    movq $2, %rax
    movq $fileName, %rdi
    movq $0, %rsi
    movq $0666, %rdx
    syscall

    #read from a file
    movq %rax, %rdi
    movq $0, %rax
    movq $encrypted_barcode, %rsi
    movq $3126, %rdx
    syscall

    #close a file
    movq $3, %rax 
    movq $3, %rdi
    syscall

    movq $encrypted_barcode, %r15   #move the address of new_barcode into R15
    addq $54, %r15          #add 54 to the address in R15
    movq $decrypted, %r14   #move the address of decrypted into R14
    movq $barcode, %r13     #move the address of barcode into R13

xloopy:
    movq $0, %r10           #move 0 into R10
    movq $0, %r11           #move 0 into R11

    movb (%r15), %r10b      #copy the byte from R15 (new_barcode) into R10
    movb (%r13), %r11b      #copy the byte from R13 (barcode) into R11

    xorq %r10, %r11         #XOR on two characters in R10 and R11
    cmpq $2, %r11
    je fromcompression
    movb %r11b, (%r14)      #move the result of XOR from R11 into R14 (decrypted)

    incq %r13               #increment R13
    incq %r14               #increment R14
    incq %r15               #increment R15
    jmp xloopy              #jump to xloopy

fromcompression:
    movq $decrypted, %r13   #move the address of decrypted into R13
    movq $decrypted_new, %r14   #move the address of decrypted_new into R14
    movq $0, %rbx           #move 0 into RBX (counter of characters in decrypted_new)

cloop:
    movb (%r13), %r10b      #copy the number of times to print character into R10
    
    cmpq $0, %r10           #compare the value in R10 with 0
    je leadchar             #if equals jump to leadchar
    
    subq $48, %r10          #substract 48 from the number (ASCII)

    incq %r13               #increment R13
    movb (%r13), %r11b      #copy the character into R11

cloopy:
    movb %r11b, (%r14)      #copy the character into R14
    incq %r14               #increment address in R14
    incq %rbx               #increment the counter of characters in decrypted_new

    decq %r10               #decrement the number of times
    cmpq $0, %r10           #compare the number of times in R10 with 0
    jg cloopy               #if greater jump to cloopy

    incq %r13               #increment R13

    jmp cloop               #jump to cloop

leadchar:
    movq $0, %r13           #move 0 into R13 (counter of characters in lead/trail)

hloop:
    movq $0, %r12           #move 0 into R12
    movb (%r8), %r12b       #copy the byte from R8 (pattern) into R12
    cmpq $0, %r12           #compare the value in R12 with 0
    je printdecryptmessage  #if equals jump to printdecryptmessage

    subq $48, %r12          #substract 48 from value in R12 (ASCII)
    addq %r12, %r13         #add value in R12 to the R13
    addq $2, %r8            #add 2 to the address in R8

    jmp hloop               #jump to hloop

printdecryptmessage:    
    movq $0, %rax           #move 0 into RAX
    movq $decrypt_new, %rdi #move decrypt_new into RDI
    call printf             #call printf

    movq $decrypted_new, %r14   #move the address of decrypted_new into R14
    addq %r13, %r14         #add the number of characters in lead to the address in R14
    movq %rbx, %r15         #copy the counter of charaters in decrypted_new from RBX into R15
    subq %r13, %r15         #substract the number of characters in lead from R15
    subq %r13, %r15         #substract the number of characters in lead from R15

amount2:
    movb (%r14), %sil       #move the byte from R14 into RSI to print it
    movq $0, %rax           #move 0 into RAX
    movq $char, %rdi        #move char into RDI
    call printf             #call printf

    incq %r14               #increment R14
    decq %r15               #decrement R15
    cmpq $0, %r15           #compare R15 with 0
    jg amount2              #if greater jump to amount2

    movq $'\n', %rsi        #move the character of newline into RSI
    movq $0, %rax           #move 0 into RAX
    movq $char, %rdi        #move char into RDI
    call printf             #call printf

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret
