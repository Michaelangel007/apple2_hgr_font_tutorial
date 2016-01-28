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
        row         = $FF
        DrawChar    = $310
        HgrLoY      = $3A0
        HgrHiY      = $3B8

        START_ROW   = 0

AsciiTable
        LDY #(START_ROW-1) & $FF
        STY row

        LDA #0          ; glyph=0
        STA glyph       ; save which glyph to draw

        BIT PAGE1       ; Page 1
        BIT TXTCLR      ; not text, but graphics
        BIT MIXSET      ; Split screen text/graphics
        BIT HIRES       ; HGR, no GR
_NextRow
        INC row
        LDY row
        LDA HgrLoY,Y
        STA HgrLo       ; Screen Address Lo
        LDA HgrHiY,Y
        ORA #$20        ; HGR Page 1
        STA HgrHi       ; Screen Address Hi

        LDY #00         ; Y = col
_NextCol
        LDA glyph       ; A = glyph
        JSR DrawChar
        INC glyph       ; yes, ++glyph
        LDA glyph       ;
        CMP #$20        ; done 16 chars?
        BEQ _NextRow
        CMP #$40
        BEQ _NextRow
        CMP #$60
        BEQ _NextRow
        CMP #$80
        BNE _NextCol
_Done   RTS             ; Optimization: BEQ _NextRow

__END:

