function [] = createcffile_mixt(dirname,nstat,nmixt)
% create files required for using syllabise()
% nstat is the number of states
% nmixt is the number of mixture to use per state (the same for all the states even if HTK allows them to be different
% the same weight is initially given to each mixture
% 

% encoding parameters
coefftype = 'MFCC' ; %[MFCC]
numcoeff = 24 ; % number of coefficients without the energy [12]
energy = 1 ; % 0: noenergy, 1: use C0th, 2: use E
delta = 1 ; % 1
ddelta = 1 ; % 1
dddelta = 0 ;
vecsize = numcoeff + (energy>0) + (delta>0)*(numcoeff+(energy>0)) + (ddelta>0)*(numcoeff+(energy>0)) + (dddelta>0)*(numcoeff+(energy>0)) ;
windowlength = 30 ; % length of window in ms [30]
cmn = 1 ; % ceptral mean normalization

%%% dirname/analysis/config
mkdir(fullfile(dirname,'analysis')) ;
fid = fopen(fullfile(dirname,'analysis','config'),'w') ;
fprintf(fid,'SOURCEFORMAT=WAV\n') ;
fprintf(fid,'TARGETKIND=%s',coefftype) ;
if energy==1, fprintf(fid,'_0');
elseif energy==2, fprintf(fid,'_E');
end
if delta==1, fprintf(fid,'_D'); end
if ddelta==1, fprintf(fid,'_A'); end
if dddelta==1, fprintf(fid,'_T'); end
if cmn==1, fprintf(fid,'_Z'); end
fprintf(fid,'\n');
%fprintf(fid,'SOURCERATE=%.0f\n',(1/44100)*1e7) ;  % assuming 44.1kHz sampling frequency, in HTK time unit (100nsec)
fprintf(fid,'TARGETRATE=%.3f\n',(windowlength/2)*1e4) ; % 50% overlap
fprintf(fid,'WINDOWSIZE=%.0f\n',windowlength*1e4) ; % convert in HTK time unit (100nsec)
fprintf(fid,'SAVECOMPRESSED=T\n') ;
fprintf(fid,'SAVEWITHCRC=F\n') ;
fprintf(fid,'ZMEANSOURCE=T\n') ;
fprintf(fid,'USEHAMMING=T\n') ;
fprintf(fid,'PREEMCOEF=0.97\n') ;
fprintf(fid,'NUMCHANS=26\n') ;
fprintf(fid,'CEPLIFTER=22\n') ;
fprintf(fid,'NUMCEPS=%2.0f\n',numcoeff) ;
fprintf(fid,'ENORMALISE=T\n') ;
fprintf(fid,'LOFREQ=500\n') ; % [500]
fprintf(fid,'HIFREQ=12000\n') ; % [6000]
fclose(fid) ;

%%% dirname/hmmprototype/hmmproto
mkdir(fullfile(dirname,'hmmprototype')) ;
fid = fopen(fullfile(dirname,'hmmprototype','hmmproto'),'w') ;
fprintf(fid,'~h ""\n') ;
fprintf(fid,'<BeginHMM>\n') ;
fprintf(fid,'    <VecSize> %2.0f <USER>\n',vecsize) ;
fprintf(fid,'    <NumStates> %2.0f\n', nstat+2) ;
% fprintf(fid,['    <State> 2 <NumMixes> ' num2str(nmixt) '\n']) ;
% for nummixture=1:nmixt
%     fprintf(fid,['       <Mixture> ' num2str(nummixture) ' ' num2str(1/nmixt) '\n']) ;
%     fprintf(fid,'          <Mean> %2.0f\n',vecsize) ;
%     for n=1:vecsize, fprintf(fid,' 0.0'); end
%     fprintf(fid,'\n');
%      fprintf(fid,'          <Variance> %2.0f\n',vecsize) ;
%     for n=1:vecsize, fprintf(fid,' 1.0'); end
%     fprintf(fid,'\n');
% end
% fprintf(fid,['    <State> 3 <NumMixes> ' num2str(nmixt) '\n']) ;
% for nummixture=1:nmixt
%     fprintf(fid,['       <Mixture> ' num2str(nummixture) ' ' num2str(1/nmixt) '\n']) ;
%     fprintf(fid,'          <Mean> %2.0f\n',vecsize) ;
%     for n=1:vecsize, fprintf(fid,' 0.0'); end
%      fprintf(fid,'          <Variance> %2.0f\n',vecsize) ;
%     for n=1:vecsize, fprintf(fid,' 1.0'); end
% end
for nst=1:nstat
    fprintf(fid,['    <State> ' num2str(nst+1) ' <NumMixes> ' num2str(nmixt) '\n']) ;
    for nummixture=1:nmixt
        fprintf(fid,['       <Mixture> ' num2str(nummixture) ' ' num2str(1/nmixt) '\n']) ;
        fprintf(fid,'          <Mean> %2.0f\n',vecsize) ;
        for n=1:vecsize, fprintf(fid,' 0.0'); end
        fprintf(fid,'\n');
        fprintf(fid,'          <Variance> %2.0f\n',vecsize) ;
        for n=1:vecsize, fprintf(fid,' 1.0'); end
        fprintf(fid,'\n');
    end
end
% fprintf(fid,'    <TransP> 5\n') ;
% fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
% fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
% fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
% fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
% fprintf(fid,'       0.20 0.20 0.20 0.20 0.20\n') ;
fprintf(fid,'    <TransP> %2.0f\n', nstat+2) ;
for nstr=1:nstat+2
    for nstc=1:nstat+2
        fprintf(fid,' %1.3f',1/(nstat+2)) ;
    end
    fprintf(fid,'\n');
end
fprintf(fid,'<EndHMM>\n') ;
fprintf(fid,'\n') ;
fclose(fid) ;

