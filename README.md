# JPEB

This is the top level repo for the JPEB computer system.

Clone the repo with `git clone --recurse-submodules`  
Pull the updates with `git pull --recurse-submodules`  

Use the makefile here for full stack tests. 
Note that this requires building the compiler, emulator, and simulator before hand.  
`make add_test`  
`make add_test.clean` cleans only that test  
`make add_test.run` compiles and runs the test in simulation  

## Docs
[ISA](https://github.com/PaulBailey-1/JPEB/blob/main/docs/ISA.md)  
[Memory Map](https://github.com/PaulBailey-1/JPEB/blob/main/docs/mem_map.md)  
[Calling Conventions](https://github.com/PaulBailey-1/JPEB/blob/main/docs/calling_conventions.md)  
[IO](https://github.com/PaulBailey-1/JPEB/blob/main/docs/IO.md#io)
