;; .emacs(.emacs.d/init.el(.elc))

;; Tips: https://keens.github.io/blog/2013/12/13/dot-emacs-clean-up/
;; 1.Emacsの最新版を使う
;; 2.普段使わない設定は全部消す
;; 3.普段使っていても代替の効くものは削除
;; 4.できる限り標準のものを使う
;; 5.autoloadを使う
;; 6.できる限りpackage.elを使う
;; 7.eval-after-loadを使う
;; 8.その他

;; ToDo:
;; html のバックアップが作成されない
;; メジャーモードが sgml-mode らしいので add-hook してみたが、
;; フックに指定した関数は呼び出されるものの、効かない。
;; アドバイスの追加とかにするかな


;; 動作環境判定用
(defconst ENV-TERM    1 "TeraTerm or Console")
(defconst ENV-MIN ENV-TERM "min: for loop")
(defconst ENV-DEBIAN  2 "debian")
(defconst ENV-LINUX   3 "Other on Linux")
(defconst ENV-COLINUX 4 "coLinux")
(defconst ENV-NETBSD 5 "netbsd")
(defconst ENV-WIN-V22 6 "Windows emacs-22.2")
(defconst ENV-WIN-V23 7 "Windows emacs-23.4")
(defconst ENV-MAX ENV-WIN-V23 "max")
(defconst C-LINUX "linux")
(defconst C-COLINUX "i486-pc-linux-gnu")
(defconst C-HURD "gnu")
(defconst C-NETBSD "netbsd")
(defconst C-WINDOWS "nt6")
;; use system-configuration
;; debian-amd64		x86_64-pc-linux-gnu
;; debian-i386		i586-pc-linux-gnu
;; coLinux)		i486-pc-linux-gnu
;; debian-hurd-i386 	i586-pc-gnu
;; NetBSD 		x86_64--netbsd
;; windows 8.1	 	i386-mingw-nt6.2.9200
;; 他に NetBSD OpenBSD BeOS
(defun get-env ()
  (let ((os system-configuration))
    (cond
     ((string-match C-COLINUX os) ENV-COLINUX)
     ((string-match C-LINUX os) ENV-DEBIAN)
     ((string-match C-HURD os) ENV-DEBIAN)
     ((string-match C-NETBSD os) ENV-NETBSD)
     ((string-match C-WINDOWS os)
      (cond
       ((getenv "EMACSOPT") ENV-WIN-V22)
       (t ENV-WIN-V23)))
     (t nil))))


