(
SynthDef.new(\Trumpet, {

    arg freq = 100, mul = 0.2, add = 0,
        attack = 0.001, decay = 0.001, sustain = 0.9, release = 0.001, sustainLevel = 0.9,  // Amp Env
        pan = 0.5;

    var osc, sig, aEnv;

    // Envelopes
    aEnv = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);

    // Oscilator
    osc = Saw.ar(freq, mul, add);

    // Mix
    sig = Pan2.ar(osc, pan);
    sig = sig * aEnv;

    Out.ar(0, sig);

}).add;
)

Synth.new(\Trumpet, [freq: 100, mul: 0.2, pan: 0.5, attack: 0.5]);
a.play












// --------------------------------------------------------------------------------
// NOTES:

/*
"http://www.soundonsound.com/sos/apr01/articles/synthsecrets.asp"

1- we now know that a trumpet produces a complete harmonic series with significant
amplitudes of higher harmonics present. Only one common waveform fits the bill;
we must set our oscillators to produce a sawtooth wave.

2- we know that, as the note gets louder, it contains more harmonics, so we must set
up a low-pass filter whose cutoff frequency rises and falls as the loudness of the
note increases and decreases, respectively.

3- we know that the relative amplitude of the lower harmonics decrease as the note
gets louder. This means that we must introduce filter resonance (or some other form
of EQ) that emphasises higher harmonics as the loudness of the note increases.

4- we know that a high note has fewer harmonics than a low note, so we must set up
our filter tracking such that, as the pitch rises, the cutoff frequency rises more
slowly, thus tapering the harmonic series.
*/