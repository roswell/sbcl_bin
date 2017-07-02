(in-package :cl-user)
(defpackage :roswell.github.utils
  (:use :cl :sn.github.repos.releases)
  (:export :*repo* :*user* :*release* :fetch-upload :github :releases-list))

(in-package :roswell.github.utils)

(defvar *user/repo*
  (last (split-sequence:split-sequence
         #\/
         (string-trim
          (string #\lf)
          (uiop:run-program "git remote -v | head -n 1|awk -F ' ' '{print $2}'" :output :string)))
        2))

(defvar *release* "files")
(defvar *user*  (first *user/repo*))
(defvar *repo* (subseq (second *user/repo*) 0 (- (length (second *user/repo*)) 4)))

(defun release-exist-p (tagname &key owner repo)
  (ignore-errors
    (find tagname
          (releases-list owner repo)
          :key (lambda (x) (getf x :|tag_name|))
          :test 'equal)))

(defun ensure-release-exists (tagname &key owner repo)
  (format t "ensure-release-exists ~A ~A ~A:" tagname owner repo)
  (force-output)
  (let ((found (release-exist-p tagname :owner owner :repo repo)))
    (if found
        found
        (releases-create owner repo tagname))))

(defun asset-upload (path tagname &key owner repo force)
  (let ((release-id (getf (release-exist-p tagname :owner owner :repo repo) :|id|))
        (name (file-namestring path)))
    (format t "release-id: ~A :name ~A force ~A" release-id name force)
    (force-output)
    (when force
      (let ((id (getf (find name (releases-assets-list owner repo release-id)
                            :key (lambda (x) (getf x :|name|))
                            :test #'equal) :|id|)))
        (format t "id:~A" id)
        (force-output)
        (when id 
          (releases-asset-delete owner repo id))))
    (releases-asset-upload
     owner repo
     release-id path)))

(defun github (path tagname owner repo &optional force)
  (unless (uiop:getenv "GITHUB_OAUTH_TOKEN")
    (error "GITHUB_OAUTH_TOKEN must be set"))
  (let ((release (ensure-release-exists tagname :owner owner :repo repo)))
    (format t "create ~A ~A ~A:" owner repo tagname)
    (format t "upload start:")
    (when (or force
              (not (find (pathname path)  (getf release :|assets|) :key (lambda (x) (getf x :|name|)) :test 'equal)))
      (asset-upload (pathname path) tagname :owner owner :repo repo :force (when force t))))
  (format t "upload done")
  (force-output t)
  t)

(defun commit-tags (tags)
  (dolist (i tags)
    (dolist (x (list
                (format nil "echo ~A> version" (first i))
                (format nil "git add version")
                (format nil "git commit -m 'version ~A on ~A'" (first i) (second i))
                (format nil "git tag -a \"~A\" -m \"~A\"" (first i) (first i))))
      (uiop:run-program x))))

(defun fetch-upload (path uri *release*)
  "fetch&upload"
  (format t "~A~%" uri)
  (finish-output)
  (ignore-errors
   (dex:fetch uri path :if-exists :supersede)
   (github path *release* *user* *repo*)))
