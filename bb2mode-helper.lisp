;;;; bb2mode-helper.lisp
;;;; 2017 Richard Dare
;;;; richardjdare.com
;;;; Helper functions for managing the commands database used in bb2-mode for Emacs.
;;;;
;;;; What does this do?
;;;; * Extracts blitz II commands and helpstrings from the text files exported by Stripper and saves
;;;;   them in a database
;;;; * Loads Blitz II command data from the database and prints a Elisp hashtable of data for use
;;;;   in bb2-mode
;;;; * prints out a list of commands that we load into Blitz II and then save as a tokenized file
;;;; * takes that tokenized file and the original list of commands and uses it to work out what
;;;;   token belongs to what command, then saves the tokens in the database.


(in-package #:bb2mode-helper)

;;; "bb2mode-helper" goes here. Hacks and glory await!

(defparameter *db-name* "bb2mode")

(defun mapconcat (function list elem)
  "Elisp style mapconcat"
  (let (*print-pretty*)
    (format nil (format nil "~~{~~a~~^~a~~}" elem)
            (mapcar function list))))

(defun ends-with-p (str1 str2)
  "Determine whether `str1` ends with `str2`"
  (let ((p (mismatch str2 str1 :from-end T)))
    (or (not p) (= 0 p))))

(defun open-database (db-user db-password)
  "call this first to connect to the database of blitz commands"
  (cl-mysql:connect :host "localhost" :user db-user :password db-password :database *db-name*))

(defun close-database ()
  "Call this when you are finished to close the database connection"
  (cl-mysql:disconnect))

;; these functions handle loading and extracting command names and helpstrings from a text file

(defun commandsfile-to-table (filename)
  "Extract Blitz II commands and helpstrings from textfile <filename> and return them in a hashtable"
  (let ((table (make-hash-table :test 'equal))
	(parts))
    (with-open-file (fs filename)
      (do ((line (read-line fs nil)
		 (read-line fs nil)))
	  ((null line))
	(setf parts (cl-ppcre:split "\\s{2,}" line))
	(setf (gethash (car parts) table) (cadr parts))))
    table))

(defun save-commands (table)
  "Take a hashtable of commands and helpstrings and save them in the database.
command-type is either \"blitz\" or \"amiga\" - returns number of commands saved"
  (let ((sql "insert into commands values (\"null\",\"~A\",\"~A\",\"~A\",\"\")")
	(result 0))
    (maphash #'(lambda (k v)
		 (let ((type (if (ends-with-p k "_") "amiga" "blitz")))
		   (if v
		       (incf result (caaar (cl-mysql:query (format nil sql k (cl-mysql:escape-string v) type)))))))
	     table)
    result))

  (defun extract-commands (stripper-text-filename)
  "Extract Blitz II commands and helpstrings from a text file create by Stripper
and store them in the mysql database 'bb2mode'.
This code expects the extraneous first 3 lines of the stripper file to have been removed."
  (format t "Extracted and saved ~A commands from ~A"
	  (save-commands (commandsfile-to-table stripper-text-filename))
	  stripper-text-filename))

;; these functions handle the creation and storage of blitz 2 tokens
(defun process-token (a b)
  "create a bb2 token from 2 bytes"
  (logior (ash a 8) (logand b 255)))

(defun load-token-file-bytes (filename)
  "Load the bb2 token file into an array of bytes"
  (let ((file-bytes nil))
    (with-open-file (f filename :element-type '(unsigned-byte 8))
      (setf file-bytes (make-array (file-length f) :fill-pointer 0))
      (loop for byte = (read-byte f nil)
	 while byte
	 do (vector-push byte file-bytes)))
    file-bytes))

(defun load-tokens (filename)
  "Load a bb2 token file into an array of hex strings"
  (let* ((filedata (load-token-file-bytes filename))
	  (tokens (make-array (length filedata) :fill-pointer 0))
	  (i 0))
    (loop while (< i (- (length filedata) 1)) do	 
	 (let ((b (elt filedata i))
	       (b1 (elt filedata (1+ i))))
	   (cond ((> b 127)
		  (vector-push (format nil "~x" (process-token b b1)) tokens)
		  (setf i (+ 2 i)))
		 ((incf i)))))
    tokens))

(defun load-token-names (filename)
  "Load a text file of blitz commands (1 per line) into an array"
  (let ((table nil))
    (with-open-file (f filename)
      (setf table (make-array (file-length f) :fill-pointer 0))
      (do ((line (read-line f nil)
		 (read-line f nil)))
	  ((null line))
	(vector-push line table)))
    table))

(defun update-tokens-from-arrays (token-names token-values)
  "Update the database with token information from 2 arrays"
  (loop for x below (length token-names) do
       (cl-mysql:query (format nil "update commands set token=\"~A\" where command=\"~A\""
			       (elt token-values x)
			       (elt token-names x)))))

(defun extract-tokens (text-filename tokenized-filename)
  "Extract Blitz II command tokens from a file and store them in the database, using an equivalent plain
text file of commands to work out what each token is"
  (let ((token-names (load-token-names text-filename))
	(token-values (load-tokens tokenized-filename)))
    (update-tokens-from-arrays token-names token-values)))

;; these functions handle printing the array of commands as an elisp hashtable declaration

(defun cleanstr (in)
  (if (stringp in) in ""))

(defun tokenstr (in)
  (if in (format nil "#x~A" in) "nil"))

(defun make-keyword-src ()
  (let ((commands (cl-mysql:query "select command, helpstr, token from commands order by type desc,command")))
    (concatenate 'string "#s(hash-table test equal data ("
		 (mapconcat (lambda (x)
			      (format nil "\"~A\" (\"~A\" \"~A\" ~A)"
				      (string-downcase (car x))
				      (car x)
				      (cleanstr (cadr x))
				      (cleanstr (tokenstr (caddr x)))))
			    (caar commands)  "~%")
		 "))")))

(defun print-elisp-keyword-table ()
  (progn (princ (make-keyword-src)) t))
