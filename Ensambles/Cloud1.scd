// The memory needs to be expanded to support a lot of CombN: ADSR maybe?
// Variable name clean
// Seems that lfo in freq in saw osc is inducing clicks, check that
(
s.options.memSize = 64000;
s.boot;
)

// Implement new envelopes, current ones don't seem to be working as expected

(
SynthDef.new("saw", {

    arg freq = 500, freq2 = 500, phase = 0, mul = 0.2, mul2 = 0.2, add = 0,
        ffreq = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,
        attack = 0.05, decay  = 0.05, sustain  = 0.99, release  = 0.1, sustainLevel = 0.5,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99, frelease = 0.1, fsustainLevel = 0.5,
        d1time = 0.2, d1decaytime = 4, d1mul = 1, d1add = 0,
        d2time = 0.2, d2decaytime = 4, d2mul = 1, d2add = 0,
        lfo1freq = 10, lfo2freq = 10, lfo1amt = 3, lfo2amt = 3,
        pan = 0, pulsewidth;

    var aenv, fenv, sig, saw, pulse, lfo1, lfo2;

    // Envelopes
    aenv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fenv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    // LFOs
    lfo1 = SinOsc.kr(lfo1freq);
    lfo2 = SinOsc.kr(lfo2freq);

    // Oscilators
    saw   = Saw.ar(freq + (lfo1 * lfo1amt), mul, add);
    pulse = Pulse.ar(freq2 + (lfo2 * lfo2amt), pulsewidth, mul2, add);

    // Signal Path
    sig = Mix.ar([saw, pulse]);                                   // Mix oscilators
    sig = RLPF.ar(sig, fenv * amt + ffreq, rq, fmul, fadd);       // Low pass filter
    sig = sig * aenv;                                             // Amp envelope
    sig = CombN.ar(sig, 2, d1time, d1decaytime, d1mul, d1add);    // Comb delay 1
    sig = CombN.ar(sig, 2, d2time, d2decaytime, d2mul, d2add);    // Comb delay 2
    sig = Pan2.ar(sig, pan);                                      // Panning

    Out.ar(0, sig);

}).add;
)

(
r = Routine({

    var delta, freq, c = 261.626, db = 277.183, d = 293.665, eb = 311.127, e = 329.628,
        f = 349.228, gb = 369.994, g = 391.995, ab = 415.305, a = 440.000, bb = 466.164,
        b = 493.883;

    loop {

        delta = exprand(0.005, 0.1);
        freq  = [c, eb, g, b].choose *
                [1, 2, 3].choose;

        Synth.new("saw",
            [mul: rrand(0.01, 0.3), mul2: rrand(0.01, 0.3), pan: rrand(-1.0, 1.0),
            freq: freq * rrand(0.98, 1.02), freq2: freq * rrand(0.98, 1.02),
            pulsewidth: rrand(0.0, 1.0), attack: 0.001, sustain: 1,
            ffreq: exprand(10.0, 200.0), amt: exprand(300.0, 4000.0), rq: 1,
            fattack: 0.001, fdecay: exprand(0.05, 0.1), fsustain: 0.1,
            fsustainLevel: 0.1,
            lfo1freq: exprand(0.1, 20), lfo2freq: exprand(0.1, 20),
            lfo1amt: exprand(0.5, 20), lfo2amt: exprand(0.5, 20),
            d1time: rrand(0.005, 0.5), d1decaytime: rrand(-1.0, 1.0),
            d2time: rrand(0.005, 0.5), d2decaytime: rrand(-1.0, 1.0)]);

        delta.yield;
    }
});

r.play;
)
