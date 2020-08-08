(import (chicken foreign))
(import (chicken process))
(import (chicken file posix))
(import (only (chicken memory) move-memory!))
(import srfi-18)
(import foreigners)
(import jack)

(define-values (status client)
  (jack-client-open "chicken"))

(define float-size (foreign-type-size "float"))

(define (simple-copy nframes in-port out-port)
  (move-memory! (jack-port-get-buffer in-port nframes)
                (jack-port-get-buffer out-port nframes)
                (* nframes float-size))
  0)

(define (with-ports handler in out)
  (lambda (_ nframes)
    (handler nframes in out)))

(let* ([in-port (jack-port-register client "input" (jack-port-flags->long 'is-input))]
       [out-port (jack-port-register client "output" (jack-port-flags->long 'is-output))]
       [waiter-thread (set-jack-callback client (with-ports simple-copy in-port out-port))])
  (jack-activate client)
  (thread-join! waiter-thread))
