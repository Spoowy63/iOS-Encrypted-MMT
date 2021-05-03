#!/bin/bash -e

# Create script as "encryptXOR.py"
cat >encryptXOR.py <<'END_SCRIPT'
import re

cryptBaseOne = @@CBONE@@
cryptBaseTwo = @@CBTWO@@

def encrypt_offset(offset):
    return str((int(offset, 16) + cryptBaseOne) ^ cryptBaseTwo)


pattern = re.compile(r'(0x[0-9a-fA-F]{7,9})[,})]')

def find_offsets_in_file():
    with open("../Tweak.xm", "rt") as file:
        data = file.read()
        matches = pattern.finditer(data)
        hasPrintedCredits = False

        for match in matches:
            # Just cause it's cool to print things :kappa:
            if not hasPrintedCredits:
                print("="*43)
                print("OFFSET ENCRYPTION TOOL MADE BY JOEYJURJENS")
                print("="*43)
                hasPrintedCredits = True

            offsetString = match.group(1)
            print("Offset found: %s " % offsetString)
            print("Encrypting offset now...")           
            data = data.replace(offsetString, encrypt_offset(offsetString))
            print("New Offset: %s" % encrypt_offset(offsetString))

        # Write the new data to the file.
        data = data.replace("ENCRYPTED: ❌", "ENCRYPTED: ✅")
        write_new_data_to_file(data)            


def write_new_data_to_file(data):
    with open("../Tweak.xm", "wt") as file:
        file.write(data)
        file.close()

# Find the offsets in tweak.xm
find_offsets_in_file()
END_SCRIPT

# Run encryptXOR.py and use right python command 
python3 encryptXOR.py
if [ $? -eq 0 ]; then
    echo "python3 found"
else
    echo "python3 not found so using python instead :)"
    python encryptXOR.py
fi

# Delete encryptXOR.py
rm encryptXOR.py