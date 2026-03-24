(RESET)
    @SCREEN
    D=A
    @screenPos
    M=D
(CHECK)
    @KBD
    D=M
    @WHITE
    D;JEQ
// Black - key presssed
(BLACK)
    @R0
    M=-1
    @FILL
    0;JEQ

// White - no key presssed
(WHITE)
    @R0
    M=0

// Fill screen location
(FILL)
    // Grab white or black value & write to screen
    @R0
    D=M
    @screenPos
    A=M
    M=D

    // Increment screen position
    @screenPos
    D=M+1
    M=D

    // @CHECK to keep looping, @RESET when we hit end of screen
    @24575
    D=A-D
    @RESET
    D;JLT
    @CHECK
    0;JEQ