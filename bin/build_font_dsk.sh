!#/bin/sh
COPY=cp

 source src2dsk.sh ../asm/drawfont.s
 source src2dsk.sh ../asm/charinspect.s
 source src2dsk.sh ../asm/font7x8.s
 source src2dsk.sh ../asm/fontbb.s
 source src2dsk.sh ../asm/asciitable.s

${COPY} emptydos33.dsk hgrfont.dsk
 a2in -r b hgrfont.dsk DRAWFONT    drawfont.bin
 a2in -r b hgrfont.dsk CHARINSPECT charinspect.bin
 a2in -r b hgrfont.dsk FONT7X8     font7x8.bin
 a2in -r b hgrfont.dsk FONTBB      fontbb.bin
 a2in -r b hgrfont.dsk ASCIITABLE  asciitable.bin

