// 2 combs?
// clean!!
/*s.options.memSize = 16384;
s.boot;*/

SynthDef.new("saw", {

    arg freq = 500,phase = 0, mul = 0.2, add = 0,
        ffreq = 20000,amt = 4000, rq = 1, fmul = 1, fadd = 0,
        attack = 0.05, decay  = 0.05, sustain  = 0.99, release  = 0.05, sustainLevel = 0.5,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99, frelease = 0.05, fsustainLevel = 0.5,
        dtime = 0.2, ddecaytime = 4, dmul = 1, dadd = 0,
        pan = 0;

    var aenv, fenv, sig;

    aenv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fenv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    sig = Saw.ar(freq, mul, add);
    sig = RLPF.ar(sig, fenv * amt + ffreq, rq, fmul, fadd);
    sig = sig * aenv;
    sig = CombN.ar(sig, 2, dtime, ddecaytime, dmul, dadd);
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;

r = Routine({

    var delta, freq, c = 261.626, db = 277.183, d = 293.665, eb = 311.127, e = 329.628,
        f = 349.228, gb = 369.994, g = 391.995, ab = 415.305, a = 440.000, bb = 466.164,
        b = 493.883;

    loop {

        delta = rrand(0.01, 0.1);
        freq  = [g, b, d].choose *
                [0.25, 0.5, 1, 2, 3].choose;


        Synth.new("saw",
                [mul: rrand(0.1, 0.3), pan: rrand(-1.0, 1.0), freq: freq,
                attack: 0.01, sustain: 1,
                ffreq: exprand(10.0, 200.0), amt: exprand(300.0, 4000.0),rq: 1,
                fattack: rrand(0.001, 0.02), fdecay: rrand(0.01, 0.2), fsustain: rrand(0.0, 0.5),
                fsustainLevel: rrand(0.01, 0.9),
                dtime: rrand(0.005, 0.5), ddecaytime: rrand(-2.0, 2.0)]);

        delta.yield;
    }
});

r.play;


