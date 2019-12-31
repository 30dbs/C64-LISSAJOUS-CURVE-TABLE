# C64-LISSAJOUS-CURVE-TABLE
a LISSAJOUS CURVE TABLE for the C64

This uses an emulated hires bitmap screen using a 16x16 matrix of chars, to allow for much fast plotting of dots, to allow the white "drawing" dots I had to multiplex 64 sprites, this was impossible to due to the 21 pixel restriction of sprite multiplexing, so I had to improvise and created an interlaced multiplexor, that multiplexes 32 sprites but switches there locations every other frame to give the illusion of 64 (albeit flashing) sprites.

The multiplexer also only adjusts the xposition, the yposition changing made the multiplexer glitch at key points where things sprites overlapped, to over come this the yposition is actually just a different sprite animation for each of the possible 16 positions.

I hope the code isn't too ugly, it's unoptimised and still has some great variable names in there such as @poop1 and @bum3 :)
