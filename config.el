;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;====================;;
;; CORE CONFIGURATION ;;
;;====================;;

(setq user-full-name "Alexander Bisono"
      user-mail-address "sbisonol@gmail.com")

(setq doom-font (font-spec :family "mononoki Nerd Font" :size 14)
      doom-variable-pitch-font (font-spec :family "Cantarell" :size 14 :weight 'regular))

(setq doom-theme 'doom-priscode)
(add-to-list 'default-frame-alist '(alpha-background . 85))


(setq org-directory "~/org/")

(setq display-line-numbers-type nil)

(setq fancy-splash-image (concat (file-name-as-directory doom-private-dir) "pc_gear_v3_smol.png"))

;;====================;;
;; MISC CONFIGURATION ;;
;;====================;;

;; Leader keys
;; NOTE: This *technically* should be under the keybinds section. However,
;; whenever my config breaks, dealing with the default leader key (SPC) and
;; other nonsense is a pain. Not to mention that for some godforsaken reason,
;; `org-mode' doesn't load with the correct bindings if it's not near the top of
;; my config. As such, I'm gonna move this as high as I think is sensible.
;; - Dr. Bluefall

(setq doom-leader-key ","
      doom-leader-alt-key "M-,"
      doom-localleader-key ", m"
      doom-localleader-alt-key "M-, m")

;; Add path to mu4e.
;; Debatably useful? Not sure. Damned if I'm changing it though. - Dr. Bluefall
;; CORRECTION: Very much useful. Whatever version of mu4e DOOM Emacs has, it
;; doesn't include `mu4e-contrib'. Luckily, mu's system package includes it.

(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")

;; Let emacs use UNIX password stores as auth sources. Pretty self-explanatory.

(auth-source-pass-enable)
(setq auth-sources '(password-store))

;; For some reason, persp-mode will occasionally break mu4e. So it gets put in
;; the timeout box.
(persp-mode -1)

;; Enable mouse support in terminal.
;;
;; ...to be honest, I rarely use the terminal anyway, but when I do, I miss
;; this.
(xterm-mouse-mode 1)

;;====================;;
;; MODE CONFIGURATION ;;
;;====================;;

;; EMail

(add-hook! mu4e-main-mode :append
           (setq-local visual-fill-column-width 64
                       visual-fill-column-center-text t)
           (visual-fill-column-mode 1))

(add-hook! mu4e-view-mode :append
           (setq-local visual-fill-column-width 110
                       visual-fill-column-center-text t)
           (visual-fill-column-mode 1))

(after! mu4e
  (setq +mu4e-backend 'mbsync
        mu4e-headers-skip-duplicates t
        sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail)

  (set-email-account! "sbisonol@gmail.com"
                      '((mu4e-sent-folder .   "/gmail/sbisonol/[Gmail]/Sent Mail")
                        (mu4e-refile-folder . "/gmail/sbisonol/[Gmail]/All Mail")
                        (mu4e-trash-folder .  "/gmail/sbisonol/[Gmail]/Trash")
                        (mu4e-refile-folder . "/gmail/sbisonol/Archives")
                        (smtpmail-smtp-server . "smtp.gmail.com")
                        (smtpmail-smtp-service . 587)
                        (smtpmail-smtp-user . "sbisonol@gmail.com")))

  (require 'mu4e-utils)
  (mu4e-bookmark-define "list:autoconf.gnu.org" "GNU Autoconf mailing list" ?a)
  (mu4e-bookmark-define "list:systemd-devel.lists.freedesktop.org" "systemd-devel mailing list" ?s)
  (mu4e-bookmark-define "list:emacs-orgmode.gnu.org" "Emacs org-mode mailing list" ?o)
  (mu4e-bookmark-define "list:info-gnu-emacs.gnu.org" "GNU Emacs Announcements" ?E)
  (mu4e-bookmark-define "list:help-gnu-emacs.gnu.org" "GNU Emacs general discussion" ?e))

;; Company Mode

(after! company
  (require 'company-box)
  (add-hook! company-mode (company-box-mode))
  (setq company-idle-delay 0))

;; SQL Mode

(after! sql
  (sql-set-product-feature 'mysql :prompt-regexp "^\\(MariaDB\\|MySQL\\) \\[[_a-zA-Z]*\\]> "))

;; Magit mode

(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-traditional))

;; C/C++ Mode

(setq lsp-clients-clangd-args
      '("--header-insertion-decorators=0" "--header-insertion=never"))

(setq c-default-style "k&r"
      c-basic-offset 4
      tab-width 4)

;; Rust mode

(after! rustic
  (setq lsp-rust-analyzer-cargo-load-out-dirs-from-check t
        lsp-rust-analyzer-proc-macro-enable t))

;; Auto-format

(put '+format-with 'safe-local-variable 'keywordp)
(add-to-list '+format-on-save-enabled-modes 'autoconf-mode)
(add-to-list '+format-on-save-enabled-modes 'makefile-automake-mode)

;; Dirvish

; NOTE: Right now, DOOM's version of Dirvish is a bit borked. Currently, this
; requires doomemacs/doomemacs#6568 to be merged locally. It's a bit of a hack,
; and it has to be redone after every 'doom upgrade' until either A) I advise
; `doom/upgrade', probably with some Magit-based tomfuckery, or B) the PR is
; merged.
;
; Luckily, there's a way to pull PRs as branches: 'git fetch origin
; pull/$PR_ID/head:$BRANCHNAME'
;
; I'll have to figure out the correct analogue for magit, but hopefully it
; shouldn't be too hard. (...famous last words)

(after! dirvish
   (setq dirvish-hide-details t)
   (setq dirvish-attributes '(git-msg
                              vc-state
                              expanded-state
                              file-size
                              all-the-icons
                              symlink-target
                              hl-line))
   (dirvish-peek-mode))

(after! (dirvish projectile)

  (defadvice! +prisco/projectile-dirvish ()
    "Run `dirvish' in a Projectile project's root."
    :override #'projectile-dired
    (interactive)
    (dirvish (projectile-acquire-root)))

  (setq +workspaces-switch-project-function (lambda (_) (projectile-dired))))

;; Org Mode

(after! org
  (setq org-agenda-span 7
        org-agenda-start-on-weekday 0
        org-roam-v2-ack t
        org-agenda-files '("~/org/primary_agenda.org")
        org-log-done 'time
        visual-fill-column-width 100
        visual-fill-column-center-text t)

(add-hook! 'org-mode-hook
           #'visual-fill-column-mode
           #'visual-line-mode))

;;=============;;
;; KEYBINDINGS ;;
;;=============;;

;; Split Navigation

(map! :n "<C-up>" #'evil-window-up
      :n "<C-down>" #'evil-window-down
      :n "<C-left>" #'evil-window-left
      :n "<C-right>" #'evil-window-right)

;; File Navigation

(map! :leader "." (cmd! (if (projectile-project-p)
                            (projectile-find-file)
                          (helm-find-files nil))))
(after! dirvish
  (map! :map dirvish-mode-map
      :en "q" #'dirvish-quit
      :en "TAB" #'dirvish-subtree-toggle))

;; Compilation

(map! :map compilation-mode-map
      :n "q" #'evil-delete-buffer)

;; Project Management

(map! :map projectile-mode-map
      :leader :n "cc" #'projectile-compile-project
      :leader :n "cp" #'projectile-package-project
      :leader :n "ct" #'projectile-test-project)

;; Email
(after! mu4e
  (require 'mu4e-contrib)
  (map! :map mu4e-headers-mode-map
        :localleader :n "ra" (cmd! (mu4e-headers-mark-all-unread-read)
                                   ;; Yes, I know this is an internal function.
                                   ;; No, I don't care. - Dr. Bluefall
                                   (let ((mu4e-headers-leave-behavior 'apply))
                                     (mu4e~headers-quit-buffer)))))

;; SLY MREPL

; I tend to have phases of developing in CL, so putting this behind a feature
; gate is probably for the best.

(map!
 (:when (featurep! :lang common-lisp)
  (:map sly-mrepl-mode-map
   :i "<up>" #'sly-mrepl-previous-input-or-button
   :i "<down>" #'sly-mrepl-next-input-or-button)))
