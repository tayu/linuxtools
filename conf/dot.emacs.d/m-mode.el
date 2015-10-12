;;
;; m-mode (my main mode) as minor mode
;; キーアサインの為にマイナーモードを定義する
;;
;; ToDo: 検索、ウインドウ切り替え、置換
;;
;;   対応する括弧へ移動: () 以外の [] <>{}「」への対応
;;   ネストする括弧への対応: backward-sexp は暫定
;;
;;   ファイラー: 取りあえず、dired の直。ディレクトリを毎回選択
;;
;;   ウインドウの切り替え。編集テキストのみを対象にする。。
;;   ウインドウの分割。統合。
;;
;; 参考：
;; define-keyは, 新たなバインディングを先頭に追加するので,
;; 順番を気にするのならば, メニューの底の項目から始めて上の項目へ向かって
;; メニュー項目の定義を入れます.
;;

;; 検索文字列
(defvar m-mode-search-string nil)
(defconst m-mode-search-no-string "no search string")


;; マーク＆ジャンプ
; ToDo: 定数宣言、マーク用配列のバッファローカル化
(defvar m-mode-mark (make-vector 4 nil))
(defun m-mode-set-mark (no)
  (message (format "Mark %d" no))
  (aset m-mode-mark (1- no) (point)))
(defun m-mode-go-mark (no)
  (let ((pos (aref m-mode-mark (1- no))))
    (cond (pos (progn
                 (message (format "Jump %d" no))
                 (goto-char pos)))
          (t (message (format "Mark %d is NOT set" no))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2 ストロークキー（CTRL-[）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar m-mode-ctl-esc-map
  (let ((map (make-sparse-keymap)))
    ;; m-mode のキーにキーマップを設定
    ;; (define-key m-mode-map (kbd "C-[") map)

    ;; キーボードマクロ：開始
    ;; C-[ C-\\ だと message() の表示が出ない
    ;; C-[ \\ だと出る
    (define-key map [(control \\)] (kbd "C-[ \\"))
    (define-key map [(\\)]
      (lambda ()
	(interactive)
	(if defining-kbd-macro
	    (end-kbd-macro)
	  (start-kbd-macro nil))))

    ;; ファイラー
    (define-key map [(control e)] (kbd "C-[ e"))
    (define-key map [(e)] 'dired)

    ;; 終了
    (define-key map [(control q)] (kbd "C-[ q"))
    (define-key map [(q)] 'save-buffers-kill-emacs)
    ;; 保存
    (define-key map [(control s)] (kbd "C-[ s"))
    (define-key map [(s)] 'save-buffer)
    ;; 対応する括弧へ移動   ;; 暫定
    (define-key map (kbd "C-[") (kbd "C-[ ["))
    (define-key map (kbd "[") (lambda ()
				(interactive)
				(cond ((char-equal
					(string-to-char "(")
					(char-after (point)))
				       (forward-list 1))
				      ((char-equal
					(string-to-char ")")
					(char-after (point)))
				       (backward-sexp 1)))))
    ;;
    map)
  "CTRL-ESC Map")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2 ストロークキー（CTRL-Q）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;処理集約用関数
(defun C-q-f-func ()
  (interactive)
  (setq m-mode-search-string
	(read-from-minibuffer
	 "SEARCH: " nil nil nil))
  (message (format "search-string: %s"
		   m-mode-search-string)))
; 登録
(defvar m-mode-ctl-q-map
  (let ((map (make-sparse-keymap)))
    ;;

    ;; 検索文字列の入力
    ;; C-f から f への委譲ができないので、同一の処理を呼び出す
    (define-key map [(control f)] 'C-q-f-func)
    (define-key map [(f)] 'C-q-f-func)

    ;; ファイル名の複写
    (define-key map [(control n)] (kbd "C-q n"))
    (define-key map [(n)] (lambda ()
			    (interactive)
			    (cond
			     (buffer-file-name (insert (buffer-file-name))))))
    ;; 検索文字列の複写
    (define-key map [(control i)] (kbd "C-q i"))
    (define-key map [(i)] (lambda ()
			    (interactive)
			    (cond
			     (m-mode-search-string
			      (insert m-mode-search-string))
			     (t (message "Empty String")))))
    ;; マーク＆ジャンプ
    (define-key map  (kbd "C-1") (kbd "C-q 1"))
    (define-key map (kbd "1") (lambda ()
				(interactive)
				(m-mode-go-mark 1)))
    (define-key map  (kbd "C-2") (kbd "C-q 2"))
    (define-key map (kbd "2") (lambda ()
				(interactive)
				(m-mode-go-mark 2)))
    (define-key map  (kbd "C-3") (kbd "C-q 3"))
    (define-key map (kbd "3") (lambda ()
				(interactive)
				(m-mode-go-mark 3)))
    (define-key map  (kbd "C-4") (kbd "C-q 4"))
    (define-key map (kbd "4") (lambda ()
				(interactive)
				(m-mode-go-mark 4)))
    ;; 行頭／行末
    ;; デフォルトと同じ
    ;; (define-key map [end] (kbd "C-q d"))
    (define-key map [(control s)] (kbd "C-q s"))
    (define-key map [(s)] 'beginning-of-line)
    (define-key map [(control d)] (kbd "C-q d"))
    (define-key map [(d)] 'end-of-line)
    ;;  ファイルの先頭／最後
    (define-key map [(control r)] (kbd "C-q r"))
    (define-key map [(r)] (lambda ()
			    (interactive)
			    (goto-char (point-min))))
    (define-key map [(control c)] (kbd "C-q c"))
    (define-key map [(c)] (lambda ()
                            (interactive)
			    (goto-char (point-max))))
    ;;
    map)
  "CTRL-Q Map")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2 ストロークキー（CTRL-K）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar m-mode-ctl-k-map
  (let ((map (make-sparse-keymap)))
    ;; m-mode のキーマップに 2 ストロークキーを設定
    ;; (define-key m-mode-map "\C-k" map)
    ;;

    ;; ウインドウ／バッファ切り替え：巡回 or 自他
    (define-key map [(control n)] (kbd "C-k n"))
    (define-key map [(n)] (lambda ()
                            (interactive)
			    (bury-buffer (buffer-name (current-buffer)))
			    (switch-to-buffer (buffer-name (other-buffer)))))
    (define-key map [(control w)] (kbd "C-k w"))
    (define-key map [(w)] (lambda ()
			   (interactive)
			   (if (one-window-p)
			       (message "no other window")
			     (select-window (next-window)))))

    ;; マーク＆19~20~ジャンプ
    (define-key map (kbd "C-1") (kbd "C-k 1"))
    (define-key map (kbd "1") (lambda ()
				(interactive)
				(m-mode-set-mark 1)))
    (define-key map (kbd "C-2") (kbd "C-k 2"))
    (define-key map (kbd "2") (lambda ()
				(interactive)
				(m-mode-set-mark 2)))
    (define-key map (kbd "C-3") (kbd "C-k 3"))
    (define-key map (kbd "3") (lambda ()
				(interactive)
				(m-mode-set-mark 3)))
    (define-key map (kbd "C-4") (kbd "C-k 4"))
    (define-key map (kbd "4") (lambda ()
				(interactive)
				(m-mode-set-mark 4)))

    ;; 行の残りの部分、あるいは、行全体を1行以上キルする
    (define-key map [(control l)] 'kill-line)
    ;; 選択範囲のコピー
    (define-key map [(control k)] (kbd "C-k k"))
    (define-key map [(k)] (lambda ()
                            (interactive)
			    (let ((col (current-column)))
			      (if (not mark-active)
				  (progn
				    (beginning-of-line)
				    (setq transient-mark-mode t)
				    (set-mark (point))))
			      (end-of-line)
			      (copy-region-as-kill (mark) (point))
			      (move-to-column col))))
    ;;
    map)
  "CTRL-K Map")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; キーマップ：1 ストロークキー
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar m-mode-map
  (let ((map (make-sparse-keymap)))
    ;;
    ;; てすと
    (define-key map [(control b)]
      (lambda ()
	(interactive)
	(message (format "てすと: %s ." (get-char-property (point) 'face)
			 ;; (get-char-property (point) 'face)
			 ;; system-configuration
			 ;; (getenv "EMACSOPT")
			 ;; (emacs-version)
			 ;; emacs-version
			 ))
	))

    ;; Tab 入力
    ;; TeraTerm からは効かない
    (define-key map [(control shift i)]
      (lambda ()
	(interactive)
	(insert "\t" )))


    ;; キーボードマクロ:実行
    (define-key map [(control \\)]
      (lambda ()
	(interactive)
	(if last-kbd-macro
	    (execute-kbd-macro last-kbd-macro)
	  (message "キーボードマクロが未定義" ))))

    ;; 大文字小文字変換
    ;; 暫定で、1 文字ずつバージョン
    ;; Vz ライクなワード単位バージョンは ToDo
    (define-key map (kbd "C-]")
      (lambda ()
	(interactive)
	(let ((c (char-after)))
	  (cond
	   (c (let ((s (char-to-string c)))
		(cond
		 ((and (not (string< s "A")) (not (string< "Z" s)))
		  (progn
		    (insert-char (string-to-char (downcase s)) 1)
		    (delete-char 1)))
		 ((and (not (string< s "a")) (not (string< "z" s)))
		  (progn
		    (insert-char (string-to-char (upcase s)) 1)
		    (delete-char 1)))
		 (t (forward-char))
		 )))))))

    ;; 検索文字列の取得
    (define-key map [(control l)] (lambda ()
				    (interactive)
				    (let
					((p (point))
					 (s m-mode-search-string)
					 (l (length m-mode-search-string)))
				      (cond
				       (s (cond
					 ((not
					  (string=
					   s
					   (buffer-substring p (+ p l))))
					  (progn
					    (setq s nil)
					    (setq l 0))))))
				      (goto-char (+ p l))
				      (forward-word 1)
				      (setq m-mode-search-string
					    (buffer-substring p (point)))
				      (goto-char p))
				    (message
				     (format "%s" m-mode-search-string))))
    ;; 前方検索
    (define-key map [(control n)] (lambda ()
                                    (interactive)
				    (cond
				     ((equal m-mode-search-string nil)
				      (message m-mode-search-no-string))
				     (t
				      (search-forward m-mode-search-string)))))

    ;; 後方検索
    (define-key map [(control p)] (lambda ()
                                    (interactive)
				    (cond
				     ((equal m-mode-search-string nil)
				      (message m-mode-search-no-string))
				     (t
				      (search-backward m-mode-search-string)
				      ))))

    ;; 削除／挿入
    (define-key map [(control y)] (lambda ()
				    (interactive)
				    (let ((col (current-column)))
				      (if (not mark-active)
					  (progn
					    (beginning-of-line)
					    (setq transient-mark-mode t)
					    (set-mark (point))))
				      (end-of-line)
				      (kill-region (mark) (point))
				      (delete-char 1)
				      (move-to-column col))))
    ;; マークとリージョン
    (define-key map [(control v)] (lambda ()
                                    (interactive)
				    (let ((col (current-column)))
				      (beginning-of-line)
				      (setq transient-mark-mode t)
				      (set-mark (point))
				      (move-to-column col))))
    ;; ヤンク
    (define-key map [(control j)] (lambda ()
				    (interactive)
				    (let ((col (current-column)))
				      (beginning-of-line)
				      (yank)
				      (newline)
				      (move-to-column col))))

    ;; 語単位の削除／ヤンク: タブやスペースはそれのみ削除
    (define-key map [(control t)] (lambda ()
				    (interactive)
				    (let ((ch (following-char))
					  (space (string-to-char " "))
					  (tab (string-to-char "\t"))
					  (pos (point )))
				      (cond ((or
					    (char-equal space ch)
					    (char-equal tab ch))
					     (while
						 (char-equal
						  ch (following-char))
					       (forward-char)))
					    (t (forward-word)))
				      (kill-region pos (point)))))
    (define-key map [(control u)] 'yank)


    ;; DEL/BS C-h/C-g キー
    (define-key map [(control h)] 'delete-backward-char)
    (define-key map [backspace] (kbd "C-h"))
    (define-key map [(control g)] 'delete-char)
    (define-key map [delete] (kbd "C-g"))
    ;; ページアップ／ダウン
    (define-key map [(control c)] 'scroll-up)
    (define-key map [(control r)] 'scroll-down)
    ;; 行アップ／ダウン
    (define-key map [(control w)] (lambda ()
                                    (interactive)
                                    (scroll-down 1)
                                    (previous-line)))
    (define-key map [(control z)] (lambda ()
                                    (interactive)
                                    (scroll-up 1)
				    (next-line)))
    ;; 行頭／行末（1 ストローク）
    ;; Teraterm ではキーが届かないらしい
    (define-key map [C-left] (kbd "C-q s"))
    (define-key map [C-right] (kbd "C-q d"))
    ;; １語→←
    (define-key map [S-left] (kbd "C-a"))
    (define-key map [S-right] (kbd "C-f"))
    (define-key map [(control f)] (lambda ()
                                    (interactive)
				    (forward-word)
				    (when (forward-word)
				      (forward-word -1)
				      )))
    (define-key map [(control a)] (lambda ()
                                    (interactive)
				    (forward-word -1)
				    ))
    ;; カーソル↑↓→←
    (define-key map [(control e)] 'previous-line)
    (define-key map [(control x)] 'next-line)
    (define-key map [(control s)] 'backward-char)
    (define-key map [(control d)] 'forward-char)
    ;;
    ;; 2 ストロークキー
    ;; (define-key map "C-[" nil)
    ;; (define-key map [(control q)] nil)
    ;; (define-key map [(control k)] nil)
    (define-key map (kbd "C-[") m-mode-ctl-esc-map)
    (define-key map [(control q)] m-mode-ctl-q-map)
    (define-key map [(control k)] m-mode-ctl-k-map)
    ;;
    map)
  "m-mode main map")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; マイナモードの作成＆有効化
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(easy-mmode-define-minor-mode m-mode "My-Mode"
			      ;; 初期値: モードをオン
			      t
			      ;; モード行に表示される文字列
			      " Moo"
			      ;; キーマップ; キーマップ変数か連想リスト
			      m-mode-map)

;; マイナーモードを on
;(defun m-mode-on ()
;  "m-mode on."
;  (interactive)
;  (setq-default m-mode t)
;  m-mode)
;
; マイナーモードを起動時に有効化：初期値が nil の場合
;(add-hook 'after-init-hook 'm-mode-on)
