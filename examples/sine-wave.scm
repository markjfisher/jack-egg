(import (only (chicken memory) move-memory!))
(import srfi-1) ;; take, list-tabulate
(import srfi-4) ;; f32
(import srfi-18) ;; threads
(import jack)
(import mathh mathh-consts)

(define results (jack-client-open "sin-maker" (jack-options->int 'no-options)))
(define client (cadr results))

(define float-size 4) ;; normally (foreign-type-size "float") but hard-coded for repl

(define (create-sine-data length peak)
  (apply circular-list
         (map (lambda (i) (* peak (sin (* (/ i length) 2.0 pi))))
              (list-tabulate length values))))

(define table-size 200)

;; the main data for the sine wave, a phase for each channel, and the data itself
(define phase-1 0)
(define phase-2 0)
(define sine-data (create-sine-data table-size 0.2))

(define (with-ports handler p1 p2)
  (lambda (_ nframes)
    (handler nframes p1 p2)))

;; returns every nth element of clist up to max values, dropping first "after" elements
(define (every-n n after clist max)
  (let loop ([acc (make-vector max)] [rest (drop clist after)] [i 0])
    (if (= max i)
        (vector->list acc)
        (begin (vector-set! acc i (first rest))
               (loop acc (drop rest n) (add1 i))))))

(define (sine-wave nframes out-port1 out-port2)
  (let* ([out-buff1 (jack-port-get-buffer out-port1 nframes)]
         [out-buff2 (jack-port-get-buffer out-port2 nframes)]
         [p1data (every-n 1 phase-1 sine-data nframes)] ;; different frequencies
         [p2data (every-n 3 phase-2 sine-data nframes)])
    (set! phase-1 (remainder (+ nframes phase-1) table-size))
    (set! phase-2 (remainder (+ (* 3 nframes) phase-2) table-size))
    (move-memory! (location (list->f32vector p1data)) out-buff1 (* nframes float-size))
    (move-memory! (location (list->f32vector p2data)) out-buff2 (* nframes float-size))
    )
  0)

(let* ([out-port1 (jack-port-register client "output1" (jack-port-flags->long 'is-output))]
       [out-port2 (jack-port-register client "output2" (jack-port-flags->long 'is-output))]
       [waiter-thread (set-jack-nano-scheme-cb client (with-ports sine-wave out-port1 out-port2))])
  (jack-activate client)
  (thread-join! waiter-thread))
