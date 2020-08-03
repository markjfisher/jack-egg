;; jack.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

(module jack
    (jack-get-version-string
     jack-client-name-size)
  (import scheme)
  (import (chicken base))
  (import (chicken foreign))

  (include "jack-impl.scm"))
