# matlab_real_time_sound

20 things you can do with this platform:
Listen to fully calibrated recordings (Internally all units are physical in Pascal, every signal is automatically calibrated using ⅓ octave filter)
Create and use a code repository for scientific auditory research - making it possible to reference specific software versions of otherwise undocumented, but frequently used matlab software.
Use any input or output device on your computer: all are recognised automatically
Change sample rate, frame length and all other parameters dynamically within the program
Fully fledged GUI lets you explore all modules visually and acoustically
See a real time waveform/spectrogram/cochleogram of your voice
See the auditory image model live
Hear how your voice sounds pitch-shifted/flanged/echoed
Explore a fully functioning multichannel hearing aid
See a live visualization of your vocal tract
Objective measures: measure the quality and intelligibility of speech and see how it changes when noise or reverberation are added
Reduce noise with a Wiener filter or spectal subtraction.
Subjective measures: measure the roughness, sharpness, loudness or annoyance of sound
Build your own modules and simply drop them in the ‘rt_modules’ folder to run
Fully object oriented - easy to expand, understand and debug, each module has only two substantive functions that are called automatically: initialization and process
Reasonably well optimised. Most modules are fast enough for real time, but not at the price of software legibility
Code is maintained on github - fully open and curated.
Future-proof software, following all matlab-conventions, no tricks, no mex.
Incorporates lots of third-party software into a unified software framework that makes results more comparable
Let the sound fly through space by dynamically changing the head related transfer function.
Simple guis that make calibration simple
Write powerful self running scripts in 4 lines


A platform to use matlab code in real time sound research and development
Real time sound platform manifesto - RTSP

Introduction
What is real time sound? (excerpt from https://doi.org/10.1016/j.specom.2017.12.003: 
https://www.sciencedirect.com/science/article/pii/S0167639317301528?via%3Dihub

An open development platform for auditory real-time signal processing
Seon ManKim StefanBleeck
Speech Communication
Volume 98, April 2018, Pages 73-84



In auditory signal processing research, we are often interested in algorithms that modify sounds to provide benefits in specific situations, for example to increase speech intelligibility in noise. Often it is interesting and sufficient to process sounds offline and play them back in an experiment to participants at a later stage. This approach has the advantage of full control over all parameters including background noise. However, in order to know if the algorithm works in real-life, we want to know about interactions between algorithm, environment and participant in real-life situations; only then the algorithm can be fully evaluated for its usefulness. In fact, most algorithms that have shown benefit in laboratory situations were either never further evaluated in real-time environments or failed to live up to their promise if they have (Gnewikow et al., 2009, Jensen et al., 2013). Real-time processing of environmental sounds means giving up control of most environment parameters, but gaining highest possible ‘ecological validity’, that is to test the participant in unpredictable situations as they would face in real life. ‘Ecological validity’ is defined as the extent to which the results of a study can be generalized to real-world settings. This approach is important for example for hearing aid noise reduction algorithms, where the wearers outside of the lab encounter unpredictable situations. However, in order to develop algorithms that have potential to be implemented in a future generation of auditory devices, they must be tested in many possible situations, but testing real-time algorithms in real-life situations is difficult or impossible for many researchers. The evaluation of real-world benefits of signal processing algorithms has been investigated and described by several research groups (Gnewikow et al., 2009, Jensen et al., 2013).
Research and development (RND) in audio processing algorithms commonly consists of three sequential development stages that can be described as: 1) offline development, 2) real-time development, and finally 3) system integration for the fully developed algorithm (Krüger et al., 2003). Generally, a new algorithm is developed first offline, and functional performance is evaluated by using an offline development database (e.g. speech databases (Garofolo et al., 1993, Varga and Steeneken, 1993)). Typically, at this stage it is sufficient to process experimental sounds offline and it is imperative to have full control of the environment and all parameters. Usually, only when the algorithms’ benefit is demonstrated under these offline laboratory situations the next development stage is justifiable. In the second stage, the algorithm is thoroughly evaluated under real-time conditions prior to hardware implementation. This often requires tuneable parameters for controlled manipulations of the considered signal processing. In this stage the algorithm is evaluated and optimised in a closed loop cycle of offline and real-time stages in real-time. Finally, in the third stage, the algorithm is integrated and realized as a prototype. The system integration is usually outside the scope of the researchers in academic institutions and will sometimes happen in industry.
Both offline and real-time stages require specific development platforms. The platform design should specify the hard- and software as well as the rules that describe how they fit together (Grimm et al., 2006a, Gopalakrishna et al., 2010, Buchholz, 2013). In existing systems, a high-level programming languages such as MATLAB, Simulink, and C/C++ is used on a personal computer (PC) platform for the offline development stage. Despite their relative simple configuration, with today's computer power, these platforms are often enough to develop and evaluate even complex algorithms offline.
However, existing real-time development platforms are much more complex and require additional training for the researcher. Real-time platforms typically consist of signal input/output (I/O) devices, an analogue-to-digital converter (ADC), a central processing unit (CPU), random-access memory (RAM), a digital-to-analogue converter (DAC) and so on. Furthermore, to deal with this extensive hardware, they usually employ a specialised suitable PC device (e.g., a performance real-time target machine) that is fast enough to do the processing for the real-time calculations (Buchholz, 2013, Hu et al., 2013a). Furthermore, to realise real-time processing on existing platforms, specialized skills are required, such as fixed point implementation, complexity optimization and system embedding – skills that are often outside the scope of academic researchers (Rass and Steeger, 2001).
In order to enable more researchers to utilise the benefits of real-time algorithm development, it would be beneficial to close the gap between online and offline stage and to make it easier to use offline algorithms in real-time directly.

