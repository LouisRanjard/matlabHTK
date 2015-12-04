function [] = createcffileetree(dirname,dirnamanalysis)
% create a HTK configuration files, dirnam/analysisetree/config1 and config2
% called from etann()

if nargin<2
    dirnamanalysis = 'analysisetree';
end
mkdir(fullfile(dirname,dirnamanalysis)) ;

%%% use 12 MFCC coeff with energy and first delta D with 2.9ms window
fid = fopen(fullfile(dirname,dirnamanalysis,'config1'),'w') ;
fprintf(fid,'SOURCEFORMAT = WAV\n') ;
%fprintf(fid,'SOURCERATE = 226.757 # ie 44100 Hz\n') ;
fprintf(fid,'TARGETKIND = MFCC_E_D # MFCC + logEnergy + Delta\n') ;
fprintf(fid,'TARGETRATE = 14512.0 # ie 1.5ms, 64 samples at 44100 Hz\n') ;
fprintf(fid,'WINDOWSIZE = 29025.0 # ie 2.9ms, 128 samples at 44100 Hz\n') ;
fprintf(fid,'SAVECOMPRESSED = T\n') ;
fprintf(fid,'SAVEWITHCRC = F\n') ;
fprintf(fid,'ZMEANSOURCE = T\n') ;
fprintf(fid,'USEHAMMING = T\n') ;
fprintf(fid,'PREEMCOEF = 0.97\n') ;
fprintf(fid,'NUMCHANS = 26\n') ;
fprintf(fid,'CEPLIFTER = 22\n') ;
fprintf(fid,'NUMCEPS = 12\n') ;
fprintf(fid,'ENORMALISE = T\n') ;
fprintf(fid,'LOFREQ = 1000\n') ;
fprintf(fid,'HIFREQ = 10000\n') ;
fclose(fid) ;

%%% use 12 PLP coeff with first delta D with 2.9ms window
fid = fopen(fullfile(dirname,dirnamanalysis,'config2'),'w') ;
fprintf(fid,'SOURCEFORMAT = WAV\n') ;
%fprintf(fid,'SOURCERATE = 226.757 # ie 44100 Hz\n') ;
fprintf(fid,'TARGETKIND = PLP_D # PLP + Delta\n') ;
fprintf(fid,'TARGETRATE = 14512.0 # ie 1.5ms, 64 samples at 44100 Hz\n') ;
fprintf(fid,'WINDOWSIZE = 29025.0 # ie 2.9ms, 128 samples at 44100 Hz\n') ;
fprintf(fid,'SAVECOMPRESSED = T\n') ;
fprintf(fid,'SAVEWITHCRC = F\n') ;
fprintf(fid,'ZMEANSOURCE = T\n') ;
fprintf(fid,'USEHAMMING = T\n') ;
fprintf(fid,'PREEMCOEF = 0.97\n') ;
fprintf(fid,'NUMCHANS = 26\n') ;
fprintf(fid,'CEPLIFTER = 22\n') ;
fprintf(fid,'NUMCEPS = 12\n') ;
fprintf(fid,'LPCODER = 12\n') ;
fprintf(fid,'ENORMALISE = T\n') ;
fprintf(fid,'LOFREQ = 1000\n') ;
%fprintf(fid,'HIFREQ = 20000\n') ;
fprintf(fid,'USEPOWER = T # to avoid "WARNING [-6371]  ValidCodeParms: Using linear spectrum with PLP in /usr/local/bin/HCopy"\n') ;
fclose(fid) ;
