        __MAIN = $1000
        .include "dos33.inc"
        .include "ca65.inc"

        KEYBOARD    = $C000
        KEYSTROBE   = $C010
        TXTCLR      = $C050 ; Mode Graphics
        MIXCLR      = $C052 ; Full  screen
        MIXSET      = $C053 ; Split screen
        PAGE1       = $C054
        HIRES       = $C057 ; Mode HGR

        HgrLo       = $F5
        HgrHi       = $F6
        glyph       = $FE
        DrawChar    = $310

DemoCharInspect:
        BIT PAGE1      ; Page 1
        BIT TXTCLR     ; not text, but graphics
        BIT MIXSET     ; Split screen text/graphics
        BIT HIRES      ; HGR, no GR

        LDA #0         ; glyph=0
        STA glyph      ; save which glyph to draw
.a      LDA #0         ; screen = 0x2000
        STA HgrLo      ;
        LDA #$20       ; HGR Page 1
        STA HgrHi      ;
        LDA glyph      ; A = glyph
        LDY #00        ; Y = col
        JSR DrawChar
.b      LDA KEYBOARD   ; read A=key
        BPL .b         ; no key?
        STA KEYSTROBE  ; debounce key
        CMP #$88       ; key == <-- ? CTRL-H
        BNE .d         ;
        DEC glyph      ; yes, --glyph
.c      LDA glyph      ; glyph &= 0x7F
        AND #$7F       ;
        STA glyph      ;
        BPL .a         ; always branch, draw prev char
.d      CMP #$95       ; key == --> ? CTRL-U
        BNE .e         ;
        INC glyph      ; yes, ++glyph
        CLC            ; always branch
        BCC .c         ;   draw prev char
.e      CMP #$9B       ; key == ESC ?
        BNE .b         ;
        RTS            ; yes, exit

PrintChar

__END:

