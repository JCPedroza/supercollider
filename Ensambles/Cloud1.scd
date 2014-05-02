// The memory needs to be expanded to support a lot of CombN:
(
s.options.memSize = 64000;
s.boot;
)

(
SynthDef.new("saw", {

    arg freq = 500, phase = 0, mul = 0.2, add = 0,
        ffreq = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,
        attack = 0.05, decay  = 0.05, sustain  = 0.99, release  = 0.05, sustainLevel = 0.5,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99, frelease = 0.05, fsustainLevel = 0.5,
        d1time = 0.2, d1decaytime = 4, d1mul = 1, d1add = 0,
        d2time = 0.2, d2decaytime = 4, d2mul = 1, d2add = 0,
        pan = 0;

    var aenv, fenv, sig;

    aenv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fenv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    sig = Saw.ar(freq, mul, add);
    sig = RLPF.ar(sig, fenv * amt + ffreq, rq, fmul, fadd);
    sig = sig * aenv;
    sig = CombN.ar(sig, 2, d1time, d1decaytime, d1mul, d1add);
    sig = CombN.ar(sig, 2, d2time, d2decaytime, d2mul, d2add);
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;
)

(
r = Routine({

    var delta, freq, c = 261.626, db = 277.183, d = 293.665, eb = 311.127, e = 329.628,
        f = 349.228, gb = 369.994, g = 391.995, ab = 415.305, a = 440.000, bb = 466.164,
        b = 493.883;

    loop {

        delta = exprand(0.01, 0.1);
        freq  = [a, c, e].choose *
                [0.25, 0.5, 1, 2, 3].choose;


        Synth.new("saw",
            [mul: rrand(0.1, 0.3), pan: rrand(-1.0, 1.0), freq: freq * rrand(1.0, 1.02),
            attack: 0.001, sustain: 1,
            ffreq: exprand(10.0, 200.0), amt: exprand(300.0, 4000.0),rq: 1,
            fattack: exprand(0.001, 0.2), fdecay: rrand(0.01, 0.2), fsustain: rrand(0.0, 0.5),
            fsustainLevel: rrand(0.01, 0.9),
            d1time: rrand(0.005, 0.5), d1decaytime: rrand(-1.5, 1.5),
            d2time: rrand(0.005, 0.3), d2decaytime: rrand(-1.5, 1.5)]);

        delta.yield;
    }
});

r.play;
)

