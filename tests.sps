#!r6rs

;; Copyright (C) Marc Nieper-Wißkirchen (2021).  All Rights Reserved.

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

(import (rnrs base (6))
	(srfi :237))

(define-record-type foo
  (make-foo x)
  foo?
  (x foo-x)
  (y foo-y foo-set-y!))

(assert (equal? #t (foo? (make-foo 1))))

(assert (equal? 2 (foo-x (make-foo 2))))

(assert (equal? '(3 4) (let ((foo (make-foo 3)))
                         (foo-set-y! foo 4)
                         (list (foo-x foo) (foo-y foo)))))

(define rtd (record-type-descriptor foo))
(define rcd (record-constructor-descriptor foo))

(assert (equal? 'foo (record-type-name rtd)))

(assert (not (record-type-parent rtd)))

(assert (record-type-generative? rtd))

(assert (not (record-type-sealed? rtd)))

(assert (not (record-type-opaque? rtd)))

(assert (equal? '#(x y) (record-type-field-names rtd)))

(assert (not (record-field-mutable? rtd 0)))

(assert (record-field-mutable? rtd 1))

(assert rcd)

(define-record-type bar
  (parent foo)
  (fields z)
  (protocol
   (lambda (n)
     (lambda (x z)
       ((n x) z)))))

(assert (foo? (make-bar 5 6)))
(assert (equal? 5 (foo-x (make-bar 5 6))))
(assert (equal? 6 (bar-z (make-bar 5 6))))
(assert (equal? 7 (let ([bar (make-bar 5 6)])
                    (foo-set-y! bar 7)
                    (foo-y bar))))

(define-record-type rec1
  (fields a)
  (protocol
   (lambda (p)
     (lambda (a/2)
       (p (* 2 a/2))))))

(define rec2
  (make-record-descriptor
   'rec2 rec1 #f #f #f '#((immutable b))
   (lambda (n)
     (lambda (a/2 b)
       ((n a/2) b)))))
(define make-rec2 (record-constructor rec2))
(define rec2? (record-predicate rec2))
(define rec2-b (record-accessor rec2 0))

(define-record-type rec3
  (parent rec2)
  (fields c)
  (protocol
   (lambda (n)
     (lambda (c)
       ((n c c) c)))))

;; Local Variables:
;; mode: scheme
;; End:
