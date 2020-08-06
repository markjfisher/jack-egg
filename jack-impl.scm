;; jack-impl.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; TODO:
;; - use location for status

(declare
  (emit-external-prototypes-first))

;; external code
#>
#include "jack/jack.h"
#include "jack/types.h"
#include "jack/session.h"

int jack_callback_fd = -1;
int pipe_callback (jack_nframes_t nframes, void *arg) {
  if (jack_callback_fd >= 0) {
    int size = sizeof(jack_nframes_t);
    int ignored;
    char frames[size + 1];
    snprintf(frames, size + 1, "%d\n", nframes);
    ignored = write(jack_callback_fd, frames, size);
  }
}
<#

(define-external jack_callback_fd int -1)
(define jack-process-scheme-cb #f)

(define (make-waiter-thread client handler)
  (let-values (((in out) (create-pipe)))
    (set! jack_callback_fd out)
    (let ([p-in (open-input-file* in)])
      (let loop ()
        (thread-wait-for-i/o! in #:input)
        (let ((v (read p-in)))
          (unless (eof-object? v)
            (handler client v)
            (loop))
          (close-input-port p-in))))))

(define (set-jack-process-scheme-cb client handler)
  (when (eq? handler jack-process-scheme-cb)
    (foreign-code "close(jack_callback_fd);"))
  (set! jack-process-scheme-cb handler)
  ((foreign-lambda* int ((c-pointer client))
     "int my_return;
     my_return = jack_set_process_callback (client, pipe_callback, 0);
     C_return(my_return);
    ") client)
  (thread-start! (make-thread (cut make-waiter-thread client handler) "jack-waiter-thread")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helpers

(define (u32->int u32)
  (car (u32vector->list u32)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global jack functions

(define jack-get-version-string (foreign-lambda c-string "jack_get_version_string"))

;; jack currently doesn't set these correctly, with a todo in the source
(define (jack-get-version)
  (let* ([f (foreign-lambda void "jack_get_version" nonnull-u32vector nonnull-u32vector nonnull-u32vector nonnull-u32vector)]
         [major (make-u32vector 1)]
         [minor (make-u32vector 1)]
         [micro (make-u32vector 1)]
         [proto (make-u32vector 1)])
    (f major minor micro proto)
    (list (u32->int major) (u32->int minor) (u32->int micro) (u32->int proto))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enum types

(define-foreign-enum-type (jack-options int)
  (jack-options->int int->jack-options)
  ((no-options jack-options/no-options) JackNullOption)
  ((no-start-server jack-options/no-start-server) JackNoStartServer)
  ((use-exact-name jack-options/use-exact-name) JackUseExactName)
  ((server-name jack-options/server-name) JackServerName)
  ((load-name jack-options/load-name) JackLoadName)
  ((load-init jack-options/load-init) JackLoadInit)
  ((session-id jack-options/session-id) JackSessionID))

(define-foreign-enum-type (jack-status int)
  (jack-status->int int->jack-status)
  ((failure status/failure) JackFailure)
  ((invalid-option status/invalid-option) JackInvalidOption)
  ((name-not-unique status/name-not-unique) JackNameNotUnique)
  ((server-started status/server-started) JackServerStarted)
  ((server-failed status/server-failed) JackServerFailed)
  ((server-error status/server-error) JackServerError)
  ((no-such-client status/no-such-client) JackNoSuchClient)
  ((load-failure status/load-failure) JackLoadFailure)
  ((init-failure status/init-failure) JackInitFailure)
  ((shm-failure status/shm-failure) JackShmFailure)
  ((version-error status/version-error) JackVersionError)
  ((backend-error status/backend-error) JackBackendError)
  ((client-zombie status/client-zombie) JackClientZombie))

(define-foreign-enum-type (jack-port-flags long)
  (jack-port-flags->long long->jack-port-flags)
  ((is-input flags/is-input) JackPortIsInput)
  ((is-output flags/is-output) JackPortIsOutput)
  ((is-physical flags/is-physical) JackPortIsPhysical)
  ((can-monitor flags/can-monitor) JackPortCanMonitor)
  ((is-terminal flags/is-terminal) JackPortIsTerminal))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jack client

(define (jack-client-open name options)
  (let* ([f (foreign-lambda c-pointer "jack_client_open" c-string int u32vector)]
         [status (make-u32vector 1)]
         [client (f name options status)])
    (list (int->jack-status (u32->int status)) client)))

(define (jack-client-close client)
  ((foreign-lambda int "jack_client_close" c-pointer) client))

(define jack-client-name-size (foreign-lambda int "jack_client_name_size"))

(define (jack-get-client-pid name)
  ((foreign-lambda int "jack_get_client_pid" c-string) name))

(define (jack-client-uuid client)
  ((foreign-lambda c-string "jack_client_get_uuid" c-pointer) client))

(define (jack-get-sample-rate client)
  ((foreign-lambda int "jack_get_sample_rate" c-pointer) client))

(define (jack-is-realtime? client)
  (let ([f (foreign-lambda int "jack_is_realtime" c-pointer)])
    (not (= 0 (f client)))))

(define (jack-frames-since-cycle-start client)
  ((foreign-lambda int "jack_frames_since_cycle_start" c-pointer) client))

(define (jack-last-frame-time client)
  ((foreign-lambda int "jack_last_frame_time" c-pointer) client))

(define (jack-cpu-load client)
  ((foreign-lambda float "jack_cpu_load" c-pointer) client))

(define (jack-port-register client name type)
  (let ([f (foreign-lambda c-pointer "jack_port_register" c-pointer c-string c-string unsigned-long unsigned-long)])
    (f client name "32 bit float mono audio" type 0)))

(define (jack-activate client)
  ((foreign-lambda int "jack_activate" c-pointer) client))

(define (jack-port-by-name client name)
  ((foreign-lambda c-pointer "jack_port_by_name" c-pointer c-string) client name))

(define (jack-port-get-buffer port frames)
  ((foreign-lambda c-pointer "jack_port_get_buffer" c-pointer int) port frames))
