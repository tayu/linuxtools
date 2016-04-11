#! /usr/bin/env gosh
;; -*- coding: utf-8 -*-

(use dbm)
(use dbm.gdbm)

(define *dbclass* <gdbm>)
(define *infile* "wikidata.dbm")
(define *outfile* "data.txt")
(define *mark* "\n++++++++++++++++++++++\n")

(define (main args)
  (call-with-output-file
      *outfile*
    (lambda (p)
      (let ((db (dbm-open *dbclass* :path *infile* :rw-mode :read)))
	(dbm-for-each
	 db
	 (lambda (k v)
	   (display k p)
	   (display *mark* p)
	   (display v p)
	   (display *mark* p)
	   ))
	(dbm-close db)
	)))
  (display "\nend \n")
  0)
