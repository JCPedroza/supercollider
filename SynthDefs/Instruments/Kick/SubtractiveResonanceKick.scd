
(
SynthDef.new(\Kick, {

    arg freq = 50, phase = 0, mul = 0.5,        // Osc
        attack = 0.001, decay = 1;            // Amp envelope

    var osc, sig, aEnv;

    osc = SinOsc.ar(freq, phase, mul);

    // Amp envelope
    aEnv = EnvGen.kr(Env([0, 1, 0], [attack, decay]), doneAction: 2);

    sig = osc * aEnv;
    sig = Pan2.ar(sig);

    Out.ar(0, sig);

}).add;
)

Synth.new(\Kick, [freq: 100]);