function [songsmatfile, song] = recognise_HTK(dirnameA,dirnameB,gapminlength,sylminlength,maxfilechunk,dirnameC)
% dirnameA must contains trained HTK recogniser
% dirnameB must contains .wav files to be recognized
% dirnameC (optional) is the directory where to write the output
% return file name of the songs datastructure with divided songs

% allow to find wav file
addpath(dirnameB);

% default is to write in the same directory as where the wav files are
if nargin<6, dirnameC=dirnameB ; end

% default maximum file duration in minutes to be recognised (split files if larger)
if nargin<5, maxfilechunk=240 ; end

% default minimum syllable length=120ms, minimum gap length=100ms 
if nargin<4, sylminlength=120 ; end
if nargin<3, gapminlength=100 ; end

if nargin<2, dirnameB='' ; end
if nargin<1, dirnameA='' ; end

%v = load('/home/louis/Documents/tutorial_recognition/Training/train_HTK/uniksequencetxt.mat','uniksequencetxt');
v = load(fullfile(dirnameA,'/uniksequencetxt.mat'),'uniksequencetxt');
uniksequencetxt = struct2cell(v);
uniksequencetxt = uniksequencetxt{1};
sylid = 1:numel(uniksequencetxt);

%%% RUN RECOGNIZER
recognizeHMM(sylid, fullfile(dirnameA), fullfile(dirnameA,'/def'), dirnameB, dirnameC, [], maxfilechunk) ;

%%% create the song datastructure for dirnameB and save songs.mat
files = dir(fullfile(dirnameC,'*.mlf')) ;
song = [] ;
for nfiles=1:numel(files)
    song = mlf2song( fullfile(dirnameC,files(nfiles).name), song, 2, gapminlength, sylminlength, 1) ;
end

% replace each syllable name as a numerical code to fill up song(n).sequence
song = song_fill_seq(song,uniksequencetxt,2);
songsmatfile = fullfile(dirnameC,'songs.mat') ;
%save('-v7',songsmatfile,'song') ;

for nfiles=1:numel(files)
    % write a TextGrid file with the syllable boundaries after having merged and cleaned with mlf2song()
    %tmp=regexprep(files(nfiles).name(end:-1:1),'flm.','dirGtxeT.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    %song2textGrid( song(nfiles), fullfile(dirnameB,tmp), 2 ) ;
    % write a label file with the syllable boundaries after having merged and cleaned with mlf2song()
    tmp=regexprep(files(nfiles).name(end:-1:1),'flm.','lebal.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    song2label( song(nfiles), fullfile(dirnameC,tmp), 2 ) ;
    % delete mlf file
    
end
    
%%% print the structure for info
fprintf(1,'\n\n');
for nsyl=1:numel(uniksequencetxt)
    fprintf(1,'%1.0f %s\n',nsyl,uniksequencetxt{nsyl});
end

%%% view the songs with soong
%soong(dirnameB,song);

%%% save recognition data to csv file
outputfile = fullfile(dirnameC,['/recognise_HTK_',datestr(now, 'yyyymmddMMSS'),'.csv']);
fid = fopen(outputfile, 'w');
if fid~=-1
    fprintf(fid, ',duration_sec');
    for n=1:numel(uniksequencetxt)
        fprintf(fid, ',%s (time),%s (events)',uniksequencetxt{n},uniksequencetxt{n});
    end
    fprintf(fid, '\n');
    for nfiles=1:numel(files)
        fprintf(fid, '%s,%.2f',song(nfiles).filename,song(nfiles).duration);
        for s=1:numel(uniksequencetxt)
            indexes = find(strcmp(song(nfiles).sequencetxt,uniksequencetxt(s)));
            somme = sum(song(nfiles).SyllableE(indexes)-song(nfiles).SyllableS(indexes));
            fprintf(fid, ',%.2f,%d',somme/song(nfiles).Fs,numel(indexes));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
else
    fprintf(1,'cannot open file: %s \n',outputfile);
end

% clean up
delete(fullfile(dirnameC,'*.mlf')) ;
rmpath(dirnameC) ;

