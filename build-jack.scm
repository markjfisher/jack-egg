(import scheme)
(import (chicken base))
(import (chicken file))
(import (chicken format))
(import (chicken io))
(import (chicken process))
(import (chicken process-context))
(import (chicken string))

;; copied from https://depp.brause.cc/breadline/build-breadline.scm

(define (library-flags var command)
  (or (get-environment-variable var)
      (let ((exit (system (string-append command " > /dev/null"))))
        (if (zero? exit)
            (let ((output (with-input-from-pipe command (cut read-string #f))))
              (when (eof-object? output)
                (error (format "Command didn't produce any output: ~a" command)))
              output)
            (error (format "Command failed with exit code ~s, set $~a" exit var))))))

(define csc (get-environment-variable "CHICKEN_CSC"))
(define jack-cflags (library-flags "JACK_CFLAGS" (string-chomp "(pkg-config --cflags jack || echo '')")))
(define jack-ldlibs (library-flags "JACK_LDLIBS" (string-chomp "(pkg-config --libs jack || echo '-ljack')")))
(define nanomsg-cflags (library-flags "NANOMSG_CFLAGS" (string-chomp "(pkg-config --cflags nanomsg || echo '')")))
(define nanomsg-ldlibs (library-flags "NANOMSG_LDLIBS" (string-chomp "(pkg-config --libs nanomsg || echo '-lnanomsg')")))

(define args (list csc jack-cflags jack-ldlibs nanomsg-cflags nanomsg-ldlibs))

;; need to match each args entry with a format entry
(define cmdline
  (string-append (apply format "~a -C ~a -L ~a -C ~a -L ~a " (map qs args))
                 (string-intersperse (map qs (command-line-arguments)) " ")))
(system cmdline)
