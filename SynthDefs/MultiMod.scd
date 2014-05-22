(
SynthDef.new(\Multi, {

    arg freq = 100, mul = 0.2, add = 0,
        attack = 0.001, decay = 0.001, sustain = 0.9, release = 0.001, sustainLevel = 0.9,  // Amp Env
        filterFreq = 10,                                                                    // Filter
        filterLFOfreq = 0, filterLFOamt = 0, filterLFOLFOfreq = 0, filterLFOLFOamt = 0,     // Filter LFOs
        pan = 0.5;

    var osc, sig, aEnv, filter, filterLFO, filterLFOLFO;

    // Envelopes
    aEnv = EnvGen.kr(Env([0, 1, sustainLevel, 0], [attack, decay, sustain, release]), doneAction: 2);

    // LFOs
    filterLFO    = SinOsc.ar(filterLFOfreq).range(0, 1);
    filterLFOLFO = SinOsc.ar(filterLFOLFOfreq).range(0, 1);

    // Oscilator
    osc = Saw.ar(freq, mul, add);

    // Mix
    sig = osc * aEnv;
    sig = RLPF.ar(sig, filterFreq +
            ((filterLFO * filterLFOamt) + (filterLFOLFO * filterLFOLFOamt)));
    sig = Pan2.ar(sig, pan);


    Out.ar(0, sig);

}).add;
)

(
Synth.new(\Multi, [freq: 100, mul: 0.2, pan: 0, attack: 0.5, sustain: 10, filterFreq: 200,
        filterLFOfreq: 5, filterLFOamt: 1000, filterLFOLFOfreq:4, filterLFOLFOamt: 1000]);
)