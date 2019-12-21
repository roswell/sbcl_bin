#-asdf
(require :asdf)

(in-package :cl-user)

(defpackage roswell.github.utils
  (:use :cl :asdf))
(in-package :roswell.github.utils)

(defsystem roswell.github.utils
  :depends-on (:dexador :plump :cl-ppcre :split-sequence :sn.github)
  :components ((:file "utils")))