Here we present a novel solution to all these issues: a real time MATLAB (interpreted) sound platform that fulfills all requirements: 
Interpreted code allows setting of breakpoints anywhere
Code runs with real time speed allowing to modify, measure or visualize sound in REAL TIME.
If you program matlab, you can modify code practically in real time and listen or see the result almost immediately on the screen.



Why is a platform for real time sound important?
Research
Education
Public outreach
Experience
“Try and error”



Who could use this:
In auditory and acoustic research there is often a tendency recently to publish result of measurements using measurement algorithms that are programmed in matlab and either described somewhere else, but not in 100% detail, or downloaded from web pages without referencing appropriately so that it allows the repeating of the experiments. Examples for good uses are PESQ, as it is maintained and there is an official distributor that allows for exact description of source and methodology. Slightly less reproducible results come often from usage of Loizou’s Matlab code that may or may not be modified by the authors. 
Examples include my own papers where we used implementations from stoi without guaranteeing reproducibility.
A further and also serious factor in this is that many algorithms work differently depending on the way that they are used: almost all algorithms are applied once to one wav file with one resulting number measuring for example speech intelligibility, quality, annoyance, roughness, etc. However, in the real world, all measures fluctuate of course as a function of time and background and many other parameters. The result of a measurement of one wav file therefore could depend on the amount of pauses in between words or the speed of speech. 
Typically, each algorithm is or should have  a described time window in which it is applied, and for a dynamic stimulus therefore the result varies over time. Examples are the loudness that is calculated with a 400 ms time window. Ideally all authors would use the same or at least identifiable source code that allows for reproduction. The web site ??? on github is an example for how this could work: authors upload the source code and stimuli of their experiments and allow the reproduction of the exact results and also allow critical evaluation in hindsight of the results. 

Our real time sound platform aims to overcome the second issue by allowing full transparency of algorithm calculations on a frame basis. There is simply no way of generating just one number for an ongoing sound file, so if one number is needed, the researchers at least need to think how the average or maxima are used to find the reported results.


Methods: how does it work?
Most important design criteria for rtsp
Immediate access for programmers without much previous programming background
Drag and drop operation: copy an existing module into a new module, modify to your heart's content, drop it into the folder ‘rtmodules’ and run it.
Two modes of operation: try out everything in a graphical user interface and combine it with other modules, try various sorts of inputs, outputs and measurements, and then run it in a simple script.
Any module can run in a script of 5 lines. (prepare, load, initialize, run, clean up)

Implementations.
Modules that are already implemented:



