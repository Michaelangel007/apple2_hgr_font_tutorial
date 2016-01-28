        __MAIN = $301
        .include "dos33.inc"
        .include "ca65.inc"

; Listing 11

        HgrLo   = $E5   ; Low  byte Pointer to screen destination
        HgrHi   = $E6   ; High byte Pointer to screen destination
        String  = $F0
        TmpLo   = $F5   ; Low  byte Working pointer to screen byte
        TmpHi   = $F6   ; High byte Working pointer to screen byte
        TopHi   = $FD
        Font    = $6000

;       ORG $0301 ; Listing 8
DrawHexByte:
        PHA             ; save low nibble
        ROR             ; shift high nibble
        ROR             ; to low nibble
        ROR             ;
        ROR             ;
        JSR DrawHexNib  ; print high nib in hex
        PLA             ; pritn low  nib in hex
DrawHexNib:
        AND #$F         ; base 16
        TAX             ;
        LDA NIB2HEX,X   ; nibble to ASCII
;       ORG $0310 ; Listing 5
DrawChar:
        JMP DrawCharCol
;       ORG $0313 ; Listing 9
SetCursorRow:
        LDA HgrLoY,X   ; HgrLoY[ row ]
        STA TmpLo
        LDA HgrHiY,X   ; HgrHiY[ row ]
        CLC
        ADC HgrHi
        STA TmpHi
        RTS
;       ORG $0321 ; Listing 11
SetCursorColRow:
        STX TmpLo
        LDA HgrLoY,Y    ; HgrLoY[ row ]
        CLC
        ADC TmpLo       ; add column
        STA TmpLo
        LDA HgrHiY,Y    ; HgrHiY[ row ]
        CLC             ; \ could optimize this into
        ADC HgrHi       ; / single ORA HgrHi
        STA TmpHi
        RTS
        NOP             ; pad
;       ORG $0335 ; Listing 6
DrawCharColRow:
        PHA
        JSR SetCursorRow
        PLA
;       ORG $033A ; Listing 7
DrawCharCol:           ;     A=%PQRstuvw
        ROL            ; C=P A=%QRstuvw?
        ROL            ; C=Q A=%Rstuvw?P
        ROL            ; C=R A=%stuvw?PQ
        TAX            ;     X=%stuvw?PQ push glyph
        AND #$F8       ;     A=%stuvw000
        STA _LoadFont+1; AddressLo = (c*8)
        TXA            ;     A=%stuvw?PQ pop glyph
        AND #3         ; Optimization: s=0 implicit CLC !
        ROL            ; C=s A=%00000PQR and 1 last ROL to get R
        ADC #>Font     ; += FontHi; Carry=0 since s=0 from above
        STA _LoadFont+2; AddressHi = FontHi + (c/32)
;       ORG $034C ; Listing 4a
_DrawChar1:
        LDX TmpHi
        STX TopHi
;       ORG $0350 ; Listing 1
_DrawChar:
        LDX #0
_LoadFont:              ; A = font[ offset ]
        LDA Font,X
        STA (TmpLo),Y   ; screen[col] = A
        CLC
        LDA TmpHi       ;
        ADC #4          ; screen += 0x400
        STA TmpHi
        INX
        CPX #8
        BNE _LoadFont
;       ORG $0363 ; Listing 4a
IncCursorCol:
        INY
        LDX TopHi       ; Move cursor back to top of scanline
        STX TmpHi
        RTS
;       ORG $0369 ; Listing 10
SetCursorColRowYX:
        JSR SetCursorRow
        CLC
        TYA
        ADC TmpLo
        STA TmpLo
        RTS
;       ORG $037E ; Listing 12
DrawString:
         STY String+0
         STX String+1
         LDY #0
_ds1:    LDA (String),Y
         BEQ _ds2       ; null byte? Done
         JSR DrawChar   ; or DrawCharCol for speed
         CPY #40        ; col < 40?
         BCC _ds1
_ds2:    RTS

                        ; pad $0385 .. $38F
        .res $390 - *, $00

;       ORG $0390 ; Listing 8
NIB2HEX:
        .byte "0123456789ABCDEF"
;       ORG $03A0 ; Listing 9a
HgrLoY:
        .byte $00,$80,$00,$80,$00,$80,$00,$80
        .byte $28,$A8,$28,$A8,$28,$A8,$28,$A8
        .byte $50,$D0,$50,$D0,$50,$D0,$50,$D0
HgrHiY:
        .byte $00,$00,$01,$01,$02,$02,$03,$03
        .byte $00,$00,$01,$01,$02,$02,$03,$03
        .byte $00,$00,$01,$01,$02,$02,$03,$03

__END:

