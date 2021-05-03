
sub firstCB {
   my $firstmin = 1010101010101010101;
   my $firstmax = 5016492529562845104;
   my $CBONERAND = int(rand($firstmax-$firstmin)) + $firstmin;
   if (substr("$CBONERAND", -1) eq "0"){  
     firstCB();
   } else {
     return $CBONERAND;
   }
}



sub secondCB {
   my $secmin = 5016492529562845105;
   my $secmax = 8999999999999999999;
   my $CBTWORAND = int(rand($secmax-$secmin)) + $secmin;
   if (substr("$CBTWORAND", -1) eq "0"){  
     secondCB();
   } else {
     return $CBTWORAND;
   }

}




my @chars = ("A".."Z", "a".."z", 0..9, "!", "?");

my $string;
$string .= $chars[rand @chars] for 1..30;

my $CBONEVAR = firstCB();
my $CBTWOVAR = secondCB();


NIC->variable("OBFS") = "$string";


print "\e[38;5;203m Enc/Obf codes:\e[0m \n\e[38;5;199m $CBONEVAR\e[0m \n\e[38;5;117m $CBTWOVAR\e[0m \n\e[38;5;142m $string\e[0m";


NIC->prompt("APPNAME", "Enter name of the app", {default => ""});

NIC->prompt("HDRT", "Enter Header Title", {default => ""});

NIC->prompt("SITE", "Enter the site where the hack is for", {default => ""});

NIC->variable("CBONE") = "$CBONEVAR";
NIC->variable("CBTWO") = "$CBTWOVAR";


NIC->variable("htmlStuff") = "<p class='text'> Encrypted template put together by:<br> <a href='https://github.com/Spoowy63'>https://github.com/Spoowy63</a><br><br>For more info on how to use this menu:<br><a href='https://github.com/Spoowy63/iOS-Encrypted-MMT'>https://github.com/Spoowy63/iOS-Encrypted-MMT</a><br><br>original template without encryption:<br><a href='https://github.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos'>https://github.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos</a><br><br>Original XOR encryption:<br><a href='https://github.com/joeyjurjens/Theos-Tweak-XOR-ing'>https://github.com/joeyjurjens/Theos-Tweak-XOR-ing</a></p>";

NIC->prompt("BINARYNAME", "Enter binary name of the app (if you know it)", {default => ""});

NIC->prompt("APPVERSION", "Enter current version of the app", {default => "1.0"});