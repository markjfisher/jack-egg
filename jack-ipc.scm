;; jack-ipc.scm
;; -*- mode: Scheme; tab-width: 2; -*- ;;

#>
#include <unistd.h>
#include <jack/jack.h>
#include <jack/types.h>
#include <jack/session.h>
#include <nanomsg/nn.h>
#include <nanomsg/pipeline.h>
#include <nanomsg/ipc.h>

int out_sock = -1;
char socket_name[80];
int nano_callback (jack_nframes_t nframes, void *arg)
{
  char frames[10];

  if (out_sock == -1) {
    int current_pid = getpid();
    sprintf(socket_name, "ipc:///tmp/jack-cb-%d.ipc", current_pid);
    out_sock = nn_socket(AF_SP, NN_PUSH);
    nn_connect(out_sock, socket_name);
  }

  sprintf(frames, "%d", nframes);
  nn_send(out_sock, frames, strlen(frames), 0);
}

<#

(define (create-ipc-name)
  (string-append "ipc:///tmp/jack-cb-" (number->string (current-process-id))  ".ipc"))

(define (shutdown-handler socket)
  (lambda (signum)
    (nn-close socket)
    (exit 0)))

(define (make-nano-listener client handler)
  (let ([socket (nn-socket 'pull)]
        [socket-name (create-ipc-name)])
    (nn-bind socket socket-name)
    (let ([signals (list signal/hup signal/int signal/quit signal/ill
                         signal/trap signal/abrt signal/bus signal/kill
                         signal/usr1 signal/usr2)]
          [handler (shutdown-handler socket)])
      (for-each (cut set-signal-handler! <> handler) signals))
    (let loop ()
      (let ([msg (nn-recv socket)])
        (handler client (string->number msg))
        (loop)))))

(define (set-jack-callback client handler)
  ((foreign-lambda* int ((c-pointer client))
     "int my_return;
     my_return = jack_set_process_callback (client, nano_callback, 0);
     C_return(my_return);
    ") client)
  (thread-start! (make-thread (cut make-nano-listener client handler) "jack-nano-thread")))

