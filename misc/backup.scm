;;
;; バックアップ
(use os.windows)


;; $ pdumpfs /home/yourname /backup
;; --> /backup/2001/02/19/yourname/..
;; --> /backup/YYYY/MM/DD/hh/mm/yourname/..
;; テスト用
;;(define-constant *data-dir* "D:/home/temp/ps1/script/sync")
;;(define-constant *backup-dir* "D:/temp/1")
;; 本番
(define-constant *data-dir* "D:/home")
(define-constant *backup-dir* "E:/backup/home8")



;; 定数
(define-constant *path-delim* "/")
(define-constant *path-nofile* "")

;; 大域変数
(define-values (*num-copy-file*) '0)
(define-values (*num-link-file*) '0)


;; ユーティリティ: メッセージ
(define (message msg)
  (sys-message-box #f msg (sys-basename *program-name*) MB_OK))


;; ユーティリティ: パスの作成: same in file.util
(define (build-path dir sudir)
  (format "~a~a~a" dir *path-delim* sudir))


;; ユーティリティ: マッチ用文字列（正規表現）の作成
(define (make-rex-strings num)
  (let ((s ""))
    (do ((i 0 (+ i 1)))
	((>= i num))
      (set! s (string-append s "[0-9]"))
    )
    s))


;; 最新のバックアップを探す
(define (search-latest-dir src dst)
  (let ((fmt (list 4 2 2 2 2)) (path dst))
    (map
     (lambda (f)
       (if (not (string=? path *path-nofile*))
	   (let ((dirs (sys-readdir path)) (latest "")
		 (rex (make-rex-strings f)))
	     ;; filter & sort
	     (set! dirs
		   (filter
		    (lambda (d)
		      (let ((p (build-path path d)))
			(cond
			 ((not (rxmatch (string->regexp rex) d)) #f)
			 ((not (file-is-directory? p)) #f)
			 (else #t))
			)) dirs))
	     (if (null? dirs)
		 (set! path *path-nofile*)
		 (begin
		   (set! dirs (sort dirs (lambda (x y) (string>? x y))))
		   (set! latest (car dirs))
		   (set! path (build-path path latest))
		   ))
	     ))) fmt)
    (if (not (string=? path *path-nofile*))
	(set! path (build-path path (sys-basename src))))
    path)
  )


;; バックアップ先を作成する
(define (make-new-dir src dst)
  (let ((tm (sys-localtime (sys-time))) (path dst))
    (let ((fmt (list (list 4 (+ 1900 (slot-ref tm 'year)))
		     (list 2 (+ 1 (slot-ref tm 'mon)))
		     (list 2 (slot-ref tm 'mday))
		     (list 2 (slot-ref tm 'hour))
		     (list 2 (slot-ref tm 'min)))))
      (map
       (lambda (f)
	 (let ((w (car f)) (v (cadr f)))
	   (set! path (build-path path (format "~v,'0d" w v)))
	   (if (not (file-is-directory? path)) (sys-mkdir path (sys-umask)))
	   )) fmt)
      (let ((basename (sys-basename src)))
	(set! path (build-path path basename))
	(if (file-exists? path)
	    (begin
	      (message (format "ERROR: mkdir: Already Exist: ~a" path))
	      (exit 1)))
	(sys-mkdir path (sys-umask))))
    path))


;; ファイルコピー、時刻セット付き
(define (copy-file src dst)
  (call-with-input-file src
    (lambda (in)
      (begin
	(call-with-output-file dst (lambda (out) (copy-port in out)))
	;; ToDo: set stat->ctime)
	(let ((stat (sys-stat src)))
	  (sys-utime dst (sys-stat->atime stat) (sys-stat->mtime stat)))
	(inc! *num-copy-file*)
	))))


;; 更新が必要かチェック
(define (need-update? src dst)
  (let ((sstat (sys-stat src))
	(dstat (sys-stat dst))
	(stat #f))
    (cond
     (if (not (= (sys-stat->size sstat) (sys-stat->size dstat))) #t)
     (if (< (sys-stat->mtime sstat) (sys-stat->mtime dstat)) #t)
     ;; ToDo: checksum or else
     )
;    (message (format "UP?: [~d]: ~a  -->  ~a" stat src dst))
    stat)
  )


;; ユーティリティ: コピー（アップデート）
(define (up-copy src dst latest fname)
;;  (message (format "IN: up-copy: ~a | ~a  | ~a | ~a" src dst latest fname))
  (let ((s (build-path src fname))
	(d (build-path dst fname))
	(l (build-path latest fname)))
    (cond
     ((not (file-exists? l)) (copy-file s d))
     ((not (need-update? s l))
      (begin
	(sys-link l d)
	(inc! *num-link-file*)))
     (else
      (begin
	(message (format "ERROR: Unknown stat: ~a/~a/~a" s d l))
	(exit 1))
      ))))


;; バックアップ実行
(define (do-backup src dst latest)
;;  (message (format "param: ~a  ||  ~a  ||  ~a" src dst latest))
  (let ((files (sys-readdir src)))
    (map
     (lambda (f)
       (let ((path (build-path src f)))
	 (cond
	  ((string=? f ".") #f)
	  ((string=? f "..") #f)
	  ((file-is-regular? path) (up-copy src dst latest f))
	  ((file-is-directory? path)
	   (let ((dstdir (build-path dst f)))
	     (sys-mkdir dstdir (sys-umask))
	     (do-backup path dstdir (build-path latest f)))
	   )
	  (else
	   (message (format "ERROR: Unknown file/dir : ~a/~a" path f))
	   (exit 1))
	  )
	 )) files)
    ))


;; メイン
(define (main args)
;;  (guard (e [else (message (format "ERROR: ~a" (~ e'message)))])
	 ;; 入力パラメータのチェック
	 (if (not (file-is-directory? *data-dir*))
	     (begin
	      (message (format "ERROR: Not Exist: Src: ~a" *data-dir*))
	      (exit 1)))
	 (if (not (file-is-directory? *backup-dir*))
	     (begin
	      (message (format "ERROR: Not Exist: dst: ~a" *backup-dir*))
	      (exit 1)))
	 ;; バックアップ
	 (let ((dst "") (latest ""))
	   ;; 最新バックアップのサーチ
	   (set! latest (search-latest-dir *data-dir* *backup-dir*))
	   ;; バックアップ先の用意
	   (set! dst (make-new-dir *data-dir* *backup-dir*))
	   ;; バックアップが無い場合、空ディレクトリ（バックアップ先と同じ）で
	   ;; ごまかす。
	   (if (string=? latest *path-nofile*) (set! latest dst))

	   ;; バックアップ実行
	   (do-backup *data-dir* dst latest)
	   )
	 (message (format "--END --: Copy ~d, Link ~d files"
			  *num-copy-file* *num-link-file*))
	 ;; )
  0)

