        .globl isPrimeAssembly
isPrimeAssembly:
        # Store FP and LR and move stack pointer 3*128
        STP X29, X30, [SP, #-384]!
        # Set FP to current SP
        MOV X29, SP

        # Create pointers for the arrays
        # X0 = base address of array a
        # ADD X0, SP, #0
        # X1 = base address of prime array
        # ADD X1, SP, #128
        # X2 = base address of composite array
        # ADD X2, SP, #256

        # Initialize loop counter and indicies
        # loop counter (i)
        MOV X4, #0
        # prime array idx 
        MOV X5, #0
        # composite index
        MOV X6, #0

loop_start:
        # check if we are past the array length X3 = 16
        CMP X4, X3
        B.GE end

        # load a[i] into X11
        LDR X11, [X0, X4, LSL #3]

        # Move a[i] into X15 and check if its prime
        MOV X15, X11
        BL isPrime

        # Check if it was prime
        CMP X15, #1
        # if equal to 1, store in prime (with offset)
        B.EQ store_prime

# else, store in composite (with offset)
store_composite:
        STR X11, [X2, X6, LSL #3]
        # increment composite idx
        ADD X6, X6, #1
        B continue_loop

store_prime:
        STR X11, [X1, X5, LSL #3]
        # increment prime idx
        ADD X5, X5, #1

continue_loop:
        # increment i
        ADD X4, X4, #1
        # loop
        B loop_start

end:
        # Restore stack and return to C code
        LDP X29, X30, [SP], #384
        RET

isPrime:
        # X15 holds value of n
        # X7 will be j, X8 will be n / 2

        # Initialize j as 2
        MOV X7, #2

        # Only need to compare with values up to n/2, so calculate n / 2 and store in X8
        LSR X8, X15, #1

loop_check:
        # Check if j > n / 2, if it is then its prime
        CMP X7, X8

        # If j > n/2, return 1 (prime)
        B.GT prime_return

        # Perform n % j
        # If remainder is found to be zero, then it is composite

        # Quotient in X9 - n / j 
        UDIV X9, X15, X7
        # remainder in X10 = n - (quotient * j)
        MSUB X10, X9, X7, X15

        # if remainder == 0, return 0 (composite)
        CBZ X10, composite_return

        # increment j by 1
        ADD X7, X7, #1

        # repeat loop
        B loop_check

composite_return:
        # Return 0 (composite)
        MOV X15, #0
        RET

prime_return:
        # Return 1 (prime)
        MOV X15, #1
        RET
