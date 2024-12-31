# bb2mode-helper

This Common Lisp package contains a bunch of code that I use to maintain [bb2-mode](https://github.com/richardjdare/bb2-mode), an Emacs major mode for Blitz Basic 2.

bb2-mode has a big table inside it containing all the Blitz 2 commands and their corresponding help strings and binary tokens. The code in this project is used to generate that table and look after the data.

First, the data is extracted from Blitz 2 using a 3rd-party program called Stripper. This scans the Blitz 2 binaries and outputs text files containing all the Blitz 2 commands and their help strings.

then, the (bb2mode-helper:extract-commands) function in this package is used to extract data from these text files and store it in a mysql database, 'bb2mode'. A complete mysql dump of this database is included in this repo.

Then, we need to get the binary tokens. Each Blitz 2 command has a 2-byte binary token associated with it.

To get the tokens we create a text file containing a dump of the Blitz 2 commands from our database, 1 per line. We then load it into Blitz 2 as an ASCII file, and save it as a tokenized file. 

Then we call (bb2mode-helper:extract tokens) passing in the ASCII file containing the command names, and the binary .bb2 file containing the tokens. This function will extract the tokens and work out which command they belong to, before storing them in the database.

Finally, we print the database out as an Elisp hashtable declaration, using (bb2mode-helper:make-keyword-src)

Before running any of these commands, you must create a mysql database bb2mode, and call (bb2mode-helper:open-database) to connect to it.
When you are finished, call (bb2mode-helper:close-database).

The "Stripper" directory contains the program that I used to extract the Blitz commands, along with text files containing the original output from running it against Blitz 2.1
