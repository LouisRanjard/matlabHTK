function [song syllab] = createsongfromwav(directo,ssyl)
% create a song and syllable structures
% each song has one syllable lasting the whole recording

if nargin<2
    ssyl=0; end

files = dir(fullfile(directo,'*.wav')) ;
song = struct('filename',{},'SyllableS',{},'SyllableE',{},'sequence',{}) ;

if nargout>1
    if ~exist(fullfile(directo,'analysis'),'file')
        mkdir(fullfile(directo,'analysis')) ;
        createcffileetree(directo,'analysis') ;
    end
    [syllab] = encodeWavlist(directo, fullfile(directo,'analysis')) ;
end

for fl=1:numel(files)
    song(fl).filename = files(fl).name ;
    y = wavread(fullfile(directo,files(fl).name)) ;
    song(fl).SyllableS = 1 ;
    song(fl).SyllableE = length(y) ;
    song(fl).sequence = fl ;
end

% if octave use -v6 because of bug writing -v7 for large dataset
if (language_of=='octave') 
    save('-v6',fullfile(directo,'songs.mat'),'song');
    if ssyl==1
        save('-v6',fullfile(directo,'syllab.mat'),'syllab'); end
else
    save('-v7',fullfile(directo,'songs.mat'), 'song' );
    if ssyl==1
        save('-v7',fullfile(directo,'syllab.mat'),'syllab'); end
end
