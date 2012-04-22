#!/bin/awk -f
#
# Expects the result of running "od -A d -t x1 binaryfile >textfile" as input
# (run this program on "textfile")

    # Before reading any input...
BEGIN {
        # Establish the type of this variable as numeric
    offset = 0
}

    # For each line of input...
{
        # If there is more than one word in the input line (optimization
        # against the last line being only an offset value)...
    if ( NF > 1 ) {
        # ...form a valid monitor command line from this input line
        # Output the address that we want the Apple ][ monitor to store the
        # following hex values at, followed by the uppercased hex values
            # Make the address out of the first field (adjust the added
            # constant to your individual situation)
        offset = $1 + 0x138F
        printf( "%X:", offset )
            # Output the rest of the fields, uppercased
        for ( i = 2; i <= NF; ++i ) {
            printf( " %s", toupper($i) )
        }
            # DOS line ending required for correct transfer through
            # HyperTerminal's Transfer->Send Text File... into Apple serial card
        printf "\r\n"
    }
}
