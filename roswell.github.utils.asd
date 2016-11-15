#-asdf
(require :asdf)

(in-package :cl-user)

(defpackage roswell.github.utils.asd
  (:use :cl :asdf))
(in-package :roswell.github.utils.asd)

(defsystem roswell.github.utils
  :depends-on (:dexador :lake :plump :cl-ppcre :split-sequence :sn.github)
  :components ((:file "utils")))
