
(
SynthDef.new(\Kick, {

    arg freq = 50, mul = 0.1,           // Osc
        attack = 0.001, decay = 0.5,    // Amp envelope
        fEnvAmt = 3000, rq = 0.001;

    var saw, sqr, sig, aEnv, fEnv;

    // Oscillators
    saw = Saw.ar(freq, mul);
    sqr = Pulse.ar(freq, 0.5, mul);

    // Amp & Filter envelopes
    aEnv = EnvGen.kr(Env([0, 1, 0], [attack, decay * 2]), doneAction: 2);
    fEnv = EnvGen.kr(Env([0.01, 1, 0.01], [attack, decay], 'exp'));

    // Signal path
    sig = Mix.ar([saw, sqr]);
    sig = RLPF.ar(sig, 20 + (fEnv * fEnvAmt), rq);
    sig = sig * aEnv;
    sig = Pan2.ar(sig);

    Out.ar(0, sig);

}).add;
)

(
Synth.new(\Kick, [freq: 10, decay: 0.2, fEnvAmt: 250]);
)

(
p = Pbind(
    \instrument, \Kick,
    \freq, Pseq([10], inf),
    \decay, Pseq([0.2], inf),
    \mul, Pseq([0.1], inf),
    \rq, Pseq([0.001], inf),
    \fEnvAmt, Pseq([300], inf),
    \dur, Pseq([0.5, 0.6, 0.4, 0.5], inf)
).play;
)