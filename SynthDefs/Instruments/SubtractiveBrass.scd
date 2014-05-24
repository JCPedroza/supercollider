// !!! two separate RLPF, one for resonance, one for envelope
(
SynthDef.new(\Brass, {

    arg freq = 100, mul = 0.2,                   // Oscilator
        sustain = 3,                             // Amp Envelope
        tremoloFreq = 0,                         // LFO: tremolo
        pan = 0.5;

    var osc, sig, aEnv, fEnv, attack, release, sustainLevel, tremolo, filterPeak, filterRq;

    // Amplitude Envelope
    attack  = (0.12 - 0.02) * (1 - mul) + 0.02;  // Attack stage gets shorter as the velocity increases.
    release = 0.2;                               // Average of analyzed brass instruments
    aEnv = EnvGen.kr(Env([0, 1, 0], [attack, sustain, release]), doneAction: 2);

    // Filter Envelope
    fEnv = EnvGen.kr(Env([0, 1, 0.8, 0], [attack, attack, sustain - attack, release]));

    // LFO: tremolo
    tremolo = SinOsc.kr(tremoloFreq).range(0.90, 1);

    // Oscilator
    osc = Saw.ar(freq, mul);

    // Filtering
    filterPeak = freq + (mul * 3000);           // Louder notes have more harmonics than quieter ones. !!!???
    filterRq   = (1 - 0.3) * (1 - mul) + 0.3;   // Amp of lower harmonics decrease as the note gets louder.

    // Signal Path
    sig = RLPF.ar(osc, freq + filterPeak, filterRq);  // Resonance LPF
    sig = RLPF.ar(sig, freq + (fEnv * filterPeak));   // Envelope LPF
    sig = sig * aEnv;                                 // Amp Envelope
    sig = sig * tremolo;                              // LFO: tremolo
    sig = Pan2.ar(sig, pan);                          // Panning

    Out.ar(0, sig);

}).add;
)

Synth.new(\Brass, [freq: 100, mul: 0.7, tremoloFreq: 5]);

/* --------------------------------------------------------------------------------
NOTES:

- Resonance and envelope LPFs are implemented separately to avoid the resonance sweeping
  through the envelope. Resonance should affect constant frequencies.

*/

/*
Resources:

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

Tonal Response:
- Louder notes have more harmonics than quieter ones.
  Solution: velocity modulates LPF cutoff frequency.
- The relative amplitude of the lower harmonics decrease as the note gets louder.
  In overblown notes, the loudest harmonic need not be the fundamental.
  Solution: by making the resonance proportional to the loudness, you ensure that high
  harmonics are accentuated to a greater and greater degree as we play louder and louder.
- There is a tonal transcient response. Not all harmonics develope at the same time.
  Solution: ADSR envelope in the LPF cutoff frequency.

*/