filename	fullname	speed	description
rt_bmm	Basilar membrane motion	101.2	the basilar membrane simulator simulates how the BM moves in response to soundgammatoneFilterBank decomposes a signal by passing it through a bank of gammatone filters equally spaced on the ERB scale. Gammatone filter banks were designed to model the human auditory system.the code is a wrapper of the MATLAB function gammatoneFilterBankwhich in turn implements the Malcom Slaney version of a 4th order gammatone filter[1] Slaney; Malcolm. "An Efficient Implementation of the Patterson-Holdworth Auditory Filter Bank." Apple Computer Technical Report 35; 1993.[2] Patterson; R.d.; K. Robinson; J. Holdsworth; D. Mckeown; C. Zhang; and M. Allerhand. "Complex Sounds and Auditory Images." Auditory Physiology and Perception. 1992; pp. 429?446.
rt_nap	Neural activity pattern	82.1	neural activity pattern represents graphically the activity in the auditory brainstem according to the auditory image model implementation by Stefan Bleeck and following the paper:Bleeck; Stefan; Ives; Tim and Patterson; Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica; 90 (4); 781-787.
rt_spectrum_lpc	Spectrogram with formants	265.6	shows the spectrogram underneath and an estimate of the first three formants on top
rt_spectrum_narrow	Spectrogram	33.3	Standard spectrogram, can be adjusted in number fft and window function and length
rt_strobes	Strobes with NAP	34.5	stabilized auditory image represents graphically the activity in the auditory brainstem according to the auditory image model.This module shows the strobe implementation by Stefan Bleeck and following the paper:Bleeck; Stefan; Ives; Tim and Patterson; Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica; 90 (4); 781-787.
rt_vad	Voice Activity Detection	120.6	Voice activity detection is implementation of Matlab function ''voiceActivityDetector''. More information: https://uk.mathworks.com/help/audio/ref/voiceactivitydetector-system-object.html
rt_vtl	Vocal tract visualizer	94.8	Vocal tract visualizer adapted from code from Hideki Kawahara based on lpc analysishttps://github.com/HidekiKawahara/SparkNG
rt_waveform	Waveform	278.6	shown is the physical pressure amplitude of the sound waveform as a function of time. The unit on the y-axis is Pascal
			
			
			
