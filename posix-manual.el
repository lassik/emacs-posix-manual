;;; posix-manual.el --- POSIX manual page lookup -*- lexical-binding: t; -*-
;;
;; SPDX-FileCopyrightText: 2019 Lassi Kortela
;; SPDX-License-Identifier: ISC
;; Author: Lassi Kortela <lassi@lassi.io>
;; URL: https://github.com/lassik/emacs-posix-manual
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Provides a `posix-manual-entry` command with tab completion. It
;; lets you easily call up POSIX manual pages in your web browser.
;;
;;; Code:

(require 'browse-url)

(require 'posix-manual-data)

;;;###autoload
(defun posix-manual-entry (page)
  "Visit the given POSIX manual page in a web browser.

Interactively, ask which PAGE to visit in the minibuffer with tab
completion. The `browse-url' function is used to open the page."
  (interactive
   (list (completing-read
          "Posix manual entry: "
          posix-manual-data nil t)))
  (let ((url (concat posix-manual-data-base-url
                     (cdr (or (assoc page posix-manual-data)
                              (error "No such POSIX manual page"))))))
    (browse-url url)))

(provide 'posix-manual)

;;; posix-manual.el ends here
