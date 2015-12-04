function [] = createcffile(dirname)
% create files required for using syllabise()
%%%%% NOT USED %%%%%%%%

%%% dirname/analysis/config, use MFCC_0_D and 20ms window
mkdir(fullfile(dirname,'analysis')) ;
fid = fopen(fullfile(dirname,'analysis','config'),'w') ;
fprintf(fid,'SOURCEFORMAT=WAV\n') ;
fprintf(fid,'TARGETKIND=MFCC_0_D\n') ;
fprintf(fid,'TARGETRATE=100000.0\n') ;
fprintf(fid,'WINDOWSIZE=200000.0\n') ;
fprintf(fid,'SAVECOMPRESSED=F\n') ;
fprintf(fid,'SAVEWITHCRC=F\n') ;
fprintf(fid,'ZMEANSOURCE=T\n') ;
fprintf(fid,'USEHAMMING=T\n') ;
fprintf(fid,'PREEMCOEF=0.97\n') ;
fprintf(fid,'NUMCHANS=26\n') ;
fprintf(fid,'CEPLIFTER=22\n') ;
fprintf(fid,'NUMCEPS=20\n') ;
fprintf(fid,'ENORMALISE=T\n') ;
fprintf(fid,'LOFREQ=300\n') ;
%fprintf(fid,'HIFREQ=20000\n') ;
fprintf(fid,'HIFREQ=10000\n') ;
fclose(fid) ;

%%% dirname/hmmprototype/hmmproto
mkdir(fullfile(dirname,'hmmprototype')) ;
fid = fopen(fullfile(dirname,'hmmprototype','hmmproto'),'w') ;
fprintf(fid,'~h ""\n') ;
fprintf(fid,'<BeginHMM>\n') ;
fprintf(fid,'    <VecSize> 42 <USER>\n') ;
fprintf(fid,'    <NumStates> 5\n') ;
fprintf(fid,'    <State> 2\n') ;
fprintf(fid,'       <Mean> 42\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'       <Variance> 42\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'    <State> 3\n') ;
fprintf(fid,'       <Mean> 42\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'       <Variance> 42\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'    <State> 4\n') ;
fprintf(fid,'       <Mean> 42\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'          0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0\n') ;
fprintf(fid,'       <Variance> 42\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'          1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0\n') ;
fprintf(fid,'    <TransP> 5\n') ;
fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'<EndHMM>\n') ;
fprintf(fid,'\n') ;
fclose(fid) ;
