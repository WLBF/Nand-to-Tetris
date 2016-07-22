// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

    @i
    M=0

(LOOP)

// If any key pressed goto BLACKEN
    @24576
    D=M

    @BLACKEN
    D;JGT

(CLEAR)

// If i<=0 goto LOOP
    @i
    D=M

    @LOOP
    D;JLE
//

// Decrement i then clear the RAM[SCREEN+i]
    @i
    M=M-1

    @SCREEN
    D=A

    @i
    D=D+M

    A=D
    M=0

    @LOOP
    0;JMP
//

(BLACKEN)

// If i > 8191 goto LOOP
    @i
    D=M

    @8191
    D=D-A

    @LOOP
    D;JGT
//

// Blacken RAM[SCREEN+i]
    @SCREEN
    D=A

    @i
    D=D+M

    A=D
    M=!M
//

// Increment i then goto LOOP
    @i
    M=M+1

    @LOOP
    0;JMP
//




