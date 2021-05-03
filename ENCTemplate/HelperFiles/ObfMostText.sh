#!/bin/bash -e

# Create script as "obfSwitches.py"
cat >obfSwitches.py <<'END_SCRIPT'
import re

filler = "@@OBFS@@"

def obfuscate_switches(text):

    obf = filler.join(text)

    return obf


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


def find_normal_switches_in_file():
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

            normalText = match.group(0)
            if ((filler not in normalText) and (normalText != "")):
                print(f"Text found: {normalText}")
                print("Obfuscating switches now...")
                data = data.replace(normalText, obfuscate_switches(normalText))
                print(f"New Offset: {obfuscate_switches(normalText)}")

        # Write the new data to the file.
        data = data.replace("OBFUSCATED: ❌", "OBFUSCATED: ✅")
        write_new_data_to_file(data)


def write_new_data_to_file(data):
    with open("../Tweak.xm", "wt") as file:
        file.write(data)
        file.close()


# Find text in tweak.xm
find_normal_switches_in_file()
END_SCRIPT

# Run obfSwitches.py and use right python command 
python3 obfSwitches.py
if [ $? -eq 0 ]; then
    echo "python3 found"
else
    echo "python3 not found so using python instead :)"
    python obfSwitches.py
fi

# Delete obfSwitches.py
rm obfSwitches.py