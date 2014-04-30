// Needs Atari2600 UGen:
// http://www.fredrikolofsson.com/pages/code-sc.html

(
SynthDef(\atari2600, {

    arg out = 0, gate = 1, tone0 = 5, tone1 = 8, freq0 = 10, freq1 = 20,
        amp = 1, pan = 0;

    var e, z;

    e = EnvGen.kr(Env.asr(0.01, amp, 0.05), gate, doneAction: 2);
    z = Atari2600.ar(tone0, tone1, freq0, freq1, 15, 15);
    Out.ar(out, Pan2.ar(z * e, pan));


}).add;
)
