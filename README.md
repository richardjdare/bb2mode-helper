# bb2mode-helper

This Common Lisp package contains a bunch of code that I use to maintain [bb2-mode](https://github.com/richardjdare/bb2-mode), an Emacs major mode for Blitz Basic 2, an Amiga Basic compiler.

All the Blitz Basic 2 commands that bb2-mode knows about are extracted from Blitz 2 using a program called Stripper. Stripper gives us the command names and the help strings that are displayed in Blitz 2 when you press the help key while the cursor is over a Blitz keyword.

This package contains Common Lisp functions for reading the text files output by Stripper into a mysql database.

Then, we use another function in this package to print out all the Blitz 2 commands into an ASCII file, one per line. This ASCII file is loaded into Blitz 2, then saved as a tokenized file. This is where our tokens come from.

We then run (bb2-mode:extract-tokens) which uses the original ascii file and the tokenized file to work out which token belongs to which command. The tokens are then stored in the database alongside their corresponding command.

Finally we use another function in this package to print the database out as an ELisp hashtable declaration that you can paste into the bb2-mode source code.

The "Stripper" directory contains the program that I used to extract the Blitz commands, along with text files containing the original output from running it against Blitz 2.1

bb2mode.sql, my database of Blitz 2 commands is also included in this project.
