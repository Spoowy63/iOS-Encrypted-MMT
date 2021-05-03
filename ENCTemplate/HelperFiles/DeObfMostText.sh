#!/bin/bash -e

# Create script as "deobfSwitches.py"
cat >deobfSwitches.py <<'END_SCRIPT'
import re

filler = "@@OBFS@@"


def deobfuscate_switches(text):

    deobf = text.replace(filler,"")

    return deobf


'''
pattern explained:
it just grabs xxxxx. examples:
addSwitch:@"xxxxx"
addSliderSwitch:@"xxxxx"
isSwitchOn:@"xxxx"
description:@"xxxx" 
'''

pattern = re.compile(
    r'((?<=Switch:@")|(?<=isSwitchOn:@")|(?<=description:@")|(?<=initWithHeaderTitle:@")|(?<=watermarkText:@")).*?(?=")')


def find_obfuscated_switches_in_file():
    with open("../Tweak.xm", "rt") as file:
        data = file.read()
        matches = pattern.finditer(data)

        hasPrintedCredits = False

        for match in matches:

            # Just cause it's cool to print things :kappa:
            if not hasPrintedCredits:
                print("=" * 43)
                print("Made By: github.com/Spoowy63")
                print("=" * 43)
                hasPrintedCredits = True

            obfText = match.group(0)
            if ((filler in obfText) and (obfText != "")):
                print(f"Text found: {obfText}")
                print("Deobfuscate switches now...")
                data = data.replace(obfText, deobfuscate_switches(obfText))
                print(f"New Offset: {deobfuscate_switches(obfText)}")

        # Write the new data to the file.
        data = data.replace("OBFUSCATED: ✅", "OBFUSCATED: ❌")
        write_new_data_to_file(data)


def write_new_data_to_file(data):
    with open("../Tweak.xm", "wt") as file:
        file.write(data)
        file.close()


# Find text in tweak.xm
find_obfuscated_switches_in_file()
END_SCRIPT

# Run deobfSwitches.py and use right python command 
python3 deobfSwitches.py
if [ $? -eq 0 ]; then
    echo "python3 found"
else
    echo "python3 not found so using python instead :)"
    python deobfSwitches.py
fi

# Delete deobfSwitches.py
rm deobfSwitches.py