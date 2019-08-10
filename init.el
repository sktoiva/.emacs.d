;; ********************************************************************************************************************
;; Basic configuration settings and use package configuration

(setq delete-old-versions -1    ; delete excess backup versions silently
      version-control t         ; use version control
      vc-make-backup-files t    ; make backups file even when in version controlled dir
      backup-directory-alist `(("." . "~/.emacs.d/backups"))  ; which directory to put backups file
      vc-follow-symlinks t                ; don't ask for confirmation when opening symlinked file
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t))  ;transform backups file name
      inhibit-splash-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-message t
      ring-bell-function 'ignore   ; silent bell when you make a mistake
      coding-system-for-read 'utf-8   ; use utf-8 by default
      coding-system-for-write 'utf-8
      sentence-end-double-space nil  ; sentence SHOULD end with only a point.
      default-fill-column 80    ; toggle wrapping text at the 80th character
      windmove-wrap-around t            ; wrap aronud when navigating between windows
      mac-option-modifier 'meta
      mac-command-modifier 'super
      mac-pass-control-to-system nil
      default-input-method "MacOSX"
      frame-title-format nil
      use-dialog-box nil
      custom-file "./custom.el")

(load custom-file)

(setq-default indent-tabs-mode nil)

;; Load files when changed on disk
(global-auto-revert-mode t)

;; Disable unecessary menus
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode 1)

;; Line numbers, word wrapping and such
(global-linum-mode 1)
(visual-line-mode 1)
(global-hl-line-mode)

;; Whitespace settings
(setq whitespace-style '(face tabs tab-mark trailing)
      mode-require-final-newline t)
(global-whitespace-mode 1)
(add-hook 'before-save-hook 'whitespace-cleanup)

;; Configure font
(add-to-list 'default-frame-alist
             '(font . "Office Code Pro-13:weight=normal"))

;; Better window management
(defadvice split-window (after move-point-to-new-window activate)
  "Moves the point to the newly created window after splitting."
  (other-window 1))

(winner-mode 1)

;; Configure and install use-package

(require 'package)

(setq package-enable-at-startup nil) ; tells emacs not to load any packages before starting up

;; the following lines tell emacs where on the internet to look up
;; for new packages.
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "https://melpa.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents) ; upgrage packages archive
  (package-install 'use-package)) ; and install the most recent version of use-package

(require 'use-package)

;; ********************************************************************************************************************

;; PATH from shell
(use-package exec-path-from-shell
  :ensure t
  :demand
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward))

(use-package nord-theme
  :ensure t
  :demand
  :config
  (load-theme 'nord t))

(use-package telephone-line
  :ensure t
  :demand
  :init
  (setq telephone-line-lhs
        '((evil   . (telephone-line-evil-tag-segment))
          (accent . (telephone-line-vc-segment
                     telephone-line-process-segment))
          (nil    . (telephone-line-minor-mode-segment
                     telephone-line-buffer-segment))))
  (setq telephone-line-rhs
        '((nil    . (telephone-line-misc-info-segment))
          (accent . (telephone-line-major-mode-segment))
          (evil   . (telephone-line-airline-position-segment))))
  (setq telephone-line-height 24
        telephone-line-subseparator-faces '((evil . nil)
                                            (accent . nil)
                                            (nil . accent))
        telephone-line-evil-use-short-tag t)
  :config
  (telephone-line-mode 1))

;; Keybindings and descriptions with general and which-key
;; Keep general loading here, for it sets the :general keyword for use-package
(use-package general
  :ensure t
  :config
  (general-evil-setup t) ;Generate vim like setters for general, like nmap)
  (nmap
    "s-s" 'save-buffer)
  ;; Global prefix key definitions spanning multiple packages
  (nmap
    :prefix "SPC"
    "t" '(nil :which-key "toggle")
    "h" '(nil :which-key "help")
    "hk" '(describe-key :which-key "describe-key")
    "hv" '(describe-variable :which-key "describe-variable")
    "hf" '(describe-function :which-key "describe-function")
    "hd" '(apropos-documentation :which-key "documentation")))

(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(use-package helm
  :ensure t
  :general
  ("M-x" #'helm-M-x
   "C-x C-f" #'helm-find-files)
  (:keymaps 'helm-map
            "<tab>" #'helm-execute-persistent-action
            "C-i" #'helm-execute-persistent-action)

  (nmap
    :prefix "SPC"
    "SPC" '(helm-find-files :which-key "helm find files"))

  :init
  (setq helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
        helm-ff-file-name-history-use-recentf t
        helm-mode-fuzzy-match                 t
        helm-completion-in-region-fuzzy-match t
        helm-M-x-fuzzy-match                  t)

  :config
  (require 'helm-config)
  (helm-mode 1)
  (helm-autoresize-mode 1))

(use-package company
  :ensure t
  :config
  (global-company-mode))

(use-package avy
  :ensure t
  :general
  (nmap
    :prefix "SPC"
    "a" '(avy-goto-char-timer :which-key "Ace jump")))

;; Parens editing

(use-package smartparens
  :ensure t
  :hook ((prog-mode . smartparens-strict-mode)
         (prog-mode . show-smartparens-mode))
  :general
  (nmap
    :prefix "SPC"
    "s" '(nil :which-key "smartparens")
    "sk" '(sp-splice-sexp-killing-forward :which-key "Splice killing forward")
    "sj" '(sp-splice-sexp-killing-backward :which-key "Splice killing backward"))
  :config
  (require 'smartparens-config)

  (sp-pair "(" ")" :wrap "C-(") ;parens wrapping in evil mode
  (sp-pair "\"" "\"" :wrap "C-\"")
  (sp-pair "{" "}" :wrap "C-{")
  (sp-use-paredit-bindings))

(use-package evil-smartparens
  :ensure t
  :after smartparens
  :hook (smartparens-enabled . evil-smartparens-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :init
  (set-face-background 'show-paren-match "#4B5266")
  (set-face-attribute 'show-paren-match nil :underline nil))

(use-package rainbow-mode
  :ensure t
  :config
  (rainbow-mode))

(use-package ag
  :ensure t
  :init
  (setq aq-highlight-search t))

(use-package helm-ag
  :ensure t
  :after ag)

(use-package projectile
  :ensure t
  :general
  (nmap
    :keymaps 'projectile-mode-map
    :prefix "SPC"
    "p" '(projectile-command-map :which-key "projectile"))
  :init
  (projectile-mode 1))

(use-package helm-projectile
  :ensure t
  :after projectile
  :init
  (setq projectile-completion-system 'helm
        projectile-switch-project-action 'helm-projectile)
  :config
  (helm-projectile-on))

(use-package neotree
  :ensure t
  :general
  (nmap
    :keymaps 'neotree-mode-map
    "<tab>" #'neotree-enter
    "SPC" #'neotree-quick-look
    "q" #'neotree-hide
    "RET" #'neotree-enter
    "g" #'neotree-refresh
    "j" #'neotree-next-line
    "k" #'neotree-previous-line
    "A" #'neotree-stretch-toggle
    "H" #'neotree-hidden-file-toggle
    "tn" '(neotree-toggle :which-key "neotree toggle"))
  (nmap
    :prefix "SPC"
    "tn" '(neotree-toggle :which-key "neotree toggle"))
  :init
  (setq neo-theme 'nerd
        neo-smart-open t))

(use-package all-the-icons
  :ensure t)

(use-package centaur-tabs
  :ensure t
  :demand t
  :general
  (nmap
    "s-}" #'centaur-tabs-forward
    "s-{" #'centaur-tabs-backward)
  :init
  (setq centaur-tabs-style "zigzag"
        centaur-tabs-set-icons t
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-height 32
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "⬤")
  :config
  (centaur-tabs-mode t)
;;  (centaur-tabs-headline-match)
  (centaur-tabs-inherit-tabbar-faces))

(use-package magit
  :ensure t
  :defer t
  :general
  (nmap
    :prefix "SPC"
    "g" '(nil :which-key "magit")
    "gg" '(magit-status :which-key "magit status"))
  :init
  (setq magit-last-seen-setup-instructions "1.4.0"
        magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)

  :config
  (use-package evil-magit :ensure t))

(use-package clojure-mode
  :ensure t
  :hook ((clojure-mode-hook . eldoc-mode))
  :mode "\\.clj\\'")

(use-package cider
  :ensure t
  :after clojure-mode
  :hook ((clojure-mode-hook . cider-mode))
  :general
  (nmap
    :keymaps 'clojure-mode-map
    :prefix ","
    "c" '(nil :which-key "cider")
    "cj" '(cider-jack-in-clj&cljs :which-key "cider-jack-in-clj&cljs"))
  (nmap
    :keymaps 'cider-mode-map
    :prefix ","
    "e" '(nil :which-key "eval")
    "ep" '(cider-eval-last-sexp :which-key "eval-last-sexp")
    "en" '(cider-eval-ns-form :which-key "eval-ns-form")
    "ur" '(my-clojure/cider-reset :which-key "user-reset")
    "g" '(nil :which-key "cider-goto")
    "gj" '(cider-find-dwim :which-key "jump-to-def"))
  :init
  (setq cider-repl-display-help-banner nil
        cider-repl-pop-to-buffer-on-connect nil
        cider-repl-result-prefix ";; => "
        cider-interactive-eval-result-prefix ";; => ")
  :config
  (defun my-clojure/cider-reset ()
    (interactive)
    (cider-ensure-connected)
    (with-current-buffer (cider-current-repl-buffer)
      (goto-char (point-max))
      (insert "(user/reset)")
      (cider-repl-return))
    (message "(user/reset) called")))

(use-package clj-refactor
  :ensure t
  :after clojure-mode
  :hook ((clojure-mode-hook . clj-refactor-mode)))
