function [syllab] = encodeWavlist( wavdir, analysisdir, coeffdir, normavec, filefilter )
% encode the wav files in wavdir according to the coding parameters of the configuration files in analysisdir
% if there is more than one configuration file, each one is used and the vector sequences are merged
% the final vector sequence is saved in coeffdir with .vect extension instead of .wav
% need VOICEBOX for writing and reading HTK file format

if nargin<5, filefilter=''; end % to apply a filter on file name
if nargin<4, normavec=[]; end
if nargin<3, coeffdir=wavdir; end

if nargout>0
    syllab = struct('seqvect',{}) ;
end

wavfiles = dir(fullfile(wavdir,[filefilter '*.wav'])) ;
for sylf=1:numel(wavfiles)
    % fprintf(1,'%s\n',wavfiles(sylf).name) ;
    % if exist(fullfile(coeffdir,strrep(wavfiles(sylf).name,'.wav','.vect')))
    %     fprintf(1,'%s already exists, skipping...\n',wavfiles(sylf).name) ; % DO NOT OVERWRITE IF ALREADY ENCODED
    %     continue ;
    % end
    conffiles = dir(fullfile(analysisdir,'*')) ;
    seqvect = [] ;
    for cff=1:numel(conffiles)
        if isdir(fullfile(analysisdir,conffiles(cff).name)), continue; end % avoid directories
        sylfilename0 = fullfile(wavdir,wavfiles(sylf).name) ;
        tmp=regexprep(wavfiles(sylf).name(end:-1:1),'vaw.','pmtffeoc.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
        sylfilename1 = fullfile(coeffdir,tmp) ;
        % check if frequency band is compatible to the file sampling frequency
        if is_octave()
            [~, Fs] = wavread(sylfilename0) ;
        else
            info = audioinfo(sylfilename0) ;
            Fs = info.SampleRate ;
        end
        htkconf = fileread( fullfile(analysisdir,conffiles(cff).name) ) ;
        T = regexp( htkconf, '(?-s)(?m)^HIFREQ=\s*(\S+)\s*$','tokens') ;
        if (~isempty(T))
            hifreq = str2double( T{1} ) ;
            if ( hifreq>(Fs/2) )
                error('encodeWavlist(): sampling frequency of %s is not compatible with sound encoding parameters (check frequency band?)',sylfilename0);
            end
        else
            error('encodeWavlist(): format problem with parameter file %s',fullfile(analysisdir,conffiles(cff).name));
        end
        system(['HCopy -A -C ' fullfile(analysisdir,conffiles(cff).name) ' ' sylfilename0 ' ' sylfilename1]) ;
        [coeffseq,fp,dt,tc,t] = readhtk(sylfilename1) ;
        seqvect = [seqvect coeffseq]; % matrix transposed with readhtk (compared to readmfcc)
        delete(sylfilename1);
    end
    % fprintf(1,'%i %i\n',size(seqvect,1),size(seqvect,2)) ;
    if numel(normavec)>0
        % normalise from0 to 1 according to a vector giving the structure, e.g. [1 12; 13 13; 14 25]
        % seqvect = norma_seqvect(seqvect',[1 12; 13 13; 14 25]) ; % NEED TO TRANSPOSE THE MATRIX
        seqvect = norma_seqvect(seqvect',normavec) ; % NEED TO TRANSPOSE THE MATRIX
        seqvect = seqvect' ;
    end
    tc = 9 ; % always use USER data format for HTK, required for reading the data later
    if nargout==0
        tmp=regexprep(wavfiles(sylf).name(end:-1:1),'vaw.','tcev.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
        writehtk(fullfile(coeffdir,tmp),seqvect,fp,tc); % NEED TO TRANSPOSE THE MATRIX BACK
    else
        syllab(sylf).seqvect = seqvect ;
    end
end
