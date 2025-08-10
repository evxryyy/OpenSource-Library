# ASCII

## Getting Started

### Module : [ASCII](https://github.com/evxryyy/Modules/blob/main/ASCII/init.luau)

On this page you will learn how to use <b>ASCII</b> module
Please read the documentation entirely if you want to really use it for your projects

??? note

    <b>This module might be difficult to understand if you dont know how to work with buffer.</b>

### Basic

Let's convert a string into a ASCII Formula

=== "Basic"

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local HelloASCII = ASCII.StrASCII("Hello World")
    print(HelloASCII) --> {72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33}
    ```

    StrASCII only accept string as a argument and valid ASCII Character and return a array of number representing each character in the ASCII Formula


You can also convert an array of numbers represented in ASCII Formula. for exemple lets the result in the last back to a string.

=== "ASCII to String"

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local HelloASCII = ASCII.ASCIIStr({72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33})
    print(HelloASCII) --> "Hello World"
    ```

    now the array has been converted back to a string.


In this module you are also be able to convert number to a binary buffer and redo the convertion of that .

### Binary

    
=== "Number to Binary"

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local bin = ASCII.BinaryNumber(10) --> buffer (each bits contain the bits binary representation) e.g (1010)
    print(bin) --> buffer size = 4

    ```

=== "Binary to Number"

    First lets do the same has the first exemple about binary

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local bin = ASCII.BinaryNumber(10) --> buffer (each bits contain the bits binary representation) e.g (1010)
    print(bin) --> buffer size = 4

    -- now lets redo the convertion of the binary result

    print(ASCII.BinaryToNumber(bin)) -- 10
    ```

For more complex exemple of binary convertion etc please Advanced Binary tab

### Advanced Binary

while converting number when calling BinaryNumber into a binary buffer you are also able to pass an array of number and it will return an 
array of buffer that each buffer contain the converted number

=== "Numbers to Binary Buffers"

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local bin = ASCII.BinaryNumber({10,15}) --> buffer (each bits contain the bits binary representation) e.g (1010)
    print(bin) --> {[1] = buffer,[2] = buffer}

    --[[
        for more exemple the first buffer contain the binary representation of 10 and the other one of 15
    ]]
    ```


You can also convert the array of buffer into a number

=== "Binary Buffers to Number"

    ```lua linenums="1"
    local ASCII = require(somewhere.ASCII)

    local bin = ASCII.BinaryNumber({10,15}) --> buffer (each bits contain the bits binary representation) e.g (1010)
    print(bin) --> {[1] = buffer,[2] = buffer}

    --[[
        for more exemple the first buffer contain the binary representation of 10 and the other one of 15
    ]]

    -- now lets convert all buffer into a number

    print(ASCII.BinaryToNumber(bin)) -- (e.g ASCII.BinaryToNumber({[1] = buffer,[2] = buffer}))
    --[[
        the output will display 175 cause all buffer will be merged (e.g [1010][1111])
        if you want to pass an array of buffer to converting them back into a number  i recommend you to please do a for loop and call BinaryToNumber with each buffer inside the loop.
    ]]
    ```
