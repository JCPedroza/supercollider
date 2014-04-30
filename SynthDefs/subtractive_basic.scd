// NEEDS TO HANDLE FFREQ!!! (currently fenv * amt * ffreq crashes audio)
// Sawtooth
SynthDef.new("saw", {

    arg freq    = 500,  phase = 0, mul = 0.2, add = 0,
        ffreq   = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,
        attack  = 0.05, decay  = 0.05, sustain  = 0.99, release  = 0.05,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99, frelease = 0.05,
        pan = 0;

    var aenv, fenv, sig;

    aenv   = EnvGen.kr(Env.adsr(attack, decay, sustain, release), doneAction: 2);
    fenv   = EnvGen.kr(Env.adsr(fattack, fdecay, fsustain, frelease), doneAction: 2);

    sig = Saw.ar(freq, mul, add);
    sig = RLPF.ar(sig, fenv * amt, rq, fmul, fadd);
    sig = sig * aenv;
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).send(s);