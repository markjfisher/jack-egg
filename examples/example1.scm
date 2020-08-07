(import (chicken foreign))
(import (chicken process))
(import (chicken file posix))
(import (only (chicken memory) move-memory!))
(import srfi-18)
(import foreigners)
(import jack)

#>
#include "jack/jack.h"
#include "jack/types.h"
#include "jack/session.h"
<#

(define results (jack-client-open "chicken" (jack-options->int 'no-options)))
(define client (cadr results))

(define float-size (foreign-type-size "float"))

;; even using direct c, this is too "noisy". the pipe-mechanism is too slow for RT processing.
(define (simple-copy-cb nframes in-port out-port)
  ;; (print "got n: " nframes ", in: " in-port ", out: " out-port)
  #;((foreign-lambda* void ((int n) (c-pointer in_port) (c-pointer out_port))
     "float* in_buff = jack_port_get_buffer (in_port, n);
      float* out_buff = jack_port_get_buffer (out_port, n);
      memcpy(out_buff, in_buff, n * sizeof(float));
  ") nframes in-port out-port)
  (move-memory!
   (jack-port-get-buffer in-port nframes)
   (jack-port-get-buffer out-port nframes)
   (* nframes float-size))
  0)

(define (with-ports handler in out)
  (lambda (_ nframes)
    (handler nframes in out)))

(print "cpu ld: " (jack-cpu-load client))
(print "samprt: " (jack-get-sample-rate client))

(let* ([in-port (jack-port-register client "input" (jack-port-flags->long 'is-input))]
       [out-port (jack-port-register client "output" (jack-port-flags->long 'is-output))]
       ;; [waiter-thread (set-jack-process-scheme-cb client (with-ports simple-copy-cb in-port out-port))]
       [waiter-thread (set-jack-nano-scheme-cb client (with-ports simple-copy-cb in-port out-port))]
       )
  (let ([r (jack-activate client)])
    (print "activated...")
    (print "in-port : " in-port)
    (print "out-port: " out-port)
    (print "activate: " r)
    (thread-join! waiter-thread)))

(thread-sleep! 60)
