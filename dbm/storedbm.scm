#! /usr/bin/env gosh
;; -*- coding: utf-8 -*-

(use dbm)
(use dbm.gdbm)

(define *mark* "++++++++++++++++++++++")


;; うさげ
(define (usage)
  (format (current-error-port)
	  "Usage: ~a infile(txt) outfile(dbm) ...\n" *program-name*)
  (exit 2))


(define (main args)
  (if (null? (cdr args))
      (usage)
      )
  (if (or (null? (cadr args)) (not (file-exists? (cadr args))))
      (usage)
      )
  (if (null? (caddr args))
      (usage)
      )

  (print "start")

  (let ((inFile (cadr args)) (outDbm (caddr args)) (key "") (val ""))
    (call-with-input-file inFile
      (lambda (port)
	(let ((newdb (dbm-open <gdbm> :path outDbm :rw-mode :create)))
	  (with-input-from-port port
	    (lambda ()
	      (let ((count 0))
		(port-for-each
		 (lambda (line)
		   (cond
		    ((string=? *mark* line)
		     (if (not (eq? 0 (string-length val)))
			 (begin
			   (display ".")
			   (dbm-put! newdb key val)
			   (set! key "")
			   (set! val "")
			   (inc! count))))
		    ((eq? 0 (string-length key))
		     (set! key line))
		    (else
		     (if (eq? 0 (string-length val))
			 (set! val line)
			 (set! val (string-append val "\n" line))))))
		 read-line)
		(print (format "\nStore ~a item ." count)))))
	  (dbm-close newdb)))))
  (display "end")
  0)