filename	fullname	speed	description
rt_amplify	Amplification	298.6	simplest example of a "manipulation" module: sound is multiplied by a constant
rt_chorus	Chorus	81.4	Chorus is wrapper of Matlab function audioexample.https://uk.mathworks.com/help/audio/examples/delay-based-audio-effects.htmlThe chorus effect usually has multiple independent delays; each modulated by a low-frequency oscillator. audioexample.Chorus> implements this effect. The block diagram shows a high-level implementation of a chorus effect.The chorus effect example has six tunable parameters that can be modified while the simulation is running:* Delay - Base delay applied to audio signal; in seconds* Depth 1 - Amplitude of modulator applied to first delay branch* Rate 1 - Frequency of modulator applied to first delay branch; in Hz* Depth 2 - Amplitude of modulator applied to second delay branch* Rate 2 - Frequency of modulator applied to second delay branch; in Hz* WetDryMix - Ratio of wet signal added to dry signal
rt_ci_sim	Cochlear implant simulation	626.6	Cochlear implant simulation simulates how a CI user might hear the worldCI simulation implemented using code from here: https://uk.mathworks.com/matlabcentral/fileexchange/69403-cochlear-implant-simulation
rt_compressor	Compression	2023.3	compressor: dynamic range compresses the amplitude envelope of the signal. Implementation is wrapper of the matlab 'compressor' function described here: https://uk.mathworks.com/help/audio/ref/compressor-system-object.htmlThe compressor System object? performs dynamic range compression independently across each input channel. Dynamic range compression attenuates the volume of loud sounds that cross a given threshold. It uses specified attack and release times to achieve a smooth applied gain curve. Properties of the compressor System object specify the type of dynamic range compression.
rt_flanger	Flanger	1576.5	Flanger is wrapper of Matlab function audioexample.Flanger as described here:https://uk.mathworks.com/help/audio/examples/delay-based-audio-effects.html.General information about flangers: https://en.wikipedia.org/wiki/Flanging
rt_graficequal	Graphic Equalizer	522.8	Graphic equalizer - standards-based graphic equalizer implements the matlab function graphicEQ https://uk.mathworks.com/help/audio/ref/graphiceq-system-object.html The graphicEQ System object? implements a graphic equalizer that can tune the gain on  individual octave or fractional octave bands. The object filters the data independently across each input channel over time using the filter specifications. Center and edge frequencies of the bands are based on the ANSI S1.11-2004 standard.
rt_hearingaid	Hearing aid	499.7	Hearing aid module simulates a simple hearing aid consisting of several stages: a set of bandpass filters splits the signal into different bands. The number of bands is defined by the parameter "bands"each band has a compressor that reduces the dynamic range and amplifies all sounds below the knee point
rt_ibm	Ideal binary mask	981.9	IBM: ideal binary mask reduces the noise in a signal with the knowledge of the clean signal the parameters allow to change the threshold of reduction and the amount of noise reduction
rt_irm	Ideal binary mask	1066.9	IRM: ideal ratio mask reduces the noise in a signal with the knowledge of the clean signal the parameters allow to change the threshold of reduction and the amount of noise reduction
rt_pitchshifter	Delay-Based Pitch Shifter	924.4	pitch shifter is implemented from this mathworks code: https://uk.mathworks.com/help/audio/examples/delay-based-pitch-shifter.html
rt_reverb	Reverberation	470.2	Reverb simulates the reverberation in a room implementation from the matlab function 'reverberator' described here: https://uk.mathworks.com/help/audio/ref/reverberator-system-object.html
rt_space	Head related transfer function	1182.3	Head related transfer function (HRTF) takes the input from ONE channel and calculates how it would sound when it comes from a specific point in space. It uses the knowledge of the shape of the outer ear as well as interaural time and level differences the implementation is by S.Bleeck and uses the hrtfs from a public database:
rt_specsub	Spectral subtraction	1754.6	Spectral subtraction: The implementation is from the book 'Speech enhancement' by Phillipos Loizou; adapted for real time run (different calculation of initial conditions)
rt_straightvoc	Straight Vocoder	65.3	implementation of the STRAIGHT vocoder by Hideki Kawahara. Code modified for real time from https://github.com/HidekiKawahara/legacy_STRAIGHT
rt_telephone	Telephone	3303.6	simple bandpass filter implementing a phone filter 300-3400 telephone bandwidth implementation from Mike Brookes via mathwork central. The filter meets the specifications of G.151 for any sample frequency and has a gain of -3dB at the passband edges.
rt_wiener	Wiener filter	1739	Wiener filter implementation  Plapous et al 2006. Code from the authors adapted slightly for real timeDescription : Wiener filter based on tracking a priori SNR using Decision-Directed  method; proposed by Plapous et al 2006. The two-step noise reduction (TSNR) technique removes the annoying reverberation effect while maintaining the benefits of the decision-directed approach. However;  classic short-time noise reduction techniques; including TSNR; introduce harmonic distortion in the enhanced speech. To overcome this problem; a method called harmonic regeneration noise reduction (HRNR)is implemented  in order to refine the a priori SNR used to compute a spectral gain able to preserve the speech harmonics. references: "Unbiased MMSE-Based Noise Power Estimation with Low Complexity and Low Tracking Delay"; IEEE TASL; 2012 Plapous; C.; Marro; C.; Scalart; P.; "Improved Signal-to-Noise Ratio Estimation for Speech Enhancement";  IEEE Transactions on Audio; Speech; and Language Processing; Vol. 14; Issue 6; pp. 2098 - 2108; Nov. 2006 More information: https://en.wikipedia.org/wiki/Wiener_filter
			
			
			
			
			
