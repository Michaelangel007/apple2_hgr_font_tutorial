#include <stdio.h>
#include "font.h"

int main()
{
    const size_t len = sizeof( FONT) / sizeof( char );
    const size_t MAX = 8192;
    char   buf[ MAX ]; // Assume font data is < 8K
    if (len > MAX)
        return printf( "ERROR: Font data to large: %u > %u\n", (unsigned) len, (unsigned) MAX );

    FILE *pFile = fopen( "font.bin", "wb" );
    if( pFile )
    {
        for( size_t i = 0; i < len; ++i )
            fwrite( &FONT[ i ], 1, 1, pFile );
        fclose( pFile );
    }       
    return 0;
}

