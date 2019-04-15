#!/bin/sh
# Build a new PSConstants file from the SDK headers
./xlatepsdk.pl PI3D.h PIStringTerminology.h PITerminology.h > PSConstants.js

# EOF