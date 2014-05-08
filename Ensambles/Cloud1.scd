// The memory needs to be expanded to support a lot of CombN: ADSR maybe?
// Variable name clean
// Seems that lfo in freq in saw osc is inducing clicks, check that
// Implement a linear and fast modulation to the LFOs
// Phasemod osc introduced some clicks, how to fix them?
(
s.options.memSize = 64000;
s.boot;
)

// Implement new envelopes, current ones don't seem to be working as expected (not sure about this one)

(
SynthDef.new(\Cloud1, {

    arg sawFreq = 500,  sawMul = 0.2,  sawAdd = 0,               // Saw oscilator
        pulseFreq = 500, pulseWidth = 0.5, pulseMul = 0.2,       // Pulse oscilator
        pulseAdd = 0,
        pmCarFreq = 100, pmModFreq = 100, pmIndex = 1,           // Phasemod oscilator
        pmModPhase = 0, pmMul = 0.2, pmAdd = 0,
        ffreq = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,   // Filter
        attack = 0.05, decay  = 0.05, sustain  = 0.99,           // Amp Envelope
        release  = 0.1, sustainLevel = 0.5,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99,          // Filter envelope
        frelease = 0.1, fsustainLevel = 0.5,
        d1time = 0.2, d1decaytime = 4, d1mul = 1, d1add = 0,     // Comb delay 1
        d2time = 0.2, d2decaytime = 4, d2mul = 1, d2add = 0,     // Comb delay 2
        lfo1freq = 10, lfo2freq = 10, lfo1amt = 3, lfo2amt = 3,  // LFOs
        lfo3freq = 10, lfo3amt = 3,
        pan = 0;                                                 // Mix

    var aEnv, fEnv, sig, saw, pulse, lfo1, lfo2, lfo3, phaseMod;

    // Envelopes
    aEnv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fEnv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    // LFOs
    lfo1 = SinOsc.kr(lfo1freq);
    lfo2 = SinOsc.kr(lfo2freq);
    lfo3 = SinOsc.kr(lfo3freq);

    // Oscilators
    saw      = Saw.ar(sawFreq + (lfo1 * lfo1amt), sawMul, sawAdd);                      // Saw
    pulse    = Pulse.ar(pulseFreq + (lfo2 * lfo2amt), pulseWidth, pulseMul, pulseAdd);  // Pulse
    phaseMod = PMOsc.ar(pmCarFreq + (lfo3 * lfo3amt), pmModFreq, pmIndex,               // Phase Modulation
            pmModPhase, pmMul, pmAdd);

    // Signal Path
    sig = Mix.ar([saw, pulse, phaseMod]);                         // Mix oscilators
    sig = RLPF.ar(sig, fEnv * amt + ffreq, rq, fmul, fadd);       // Low pass filter
    sig = sig * aEnv;                                             // Amp envelope
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
        freq  = [c, e, g, b, gb].choose *
                [0.5, 1, 2, 3, 4].choose;

        Synth.new(\Cloud1,
            [
            // Sawtooth
            sawMul: rrand(0.01, 0.25), pulseMul: rrand(0.01, 0.25), pan: rrand(-1.0, 1.0),
            sawFreq: freq * rrand(0.99, 1.01), pulseFreq: freq * rrand(0.99, 1.01),

            // PhaseMod
            pmCarFreq: freq, pmModFreq: [0.5, 1, 2].choose * freq, pmIndex: exprand(0.5, 4),
            pmMul: rrand(0.01, 0.3), lfo3freq: exprand(0.1, 20), lfo3amt: exprand(0.5, 50),

            pulseWidth: rrand(0.0, 1.0), attack: 0.001, sustain: 1,
            ffreq: exprand(10.0, 200.0), amt: exprand(300.0, 4000.0), rq: rrand(0.8, 1),
            fattack: exprand(0.001, 0.08), fdecay: exprand(0.05, 0.1), fsustain: 0.1,
            fsustainLevel: 0.1,
            lfo1freq: exprand(0.1, 20), lfo2freq: exprand(0.1, 20),
            lfo1amt: exprand(0.5, 50), lfo2amt: exprand(0.5, 50),
            d1time: rrand(0.005, 0.5), d1decaytime: rrand(-1.0, 1.0),
            d2time: rrand(0.005, 0.5), d2decaytime: rrand(-1.0, 1.0)
            ]);

        delta.yield;
    }
});

r.play;
)
