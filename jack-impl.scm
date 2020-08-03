;; jack-impl.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

(declare
  (emit-external-prototypes-first))

#>
#include "jack/jack.h"
<#

(define jack-get-version-string (foreign-lambda c-string "jack_get_version_string"))

