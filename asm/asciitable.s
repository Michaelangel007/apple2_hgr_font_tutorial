        __MAIN = $1080
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
        HgrLoY      = $3A0
        HgrHiY      = $3B8

AsciiTable
        BIT PAGE1       ; Page 1
        BIT TXTCLR      ; not text, but graphics
        BIT MIXSET      ; Split screen text/graphics
        BIT HIRES       ; HGR, no GR

        LDA #0          ; glyph=0
        STA glyph       ; save which glyph to draw

        LDY #8          ; Row=8
_RowN
        LDA HgrLoY,Y
        STA HgrLo       ; Screen Address Lo
        LDA HgrHiY,Y
        ORA #$20        ; HGR Page 1
        STA HgrHi       ; Screen Address Hi

        LDY #00         ; Y = col
_Glyph
        LDA glyph       ; A = glyph
        JSR DrawChar
        INC glyph       ; yes, ++glyph
        LDA glyph       ;
        CMP #$20        ; done 16 chars?
        BEQ _Row1
        CMP #$40
        BEQ _Row2
        CMP #$60
        BEQ _Row3
        CMP #$80
        BNE _Glyph      ;
_Done   RTS             ; Optimization: BEQ _Row4
_Row1   LDY #9
        BNE _RowN
_Row2   LDY #10
        BNE _RowN
_Row3   LDY #11
        BNE _RowN

__END:

