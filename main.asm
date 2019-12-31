
zpscreen_lo=$e ;$f0
zpscreen_hi=$f ;$f1
tmp_lc=$10
tmp_ac=$11
framec=$12
tmp=$54
slope=$90 ;8f ; 11

chardata=$2000
spritedata=$3000
screencols=$d800
bitmask=$c000
by128lo=$c080
by128hi=$c100
xs_lo=$80
xs_hi=$88
spritesx=$c400
spritesy=$c500

t_sin=$c200
t_cos=$c300 ; $c600


*=$0801

        BYTE    $0b, $08, $0A, $00, $9E, $32, $30, $36, $31, $00,  $00 , $00




maininit

spr_offx=#$77
spr_offy=#$31
ras_offy=#$28

CIA_1  =  $dc00            ; CIA#1 (Port Register A)
CIA_2  =  $dc01            ; CIA#1 (Port Register B)

CIA_ddra =  $dc02            ; CIA#1 (Data Direction Register A)
CIA_ddrb =  $dc03            ; CIA#1 (Data Direction Register B)



VIC_SPRITE_MSB=$D010
VIC_SPRITE_ENABLE=$D015
VIC_SPRITE_YEXPAND=$D017
VIC_SPRITE_PRIORITY=$D01B
VIC_SPRITE_MULTICOLOUR=$D01C
VIC_SPRITE_XEXPAND=$D01D
VIC_BORDERCOLOUR=$D020
VIC_BGCOLOUR=$D021
VIC_BGCOLOUR_MC1=$D022
VIC_BGCOLOUR_MC2=$D023

        lda #$ff
        sta VIC_SPRITE_ENABLE
        lda #$32
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        lda #$78
        sta $d000
        lda #$88
        sta $d002
        lda #$98
        sta $d004
        lda #$a8
        sta $d006
        lda #$b8
        sta $d008
        lda #$c8
        sta $d00a
        lda #$d8
        sta $d00c
        lda #$e8
        sta $d00e

        lda #$c0
        sta $07f8
        sta $07f8+1
        sta $07f8+2
        sta $07f8+3
        sta $07f8+4
        sta $07f8+5
        sta $07f8+6
        sta $07f8+7

        lda #$01
        sta $d027
        sta $d027+1
        sta $d027+2
        sta $d027+3
        sta $d027+4
        sta $d027+5
        sta $d027+6
        sta $d027+7


        ldx #$00
        sta $f0
        sta $f1
@back
        lda $0,x
        sta $0400,x
        inx
        ;jmp @back


; zero out grid variables
        ldx #07
        lda #$00
@lp10   sta xs_lo,x
        ;sta xs_hi,x
        dex
        bpl @lp10

        jsr createbitmask
        jsr copysin

        lda #$0c
        sta zpscreen_lo
        lda #$04
        sta zpscreen_hi

        lda #$18
        sta $d018

        lda #$0b
        sta $d020
        sta $d021
        ldx #$00
@milp10
        txa
        ldy #$00
@milp20     
        sta (zpscreen_lo),y
        clc
        adc #$10
        iny
        cpy #$10
        bne @milp20
        lda zpscreen_lo
        clc
        adc #$28
        sta zpscreen_lo 
        lda zpscreen_hi
        adc #$00
        sta zpscreen_hi
        inx
        cpx #$10
        bne @milp10


        jsr clearchardata
        jsr fillscreencols
        jsr createsprites



        lda #%01111111
        sta $DC0D       ;"Switch off" interrupts signals from CIA-1
        and $D011
        sta $D011       ;Clear most significant bit in VIC's raster register

        lda #$10        
        sta $D012       ; set raster to occour 1 lines down

        lda #<irq_handler
        sta $0314       ; set low bit of start
        lda #>irq_handler
        sta $0315       ; set high bit of start

        lda #%00000001
        sta $D01A
@endloop
        jmp @endloop


sprmulti0a

        clc
        lda #$00
        sta $d000
        sta $d001

        lda #spr_offy
        sta $d003
        sta $d005
        sta $d007

        lda spritesx+2
        adc spr_offx
        sta $d002
        lda spritesy+2
        ora #$c0
        sta $07f8+1
        
        lda spritesx+4
        adc spr_offx
        sta $d004
        lda spritesy+4
        ora #$c0
        sta $07f8+2

        lda spritesx+6
        adc spr_offx
        sta $d006
        lda spritesy+6
        ora #$c0
        sta $07f8+3

        rts

sprmulti0b

        lda #spr_offy
        sta $d001
        sta $d003
        sta $d005
        sta $d007

        clc
        lda spritesx+1
        adc spr_offx
        sta $d000
        lda spritesy+1
        ora #$c0
        sta $07f8+0

        lda spritesx+3
        adc spr_offx
        sta $d002
        lda spritesy+3
        ora #$c0
        sta $07f8+1
        
        lda spritesx+5
        adc spr_offx
        sta $d004
        lda spritesy+5
        ora #$c0
        sta $07f8+2

        lda spritesx+7
        adc spr_offx
        sta $d006
        lda spritesy+7
        ora #$c0
        sta $07f8+3

        rts

sprmulti1a

        lda #spr_offy+$10
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        clc
        lda spritesx+8
        adc spr_offx
        sta $d008
        lda spritesy+8
        ora #$c0
        sta $07f8+4

        lda spritesx+10
        adc spr_offx
        sta $d00a
        lda spritesy+10
        ora #$c0
        sta $07f8+5
        
        lda spritesx+12
        adc spr_offx
        sta $d00c
        lda spritesy+12
        ora #$c0
        sta $07f8+6

        lda spritesx+14
        adc spr_offx
        sta $d00e
        lda spritesy+14
        ora #$c0
        sta $07f8+7

        rts

sprmulti1b

        lda #spr_offy+$10
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        clc
        lda spritesx+9
        adc spr_offx
        sta $d008
        lda spritesy+9
        ora #$c0
        sta $07f8+4

        lda spritesx+11
        adc spr_offx
        sta $d00a
        lda spritesy+11
        ora #$c0
        sta $07f8+5
        
        lda spritesx+13
        adc spr_offx
        sta $d00c
        lda spritesy+13
        ora #$c0
        sta $07f8+6

        lda spritesx+15
        adc spr_offx
        sta $d00e
        lda spritesy+15
        ora #$c0
        sta $07f8+7

        rts

sprmulti2a

        lda #spr_offy+$20
        sta $d001
        sta $d003
        sta $d005
        sta $d007


        clc
        lda spritesx+16
        adc spr_offx
        sta $d000
        lda spritesy+16
        ora #$c0
        sta $07f8+0

        lda spritesx+18
        adc spr_offx
        sta $d002
        lda spritesy+18
        ora #$c0
        sta $07f8+1
        
        lda spritesx+20
        adc spr_offx
        sta $d004
        lda spritesy+20
        ora #$c0
        sta $07f8+2

        lda spritesx+22
        adc spr_offx
        sta $d006
        lda spritesy+22
        ora #$c0
        sta $07f8+3

        rts

sprmulti2b

        lda #spr_offy+$20
        sta $d001
        sta $d003
        sta $d005
        sta $d007

        clc
        lda spritesx+17
        adc spr_offx
        sta $d000
        lda spritesy+17
        ora #$c0
        sta $07f8+0

        lda spritesx+19
        adc spr_offx
        sta $d002
        lda spritesy+19
        ora #$c0
        sta $07f8+1
        
        lda spritesx+21
        adc spr_offx
        sta $d004
        lda spritesy+21
        ora #$c0
        sta $07f8+2

        lda spritesx+23
        adc spr_offx
        sta $d006
        lda spritesy+23
        ora #$c0
        sta $07f8+3

        rts

