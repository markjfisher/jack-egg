(import (test))

(import (jack))

(test-begin "jack-client")

(test-group
 "simple jack functions"
 (test-assert "version string is not empty" (string<? "" (jack-get-version-string)))
 (test-assert "client name size is not 0" (> (jack-client-name-size) 0)))

(test-end)
