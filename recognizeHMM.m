function [] = recognizeHMM( idlist, rootdir, defdir, filesdir, destdir, normavec )
% given a list of HMM (idlist), found in rootdir/hmms/HMM(idlist[n])
% performs recognition from the set of files in filesdir (filesdir/*.wav files)
% creates the encoded wav files and recognition files in destdir
% uses the grammar definition of defdir/gram.txt and defdir/dict.txt
% uses configuration variable for HVite defdir/configvar.txt
% example: recognizeHMM( [0;1], '/data/Tieke/testhtk/', '/data/Tieke/testhtk/def', '/data/Tieke/testhtk/data', '/data/Tieke/testhtk/data' );

if nargin<6, normavec=[]; end

if strcmp(rootdir(end),'/') % remove "/" at the end of the root dir name is present
	rootdir=rootdir(1:end-1) ; end
if strcmp(defdir(end),'/') % remove "/" at the end of the def dir name is present
	defdir=defdir(1:end-1) ; end
if strcmp(filesdir(end),'/') % remove "/" at the end of the files dir name is present
	filesdir=filesdir(1:end-1) ; end
if strcmp(destdir(end),'/') % remove "/" at the end of the files dir name is present
    destdir=destdir(1:end-1) ; end

% create a network file from the grammar and the dictionary files
system(['HParse -A -T 1 ' defdir '/gram.txt ' defdir '/net.slf']) ;

% check the grammar against the dictionary files
system(['HSGen -A -n 10 -s ' defdir '/net.slf ' defdir '/dict.txt']) ;

% create the hmmlist.txt and implement the command HVite with the list of hmm definition files
HVite_string = ['HVite -s 10.0 -p -20.0 -A -T 1 -C ' defdir '/configvar.txt'] ;
% HVite_string = ['HVite -A -T 1 -C ' defdir '/configvar.txt'] ;
fid = fopen(fullfile(defdir,'hmmlist.txt'),'w') ;
for idl=1:numel(idlist)
    % check if the definition file for this HMM exists
	% [INFO, ERR, MSG] = stat([rootdir '/hmms/HMM' num2str(idlist(idl)) '/model/hmm10/hmm' num2str(idlist(idl))]) ; % OCTAVE
    % if ERR==0
    nrest = 1 ;
    while exist(fullfile(rootdir, 'hmms', ['HMM' num2str(idlist(idl))], 'model', ['hmm' num2str(nrest+1)]),'file') ;
        nrest = nrest+1 ;
    end
	if exist([rootdir '/hmms/HMM' num2str(idlist(idl)) '/model/hmm' num2str(nrest) '/hmm' num2str(idlist(idl))],'file')
		fprintf(fid,'syl%s\n',num2str(idlist(idl))) ;
		HVite_string = [HVite_string ' -H ' rootdir '/hmms/HMM' num2str(idlist(idl)) '/model/hmm' num2str(nrest) '/hmm' num2str(idlist(idl))] ;
	end
end
fclose(fid) ;

% Do recognition for each file in files dir
% compute coefficients
encodeWavlist( filesdir, fullfile(rootdir,'analysis'), destdir,normavec) ;
recfiles = dir(fullfile(filesdir,'*.wav')) ;
for recf=1:numel(recfiles)
	% system(['HCopy -A -C ' rootdir '/analysis/analysis.conf ' fullfile(filesdir,recfiles(recf).name) ' ' strrep(fullfile(filesdir,recfiles(recf).name),'.wav','.vect')]) ;
	% run the Viterbi
    tmp1=regexprep(recfiles(recf).name(end:-1:1),'vaw.','flm.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    tmp2=regexprep(recfiles(recf).name(end:-1:1),'vaw.','tcev.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
	system([HVite_string ' -i ' fullfile(destdir,tmp1) ' -w ' defdir '/net.slf ' defdir '/dict.txt ' defdir '/hmmlist.txt ' fullfile(destdir,tmp2)]) ;
	% convert to TextGrid for Praat display
    % do it later after the limits on gap and syllable lengths have been applied
	% mlf2textGrid( strrep(fullfile(destdir,recfiles(recf).name),'.wav','.mlf'), strrep(fullfile(destdir,recfiles(recf).name),'.wav','.textGrid') ) ;
end
