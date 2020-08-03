(import (test))
(import (jack))

(test-begin "jack")

(let [(version-string (jack-get-version-string))]
  (test-assert "version string is not empty" (string<? "" version-string)))

(let [(size (jack-client-name-size))]
  (test-assert "client name size is not 0" (> size 0)))

(test-end)