sprmulti3a

        lda #spr_offy+$30
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f


        clc
        lda spritesx+24
        adc spr_offx
        sta $d008
        lda spritesy+24
        ora #$c0
        sta $07f8+4

        lda spritesx+26
        adc spr_offx
        sta $d00a
        lda spritesy+26
        ora #$c0
        sta $07f8+5
        
        lda spritesx+28
        adc spr_offx
        sta $d00c
        lda spritesy+28
        ora #$c0
        sta $07f8+6

        lda spritesx+30
        adc spr_offx
        sta $d00e
        lda spritesy+30
        ora #$c0
        sta $07f8+7

        rts

sprmulti3b

        lda #spr_offy+$30
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        clc
        lda spritesx+25
        adc spr_offx
        sta $d008
        lda spritesy+25
        ora #$c0
        sta $07f8+4

        lda spritesx+27
        adc spr_offx
        sta $d00a
        lda spritesy+27
        ora #$c0
        sta $07f8+5
        
        lda spritesx+29
        adc spr_offx
        sta $d00c
        lda spritesy+29
        ora #$c0
        sta $07f8+6

        lda spritesx+31
        adc spr_offx
        sta $d00e
        lda spritesy+31
        ora #$c0
        sta $07f8+7

        rts

sprmulti4a

        lda #spr_offy+$40
        sta $d001
        sta $d003
        sta $d005
        sta $d007


        clc
        lda spritesx+32
        adc spr_offx
        sta $d000
        lda spritesy+32
        ora #$c0
        sta $07f8+0

        lda spritesx+34
        adc spr_offx
        sta $d002
        lda spritesy+34
        ora #$c0
        sta $07f8+1
        
        lda spritesx+36
        adc spr_offx
        sta $d004
        lda spritesy+36
        ora #$c0
        sta $07f8+2

        lda spritesx+38
        adc spr_offx
        sta $d006
        lda spritesy+38
        ora #$c0
        sta $07f8+3

        rts

sprmulti4b

        lda #spr_offy+$40
        sta $d001
        sta $d003
        sta $d005
        sta $d007


        clc
        lda spritesx+33
        adc spr_offx
        sta $d000
        lda spritesy+33
        ora #$c0
        sta $07f8+0

        lda spritesx+35
        adc spr_offx
        sta $d002
        lda spritesy+35
        ora #$c0
        sta $07f8+1
        
        lda spritesx+37
        adc spr_offx
        sta $d004
        lda spritesy+37
        ora #$c0
        sta $07f8+2

        lda spritesx+39
        adc spr_offx
        sta $d006
        lda spritesy+39
        ora #$c0
        sta $07f8+3

        rts

sprmulti5a

        lda #spr_offy+$50
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        clc
        lda spritesx+40
        adc spr_offx
        sta $d008
        lda spritesy+40
        ora #$c0
        sta $07f8+4

        lda spritesx+42
        adc spr_offx
        sta $d00a
        lda spritesy+42
        ora #$c0
        sta $07f8+5
        
        lda spritesx+44
        adc spr_offx
        sta $d00c
        lda spritesy+44
        ora #$c0
        sta $07f8+6

        lda spritesx+46
        adc spr_offx
        sta $d00e
        lda spritesy+46
        ora #$c0
        sta $07f8+7

        rts

sprmulti5b

        lda #spr_offy+$50
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f


        clc
        lda spritesx+41
        adc spr_offx
        sta $d008
        lda spritesy+41
        ora #$c0
        sta $07f8+4

        lda spritesx+43
        adc spr_offx
        sta $d00a
        lda spritesy+43
        ora #$c0
        sta $07f8+5
        
        lda spritesx+45
        adc spr_offx
        sta $d00c
        lda spritesy+45
        ora #$c0
        sta $07f8+6

        lda spritesx+47
        adc spr_offx
        sta $d00e
        lda spritesy+47
        ora #$c0
        sta $07f8+7

        rts

