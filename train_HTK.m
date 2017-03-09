function [uniksequencetxt] = train_HTK(dirnameA)
% TRAIN A SIMPLE HMM RECOGNIZER USING HTK
% dirnameA must contains annotated .wav files with praat (.TestGrid files) or others:
% or raven (.raven files)
% or Audacity (.label files)

if nargin<1, dirnameA='' ; end

% allow to find wav files
addpath(dirnameA);

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

%%% AUDACITY MANUAL ANNOTATION
files = dir(fullfile(dirnameA,'*.label')) ;
if numel(files)==0
    naudacity=0;
else
    naudacity=numel(files);
    for nfiles=1:numel(files)
       tmp=regexprep(files(nfiles).name(end:-1:1),'lebal.','flm.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
       label2mlf(fullfile(dirnameA,files(nfiles).name),...
            fullfile(dirnameA,tmp)) ;
    end
end
% also allow .txt Audacity label files
files = dir(fullfile(dirnameA,'*.txt')) ;
if numel(files)>0
    naudacity=numel(files);
    for nfiles=1:numel(files)
       tmp=regexprep(files(nfiles).name(end:-1:1),'txt.','flm.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
       label2mlf(fullfile(dirnameA,files(nfiles).name),...
            fullfile(dirnameA,tmp)) ;
    end
end

if nraven==0 && ntextgrid==0 && naudacity==0
    error(['No annotated files (.raven or .TextGrid or .label or .txt) found in ' dirnameA]); end

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

%%% HTK TRAIN A HMM
% convert all sequences into "1" sequences, thus all syllable have the same id
%for n=1:numel(song) song(n).sequence=(song(n).sequence.*0)+1 ; end
if ~exist(fullfile(dirnameA,'train_HTK'),'file'), mkdir(fullfile(dirnameA,'train_HTK')) ; end
createcffile_mixt(fullfile(dirnameA,'train_HTK')) ;
sylid = unique([songtrain.sequence]);
% create the grammar and dictionary configuration files
createcffile_grammar(fullfile(dirnameA,'train_HTK'),sylid);
% initialise the HMMs
%initialiseHMM(song,fullfile(dirnameA,'syllabised'),0) ; % train for gaps in between syllables
for sid=sylid
    initialiseHMM(songtrain,fullfile(dirnameA,'train_HTK'),sid) ;
end

%%% clean up and save
delete(fullfile(dirnameA,'*.mlf')) ;
save('-v7',fullfile(dirnameA,'train_HTK/uniksequencetxt.mat'),'uniksequencetxt') ;
rmpath(dirnameA);
