#!/bin/bash -e

# Create script as "decryptXOR.py"
cat >decryptXOR.py <<'END_SCRIPT'
import re

#######################################
#THIS IS BASICALLY JUST THE MODIFIED ENCRYPT FILE THAT JOEY MADE SO MOST CREDITS GO TO HIM :)
#######################################

# Change those two to your own numbers, make sure they are different from each other!
# Make sure you puth for both a 19 numbers long number, else it will fuck up.
# If you change these, also open Utils.h & change them there too with the same values you have here.
cryptBaseOne = @@CBONE@@
cryptBaseTwo = @@CBTWO@@

def decrypt_offset(offset):
    return str(hex(((int(hex(int(offset)), 16) ^ cryptBaseTwo) - cryptBaseOne)))

# Translation of this pattern:
# Encrypted offset contain numbers --> [0-9]
# Only want encrypted offsets and not some random one digit number --> {6,30}
# Must end with: ',' or '}' or ')' --> [,})]
    # Last encrypted offset in switch will end with '}'
    # multiple encrypted offsets in array is ','
    # getRealOffset ends with ')'
pattern = re.compile(r'([0-9]{10,30})[,})]')

def find_encrypted_offsets_in_file():
    with open("../Tweak.xm", "rt") as file:
        data = file.read()
        matches = pattern.finditer(data)
        hasPrintedCredits = False

        for match in matches:
            # Just cause it's cool to print things :kappa:
            if not hasPrintedCredits:
                print("="*43)
                print("Made By: github.com/Spoowy63\nThanks to Joey for the original encrypt file :)")
                print("="*43)
                hasPrintedCredits = True

            offsetString = match.group(1)
            print("Offset found: %s " % offsetString)
            print("Decrypting offset now...")           
            data = data.replace(offsetString, decrypt_offset(offsetString))
            print("New Offset: %s" % decrypt_offset(offsetString))

        # Write the new data to the file.
        data = data.replace("ENCRYPTED: ✅", "ENCRYPTED: ❌")
        write_new_data_to_file(data)            


def write_new_data_to_file(data):
    with open("../Tweak.xm", "wt") as file:
        file.write(data)
        file.close()

# Find the offsets in tweak.xm
find_encrypted_offsets_in_file()
END_SCRIPT

# Run decryptXOR.py and use right python command 
python3 decryptXOR.py
if [ $? -eq 0 ]; then
    echo "python3 found"
else
    echo "python3 not found so using python instead :)"
    python decryptXOR.py
fi

# Delete decryptXOR.py
rm decryptXOR.py