sprmulti6a
        lda #spr_offy+$60
        sta $d001
        sta $d003
        sta $d005
        sta $d007

        clc
        lda spritesx+48
        adc spr_offx
        sta $d000
        lda spritesy+48
        ora #$c0
        sta $07f8+0

        lda spritesx+50
        adc spr_offx
        sta $d002
        lda spritesy+50
        ora #$c0
        sta $07f8+1
        
        lda spritesx+52
        adc spr_offx
        sta $d004
        lda spritesy+52
        ora #$c0
        sta $07f8+2

        lda spritesx+54
        adc spr_offx
        sta $d006
        lda spritesy+54
        ora #$c0
        sta $07f8+3

        rts

sprmulti6b
        lda #spr_offy+$60
        sta $d001
        sta $d003
        sta $d005
        sta $d007


        clc
        lda spritesx+49
        adc spr_offx
        sta $d000
        lda spritesy+49
        ora #$c0
        sta $07f8+0

        lda spritesx+51
        adc spr_offx
        sta $d002
        lda spritesy+51
        ora #$c0
        sta $07f8+1
        
        lda spritesx+53
        adc spr_offx
        sta $d004
        lda spritesy+53
        ora #$c0
        sta $07f8+2

        lda spritesx+55
        adc spr_offx
        sta $d006
        lda spritesy+55
        ora #$c0
        sta $07f8+3

        rts

sprmulti7a

        lda #spr_offy+$70
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f



        clc
        lda spritesx+56
        adc spr_offx
        sta $d008
        lda spritesy+56
        ora #$c0
        sta $07f8+4

        lda spritesx+58
        adc spr_offx
        sta $d00a
        lda spritesy+58
        ora #$c0
        sta $07f8+5
        
        lda spritesx+60
        adc spr_offx
        sta $d00c
        lda spritesy+60
        ora #$c0
        sta $07f8+6

        lda spritesx+62
        adc spr_offx
        sta $d00e
        lda spritesy+62
        ora #$c0
        sta $07f8+7

        rts

sprmulti7b

        lda #spr_offy+$70
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f



        clc
        lda spritesx+57
        adc spr_offx
        sta $d008
        lda spritesy+57
        ora #$c0
        sta $07f8+4

        lda spritesx+59
        adc spr_offx
        sta $d00a
        lda spritesy+59
        ora #$c0
        sta $07f8+5
        
        lda spritesx+61
        adc spr_offx
        sta $d00c
        lda spritesy+61
        ora #$c0
        sta $07f8+6

        lda spritesx+63
        adc spr_offx
        sta $d00e
        lda spritesy+63
        ora #$c0
        sta $07f8+7

        rts



irq_handler
        inc framec
        lda framec
        and #$01
        sta framec
        beq @even
@odd

        lda ras_offy
@odd10
        cmp $d012
        bne @odd10
        jsr sprmulti0b
        lda #ras_offy+16
@odd20
        cmp $d012
        bne @odd20
        jsr sprmulti1b
        lda #ras_offy+32
@odd30
        cmp $d012
        bne @odd30
        jsr sprmulti2b
        lda #ras_offy+48
@odd40
        cmp $d012
        bne @odd40
        jsr sprmulti3b
        lda #ras_offy+64
@odd50
        cmp $d012
        bne @odd50
        jsr sprmulti4b
        lda #ras_offy+80
@odd60
        cmp $d012
        bne @odd60
        jsr sprmulti5b
        lda #ras_offy+96
@odd70
        cmp $d012
        bne @odd70
        jsr sprmulti6b
        lda #ras_offy+112
@odd80
        cmp $d012
        bne @odd80
        jsr sprmulti7b

        jmp @end
@even
        lda ras_offy
@even10
        cmp $d012
        bne @even10
        jsr sprmulti0a
        lda #ras_offy+#$10
@even20
        cmp $d012
        bne @even20
        jsr sprmulti1a
        lda #ras_offy+#$20
@even30
        cmp $d012
        bne @even30
        jsr sprmulti2a
        lda #ras_offy+#$30
