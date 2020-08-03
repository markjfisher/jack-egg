;; jack.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; (require-library srfi-1)

(module jack
  (jack-get-version-string)
  (import scheme)
  (import (chicken base))
  (import (chicken condition))
  (import (chicken file))
  (import (chicken foreign))
  (import (chicken format))
  (import (chicken gc))
  (import (chicken port))
  (import (chicken repl))

  (include "jack-impl.scm"))
