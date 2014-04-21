// rq of 1 sounds strange: like two sounds?
// Is it possible to make this work with ADSR env instead of ENV? (synths being destroyed)

var pattern, clock;

SynthDef.new(\saw, {

    arg freq    = 500,  phase = 0, mul = 0.2, add = 0,
        ffreq   = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,
        attack  = 0.05, decay  = 0.05, sustain  = 0.99, release  = 0.05, sustainLevel  = 0.5,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99, frelease = 0.05, fsustainLevel = 0.5,
        pan = 0;

    var aenv, fenv, sig;

    aenv = EnvGen.kr(Env([0, 1, sustainLevel, 0],
        [attack, decay, sustain, release]), doneAction: 2);
    fenv = EnvGen.kr(Env([0, 1, fsustainLevel, 0],
        [fattack, fdecay, fsustain, frelease]));

    sig = Saw.ar(freq, mul, add);
    sig = RLPF.ar(sig, fenv * amt + ffreq, rq, fmul, fadd);
    sig = sig * aenv;
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;

clock = TempoClock(12);
pattern = Pbind(
    \freq, Pseq(100 * [1, 2, 3], inf),

    \ffreq, 10,
    \amt, 3000,
    \rq, 0.1,

    \attack, 0.001,
    \decay, 0.1,
    \sustain, 0,

    \fattack, 0.001,
    \fdecay, 0.05,
    \fsustainLevel, 0,
    \fsustain, 0,
    \frelease, 0.5,

    \instrument, \saw
).play(clock);