;; 文字色の設定
;; 環境毎の設定が分散するとかえって扱いにくい。ので、まとめる
;; TeraTerm では色数が制限されるらしい
;; set-face-bold-p は obsolete で set-face-bold を使えって事らしい
;; が、Windows 側は -p でないとダメ
(defun set-screen-color ()
  (let ((env (get-env)))
    ;; コメント
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (progn
	(set-face-foreground 'font-lock-comment-face "Gray")
	(set-face-bold-p 'font-lock-comment-face nil)))
     (t
      (progn
	(set-face-foreground 'font-lock-comment-face "Yellow")
	(set-face-bold 'font-lock-comment-face nil)
	))
     )
    ;; 予約語
    (set-face-foreground 'font-lock-keyword-face "Green")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-keyword-face t)))
    ;; ビルトイン関数
    (set-face-foreground 'font-lock-builtin-face "Green")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-builtin-face nil))
     (t
      (set-face-bold 'font-lock-builtin-face nil)))
    ;; 関数名
    (set-face-foreground 'font-lock-function-name-face "Blue")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-function-name-face t))
     (t
      (set-face-bold 'font-lock-function-name-face t)))
    ;; 変数名: Blue
    (set-face-foreground 'font-lock-variable-name-face "Cyan")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-variable-name-face nil))
     (t
      (set-face-bold 'font-lock-variable-name-face t)))
    ;; 文字列定数
    (set-face-foreground 'font-lock-string-face  "Magenta")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-string-face nil))
     (t
      (set-face-bold 'font-lock-string-face t)))
    ;; 定数
    (set-face-foreground 'font-lock-constant-face "Magenta")
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-constant-face t))
     (t
      (set-face-bold 'font-lock-constant-face t)))
    ;; 警告
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (set-face-bold-p 'font-lock-warning-face nil))
     (t
      (set-face-bold 'font-lock-warning-face nil)))
    ;; モード毎の設定
    ;; eval-after-load への指定は *ファイル名* で行う
    ;; モード名で指定するなら add-hook にする
    (eval-after-load "sh-script" ; .sh sh-mode shell-script-mode
      (quote
       (progn
	 (set-face-foreground 'sh-heredoc "Red")
	 )))

    ;; 特定環境
    (cond
     ((or (= env ENV-COLINUX) (= env ENV-WIN-V22) (= env ENV-WIN-V23))
      (progn
	;; カーソル色
	(add-to-list 'default-frame-alist '(cursor-color . "SlateBlue2"))
	;; モードライン文字色
	(set-face-foreground 'modeline "white")
	;; モードライン背景色
	(set-face-background 'modeline "MediumPurple2")
	;; 選択中のリージョン
	(set-face-background 'region "LightSteelBlue1")
	;; モードライン（アクティブでないバッファ）の文字色
	(set-face-foreground 'mode-line-inactive "gray30")
	;; モードライン（アクティブでないバッファ）の背景色
	(set-face-background 'mode-line-inactive "gray85")
	)))
  ))


;; 共通設定
(defun init-common ()
  ;; エンコーディング: UTF-8: 大文字だと認識しないのでエイリアス
  (define-coding-system-alias 'UTF-8 'utf-8)
  ;; 行末の空白を表示
  (setq-default show-trailing-whitespace t)
  ;; モードラインに時刻を表示する
  (display-time)
  ;; 直前／直後の括弧に対応する括弧を光らせる
  (show-paren-mode)
  ;; UTF-8を優先使用
  (prefer-coding-system 'utf-8)
  ;; るびきち「日刊Emacs」generic-xは入れとけ
  (require 'generic-x)
  ;; 文字色の変更
  (set-screen-color)
  ;; マークダウンモード（指定が不要になってほしい）
  (add-to-list 'auto-mode-alist '( "\\.md\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '( "\\.markdown\\'" . markdown-mode))
  )

;; 共通設定: Windows
(defun init-windows-common ()
  ;; バックアップ関連設定
  ;; バックアップを作成する
  (setq make-backup-files t)
  ;; バックアップをコピーで作成する
  (setq backup-by-copying t)
  ;; バックアップファイル名にディレクトリ名を付加する
  ;; 命名関数を再定義
  (defun make-backup-file-name (filename)
    (concat
     "D:/trashbox/"
     (format-time-string "%04Y%02m%02d-%02H%02M%02S-" (current-time))
     (file-name-nondirectory filename)))
  ;; 自動セーブファイルの作成先
  (defun make-auto-save-file-name ()
    (concat
     "D:/trashbox/"
     "#"
     (format-time-string "%04Y%02m%02d-%02H%02M%02S-" (current-time))
     (file-name-nondirectory buffer-file-name)
     "#"))

  ;; 表示
  ;; カーソル行強調表示（アンダーラインは画面末まで引かれない）
  ;;(setq hl-line-face 'underline)
  (global-hl-line-mode)
  ;; 新規フレームのデフォルト設定
  (setq default-frame-alist
	(append
	 '(
	   (width . 81)                           ; フレーム幅(文字数)
	   (height . 30)                          ; フレーム高(文字数)
	   (foreground-color . "#00040F")         ; 文字色
	   (background-color . "#FFFAF0")         ; 背景色
	   ) default-frame-alist))
  ;; カラム番号の表示: windows 版のみしか効かない
  (setq column-number-mode t)

  ;; メニューから保存されたものを取り込む
  (cond
   ((string-match "23.4" emacs-version) (init-custom-23))
   ((string-match "22.2" emacs-version) (init-custom-22))
   )
  )

;; emacs environment for coLinux via TeraTerm
;; read environment for linux
(defun init-linux ()
  ;; サーチパスの設定; coLinux on Windows 7 (~/win)
  (let ((home_dir "~/.conf/site-lisp")
	(win_dir "~/win/emacs/site-lisp"))
    (setq
     load-path
     (append
      (list
       home_dir
       win_dir
       (concat home_dir "/local")
       (concat home_dir "/ext")
       ) load-path)))

  ;; 共通設定
  (init-common)

  ;; 文字コード: utf-8
  ;; UTF-8
  (set-language-environment 'utf-8)

  ;; バックアップ関連の設定
  ;; バックアップファイルを作成する様に指定
  (setq make-backup-files t)
  ;; バックアップ用にコピーする。シムリンクを保持
  (setq backup-by-copying t)
  ;; バックアップファイルの命名関数を再定義して、ディレクトリ名を付加する
  (defun make-backup-file-name (filename)
    (concat
     "~/.trash/"
     (format-time-string "%04Y%02m%02d-%02H%02M%02S-" (current-time))
     (file-name-nondirectory filename)))
  ;; 自動セーブファイルの作成先
  (defun make-auto-save-file-name ()
    (concat
     "~/.trash/"
     "#"
     (format-time-string "%04Y%02m%02d-%02H%02M%02S-" (current-time))
     (file-name-nondirectory buffer-file-name)
     "#"))

  ;; 表示関連設定
  ;; 現在行に色をつける
  (setq hl-line-face 'underline)
  (global-hl-line-mode)
  ;; メニューを表示しない
  (menu-bar-mode -1)

  )

;; read environment for windows
(defun init-windows ()
  ;; サーチパスの設定; Windows: normal
  (let ((home_dir "D:\\home\\doc\\emacs\\"))
    (setq
     load-path
     (append
      (list
       home_dir
       (concat home_dir "site-lisp")
       ) load-path)))

  ;; 共通設定
  (init-common)
  ;; 環境別設定: Windows
  (init-windows-common)
)

;; windows 開発環境
(defun init-windows-dev ()
  (let ((home_dir "D:\\home\\doc\\emacs\\"))
    (setq
     load-path
     (append
      (list
       home_dir
       (concat home_dir "site-lisp\\debug")
       (concat home_dir "site-lisp")
       ) load-path)))
  ;; 共通設定
  (init-common)
  ;; 環境別設定: Windows
  (init-windows-common)
  ;; デバッグ用設定
  (load "init-debug")
  )

;; メニューから保存されたものを取り込む
(defun init-custom-23 ()
  (load "custom")
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(column-number-mode t)
   '(current-language-environment "Japanese")
   '(display-time-mode t)
   '(inhibit-startup-screen t)
   '(show-paren-mode t))
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(default ((t (:inherit nil :stipple nil :background "#FFFAF0" :foreground "#00040F" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline" :family #("ＭＳ ゴシック" 0 7 (charset cp932-2-byte)))))))
  )

;; メニューから保存されたものを取り込む
(defun init-custom-22 ()
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(column-number-mode t)
   '(display-time-mode t)
   '(inhibit-startup-screen t)
   '(show-paren-mode t))
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   )
  )


;; -- main --
(let ((env (get-env)))
  (cond
   ((= env ENV-COLINUX) (init-linux))
   ((= env ENV-DEBIAN) (init-linux))
   ((= env ENV-NETBSD) (init-linux))
   ((= env ENV-WIN-V22) (init-windows-dev))
   ((= env ENV-WIN-V23) (init-windows))
   (t (princ (format "Init Error: os is not supported .\n")))
  ))

;; キーマップ定義用マイナーモードの読み込み
(load "m-mode")