@even40
        cmp $d012
        bne @even40
        jsr sprmulti3a
        lda #ras_offy+#$40
@even50
        cmp $d012
        bne @even50
        jsr sprmulti4a
        lda #ras_offy+#$50
@even60
        cmp $d012
        bne @even60
        jsr sprmulti5a
        lda #ras_offy+#$60
@even70
        cmp $d012
        bne @even70
        jsr sprmulti6a
        lda #ras_offy+#$70
@even80
        cmp $d012
        bne @even80
        jsr sprmulti7a
        jmp @end





@end

        lda #%11111111  ; CIA#1 Port A set to output 
        sta CIA_ddra             
        lda #%00000000  ; CIA#1 Port B set to input
        sta CIA_ddrb             


        lda #%01111111  ; select row 8
        sta CIA_1 
        lda CIA_2         ; load column information
        and #%00010000  ; test 'space' key to exit 
        bne @ret      ; zero flag is not set -> skip to right

        jsr clearchardata

@ret


        lda #$c0
@lp30
        cmp $d012
        bne @lp30
        jmp mainloop



mathtmp byte 0,$10,$20,$30,$40,$50,$60,$70

mainloop
       ;inc $d020
        lda framec
        beq @dostuff
        jmp @donostuff
@dostuff

        ; do maths on grid variables
        ldx #07
@lp     
        txa
        clc
        adc xs_lo,x
        sta xs_lo,x
        dex
        bpl @lp





        ; first stuff
        ldx #$07
        stx tmp_lc
@lpa10
        lda mathtmp,x
        sta @buma+1
        lda xs_lo,x
        tay
        lda t_sin,y
        clc
@buma
        adc #$10
        pha
        lda t_cos,y
        sta spritesy,x
        tay
        pla
        sta spritesx,x
        tax
        jsr plotadot 

        dec tmp_lc
        ldx tmp_lc
        cpx #$00
        bne @lpa10

        ; left 1
        lda spritesx+1
        sec
        sbc #$10
        sta spritesx+8
        lda spritesy+1
        sta spritesy+8

        ;left 2
        lda spritesx+2
        sec
        sbc #$20
        sta spritesx+16
        lda spritesy+2
        sta spritesy+16

        ;left 3
        lda spritesx+3
        sec
        sbc #$30
        sta spritesx+24
        lda spritesy+3
        sta spritesy+24

        ;left 4
        lda spritesx+4
        sec
        sbc #$40
        sta spritesx+32
        lda spritesy+4
        sta spritesy+32

        ;left 5
        lda spritesx+5
        sec
        sbc #$50
        sta spritesx+40
        lda spritesy+5
        sta spritesy+40

        ;left 6
        lda spritesx+6
        sec
        sbc #$60
        sta spritesx+48
        lda spritesy+6
        sta spritesy+48

        ;left 7
        lda spritesx+7
        sec
        sbc #$70
        sta spritesx+56
        lda spritesy+7
        sta spritesy+56


        lda #$38
        sta @poo1+1
        sta @poo2+1


        lda #<xs_lo+7
        sta @bum3+1
        
        ; inner loop
        ldx #$07
        stx tmp_ac
@lp10   
        lda mathtmp,x
        sta @bum2+1     
        ldx #$07
        stx tmp_lc
@lp20
        lda mathtmp,x
        sta @bum+1
        lda xs_lo,x
        tay
        lda t_sin,y
        clc
@bum
        adc #$10
@poo1   sta spritesx+8,x

        ;tax
        pha
        
@bum3
        ldy xs_lo
        lda t_cos,y
@poo2   sta spritesy+8,x
        ;clc
@bum2
        adc #$10
        tay
        pla
        tax
        jsr plotadot 

        dec tmp_lc
        ldx tmp_lc
        bne @lp20

        lda @poo1+1
        sec
        sbc #$08
        sta @poo1+1
        sta @poo2+1
        

        dec @bum3+1
        dec tmp_ac
        ldx tmp_ac
        bne @lp10








