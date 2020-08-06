;; jack.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

(module jack
    (jack-get-version-string
     jack-get-version

     jack-options->int
     int->jack-options
     jack-status->int
     int->jack-status
     jack-port-flags->long
     long->jack-port-flags

     jack-client-open
     jack-client-close
     jack-client-name-size
     jack-get-client-pid
     jack-client-uuid
     jack-get-sample-rate
     jack-is-realtime?
     jack-frames-since-cycle-start
     jack-last-frame-time
     jack-cpu-load
     set-jack-process-scheme-cb
     jack-port-register
     jack-activate
     jack-port-by-name
     jack-port-get-buffer
     )
  (import scheme)
  (import srfi-4)
  (import srfi-18)
  (import (chicken base))
  (import (chicken foreign))
  (import (chicken process))
  (import (chicken file posix))
  (import foreigners)

  (include "jack-impl.scm"))
