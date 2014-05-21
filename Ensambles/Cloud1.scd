// Implement a linear and fast modulation to the LFOs

(
SynthDef.new(\Cloud1, {

    arg sawFreq = 500,  sawMul = 0.2,  sawAdd = 0,                                   // Saw oscilator
        pulseFreq = 500, pulseWidth = 0.5, pulseMul = 0.2,                           // Pulse oscilator
        pulseAdd = 0,
        ffreq = 20000, amt = 4000, rq = 1, fmul = 1, fadd = 0,                       // Filter
        attack = 0.001, decay  = 0.05, sustain  = 2,                                 // Amp Envelope
        release  = 1, sustainLevel = 0.9,
        fattack = 0.05, fdecay = 0.05, fsustain = 0.99,                              // Filter envelope
        frelease = 0.1, fsustainLevel = 0.5,
        pitchLFO1freq = 10, pitchLFO2freq = 10, pitchLFO1amt = 3, pitchLFO2amt = 3,  // Pitch LFOs
        pan = 0;                                                                     // Mix

    var aEnv, fEnv, sig, saw, pulse, pitchLFO1, pitchLFO2;

    // Envelopes
    aEnv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fEnv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    // LFOs
    pitchLFO1 = SinOsc.kr(pitchLFO1freq);
    pitchLFO2 = SinOsc.kr(pitchLFO2freq);

    // Oscilators
    saw      = Saw.ar(sawFreq + (pitchLFO1 * pitchLFO1amt), sawMul, sawAdd);                      // Saw
    pulse    = Pulse.ar(pulseFreq + (pitchLFO2 * pitchLFO2amt), pulseWidth, pulseMul, pulseAdd);  // Pulse

    // Signal Path
    sig = Mix.ar([saw, pulse]);                                   // Mix oscilators
    sig = RLPF.ar(sig, fEnv * amt + ffreq, rq, fmul, fadd);       // Low pass filter
    sig = sig * aEnv;                                             // Amp envelope
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

        delta = exprand(0.0025, 0.1);
        freq  = [d, f, a, c].choose * [1, 2, 3].choose;

        Synth.new(\Cloud1, [

            // Saw
            sawFreq: freq * rrand(0.99, 1.01), sawMul: rrand(0.004, 0.05),

            // Pulse
            pulseFreq: freq * rrand(0.99, 1.01), pulseMul: rrand(0.004, 0.05),
            pulseWidth: rrand(0.001, 0.999),

            // LFOs
            pitchLFO1freq: rrand(0.05, 20), pitchLFO1amt: rrand(0.5, 6),
            pitchLFO2freq: rrand(0.05, 20), pitchLFO2amt: rrand(0.5, 6),

            // Filter & Filter Envelope
            ffreq: 10.0, rq: [1, 1, 1, 1, 1, 1, rrand(0.1, 1)].choose,
            amt: freq + exprand(100.0, 7000.0),
            fattack: 0.001, fdecay: exprand(0.05, 1), fsustain: rrand(0.1, 0.7),
            fsustainLevel: rrand(0.1, 0.9), frelease: rrand(0.1, 0.7),

            // Amp Envelope
            attack: exprand(0.001, 1), decay: exprand(0.05, 1),
            sustainLevel: rrand(0.1, 0.9),

            // Mix
            pan: rrand(-1.0, 1.0)

            ]);

        delta.yield;
    }
});

r.play;
)

// GUI
(
w = Window.new("Cloud1", Rect(200,200,255,100));
w.front;
)