@donostuff


        inc $f0

        asl $D019
        JMP $EA31



createbitmask

        lda #<chardata
        sta zpscreen_lo
        lda #>chardata
        sta zpscreen_hi

        ldx #$00
@cbm10
        txa
        and #$07
        tay
        lda bitmasktmp,y
        sta bitmask,x

        cmp #$80
        bne @for


        



        ; create maths tables
@for
        lda zpscreen_lo
        sta by128lo,x
        lda zpscreen_hi
        sta by128hi,x

        inx
        txa
        and #$07
        bne @past

        lda zpscreen_lo
        clc
        adc #$80
        sta zpscreen_lo
        lda zpscreen_hi
        adc #$00
        sta zpscreen_hi


@past
        cpx #$80
        bne @cbm10




        rts



plotadot ; call with x=x, y-y. Destroys a
        lda by128lo,x
        sta zpscreen_lo
        lda by128hi,x
        sta zpscreen_hi
        lda bitmask,x
        ora (zpscreen_lo),y 
        sta (zpscreen_lo),y
        rts


clearchardata
        ldx #$00
        txa
@clearchardata10
        lda staticchars,x
        sta chardata,x
        lda #$00
        sta chardata+$100,x
        sta chardata+$200,x
        sta chardata+$300,x
        sta chardata+$400,x
        sta chardata+$500,x
        sta chardata+$600,x
        sta chardata+$700,x
        dex
        bne @clearchardata10
        rts

fillscreencols

        ldx #$00
@fsc30
        lda scrndata,x
        sta $0400,x
        lda scrndata+$100,x
        sta $0400+$100,x
        lda scrndata+$200,x
        sta $0400+$200,x
        lda scrndata+$2e8,x
        sta $0400+$2e8,x
        lda coldata,x
        sta $d800,x
        lda coldata+$100,x
        sta $d800+$100,x
        lda coldata+$200,x
        sta $d800+$200,x
        lda coldata+$2e8,x
        sta $d800+$2e8,x
        inx
        bne @fsc30
        rts


copysin
        ldx #$00
@cs10
        lda sintmp,x
        sta t_sin,x
        lda costmp,x
        sta t_cos,x
        inx
        bne @cs10



        ldx #$00
@cs20
        lda spritedata,x
        sta $3000,x
        inx
        cpx #$40
        bne @cs20



        rts




createsprites

        ; clear 1k of sprite data
        ldx #$00
        txa
@cs10
        sta spritedata,x
        sta spritedata+$100,x
        sta spritedata+$200,x
        sta spritedata+$300,x
        inx
        bne @cs10

        lda #<spritedata
        sta tmp
        lda #>spritedata
        sta tmp+1

        ldx #$00
@cs20
        lda #$e0
        ldy #00
        sta (tmp),y
        iny
        iny
        iny
        sta (tmp),y
        iny
        iny
        iny
        sta (tmp),y

        lda tmp
        clc
        adc #$43
        sta tmp
        lda tmp+1
        adc #$00
        sta tmp+1
        inx
        cpx #$10
        bne @cs20
        rts




bitmasktmp byte 128,64,32,16,8,4,2,1

sintmp  byte 7,7,7,6,6,6,6,6,6,5,5,5,5,5,5,4,4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8,8,7,7
costmp  byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,6,5,5,5,5,5,5,4,4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


