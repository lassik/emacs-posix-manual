#! /usr/bin/env racket

#lang racket

(require net/url)

(require scrapyard)
(require sxml)

(define (join-url base rel)
  (url->string (combine-url/relative (string->url base) rel)))

(define (relative-url base url)
  (unless (string-prefix? url base)
    (error "URL doesn't start with the right base URL"))
  (substring url (string-length base)))

(define posix-base-url "https://pubs.opengroup.org/onlinepubs/9699919799/")

(define (alphabet-pages)
  (let* ((page (string-append posix-base-url "idx/alphabet.html"))
         (document (scrape-html (cache-http "alphabet.html" page))))
    (map (lambda (href) (join-url page href))
         ((sxpath "//a/@href/text()") document))))

(define (alphabet-page->pairs page)
  (let ((document (scrape-html (cache-http (file-name-from-path page) page))))
    (map (lambda (elem)
           (let ((text (first ((sxpath "text()") elem)))
                 (href (first ((sxpath "@href/text()") elem))))
             (cons text (relative-url posix-base-url (join-url page href)))))
         ((sxpath "//li[@type='disc']/a") document))))

(define (all-pairs)
  (let ((pairs (append-map alphabet-page->pairs (alphabet-pages))))
    (sort pairs string<? #:key car)))

(define (write-emacs-lisp-file)
  (call-with-atomic-output-file
   "posix-manual-data.el"
   (lambda (out _)
     (parameterize ((current-output-port out))
       (displayln ";;; Automatically generated by posix-manual-data.rkt")
       (newline)
       (pretty-write `(defconst posix-manual-data-base-url ,posix-base-url))
       (newline)
       (pretty-write `(defconst posix-manual-data ',(all-pairs)))
       (newline)
       (pretty-write `(provide 'posix-manual-data))))))

(write-emacs-lisp-file)