function [songsmatfile song] = syllabise(dirnameA,dirnameB,gapminlength,sylminlength,fpanel)
% TRAIN A SIMPLE HMM RECOGNIZER USING HTK
% dirnameA must contains annotated .wav files with praat (.TestGrid files)
% or raven (.raven files)
% dirnameB must contains .wav files to be recognized
% return the file name of the songs datastructure containing the divided
% songs
% fpanel is the parent figure's panel to be used

% default minimum syllable length=120ms, minimum gap length=100ms 
if nargin<4, sylminlength=120 ; end
if nargin<3, gapminlength=100 ; end

if nargin<2, dirnameB='' ; end
if nargin<1, dirnameA='' ; end

if numel(dirnameA)<1
    % call interface to get parameters
    handles = getsyllabiseparameter(dirnameA,dirnameB,gapminlength,sylminlength);
    dirnameA = get(handles.dirname1,'String') ;
    dirnameB = get(handles.dirname2,'String') ;
    gapminlength = str2double(get(handles.gapminlength,'String')) ;
    sylminlength = str2double(get(handles.sylminlength,'String')) ;
    %close(handles.figure) ;
end

%%% RAVEN MANUAL ANNOTATION
files = dir(fullfile(dirnameA,'*.raven')) ;
if numel(files)==0
    nraven=0;
else
    nraven=numel(files);
    for nfiles=1:numel(files)
       tmp=regexprep(files(nfiles).name(end:-1:1),'nevar.','flm.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
       raven2mlf(fullfile(dirnameA,files(nfiles).name),...
           fullfile(dirnameA,tmp)) ;
    end
end

%%% PRAAT MANUAL ANNOTATION
% manually annotate a bunch of song examples file with praat and saved annotation as TextGrid files 
% convert the TextGrid files to mlf files (readable by HTK)
files = dir(fullfile(dirnameA,'*.TextGrid')) ;
if numel(files)==0
    ntextgrid=0;
else
    ntextgrid=numel(files);
    for nfiles=1:numel(files)
       tmp=regexprep(files(nfiles).name(end:-1:1),'dirGtxeT.','flm.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
       textGrid2mlf(fullfile(dirnameA,files(nfiles).name),...
            fullfile(dirnameA,tmp)) ;
    end
end

if nraven==0 && ntextgrid==0
    error(['No annotated files (.raven or .TextGrid) found in ' dirnameA]); end

%%% make a song datastructure for the training files
%%% process a directory containing .mlf files
files = dir(fullfile(dirnameA,'*.mlf')) ;
songtrain = [] ;
uniksequencetxt = [] ; % store all unik sequence id
for nfiles=1:numel(files)
    % manual annotation therefore there is no limitation on syllable/gap length
    songtrain = mlf2song( fullfile(dirnameA,files(nfiles).name), songtrain) ;
    for c=1:size(songtrain(end).sequencetxt,2)
        % fill up a structure with all unique sequencetxt
        found=0 ;
        for a=1:size(uniksequencetxt,2)
            if strcmp(uniksequencetxt(a),songtrain(end).sequencetxt(c))
                found=1 ; break ;
            end
        end
        if found==0 % sequencetxt not found, need to add it in the structure
            uniksequencetxt{end+1} = songtrain(end).sequencetxt{c} ;
        end
    end
end
%%% print the structure for info
for nsyl=1:numel(uniksequencetxt)
    fprintf(1,'%1.0f %s\n',nsyl,uniksequencetxt{nsyl});
end
%%% replace each syllable name as a numerical code to fill up song(n).sequence
songtrain = song_fill_seq(songtrain,uniksequencetxt,1) ;
%%% update the song sequences so that each syllable has a unique number
% fsyl = 0 ;
% for sg=1:numel(song)
%     song(sg).sequence = find(song(sg).sequence)+fsyl ;
%     %fsyl = song(sg).sequence(end) ; % bug if no syllable defined at all
%     fsyl = numel(song(sg).sequence)+fsyl ;
% end
% save('-v7',fullfile(dirnameA,'songs.mat'),'song') ;

%%% HTK TRAIN A HMM FOR SIGNAL/NOISE 
% convert all sequences into "1" sequences, thus all syllable have the same id
%for n=1:numel(song) song(n).sequence=(song(n).sequence.*0)+1 ; end
if ~exist(fullfile(dirnameA,'syllabised'),'file'), mkdir(fullfile(dirnameA,'syllabised')) ; end
%createcffile(fullfile(dirnameA,'syllabised')) ;
createcffile_mixt(fullfile(dirnameA,'syllabised'),6,4) ;
sylid = unique([songtrain.sequence]);
% create the grammar and dictionary configuration files
createcffile_grammar(fullfile(dirnameA,'syllabised'),sylid);
% initialise the HMMs
%initialiseHMM(song,fullfile(dirnameA,'syllabised'),0) ; % train for gaps in between syllables
for sid=sylid
    initialiseHMM(songtrain,fullfile(dirnameA,'syllabised'),sid) ;
end

%%% RUN RECOGNIZER
%recognizeHMM([0;1],fullfile(dirnameA,'syllabised'),...
recognizeHMM(sylid,fullfile(dirnameA,'syllabised'),...
    fullfile(dirnameA,'syllabised/def'),dirnameB,dirnameB) ;

%%% create the song datastructure for dirnameB and save songs.mat
files = dir(fullfile(dirnameB,'*.mlf')) ;
song = [] ;
for nfiles=1:numel(files)
    song = mlf2song( fullfile(dirnameB,files(nfiles).name), song, 2, gapminlength, sylminlength, 1) ;
end

% replace each syllable name as a numerical code to fill up song(n).sequence
song = song_fill_seq(song,uniksequencetxt,2);
songsmatfile = fullfile(dirnameB,'songs.mat') ;
save('-v7',songsmatfile,'song') ;

for nfiles=1:numel(files)
    % write a TextGrid file with the syllable boundaries after having merged and cleaned with mlf2song()
    tmp=regexprep(files(nfiles).name(end:-1:1),'flm.','dirGtxeT.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    song2textGrid( song(nfiles), fullfile(dirnameB,tmp), 2 ) ;
end
    
% %%% update the song sequences so that each syllable has a unique number
% fsyl = 0 ;
% for sg=1:numel(song)
%     song(sg).sequence = find(song(sg).sequence)+fsyl ;
%     %fsyl = song(sg).sequence(end) ; % bug if no syllable defined at all
%     fsyl = numel(song(sg).sequence)+fsyl ;
% end

%%% print the structure for info
for nsyl=1:numel(uniksequencetxt)
    fprintf(1,'%1.0f %s\n',nsyl,uniksequencetxt{nsyl});
end

%%% view the songs with soong
%soong(dirnameB,song);