scrndata
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$0F,$11,$0F,$11,$0F,$11,$0F,$11,$0F,$11,$0F,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$10,$12,$10,$12,$10,$12,$10,$12,$10,$12,$10,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$22,$32,$42,$52,$62,$72,$82,$92,$A2,$B2,$C2,$D2,$E2,$F2,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$23,$33,$43,$53,$63,$73,$83,$93,$A3,$B3,$C3,$D3,$E3,$F3,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$24,$34,$44,$54,$64,$74,$84,$94,$A4,$B4,$C4,$D4,$E4,$F4,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$25,$35,$45,$55,$65,$75,$85,$95,$A5,$B5,$C5,$D5,$E5,$F5,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$26,$36,$46,$56,$66,$76,$86,$96,$A6,$B6,$C6,$D6,$E6,$F6,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$27,$37,$47,$57,$67,$77,$87,$97,$A7,$B7,$C7,$D7,$E7,$F7,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$28,$38,$48,$58,$68,$78,$88,$98,$A8,$B8,$C8,$D8,$E8,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$29,$39,$49,$59,$69,$79,$89,$99,$A9,$B9,$C9,$D9,$E9,$F9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$2A,$3A,$4A,$5A,$6A,$7A,$8A,$9A,$AA,$BA,$CA,$DA,$EA,$FA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$2B,$3B,$4B,$5B,$6B,$7B,$8B,$9B,$AB,$BB,$CB,$DB,$EB,$FB,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$2C,$3C,$4C,$5C,$6C,$7C,$8C,$9C,$AC,$BC,$CC,$DC,$EC,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$2D,$3D,$4D,$5D,$6D,$7D,$8D,$9D,$AD,$BD,$CD,$DD,$ED,$FD,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$11,$2E,$3E,$4E,$5E,$6E,$7E,$8E,$9E,$AE,$BE,$CE,$DE,$EE,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$12,$2F,$3F,$4F,$5F,$6F,$7F,$8F,$9F,$AF,$BF,$CF,$DF,$EF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$03,$00,$03,$00,$04,$05,$02,$00,$06,$07,$00,$01,$02,$03,$02,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$04,$09,$0A,$02,$00,$0B,$0C,$0D,$0D,$02,$01,$00,$00,$0E,$07,$0E,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


coldata
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$02,$02,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$02,$02,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$08,$08,$08,$08,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$08,$08,$08,$08,$08,$08,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$07,$07,$07,$07,$07,$07,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$07,$07,$07,$07,$07,$07,$07,$07,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$01,$01,$01,$01,$01,$0B,$01,$01,$01,$01,$01,$0B,$01,$01,$0B,$01,$01,$01,$01,$01,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$01,$01,$01,$01,$01,$0B,$01,$01,$01,$01,$01,$01,$0B,$0B,$01,$01,$01,$01,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
        BYTE    $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B

staticchars
        BYTE    $FC,$E6,$E6,$FC,$E0,$E0,$E0,$00
        BYTE    $FC,$E6,$E6,$FC,$E6,$E6,$E6,$00
        BYTE    $FE,$E6,$E0,$F8,$E0,$E6,$FE,$00
        BYTE    $7E,$E6,$E0,$3C,$06,$E6,$FC,$00
        BYTE    $7C,$E6,$E6,$FE,$E6,$E6,$E6,$00
        BYTE    $7C,$E6,$E0,$E0,$E0,$E6,$7C,$00
        BYTE    $FE,$18,$18,$18,$18,$18,$18,$00
        BYTE    $7C,$E6,$E6,$E6,$E6,$E6,$7C,$00
        BYTE    $06,$06,$06,$06,$E6,$E6,$7C,$00
        BYTE    $FC,$D6,$D6,$D6,$C6,$C6,$C6,$00
        BYTE    $18,$18,$18,$18,$18,$18,$18,$00
        BYTE    $FE,$E6,$E0,$F8,$E0,$E0,$E0,$00
        BYTE    $E6,$E6,$E6,$E6,$E6,$E6,$7C,$00
        BYTE    $E0,$E0,$E0,$E0,$E0,$E0,$FE,$00
        BYTE    $7C,$E6,$06,$7E,$E0,$E0,$FE,$00
        BYTE    $0F,$30,$60,$40,$80,$80,$80,$80
        BYTE    $80,$80,$80,$40,$60,$30,$0F,$00
        BYTE    $E0,$18,$0C,$04,$02,$02,$02,$02
        BYTE    $02,$02,$02,$04,$0C,$18,$E0,$00

