# matlabHTK
## Matlab Interface to HTK for Bioacoustic

---

MatlabHTK requires HTK (http://htk.eng.cam.ac.uk/) installed on system

MatlabHTK uses VOICEBOX speech processing toolbox MATLAB routines to read/write HTK binary files (http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html)

---

##  Function documentation
The calls to HTK functions are _**indicated**_.

### train_HTK()
* Process manually annotated sound recording files (Raven, Praat or Audacity) and convert to format readable to HTK (.mlf)
* Create directories and configuration files for HTK parameters (config, hmmprototype, configvar.txt, dict.txt, gram.txt, wavlist.txt, trainlist.txt, uniksequencetxt.mat)
* Extract the annotated sound signals and compute the window sound parameter values (_**HCopy**_)
* For each sound category, train a HMM using HTK function (_**HInit**_, _**HCompV**_, _**HRest**_)
* Clean up temporary files

### recognise_HTK()
* Check the hidden Markov model network (_**HParse**_, _**HSGen**_)
* For each file in the argument directory, perform recognition using the set of HMM (_**HVite**_)
* Convert recognition file to label file
* Save recognition result summary to a .csv file for postprocessing
* Clean up temporary files

### compare_label()
* compare the annotation similarity between two label files for the same sound file
* conduct a randomization test to assess significance of the similarity score
* write a confusion matrix for the first input label file to the second input label file


