;;;; bb2mode-helper.asd

(asdf:defsystem #:bb2mode-helper
  :description "Describe bb2mode-helper here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:cl-ppcre
               #:cl-mysql)
  :serial t
  :components ((:file "package")
               (:file "bb2mode-helper")))

