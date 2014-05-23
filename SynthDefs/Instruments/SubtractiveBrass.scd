// scale attack times correctly, currently the attack time is too long at low amps
(
SynthDef.new(\Brass, {

    arg freq = 100, mul = 0.2, add = 0,
        sustain = 1, sustainLevel = 1,  // Amp Env
        pan = 0.5;

    var osc, sig, aEnv, attack, release;

    // Envelopes
    attack  = (0.01 / mul);
    release = 0.1;
    aEnv = EnvGen.kr(Env([0, sustainLevel, 0], [attack, sustain, release]), doneAction: 2);

    // Oscilator
    osc = Saw.ar(freq, mul, add);

    // Mix
    sig = osc * aEnv;
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;
)

Synth.new(\Brass, [freq: 100, mul: 0.05]);

// --------------------------------------------------------------------------------
// NOTES:

/*
http://www.soundonsound.com/sos/apr01/articles/synthsecrets.asp

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

http://www.soundonsound.com/sos/may01/articles/synthsecrets.asp

Amplitude Response:
- Faster attack with higher amplitudes. Attack stage gets shorter as the velocity increases.
- Possible tremolo during sustain phase.
- Short release.
*/