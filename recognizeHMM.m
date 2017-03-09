function [] = recognizeHMM( idlist, rootdir, defdir, filesdir, destdir, normavec, maxfilechunk )
% given a list of HMM (idlist), found in rootdir/hmms/HMM(idlist[n])
% performs recognition from the set of files in filesdir (filesdir/*.wav files)
% creates the encoded wav files and recognition files in destdir
% uses the grammar definition of defdir/gram.txt and defdir/dict.txt
% uses configuration variable for HVite defdir/configvar.txt
% example: recognizeHMM( [0;1], '/data/Tieke/testhtk/', '/data/Tieke/testhtk/def', '/data/Tieke/testhtk/data', '/data/Tieke/testhtk/data' );

if nargin<7, maxfilechunk=240; end

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
    while exist(fullfile(rootdir, 'hmms', ['HMM' num2str(idlist(idl))], 'model', ['hmm' num2str(nrest+1)]),'file')
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
recfiles = dir(fullfile(filesdir,'*.wav')) ;
for recf=1:numel(recfiles)
    if is_octave()
        [~, Fs] = wavread(fullfile(destdir,recfiles(recf).name),1) ;
        TotalSamples = wavread(fullfile(destdir,recfiles(recf).name),'size') ;
    else
        info = audioinfo(fullfile(destdir,recfiles(recf).name));
        Fs = info.SampleRate;
        TotalSamples = info.TotalSamples;
    end
    chunkCnt = 1;
    for startLoc = 1:(maxfilechunk*60*Fs):TotalSamples % break into file of chunk size max
        endLoc = min(startLoc + maxfilechunk*60*Fs - 1, TotalSamples);
        if (TotalSamples>endLoc) % write a temporary wav file of required length
            FileName = sprintf('outfile%03d.wav', chunkCnt);
            if is_octave()
                y = wavread(fullfile(destdir,recfiles(recf).name), [startLoc endLoc]);
                wavwrite(y, Fs, fullfile(destdir,FileName));
            else
                y = audioread(fullfile(destdir,recfiles(recf).name), [startLoc endLoc]);
                audiowrite(fullfile(destdir,FileName), y, Fs);
            end
            chunkCnt = chunkCnt + 1;
        elseif (chunkCnt == 1)
            FileName = recfiles(recf).name;
        end
        % system(['HCopy -A -C ' rootdir '/analysis/analysis.conf ' fullfile(filesdir,recfiles(recf).name) ' ' strrep(fullfile(filesdir,recfiles(recf).name),'.wav','.vect')]) ;
        [~,filenoext,~] = fileparts(FileName) ;
        encodeWavlist( filesdir, fullfile(rootdir,'analysis'), destdir, normavec, filenoext) ;
        % run the Viterbi
        tmp1=regexprep(FileName(end:-1:1),'vaw.','flm.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
        tmp2=regexprep(FileName(end:-1:1),'vaw.','tcev.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
        system([HVite_string ' -i ' fullfile(destdir,tmp1) ' -w ' defdir '/net.slf ' defdir '/dict.txt ' defdir '/hmmlist.txt ' fullfile(destdir,tmp2)]) ;
        % remove encoded files
        delete(fullfile(destdir,tmp2)) ;
        % convert to TextGrid for Praat display
        % do it later after the limits on gap and syllable lengths have been applied
        % mlf2textGrid( strrep(fullfile(destdir,recfiles(recf).name),'.wav','.mlf'), strrep(fullfile(destdir,recfiles(recf).name),'.wav','.textGrid') ) ;
    end
    % merge all the mlf files
    if (chunkCnt>1)
        fileout = regexprep(recfiles(recf).name(end:-1:1),'vaw.','flm.','once') ; fileout=fileout(end:-1:1) ;
        fido = fopen(fullfile(destdir,fileout),'w') ;
        fprintf(fido,'#!MLF!#\n"%s"\n',fileout) ;
        t_shift = 0 ;
        for n=1:(chunkCnt-1)
            mlfFileName = sprintf('outfile%03d.mlf', n) ;
            fidi = fopen(fullfile(destdir,mlfFileName),'r') ;
            tline = fgetl(fidi) ;
            if numel( strfind(tline,'#!MLF!#') )==0, error(1,('recognizeHMM(): mlf file format error\n')); end
            tline = fgetl(fidi) ; % skip mlf file name
            tline = fgetl(fidi) ;
            while 1
                if strcmp(tline,'.')==1, break, end % if the line is "." it means the eof is reached
                A = sscanf(tline,'%f %f syl%f %*f') ; % get beginning and end and name of recognised segment
                [B, ~, errmsg] = sscanf(tline,'%*f %*f %s %*f') ; % get the segment name
                if numel(errmsg)==0
                    fprintf(fido,'%s %s %s 0\n',num2str(t_shift+A(1)),num2str(t_shift+A(2)),char(B)') ;
                end
                tline = fgetl(fidi) ;
            end
            t_shift = t_shift + A(2) ; % keep track of duration of each splitted file
            fclose(fidi) ;
            delete(fullfile(destdir,mlfFileName)) ;
	        delete(fullfile(destdir,sprintf('outfile%03d.wav', n))) ;
        end
        % end the mlf file (always need a ".")
        fprintf(fido,'.\n') ;
        fclose(fido) ;
    end
end
