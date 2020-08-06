## About

jack-egg: CHICKEN Scheme bindings to Jack Audio library

## building

    chicken-install

## testing

    chicken-install -test

## example session

    #;1> (define results (jack-client-open "chicken" (jack-options->int 'no-options)))
    #;2> (define client (cadr results))
    #;3> (jack-get-sample-rate client)
    48000

## example application

    cd examples
    csc example1.csm -ljack
    ./example1

Now hook up the input and output in your favourite jack routing application.
Note, this is quite "noisy" illustrating the pipe communication method is not
RT capable.
