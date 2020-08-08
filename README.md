## About

jack-egg: CHICKEN Scheme bindings to Jack Audio library

Currently needs nanomsg installed, as it uses this to communicate between
the jack server and the scheme callback procedure.

## building

    chicken-install

## testing

    chicken-install -test

## example session

    #> (import jack)
    #> (define-values (status client)
         (receive (jack-client-open "chicken" (jack-options->int 'no-options))))
    #> (jack-get-sample-rate client)
    48000

## example applications

    cd examples
    csc example1.scm -ljack
    ./example1

    csc sine-wave.scm -ljack
    ./sine-wave
