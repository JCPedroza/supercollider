/*

Carrier: frequency, amplitude, and phase modulation.
Filter: frequency and rq (resonance) modulation.
All waveforms are sines.

    +---------+       +-----+       +-----+       +-----+
    | CARRIER | ----> | ENV | ----> | LPF | ----> | PAN | ---->
    +---------+       +-----+       +-----+       +-----+
         ^                             ^
         |                             |
  +------------+                  +---------+
  | FM, AM, PM |                  | FM, RQM |
  +------------+                  +---------+

*/

(
SynthDef.new(\Moddy, {

    arg carrierFreq = 440, carrierMul = 0.2,

        carrierAttack = 0.001, carrierDecay = 0.001, carrierSustain = 8,
        carrierRelease = 0.001, carrierSustainLevel = 0.9,

        freqModFreq   = 220, freqModAmt   = 0.5,
        ampModFreq    = 230, ampModAmt    = 0.5,
        phaseModFreq  = 240, phaseModAmt  = 0.5,

        filterModFreq = 250, filterModAmt = 0.5, filterAmt = 200, filterRq = 1,
        rqModFreq     = 260, rqModAmt     = 0.5,

        pan = 0.5;

    var carrier, freqMod, ampMod, phaseMod, filterMod, rqMod, sig, carrierAmpEnv;

    // Envelopes

    carrierAmpEnv = EnvGen.kr(Env([0, 1, carrierSustainLevel, 0],
        [carrierAttack, carrierDecay, carrierSustain, carrierRelease]), doneAction: 2);

    // Oscilators

    freqMod   = SinOsc.ar(freqModFreq, 0, freqModAmt);                            // FM
    ampMod    = SinOsc.ar(ampModFreq, 0, ampModAmt);                              // AM
    phaseMod  = SinOsc.ar(phaseModFreq, 0, phaseModAmt);                          // PM
    filterMod = SinOsc.ar(filterModFreq, 0, filterModAmt).range(0, 1);            // Filter Modulation
    rqMod     = SinOsc.ar(rqModFreq, 0, rqModAmt).range(0, 1);
    carrier   = SinOsc.ar(carrierFreq * freqMod, phaseMod, carrierMul * ampMod);  // Carrier


    // Signal Path

    sig = carrier * carrierAmpEnv;                                                // Amp Envelope
    sig = RLPF.ar(sig, carrierFreq + (filterAmt * filterMod), filterRq * rqMod);  // LPF
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;
)

// Tests
(
Synth.new(\Moddy, [

    // Carrier
    carrierFreq: 200,

    // FM
    freqModFreq: 300, freqModAmt: 1,

    // AM
    ampModFreq: 400, ampModAmt: 1,

    // PM
    phaseModFreq: 500, phaseModAm: 1,

    // Filter Modulation
    filterAmt: 1000, filterRq: 0.5,
    filterModFreq: 2000, filterModAmt: 1,
    rqModFreq: 200, rqModAmt: 1]);
)
