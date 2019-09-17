;;; init.el --- Emacs init file

;;; Commentary:
;; My Emacs configuration

;;; Code:
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq make-backup-files nil
      auto-save-default nil)

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil)

(progn
  (menu-bar-mode -1)
  (tool-bar-mode -1))

(progn
  (global-display-line-numbers-mode 1)
  (global-hl-line-mode 1)
  (setq-default display-line-numbers-width 4))

(setq-default indent-tabs-mode nil)

(setq line-number-mode t
      column-number-mode t)

(progn
  (show-paren-mode 1)
  (electric-pair-mode 1))

(defalias 'yes-or-no-p 'y-or-n-p)

(add-hook 'before-save-hook 'whitespace-cleanup)

(setq scroll-step 1
      scroll-conservatively 10000)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse 't)

(defun beginning-or-nonspace ()
  "Move the point to the first non-space character, or, if the point is already there, to the first character."
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
      (beginning-of-line)))
(global-set-key (kbd "C-a") #'beginning-or-nonspace)

(defun delimit-region (open close)
  "Delimit region with brackets; OPEN is the open bracket and CLOSE is the close bracket."
  (interactive)
  (let ((b (region-beginning))
        (e (region-end)))
    (let ((e (+ e 1)))
      (goto-char b)
      (insert open)
      (goto-char e)
      (insert close))))
(progn
  (global-set-key (kbd "C-M-(") (lambda () (interactive) (delimit-region "(" ")")))
  (global-set-key (kbd "C-M-{") (lambda () (interactive) (delimit-region "{" "}")))
  (global-set-key (kbd "C-M-[") (lambda () (interactive) (delimit-region "[" "]"))))

(defun out-parens-quotes ()
  "Move the point forward if it is between quotes or parens."
  (interactive)
  (let ((next (string (following-char)))
        (quotes "\"")
        (squotes "'")
        (parens ")")
        (rparens "]")
        (brackets "}"))
    (while (not (or (string= next quotes)
                    (string= next squotes)
                    (string= next parens)
                    (string= next rparens)
                    (string= next brackets)))
      (progn
        (forward-char)
        (setq next (string (following-char)))))
    (if (or (string= next quotes)
            (string= next squotes)
            (string= next parens)
            (string= next rparens)
            (string= next brackets))
        (forward-char))))
(global-set-key (kbd "<C-tab>") 'out-parens-quotes)

(defvar shell-mode-map)
(defun shell-delete ()
  "Delete shell window."
  (define-key shell-mode-map (kbd "<C-escape>") #'delete-window))
(global-set-key (kbd "<C-escape>") 'shell)
(setq display-buffer-alist '(("\\*shell\\*" display-buffer-at-bottom)))
(eval-after-load "shell" #'shell-delete)

(add-hook 'gud-mode-hook 'gdb-many-windows)
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers 1)
  :bind
  ("C-c C-r" . ivy-resume))
(use-package counsel
  :ensure t
  :config
  (counsel-mode 1))
(use-package swiper
  :ensure t
  :bind
  ("C-s" . swiper))
(use-package avy
  :ensure t
  :config
  (avy-setup-default)
  :bind
  ("C-:" . avy-goto-char)
  ("C-'" . avy-goto-char-2)
  ("M-g f" . avy-goto-line)
  ("M-g w" . avy-goto-word-1)
  ("M-g e" . avy-goto-word-0)
  ("C-c C-j" . avy-resume))
(use-package ace-window
  :ensure t
  :bind
  ("M-o" . ace-window)
  :config
  (setq aw-dispatch-always t))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package eclipse-theme
  :ensure t
  :config
  (load-theme 'eclipse t))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package company
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-company-mode)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next-or-abort)
        ("C-p" . company-select-previous-or-abort))
  :config
  (setq company-idle-delay 0))

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode 1))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package projectile
  :ensure t
  :config
  (defvar projectile-mode)
  (defvar projectile-mode-map)
  (projectile-mode 1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode 1))

(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (global-set-key (kbd "C-x M-g") 'magit-dispatch))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package irony
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package company-irony
  :ensure t
  :config
  (eval-after-load 'company
    '(add-to-list 'company-backends 'company-irony)))

(use-package flycheck-irony
  :ensure t
  :config
  (eval-after-load 'flycheck
    '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup)))

(use-package irony-eldoc
  :ensure t
  :config
  (add-hook 'irony-mode-hook #'irony-eldoc))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package elpy
  :ensure t
  :init
  (elpy-enable))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package indium
  :ensure t
  :config
  (add-hook 'js-mode-hook 'indium-interaction-mode)
  (setq indium-chrome-executable "google-chrome-stable"))
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(use-package bash-completion
  :ensure t)
;; ------------------------------------------------------------
;; ------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (yasnippet-snippets yasnippet use-package magit irony-eldoc indium flycheck-irony flycheck elpy eclipse-theme counsel-projectile company-irony bash-completion ace-window))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; init.el ends here