filename	fullname	speed	description
rt_asl	ASL: active speech level	70.8	active speech level described is the perceived instantaneous level of speech soundsin https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-P.56-201112-I!!PDF-E&type=items.Active speech level measurement following ITU-T P.56 Author: Lu Huo; LNS/CAU; December; 2005; Kiel.
rt_csii	CSII: Coherence and speech intelligibility index	44.7	CSII - Coherence and speech intelligibility index.estimates the speech intelligibility in noise and requires the clean signalThis is the Loizou Book implementation with minor changes to work in real time
rt_dBSPL	Decibel Sound Pressure Level	128.9	Sound level meter. A-level code The A-weighting filter's coefficientsare according to IEC 61672-1:2002 standard from https://uk.mathworks.com/matlabcentral/fileexchange/46819-a-weighting-filter-with-matlabthe module includes an octave band filter from the matlab implementation
rt_haspi	HASPI (impaired speech intelligibility)	97.3	haspi measures the speech intelligibility when considering a hearing lossKates; James & Arehart; Kathryn. (2014). The hearing-aid speech perception index (HASPI). Speech Communication. 65. 10.1016/j.specom.2014.06.002. From the abstract: This paper presents a new index for predicting speech intelligibility for normal-hearing and hearing-impaired listeners. The Hearing-Aid Speech Perception Index (HASPI) is based on a model of the auditory periphery that incorporates changes due to hearing loss. The index compares the envelope and temporal fine structure outputs of the auditory model for a reference signal to the outputs of the model for the signal under test. The auditory model for the reference signal is set for normal hearing; while the model for the test signal incorporates the peripheral hearing loss. The new index is compared to indices based on measuring the coherence between the reference and test signals and based on measuring the envelope correlation between the two signals. HASPI is found to give accurate intelligibility predictions for a wide range of signal degradations including speech degraded by noise and nonlinear distortion; speech processed using frequency compression; noisy speech processed through a noise-suppression algorithm; and speech where the high frequencies are replaced by the output of a noise vocoder. The coherence and envelope metrics used for comparison give poor performance for at least one of these test conditions. Implementation from source code from the author. The parameters set the hearing loss as the audiogram data
rt_loudness	Loudness	257.6	Loudness estimates the perceived Loudness of a sound using the matlab implementation of 'integratedLoudness' https://uk.mathworks.com/help/audio/ref/integratedloudness.html
rt_loudnessfastl	Loudness (Fastl)	51.4	Loudness (Fastl) estimates the perceived Loudness of a soundusing the implementation from Hugo Fastl available herehttps://www.salford.ac.uk/research/sirc/research-groups/acoustics/psychoacoustics/sound-quality-making-products-sound-better/accordion/sound-quality-testing/matlab-codes
rt_lpc	Linear Predictive Coefficients (LPC)	18.7	Linear Predictive Coefficients (LPC) implementation from Hideki Kawahara from github: https://github.com/HidekiKawaharamore information here: https://en.wikipedia.org/wiki/Linear_predictive_codingmatlab uses the function https://uk.mathworks.com/help/signal/ref/lpc.html
rt_mfccs	MFCCs (mel frequency cepstral coefficients)	50.7	MFCCs (mel frequency cepstral coefficients) measures features of speech that are often used in automatic speech recognition the code is a wrapper for the matlab function 'cepstralfeatureextractor'https://uk.mathworks.com/help/audio/ref/cepstralfeatureextractor-system-object.html
rt_ncm	NCM	50.6	estimation of speech intelligibility using  normalized covariance metric.and requires the clean signalReference[1]  Ma; J.; Hu; Y. and Loizou; P. (2009). "Objective measures for predicting speech intelligibility in noisy conditions based on new band-importance functions"; Journal of the Acoustical Society of America; 125(5); 3387-3405.Authors:  Fei Chen and Philipos C. Loizou https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2806444/
rt_pesq	PESQ (speech quality)	401.6	Perceptual estimation of speech quality (PESQ) measure based on the ITU standard P.862 [1].and requires the clean signalReference[1] ITU (2000). Perceptual evaluation of speech quality (PESQ); and objective method for end-to-end speech quality assessment of narrowband telephone networks and speech codecs. ITU-T Recommendation P. 862   Authors: Yi Hu and Philipos C. Loizou
rt_pitch	Pitch estimation	207.2	pitch estimates the fundamental frequency implementation from the matlab function 'pitch' described here:https://uk.mathworks.com/help/audio/ref/pitch.html
rt_roughness	Roughness - fluctuation strength	32.7	Roughness estimates the perceived roughness of a sound from the psysoundpro toolbox (https://sourceforge.net/projects/psysoundpro/)
rt_sharpness	Sharpness (Fastl)	121.9	Loudness estimates subjective loudness perception based on ISO 532 B / DIN 45 631
rt_stoi	STOI (speech intelligibility)	91.4	short-time objective intelligibility (STOI) measure described in [1; 2];  is expected to have a monotonic relation with the subjective speech-intelligibility;  where a higher d denotes better intelligible speech. Implementation is from C.H. Taal with minor modifications for real time running 
rt_sai	Stabilized auditory image	70.8	stabilized auditory image represents graphically the activity in the auditory brain stem according to the auditory image model implementation by Stefan Bleeck and following the paper: Bleeck; Stefan; Ives; Tim and Patterson; Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica; 90 (4); 781-787.
			






Future direction of the project


References


