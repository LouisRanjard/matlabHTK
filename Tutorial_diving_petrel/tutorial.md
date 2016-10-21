
### Tutorial matlabHTK
This tutorial presents how to set a HMM recogniser using previously annotated example label files with Audacity.

---

#### Download and unzip the last version of matlabHTK from https://github.com/LouisRanjard/matlabHTK
Open Octave or Matlab. Add the matlabHTK function to the Matlab/Octave path and change directory to the tutorial directory. For example, if the package was downloaded in /home/louis:
```
addpath(genpath('/home/louis/matlabHTK-master')) ;
cd /home/louis/matlabHTK-master/Tutorial_diving_petrel ;
more off;
```
Use `more off;` in Octave to suppress some unnecessary messages (disable Paging Screen Output).

#### Training
Set up and train HMMs for each label found in the manually annotated label files in training directory
```
train_HTK('./training');
```

#### Recognition
Run the recognition for all wav files found in the recognition directory
```
recognise_HTK('./training/train_HTK','./recognition');
```

#### Plot
Plot the recognition results for the label 'diving_petrel'. Input the date and time when the recording started.
```
plot_Label('./recognition/recording.label','./recognition/recording.wav','diving_petrel',10,'25/09/2014 18:00:00');
```

---

&nbsp;

### HTK parameters (from HTKBook)

* __Parameter value testing__

Different values for the HTK sound parameters were tested and the similarity score was calculated for a manually annotated recording using the following function
```
compare_label('./recognition/reference/recording.label','./recognition/recording.label',30);
```
Tests were performed by sequentially modifying the value of one parameter chosen from the set of parameter values that gave the best results. If a specific change increased the similarity score then it was kept identical for the rest of the tests. A thorough description of the parameters can be found in the HTK Book (Young et al., 2006). To control for consistency, the set of parameters that gave the best results was tested three times. The replicated model building and recognition gave similar similarity scores (89.23%, 89.12% and 89.23%). The randomisation test was performed using 60-second time window bins and indicated that the recognition was better than expected by chance, with a significant p-value (<<0.001). 

&nbsp;

__Table__. The set of HTK parameter values investigated and corresponding similarity scores against the visually annotated recording file. In all tests, the TARGETKIND parameter was set to MFCC. Inclusion of the delta parameters correspond to option _D, _A, _T in the HTK parameter file and the cepstral mean normalisation (cmn) correspond to _Z. For example, the first column correspond to the following HTK parameter file option for encoding TARGETKIND=MFCC_D_A_E. The other HTK parameters are indicated in the column names.

NUMCEPS | energy | delta | ddelta | dddelta | cmn | WINDOWSIZE (ms) | LOFREQ | HIFREQ | ZMEANSOURCE | USEHAMMING | PREEMCOEF | NUMCHANS | CEPLIFTER | ENORMALISE | Similarity versus manual annotation
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 89.23%
24 | C0 | 1 | 1 |  | 1 | 30 | 500 | 12000 | T | T | 1 | 26 | 22 | T | 89.09%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 40 | 22 | T | 88.97%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 10 | T | 88.81%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | F | 88.77%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 10000 | T | T | 0.97 | 26 | 22 | T | 88.66%
20 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 88.51%
12 |  | 1 |  |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 88.41%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | F | T | 0.97 | 26 | 22 | T | 88.35%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 40 | T | 88.21%
12 |  | 1 | 1 |  |  | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 88.13%
12 |  | 1 | 1 |  | 1 | 35 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 87.74%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 8000 | T | T | 0.97 | 26 | 22 | T | 87.04%
12 |  | 1 | 1 |  | 1 | 20 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 86.57%
12 |  | 1 | 1 |  | 1 | 25 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 86.46%
12 |  | 1 | 1 |  | 1 | 20 | 500 | 12000 | T | T | 0.97 | 26 | 22 | T | 86.27%
12 |  | 1 | 1 |  | 1 | 30 | 500 | 12000 | T | T | 0.97 | 26 | 22 | T | 86.02%
12 |  | 1 | 1 | 1 | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 85.86%
12 | C0 | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | F | 82.36%
12 | C0 | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 82.23%
12 |  | 1 | 1 |  | 1 | 10 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 82.22%
12 | E | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 81.73%
6 |  | 1 | 1 |  | 1 | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 80.50%
12 | E | 1 | 1 |  | 1 | 20 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 79.86%
12 |  | 1 | 1 |  | 1 | 45 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 76.25%
12 |  | 1 | 1 |  | 1 | 45 | 500 | 12000 | T | T | 0.97 | 26 | 22 | T | 75.00%
12 | C0 | 1 | 1 |  | 1 | 45 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 74.35%
12 | C0 | 1 | 1 |  | 1 | 60 | 500 | 12000 | T | T | 0.97 | 26 | 22 | T | 70.55%
12 |  |  |  |  |  | 30 | 500 | 6000 | T | T | 0.97 | 26 | 22 | T | 69.70%
12 | E | 1 | 1 |  |  | 1 | 0 | 22050 | T | T | 0.97 | 26 | 22 | T | 37.99%


The default values of the parameters for representing the sound and constructing the HMMs have been optimised for analysing bird vocalisation data (see Table below). However, a given dataset may benefit from slight changes in these values. For example, a frequency band pass filter can be defined in the HTK parameter file when prior knowledge can inform the target frequencies of interest using LOFREQ and HIFREQ options. The structure of the HMM can be also be modified allowing the user to set the number of states and Gaussian mixtures to model these states. It is also possible to set a minimum duration thresholds in ms for the annotated part of the recordings and the gap separating them, arguments _sylminlength_ and _gapminlength_ of the function _recognise_HTK()_. After the HTK recognition is performed, consecutive labels will be merged or deleted depending on the values of these thresholds. These values can be used to avoid recognising too short sound segments when information on the duration of the target vocalisations is known.


* __Parameter description__

To change the parameter values, edit file 'matlabHTK/createcffile_mixt.m'

Parameter name | Definition | Default value in matlabHTK
--- | --- | ---
SOURCEFORMAT | File format of source | WAV
TARGETKIND | Parameter kind of target | MFCC_D_A_Z
TARGETRATE | Sample rate of target in 100ns units | 50% overlap
WINDOWSIZE | Analysis window size in units of 100ns | 30ms
SAVECOMPRESSED | Save the output file in compressed form | T
SAVEWITHCRC | Attach a checksum to output parameter file | F
ZMEANSOURCE | Zero mean source waveform before analysis | T
USEHAMMING | Use a Hamming window | T
PREEMCOEF | Set pre-emphasis coefficient | 0.97
NUMCHANS | Number of filterbank channels | 26
CEPLIFTER | Cepstral liftering coefficient | 22
NUMCEPS | Number of cepstral parameters | 24
ENORMALISE | Normalise log energy | T
LOFREQ | Low frequency cut-off in fbank analysis | 500
HIFREQ | High frequency cut-off in fbank analysis | 12000

