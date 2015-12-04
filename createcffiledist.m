function [] = createcffiledist(dirname,dirnamanalysis)
% create a HTK configuration files, dirnam/config
% called from dopwdist()

mkdir(fullfile(dirname,dirnamanalysis)) ;

fid = fopen(fullfile(dirname,dirnamanalysis,'config'),'w') ;

%%% use 20 MFCC coeff with energy with 2.9ms window
fprintf(fid,'SOURCEFORMAT = WAV\n') ;
%fprintf(fid,'SOURCERATE = 226.757 # ie 44100 Hz\n') ;
fprintf(fid,'TARGETKIND = MFCC_0 # MFCC + C0th coeff for Energy\n') ;
fprintf(fid,'TARGETRATE = 14512.0 # ie 1.5ms, 64 samples at 44100 Hz\n') ;
fprintf(fid,'WINDOWSIZE = 29025.0 # ie 2.9ms, 128 samples at 44100 Hz\n') ;
fprintf(fid,'SAVECOMPRESSED = T\n') ;
fprintf(fid,'SAVEWITHCRC = F\n') ;
fprintf(fid,'ZMEANSOURCE = T\n') ;
fprintf(fid,'USEHAMMING = T\n') ;
fprintf(fid,'PREEMCOEF = 0.97\n') ;
fprintf(fid,'NUMCHANS = 26\n') ;
fprintf(fid,'CEPLIFTER = 22\n') ;
fprintf(fid,'NUMCEPS = 20\n') ;
fprintf(fid,'ENORMALISE = T\n') ;
fprintf(fid,'LOFREQ = 300\n') ;
fprintf(fid,'HIFREQ = 10000\n') ;

fclose(fid) ;
