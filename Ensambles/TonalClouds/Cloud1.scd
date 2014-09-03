
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
        filterLFOfreq = 1, filterLFOamt = 1,                                         // Filter LFOs
        filterLFOLFOfreq = 1, filterLFOLFOamt = 1,
        panInit = 0, panEnd = 0, panDuration = 1;

    var aEnv, fEnv, pitchLFO1, pitchLFO2, filterLFO, filterLFOLFO, saw, pulse, sig;

    // Envelopes
    aEnv   = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);
    fEnv   = EnvGen.kr(Env([0, 1, fsustainLevel, 0], [fattack, fdecay, fsustain, frelease]));

    // LFOs
    pitchLFO1    = SinOsc.kr(pitchLFO1freq);
    pitchLFO2    = SinOsc.kr(pitchLFO2freq);
    filterLFO    = SinOsc.kr(filterLFOfreq).range(0, 1);
    filterLFOLFO = SinOsc.kr(filterLFOLFOfreq).range(0, 1);


    // Oscilators
    saw   = Saw.ar(sawFreq + (pitchLFO1 * pitchLFO1amt), sawMul, sawAdd);                      // Saw
    pulse = Pulse.ar(pulseFreq + (pitchLFO2 * pitchLFO2amt), pulseWidth, pulseMul, pulseAdd);  // Pulse

    // Signal Path
    sig = Mix.ar([saw, pulse]);                                               // Mix oscilators
    sig = RLPF.ar(sig, (fEnv * amt + ffreq) +                                 // Low pass filter
            ((filterLFO * filterLFOamt) + (filterLFOLFO * filterLFOLFOamt)),  // Filter LFOs
            rq, fmul, fadd);
    sig = sig * aEnv;                                                         // Amp envelope
    sig = Pan2.ar(sig, Line.kr(panInit, panEnd, panDuration));                // Panning

    Out.ar(0, sig);

}).add;
)

(
r = Routine({

    var delta, freq, panValue, c = 261.626, db = 277.183, d = 293.665, eb = 311.127, e = 329.628,
        f = 349.228, gb = 369.994, g = 391.995, ab = 415.305, a = 440.000, bb = 466.164,
        b = 493.883;

    loop {

        delta = exprand(0.0025, 0.15);
        freq     = [a, db, e].choose * [1, 2, 3].choose;
        panValue = rrand(-1.0, 1.0);

        Synth.new(\Cloud1, [

            // Saw
            sawFreq: freq * rrand(0.99, 1.01), sawMul: rrand(0.004, 0.05),

            // Pulse
            pulseFreq: freq * rrand(0.99, 1.01), pulseMul: rrand(0.004, 0.05),
            pulseWidth: rrand(0.001, 0.999),

            // LFOs
            pitchLFO1freq: rrand(0.05, 20), pitchLFO1amt: rrand(0.5, 10),
            pitchLFO2freq: rrand(0.05, 20), pitchLFO2amt: rrand(0.5, 10),

            filterLFOfreq: [rrand(0.01, 3), exprand(0.1, 20)].choose,
            filterLFOamt: [0, exprand(1, 5000)].choose,

            filterLFOLFOfreq: [rrand(0.01, 3), exprand(0.1, 20)].choose,
            filterLFOLFOamt: [0, 0, rrand(100, 2000)].choose,

            // Filter & Filter Envelope
            ffreq: freq, rq: [1, 1, 1, 1, 1, 1, rrand(0.4, 1)].choose,

            amt: freq + exprand(100.0, 200.0),
            fattack: 0.001, fdecay: exprand(0.025, 0.1), fsustain: rrand(0.025, 0.1),
            fsustainLevel: rrand(0.25, 0.9), frelease: rrand(0.025, 0.1),

            // Amp Envelope
            attack: exprand(0.008, 0.1), decay: exprand(0.05, 0.1),
            sustainLevel: rrand(0.1, 0.9),

            // Pan
            panInit: [panValue, rrand(-1.0, 1.0)].choose,
            panEnd: [panValue, rrand(-1.0, 1.0)].choose,
            panDuration: rrand(0.1, 1)

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