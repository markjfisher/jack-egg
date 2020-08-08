;; jack-client.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

(declare
  (emit-external-prototypes-first))

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
;; jack client

(define (jack-client-open name #!optional (options (jack-options->int 'no-options)))
  (let* ([f (foreign-lambda c-pointer "jack_client_open" c-string int u32vector)]
         [status (make-u32vector 1)]
         [client (f name options status)])
    (values (int->jack-status (u32->int status)) client)))

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
