(import (test))

(import (jack))

(test-begin "jack-enums")

(test-group
 "int->jack-options"
 (test "int->jack-options #x00"      'no-options (int->jack-options #x00))
 (test "int->jack-options #x01" 'no-start-server (int->jack-options #x01))
 (test "int->jack-options #x02"  'use-exact-name (int->jack-options #x02))
 (test "int->jack-options #x04"     'server-name (int->jack-options #x04))
 (test "int->jack-options #x08"       'load-name (int->jack-options #x08))
 (test "int->jack-options #x10"       'load-init (int->jack-options #x10))
 (test "int->jack-options #x20"      'session-id (int->jack-options #x20)))

(test-group
 "jack-options->int"
 (test "jack-options->int 'no-options"      #x00 (jack-options->int 'no-options))
 (test "jack-options->int 'no-start-server" #x01 (jack-options->int 'no-start-server))
 (test "jack-options->int 'use-exact-name"  #x02 (jack-options->int 'use-exact-name))
 (test "jack-options->int 'server-name"     #x04 (jack-options->int 'server-name))
 (test "jack-options->int 'load-name"       #x08 (jack-options->int 'load-name))
 (test "jack-options->int 'load-init"       #x10 (jack-options->int 'load-init))
 (test "jack-options->int 'session-id"      #x20 (jack-options->int 'session-id)))

(test-group
 "int->jack-status"
 (test "int->jack-status #x01"   (int->jack-status #x01)   'failure)
 (test "int->jack-status #x02"   (int->jack-status #x02)   'invalid-option)
 (test "int->jack-status #x04"   (int->jack-status #x04)   'name-not-unique)
 (test "int->jack-status #x08"   (int->jack-status #x08)   'server-started)
 (test "int->jack-status #x10"   (int->jack-status #x10)   'server-failed)
 (test "int->jack-status #x20"   (int->jack-status #x20)   'server-error)
 (test "int->jack-status #x40"   (int->jack-status #x40)   'no-such-client)
 (test "int->jack-status #x80"   (int->jack-status #x80)   'load-failure)
 (test "int->jack-status #x100"  (int->jack-status #x100)  'init-failure)
 (test "int->jack-status #x200"  (int->jack-status #x200)  'shm-failure)
 (test "int->jack-status #x400"  (int->jack-status #x400)  'version-error)
 (test "int->jack-status #x800"  (int->jack-status #x800)  'backend-error)
 (test "int->jack-status #x1000" (int->jack-status #x1000) 'client-zombie))

(test-group
 "jack-status->int"
 (test "jack-status->int 'failure"         #x01   (jack-status->int 'failure))
 (test "jack-status->int 'invalid-option"  #x02   (jack-status->int 'invalid-option))
 (test "jack-status->int 'name-not-unique" #x04   (jack-status->int 'name-not-unique))
 (test "jack-status->int 'server-started"  #x08   (jack-status->int 'server-started))
 (test "jack-status->int 'server-failed"   #x10   (jack-status->int 'server-failed))
 (test "jack-status->int 'server-error"    #x20   (jack-status->int 'server-error))
 (test "jack-status->int 'no-such-client"  #x40   (jack-status->int 'no-such-client))
 (test "jack-status->int 'load-failure"    #x80   (jack-status->int 'load-failure))
 (test "jack-status->int 'init-failure"    #x100  (jack-status->int 'init-failure))
 (test "jack-status->int 'shm-failure"     #x200  (jack-status->int 'shm-failure))
 (test "jack-status->int 'version-error"   #x400  (jack-status->int 'version-error))
 (test "jack-status->int 'backend-error"   #x800  (jack-status->int 'backend-error))
 (test "jack-status->int 'client-zombie"   #x1000 (jack-status->int 'client-zombie)))

(test-group
 "jack-port-flags->long"
 (test "jack-port-flags->long 'is-input"     #x01 (jack-port-flags->long 'is-input))
 (test "jack-port-flags->long 'is-output"    #x02 (jack-port-flags->long 'is-output))
 (test "jack-port-flags->long 'is-physical"  #x04 (jack-port-flags->long 'is-physical))
 (test "jack-port-flags->long 'can-monitor"  #x08 (jack-port-flags->long 'can-monitor))
 (test "jack-port-flags->long 'is-terminal"  #x10 (jack-port-flags->long 'is-terminal)))

(test-group
 "long->jack-port-flags"
 (test "long->jack-port-flags #x01"  (long->jack-port-flags #x01) 'is-input)
 (test "long->jack-port-flags #x02"  (long->jack-port-flags #x02) 'is-output)
 (test "long->jack-port-flags #x04"  (long->jack-port-flags #x04) 'is-physical)
 (test "long->jack-port-flags #x08"  (long->jack-port-flags #x08) 'can-monitor)
 (test "long->jack-port-flags #x10"  (long->jack-port-flags #x10) 'is-terminal))

(test-end)
