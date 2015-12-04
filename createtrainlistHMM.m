function [] = createtrainlistHMM( song, rootdir, id, distSN, N )
% read a song datastructure which sequence is properly labelled, "id " being the syllable type for which the HMM is created
% initialise an HTK HMM, create directories, perform acoustical analysis
% rootdir must contain a subdir "rootdir/analysis" containing an "analysis.conf" file for encoding
% create the file "rootdir/hmms/HMMid/model/trainlist.txt" containing the list of vector sequences for training
% the minimum length for a syllable is set at 50ms
% the name of the HMM created is syl"id"
% if id==0 or not provided, it will create a HMM for noise, getting the chunks of sound between the syllables
% distSN and N are used to limit the N first examples of each cluster or training

deb=0; % will store the limits of the signal
fin=0;

if nargin<3
	id=0;
	if nargin<4
		distSN=[];
	end
end

if strcmp(rootdir(end),'/') % remove "/" at the end of the root dir name is present
	rootdir=rootdir(1:end-1) ;
end
if isdir([rootdir '/hmms'])==0 % main directory for HMMs
	mkdir([rootdir '/hmms']) ;
end
mkdir([rootdir '/hmms/HMM' num2str(id)]) ; % main directory for this HMM
mkdir([rootdir '/hmms/HMM' num2str(id) '/data']) ;
mkdir([rootdir '/hmms/HMM' num2str(id) '/data/lab']) ;
mkdir([rootdir '/hmms/HMM' num2str(id) '/data/coeff']) ;
mkdir([rootdir '/hmms/HMM' num2str(id) '/data/sig']) ;
mkdir([rootdir '/hmms/HMM' num2str(id) '/model']) ;
mkdir([rootdir '/hmms/HMM' num2str(id) '/model/proto']) ;

% create a wavlist.txt file containing the list of the signal files
fidwavlist = fopen([rootdir '/hmms/HMM' num2str(id) '/model/wavlist.txt'],'w') ;
% create a trainlist.txt file containing the list of the encoded signal files
fidtrainlist = fopen([rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt'],'w') ;

countsyl=0; % syllable counter to find the correct line in distSN
% retrieve the different part of signal, copy and encode them
for sg=1:numel(song)
	% first find the song file
	%[status, filename] = system(['locate -n1 -r ?*/' song(sg).filename '$']);
	filename = which(song(sg).filename);
	if numel(strfind(filename,song(sg).filename))==0
	        error(['file not found ' song(sg).filename ':' filename]);
		continue;
	end
	fprintf(1,'%s\n',filename) ;
	[ y , Fs , bits ] = wavread(filename) ;
	y = y(:,1) ; % conversion from stereo to mono
	for sy=1:numel(song(sg).SyllableS)
		countsyl=countsyl+1;
		if id==0 % look for noise, take the noise chunks before each syllable (therefore do not use the last noise chunk at the end of the songs)
			deb = (sy>1)*song(sg).SyllableE(sy-(sy>1))+(sy==1) ;
			fin = song(sg).SyllableS(sy) ;
		else % check if the syllable belong to the current analysed type
			if song(sg).sequence(sy)==id
				% check that this example is part of the N first examples for this cluster
				if numel(distSN)>0
					% to find the correct column in the distance matrix, take the minimum distance for this syllable in distSN
					[minval minidx]=min(distSN(countsyl,:));
					tmp=sort(distSN(:,minidx));
					if minval>tmp(N) 
						continue; % distance greater than the N one for this cluster, the syllable is not saved
					end
				end
				deb = song(sg).SyllableS(sy) ;
				fin = song(sg).SyllableE(sy) ;
			else
				continue ;
			end
		end
		if (fin-deb)>((50*Fs)/1000) % minimum syllable length 50ms
			if id==0 % unique identifier for the current syllable: #song_#syllable
				idsyl = [num2str(sg) '_00' num2str(sy)] ;
			else
				idsyl = [num2str(sg) '_' num2str(sy)] ;
			end
			wavwrite([rootdir '/hmms/HMM' num2str(id) '/data/sig/sig' idsyl '.wav'], y(deb:fin), Fs, bits) ;
			% update the wavlist file
			fprintf(fidwavlist,'%s %s\n',[rootdir '/hmms/HMM' num2str(id) '/data/sig/sig' idsyl '.wav'],[rootdir '/hmms/HMM' num2str(id) '/data/coeff/sig' idsyl '.vect']) ;
			% update the trainlist file
			fprintf(fidtrainlist,'%s\n',[rootdir '/hmms/HMM' num2str(id) '/data/coeff/sig' idsyl '.vect']) ;
			% create label file
			fid = fopen([rootdir '/hmms/HMM' num2str(id) '/data/lab/sig' idsyl '.lab'],'w') ;
			%fprintf(fid,'1 %10.0f syl%i\n',round(((fin-deb)*10000000)/Fs),id) ;
			fprintf(fid,'1 %10.0f %i\n',round(((fin-deb)*10000000)/Fs),id) ;
			fclose(fid) ;
		end
	end
end
fclose(fidtrainlist) ;
fclose(fidwavlist) ;
system(['HCopy -A -C ' rootdir '/analysis/analysis.conf -S '  rootdir '/hmms/HMM' num2str(id) '/model/wavlist.txt']) ;
