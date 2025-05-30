import("stdfaust.lib");

// FM Sintisajzer sa vibratom
fm = hgroup("[0]Fm", os.osc(carFreqWithVibrato + os.osc(modFreq) * index) * volume)
with {
    modFreq = hslider("[0]Modulator Frequency", 20, 0.1, 2000, 0.01);
    index = hslider("[1]Modulation Index[style:knob]", 100, 0, 1000, 0.01);
    carFreq = hslider("[2]Carrier Frequency", 440, 50, 2000, 0.01);
    volume = hslider("[3]Volume[style:knob]", 0.8, 0, 1, 0.01);  // Кontroler za pojačanje
    carFreqWithVibrato = carFreq + vibrato;  // Dodavanje vibrata na frekvenciju nosioca
};

// Vibrato efekat
vibratoFreq = hslider("[9]Vibrato Frequency", 5, 0.1, 10, 0.1);
vibratoAmp = hslider("[10]Vibrato Depth", 0.01, 0, 0.1, 0.001);
vibrato = os.osc(vibratoFreq) * vibratoAmp;  // Vibrato se dodaje na frekvenciju nosioca


// Envelope
envelope = hgroup("[1]Envelope", en.adsr(attack, decay, sustain, release, gate) * gain * 0.3)
with {
    attack = hslider("[0]Attack[style:knob]", 50, 1, 1000, 1) * 0.001;
    decay = hslider("[1]Decay[style:knob]", 50, 1, 1000, 1) * 0.001;
    sustain = hslider("[2]Sustain[style:knob]", 0.8, 0.01, 1, 1);
    release = hslider("[3]Release[style:knob]", 50, 1, 1000, 1) * 0.001;
    gain = hslider("[4]gain[style:knob]", 1, 0, 1, 0.01);
    gate = button("[5]gate");
};

// Tremolo efekat
tremoloRate = hslider("[6]Tremolo Rate[style:knob]", 5, 0.1, 20, 0.1);  // Brzina tremola
tremoloDepth = hslider("[7]Tremolo Depth[style:knob]", 0.5, 0, 1, 0.01);  // Dubina tremola
lfo = os.osc(tremoloRate);  // LFO za tremolo
tremolo = (1 + lfo * tremoloDepth) * 0.5;  

// Filtаr
filterFreq = hslider("Filter Cutoff [Hz]", 1000, 100, 5000, 10);
filterRes = hslider("Filter Resonance", 0.5, 0, 1, 0.01);
filterGain = hslider("Filter Gain", 1, 0, 10, 0.1);
filteredSignal = fm * envelope * tremolo;
filteredSignalWithFilter = filteredSignal : fi.resonbp(filterFreq, filterRes, filterGain);

// Panorama
pan = hslider("[8]Panning", 0, -1, 1, 0.01);  // -1 za levo, 1 za desno, 0 za sredinu

// Stereo izlaz
leftSignal = filteredSignalWithFilter * (1 - pan) * 0.5;
rightSignal = filteredSignalWithFilter * (1 + pan) * 0.5;

process = (leftSignal, rightSignal);

