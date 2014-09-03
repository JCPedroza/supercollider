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

        pan = 0;

    var carrier, freqMod, ampMod, phaseMod, filterMod, rqMod, sig, carrierAmpEnv;

    // Envelopes

    carrierAmpEnv = EnvGen.kr(Env([0, 1, carrierSustainLevel, 0],
        [carrierAttack, carrierDecay, carrierSustain, carrierRelease]), doneAction: 2);

    // Oscilators

    freqMod   = SinOsc.ar(freqModFreq, 0, freqModAmt).range(0, 1);                // FM
    ampMod    = SinOsc.ar(ampModFreq, 0, ampModAmt).range(0, 1);                  // AM
    phaseMod  = SinOsc.ar(phaseModFreq, 0, phaseModAmt).range(0, 1);              // PM
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

(
r = Routine({

    var delta, topEnd, lowEnd;

    loop {

        delta = exprand(0.0025, 0.15);
        topEnd = 3000.0;
        lowEnd = 50.0;

        Synth.new(\Moddy, [

            // Carrier
            carrierFreq: rrand(lowEnd, topEnd), carrierMul: rrand(0.05, 0.3),

            // FM
            freqModFreq: rrand(lowEnd, topEnd), freqModAmt: rrand(0.1, 2),

            // AM
            ampModFreq: rrand(lowEnd, topEnd), ampModAmt: rrand(0.1, 2),

            // PM
            phaseModFreq: rrand(lowEnd, topEnd), phaseModAm: rrand(0.1, 2),

            // Filter Modulation
            filterAmt: exprand(100.0, 9000), filterRq: 1,
            filterModFreq: exprand(100.0, 1000), filterModAmt: 0,
            rqModFreq: exprand(0.1, 300), rqModAmt: 0,

            // ENV
            carrierAttack: 0.01, carrierDecay: rrand(0.05, 0.3), carrierSustain: 0.1,
            carrierRelease: 0.1, carrierSustainLevel: 0.1,

            // Pan
            pan: rrand(-1.0, 1.0)

        ]);

        delta.yield;
    }
});

r.play;
)