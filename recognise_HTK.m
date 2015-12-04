function [songsmatfile, song] = recognise_HTK(dirnameA,dirnameB,gapminlength,sylminlength)
% dirnameA must contains trained HTK recogniser
% dirnameB must contains .wav files to be recognized
% return file name of the songs datastructure with divided songs

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
recognizeHMM(sylid, fullfile(dirnameA), fullfile(dirnameA,'/def'), dirnameB, dirnameB) ;

%%% create the song datastructure for dirnameB and save songs.mat
files = dir(fullfile(dirnameB,'*.mlf')) ;
song = [] ;
for nfiles=1:numel(files)
    song = mlf2song( fullfile(dirnameB,files(nfiles).name), song, 2, gapminlength, sylminlength, 1) ;
end

% replace each syllable name as a numerical code to fill up song(n).sequence
song = song_fill_seq(song,uniksequencetxt,2);
songsmatfile = fullfile(dirnameB,'songs.mat') ;
%save('-v7',songsmatfile,'song') ;

for nfiles=1:numel(files)
    % write a TextGrid file with the syllable boundaries after having merged and cleaned with mlf2song()
    %tmp=regexprep(files(nfiles).name(end:-1:1),'flm.','dirGtxeT.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    %song2textGrid( song(nfiles), fullfile(dirnameB,tmp), 2 ) ;
    % write a label file with the syllable boundaries after having merged and cleaned with mlf2song()
    tmp=regexprep(files(nfiles).name(end:-1:1),'flm.','lebal.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    song2label( song(nfiles), fullfile(dirnameB,tmp), 2 ) ;
end
    
%%% print the structure for info
for nsyl=1:numel(uniksequencetxt)
    fprintf(1,'%1.0f %s\n',nsyl,uniksequencetxt{nsyl});
end

%%% view the songs with soong
%soong(dirnameB,song);

%%% save recognition data to csv file
outputfile = fullfile(dirnameB,['/recognise_HTK_',datestr(now, 'yyyymmdd'),'.csv']);
fid = fopen(outputfile, 'w');
fprintf(fid, ',duration');
for n=1:numel(uniksequencetxt)
    fprintf(fid, ',%s',uniksequencetxt{n});
end
for nfiles=1:numel(files)
    fprintf(fid, '%s,%f',song(nfiles).filename,song(nfiles).duration);
    for s=1:numel(uniksequencetxt)
        indexes = find(strcmp(song(nfiles).sequencetxt,uniksequencetxt(s)));
        somme = sum(song(nfiles).SyllableE(indexes)-song(nfiles).SyllableS(indexes));
        fprintf(fid, ',%d',somme/song(nfiles).Fs);
    end
    fprintf(fid, '\n');
end
fclose(fid);

