// !!! growl lfo needs to be triangle waveform
// !!! is the growl noticeable? tweak if not
// !!! Are the vibrato envelope times ok? Can they be improved?
// !!! Are the filter's cutoff freqs ok?
// !!! Can the noise be implemented better?
// !!! AD to tremolo

(
SynthDef.new(\Brass, {

    arg freq = 100, mul = 0.2,                   // Oscilator
        sustain = 3,                             // Amp Envelope
        tremoloFreq = 5,                         // LFO: tremolo
        vibratoFreq = 4.5, vibratoAmt = 0.4,     // LFO: vibrato
        pan = 0;

    var osc, sig, aEnv, fEnv, attack, release, tremolo, filterPeak, filterRq,
        growl, growlEnv, vibrato, vibratoEnv, noise, filterMax, filterMin;

    mul = (1 - 0.3) * mul + 0.3;                   // re-scaling to 0.3 being the lowest value
    mul = (mul.log - 0.1.log) / (1.log - 0.1.log); // mul lin to log conversion

    // Amplitude Envelope
    attack  = (0.07 - 0.02) * (1 - mul) + 0.02;  // Attack stage gets shorter as the velocity increases.
    release = 0.2;                               // Average of analyzed brass instruments
    aEnv = EnvGen.kr(Env([0, 1, 0], [attack, sustain, release]), doneAction: 2);

    // Filter Envelope
    fEnv = EnvGen.kr(Env([0, 1, 0.8, 0], [attack, attack, sustain - attack, release]));

    // Amp LFO: tremolo
    tremolo = SinOsc.kr(tremoloFreq).range(0.90, 1);

    // Filter LFO: growl
    growl    = SinOsc.ar(80).range(0,1);
    growlEnv = EnvGen.kr(Env([0, 1, 0], [0.001, attack * 2, 0.1]));
    growl    = growl * growlEnv;

    // Freq LFO: vibrato
    vibrato    = SinOsc.kr(vibratoFreq);
    vibratoEnv = EnvGen.kr(Env([0, 1, 0], [sustain / 2.0, sustain / 2.0, 0.1]));
    vibrato    = vibrato * vibratoEnv;

    // Oscilators
    osc   = Saw.ar(freq + (vibrato * vibratoAmt), mul);
    noise = WhiteNoise.ar(mul/26);

    // Filtering
    // Louder notes have more harmonics than quieter ones. (filterPeak calculation)
    // Relative amp of lower harmonics decrease as the note gets louder. (filterRq calculation)
    filterMax  = 2000;
    filterMin  = 200;
    filterPeak = (filterMax - filterMin) * mul + filterMin;
    filterRq   = (1 - 0.1) * (1 - mul) + 0.1;

    // Signal Path
    sig = Mix.ar([osc, noise]);
    sig = RLPF.ar(sig, freq + filterPeak, filterRq);                   // Resonance LPF
    sig = RLPF.ar(sig, freq + (fEnv * filterPeak) + (growl * 5000));   // Envelope LPF
    sig = sig * aEnv;                                                  // Amp Envelope
    sig = sig * tremolo;                                               // LFO: tremolo
    sig = Pan2.ar(sig, pan);                                           // Panning

    Out.ar(0, sig);

}).add;
)

Synth.new(\Brass, [freq: 100, mul: 0.8]);

/* --------------------------------------------------------------------------------
NOTES:

- Resonance and envelope LPFs are implemented separately to avoid the resonance sweeping
  through the envelope.

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
  Solution:
  Velocity controls LPF cutoff frequency.
- The relative amplitude of the lower harmonics decrease as the note gets louder.
  In overblown notes, the loudest harmonic need not be the fundamental.
  Solution:
  By making the resonance proportional to the loudness, you ensure that high
  harmonics are accentuated to a greater and greater degree as we play louder and louder.
- There is a tonal transcient response. Not all harmonics develope at the same time.
  Solution:
  ADSR envelope in the LPF cutoff frequency.

Growl:
- All brass instruments require a 'settling time' at the start of the note. This is
  because it takes a finite amount of time for the standing wave to reach its steady state.
  This means that there's a period of pitch instability lasting about 50mS: a duration of
  the same order as the time it takes for all the harmonics to reach their steady-state amplitudes.
  Now, you might expect to apply some sort of modulation to the oscillator to emulate this, but
  there's a good reason not to do so: sidebands
  Solution:
  Instead, I apply a modulator to the low-pass filter in a way that achieves the desired effect.
  A triangle wave is an acceptable source for this modulation, and a frequency in the
  region of 80Hz does the trick nicely. Of course, you don't want the resulting growl to last
  for the duration of the note; it should last as long as the instability in the acoustic
  instrument we're synthesizing. Therefore, we patch the modulation into the filter through a
  VCA whose gain is controlled by an AD contour generator

Vibrato:
- Since vibrato does not occur during the transient stage of the note, you can't simply apply
  an LFO to the oscillator. Delayed vibrato is what is required, and it's usually implemented as
  an AR ramp controlling the amount of modulation.
- I find that modulating frequencies in the region of 5Hz sound the most realistic, and that the
  amplitude of the modulation must be very low, otherwise the timbre will sound electronic.

Conclusion:

The truth is still more complex than presented here. For example, we've ignored any conventional
pitch envelope that the player might wish to create (including portamento effects) and the effects
of formants on the timbre of the tonal elements of the sound. I have also ignored the phases of the
harmonics which, due to the complexities of brass instruments, are not all in phase with one another.
Furthermore, the amplitude of individual harmonics may change during the course of the note, and in
ways that we cannot easily emulate using low-pass filters and amplifiers. Even the frequencies of the
harmonics (which, at this point, we should strictly call 'partials') are not constant, and can vary
between the transient and the steady state. Indeed, for reasons we need not dwell on here, the partials
are not, strictly speaking, harmonics at all. Their frequencies are stretched out (sharpened) as the
harmonic number increases.

When you look at it like this, you have to conclude that subtractive synthesis is not an ideal way to
recreate brass sounds. In theory, microtonal additive synthesis would be a far better way to go about
it. Indeed, additive synths such as the Kawai K5 and K5000 are superb at recreating brass-type sounds.
Nevertheless, if you're careful about it, subtractive synthesis can make more than a passable stab
(pun intended) at producing the sounds of brass instruments.

*/