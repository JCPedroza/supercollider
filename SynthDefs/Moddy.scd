(
SynthDef.new(\Moddy, {

    arg carrierFreq = 440, carrierMul = 0.2,

        carrierAttack = 0.001, carrierDecay = 0.001, carrierSustain = 8,
        carrierRelease = 0.001, carrierSustainLevel = 0.9,

        freqModFreq  = 220, freqModAmt  = 0.5,
        ampModFreq   = 230, ampModAmt   = 0.5,
        phaseModFreq = 240, phaseModAmt = 0.5,

        pan = 0.5;

    var carrier, freqMod, ampMod, phaseMod, sig, carrierAmpEnv;

    // Envelopes

    carrierAmpEnv = EnvGen.kr(Env([0, 1, carrierSustainLevel, 0],
        [carrierAttack, carrierDecay, carrierSustain, carrierRelease]), doneAction: 2);

    // Oscilators

    freqMod  = SinOsc.ar(freqModFreq, 0, freqModAmt);                            // FM
    ampMod   = SinOsc.ar(ampModFreq, 0, ampModAmt);                              // AM
    phaseMod = SinOsc.ar(phaseModFreq, 0, phaseModAmt);                          // PM
    carrier  = SinOsc.ar(carrierFreq * freqMod, phaseMod, carrierMul * ampMod);  // Carrier


    // Signal Path

    sig = carrier * carrierAmpEnv;
    sig = Pan2.ar(sig, pan);

    Out.ar(0, sig);

}).add;
)

// Simple trigger
(
Synth.new(\Moddy, [carrierFreq: 220, freqModFreq: 100, freqModAmt: 1,
    ampModFreq: 560, ampModAmt: 1, phaseModFreq: 2900, phaseModAm: 1]);
)

// Cloud trigger
(

)