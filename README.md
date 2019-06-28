“Real time sound platform”

things you can do with this platform: 
•	See sound 
•	Listen to sound 
•	Measure sound 
•	Modify sound

The platform is a collection of modules that can be connected in any sensible way. For example: record sound, manipulate it, visualise it, play it.

You can do this in two ways: 
- with a fully-fledged GUI that lets you explore all modules visually and acoustically 
- with very simple script (create a module, add to model, run).

The repository consists of around 40 (and counting) modules that all work with real time sound. Many modules are from my research over the last 20 years, some are using open source third party software. Some are just wrapper for the fantastic Matlab system sound objects.

Here are some examples of what you can do: 
•	Use any input or output device on your computer: all are recognised automatically 
•	Extreme low latencies down to <4 ms, depending on the sample rate and frame rate 
•	Change sample rate, frame length and all other parameters dynamically 
•	Fully fledged GUI lets you explore all modules visually and acoustically 
•	See a real time waveform/spectrogram/cochleogram of your voice 
•	See the auditory image model live 
•	Listen to fully calibrated recordings (Internally all units are physical in Pascal, every signal is automatically calibrated using ⅓ octave filter) 
•	Create and use a code repository for scientific auditory research - making it possible to reference specific software versions of otherwise undocumented, but frequently used MATLAB software. 
•	Listen how speech sounds when having a cochlear implant or a hearing impairment 
•	Hear how your voice sounds pitch-shifted/flanged/echoed, reverberated 
•	Explore a fully functioning multichannel hearing aid, including audiogram and multi-channel compression 
•	Let the sound fly through space by dynamically changing the head related transfer function. 
•	See a live visualization of your vocal tract 
•	Reduce noise with a Wiener filter or spectral subtraction. 
•	Objective measures: measure the quality and intelligibility of speech and see how it changes when noise or reverberation are added 
•	Subjective measures: measure the roughness, sharpness, loudness or annoyance of sound 
•	Build your own modules and simply drop them in the ‘rt_modules’ folder to run 
•	Fully object oriented - easy to expand, understand and debug, each module has only two substantive functions that are called automatically: initialization and process 
•	Reasonably well optimised. Most modules are fast enough for real time, but not at the price of software legibility 
•	Code is maintained on github - fully open and curated. 
•	Future-proof software, following all matlab-conventions, no tricks, no mex. 
•	Incorporates lots of third-party software into a unified software framework that makes results more comparable 
•	Write powerful self-running scripts in 4 lines 
•	Use the calibration scripts to create precise calibration files for any new sound instrument. 
•	Each module comes with information about source and how to use it (work ongoing)

Cite As
Stefan Bleeck (2019). matlab_real_time_sound (https://www.github.com/sbleeck/matlab_real_time_sound), GitHub. Retrieved June 28, 2019.
