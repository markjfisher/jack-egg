(import (chicken foreign))
(import (chicken process))
(import (chicken file posix))
(import (only (chicken memory) move-memory!))
(import srfi-1 srfi-4 srfi-9 srfi-18)
(import foreigners)
(import jack)
(import mathh mathh-consts)

#>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <signal.h>
#include <unistd.h>
#include <jack/jack.h>


void copy_data(float* vector, void* to, int length) {
  memcpy(vector, to, length * sizeof(float));
}

jack_port_t *output_port1, *output_port2;

#ifndef M_PI
#define M_PI  (3.14159265)
#endif

#define TABLE_SIZE   (200)
typedef struct
{
 float sine[TABLE_SIZE];
 int left_phase;
 int right_phase;
}
paTestData;

paTestData sin_data;

void init_sin_data() {
  int i;
  fprintf(stdout, "initilising sin data\n");
  for( i=0; i<TABLE_SIZE; i++ ) {
    sin_data.sine[i] = 0.2 * (float) sin( ((double)i/(double)TABLE_SIZE) * M_PI * 2. );
  }
  sin_data.left_phase = sin_data.right_phase = 0;
}

int
process_cb (jack_nframes_t nframes, void *arg)
{
  jack_default_audio_sample_t *out1, *out2;
  // paTestData *data = (paTestData*)arg;
  paTestData *data = &sin_data;
  int i;
 
  out1 = (jack_default_audio_sample_t*)jack_port_get_buffer (output_port1, nframes);
  out2 = (jack_default_audio_sample_t*)jack_port_get_buffer (output_port2, nframes);
 
  for( i=0; i<nframes; i++ ) {
    out1[i] = data->sine[data->left_phase];  /* left */
    out2[i] = data->sine[data->right_phase];  /* right */
    data->left_phase += 1;
    if( data->left_phase >= TABLE_SIZE ) data->left_phase -= TABLE_SIZE;
    data->right_phase += 3; /* higher pitch so we can distinguish left and right. */
    if( data->right_phase >= TABLE_SIZE ) data->right_phase -= TABLE_SIZE;
  }
      
  return 0;
}

<#

(define copy_data (foreign-lambda void "copy_data" f32vector c-pointer int))

(define results (jack-client-open "sin-maker" (jack-options->int 'no-options)))
(define client (cadr results))

(define float-size 4) ;; normally (foreign-type-size "float")

(define-record-type sin-table
  (make-table count data left-phase right-phase)
  sin-table?
  (count sin-table-count sin-table-count-set!)
  (data sin-table-data sin-table-data-set!)
  (left-phase sin-table-left-phase sin-table-left-phase-set!)
  (right-phase sin-table-right-phase sin-table-right-phase-set!))

(define (sin-data length peak)
  (apply f32vector
         (map (lambda (i) (* peak (sin (* (/ i length) 2.0 pi))) ) (list-tabulate length values))))

(define table-size 64)

(define table
  (make-table table-size (sin-data table-size 0.2) 0 0))

(define (with-ports handler p1 p2)
  (lambda (_ nframes)
    (handler nframes p1 p2)))

(define (sin-wave nframes out-port1 out-port2)
  #;(print "in sin-wave")
  (let ([out-buff1 (jack-port-get-buffer out-port1 nframes)]
        [out-buff2 (jack-port-get-buffer out-port2 nframes)]
        [cl (apply circular-list (f32vector->list (sin-table-data table)))]
        [phase-1 (remainder (+ 1 (sin-table-left-phase table)) table-size)]
        [phase-2 (remainder (+ 3 (sin-table-right-phase table)) table-size)])
    (sin-table-left-phase-set! table phase-1)
    (sin-table-right-phase-set! table phase-2)
    (let*-values ([(_ data-1) (split-at cl phase-1)]
                  [(_ data-2) (split-at cl phase-2)]
                  [(phased-sin-data-1) (apply f32vector (take data-1 nframes))]
                  [(phased-sin-data-2) (apply f32vector (take data-2 nframes))])
      #;(copy_data phased-sin-data-1 out-buff1 nframes)
      #;(copy_data phased-sin-data-2 out-buff2 nframes)
      (move-memory! (location phased-sin-data-1) out-buff1 (* nframes float-size))
      (move-memory! (location phased-sin-data-2) out-buff2 (* nframes float-size))))
  0)

(define-foreign-variable output_port1 (c-pointer "jack_port_t") "output_port1")
(define-foreign-variable output_port2 (c-pointer "jack_port_t") "output_port2")

(define (set-jack-nano-scheme-cb2 client handler)
  ((foreign-lambda* int ((c-pointer client))
     "int my_return;
     my_return = jack_set_process_callback (client, process_cb, 0);
     C_return(my_return);
    ") client)
  0)

(let* ([out-port1 (jack-port-register client "output1" (jack-port-flags->long 'is-output))]
       [out-port2 (jack-port-register client "output2" (jack-port-flags->long 'is-output))]
       [waiter-thread (set-jack-nano-scheme-cb2 client (with-ports sin-wave out-port1 out-port2))])
  (print "setting ports to 1: " out-port1 ", 2: " out-port2)
  (set! output_port1 out-port1)
  (set! output_port2 out-port2)
  (foreign-code "init_sin_data();")
  (jack-activate client)
  (print "waiter-thread: " waiter-thread)
  #;(thread-join! waiter-thread))

(thread-sleep! 6000)
