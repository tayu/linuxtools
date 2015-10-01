#! /usr/bin/emacs --script

(defun is-el ( fname )
  (string-match ".+\.el$" fname))


(defun do-compile-1 ( f )
  (if (is-el f)
      (progn
	(princ (format "compile: %s\n" f))
	(byte-compile-file f))))


(defun do-compile ( lst )
  (dolist (l lst)
    (do-compile-1 l)))


(defun do-compile-current-el ()
  (let ((dirs (directory-files "." nil ".+\.el$")))
    (dolist (f dirs)
      (do-compile-1 f))))


(defun main (argv)
  (cond
   ((< 0 (length argv)) (do-compile argv))
   (t (do-compile-current-el))))

;;(princ (format "%d\n" 1))
(main argv)
(princ "DONE: \n")
(setq argv nil)
