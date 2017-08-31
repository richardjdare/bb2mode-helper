# bb2mode-helper

This Common Lisp package contains a bunch of code that I use to maintain bb2-mode, an Emacs major mode for Blitz Basic 2, an Amiga Basic compiler. All the Blitz Basic 2 commands that bb2-mode knows about, their corresponding help strings and binary tokens are kept in a mysql database. This code manages that database.

What this does:
* Extracts Blitz 2 commands and help strings from text files exported by Stripper, a Blitz Basic utility, and stores them in the database.
* Extracts Blitz 2 tokens from a tokenized Blitz 2 file, matches them to their corresponding command name and stores them in the database. To do this you must print out an ascii file with your blitz commands in, 1 per line and save it as a tokenized file in Blitz 2 on the Amiga. Then you must call (bb2-mode:extract-tokens) with the ascii file and corresponding tokenized file.
* Prints the bb2mode database as an Elisp hashtable declaration you can paste into the bb2-mode source code.

 bb2mode.sql, my database of Blitz 2 commands is also included in this project.
