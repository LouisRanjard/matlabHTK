function [] = initialiseHMM( song, rootdir, id, normavec, maxcnt )
% read a song datastructure which sequence is properly labelled, "id " being the syllable type for which the HMM is created
% initialise an HTK HMM, create directories, perform acoustical analysis
% rootdir must contain a subdir "rootdir/analysis" containing one or more configuration file(s) for encoding
% rootdir must contain a subdir "rootdir/hmmprototype" containing an "hmmproto" file for defining the basic HMM structure to be used
%	the first line of this file must be: ~h ""
% the minimum length for a syllable is set at 50ms
% the name of the HMM created is syl"id"
% the maximum number of training chunk can be limited with the parameter "maxcnt" (default is 1000)
% if id==0 or not provided, it will create a HMM for noise, getting the chunks of sound between the syllables
% example: initialiseHMM( song(1:80), '/data/Tieke/testhtk', 1);

deb=0; % will store the limits of the signal
fin=0;

if nargin<5
	maxcnt=1000 ;
	if nargin<4
		normavec=[] ;
        if nargin<3
            id=0 ;
        end
	end
end

if strcmp(rootdir(end),'/') % remove "/" at the end of the root dir name is present
	rootdir=rootdir(1:end-1) ;
end
if isdir(fullfile(rootdir,'hmms'))==0 % main directory for HMMs
	mkdir(fullfile(rootdir,'hmms')) ;
end
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)])) ; % main directory for this HMM
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data')) ;
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','lab')) ;
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','coeff')) ;
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','sig')) ;
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model')) ;
[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','proto')) ;

% create a wavlist.txt file containing the list of the signal files
fidwavlist = fopen(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','wavlist.txt'),'w') ;
% create a trainlist.txt file containing the list of the encoded signal files
fidtrainlist = fopen(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','trainlist.txt'),'w') ;

% retrieve the different part of signal, copy and encode them
cntt = 0 ; % count the number of training sound chunk
for sg=randperm(numel(song)) % randomise the index of songs
	fprintf(1,'%i-%s-',sg,song(sg).filename) ;
	% first find the song file
    if exist(fullfile(rootdir,song(sg).filename),'file')
        filename = fullfile(rootdir,song(sg).filename) ;
    else
        if isunix % if under unix, try to find the file
            %[status, filename] = system(['locate -n1 -r ?*/' song(sg).filename '$']);
            %filename = filename(1:end-1) ; % remove the \n at the end
	    filename = which(song(sg).filename);
        else
            filename = '' ; 
        end
    end
	if numel(strfind(filename,song(sg).filename))==0
    	fprintf(1,'file not found: %s \n',song(sg).filename);
		continue ;
	end
	fprintf(1,'%s\n',filename) ;
	[ y , Fs , bits ] = wavread(filename) ;
	y = y(:,1) ; % conversion from stereo to mono
	for sy=1:numel(song(sg).SyllableS)
		if id==0 % look for noise, take the noise chunks before each syllable (therefore do not use the last noise chunk at the end of the songs)
			deb = round( (sy>1)*song(sg).SyllableE(sy-(sy>1))+(sy==1) ) ;
			fin = round( song(sg).SyllableS(sy) ) ;
		else % check if the syllable belong to the current analysed type
			if song(sg).sequence(sy)==id
				deb = round( song(sg).SyllableS(sy) ) ;
				fin = round( song(sg).SyllableE(sy) ) ;
			else
				continue ;
			end
        end
        deb = max(1,deb) ; % avoid to exceed dimension
        fin = min(length(y),fin) ;
		if (fin-deb)>((50*Fs)/1000) % minimum syllable length 50ms
			idsyl = [num2str(sg) '_' num2str(sy) '_' num2str(id)] ; % unique identifier for the current syllable: #song_#syllable_id
			% wavwrite([rootdir '/hmms/HMM' num2str(id) '/data/sig/sig' idsyl '.wav'], y(deb:fin), Fs, bits) ;
			wavwrite(y(deb:fin), Fs, bits, fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','sig',['sig' idsyl '.wav'])) ; % change for Matlab R2008b
			% update the wavlist file
			fprintf(fidwavlist,'%s %s\n',fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','sig',['sig' idsyl '.wav']),...
                fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','coeff',['sig' idsyl '.vect'])) ;
			% update the trainlist file
			fprintf(fidtrainlist,'%s\n',fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','coeff',['sig' idsyl '.vect'])) ;
			% create label file
			fid = fopen(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','lab',['sig' idsyl '.lab']),'w') ;
			fprintf(fid,'1 %10.0f syl%i\n',round(((fin-deb)*10000000)/Fs),id) ;
			fclose(fid) ;
			cntt = cntt+1 ;
		end
	end
	if cntt>maxcnt
		break; % stop because enough training sounds has been found
	end
end
fclose(fidtrainlist) ;
fclose(fidwavlist) ;
% encode all the wav chunks
%system(['HCopy -A -C ' rootdir '/analysis/analysis.conf -S '  rootdir '/hmms/HMM' num2str(id) '/model/wavlist.txt']) ;
encodeWavlist(fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','sig'),fullfile(rootdir,'analysis'),fullfile(rootdir,'hmms',['HMM' num2str(id)],'data','coeff'),normavec) ;

% create the HMM prototype and train it
system(['cp ' rootdir '/hmmprototype/hmmproto ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_']) ; % copy the prototype
% setstr(39) is ASCII code for single quote "'"
system(['sed ' setstr(39) 's/""/"syl' num2str(id) '"/g' setstr(39) ' ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_ > ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id)]) ; % change the name for this particular hmm
system(['rm -f ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_']) ;

% initialise the HMM parameters
mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','hmm0')) ;
system(['HInit -A -T 2 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0 -H ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) ' -l syl' num2str(id) ' -L ' rootdir '/hmms/HMM' num2str(id) '/data/lab syl' num2str(id)]);

% use HCompV to get the global variance vector
mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','hmm0flat')) ;
system(['HCompV -A -T 1 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat -H ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) ' -f 0.01 syl' num2str(id)]);
% make a macros file to be used later
% find the parameter target kind and vector size in analysis.conf
[status, output] = system(['grep -E *VecSize* ' rootdir '/hmmprototype/hmmproto']) ;
fidmacros = fopen(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model','hmm0flat','macros'),'w') ;
fprintf(fidmacros,'~o %s',output) ;
fclose(fidmacros) ;
system(['cat ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/vFloors >> ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/macros']) ;

% training, re-estimation using Baum-Welch
for itera=1:10
	[s,mess,messid] = mkdir(fullfile(rootdir,'hmms',['HMM' num2str(id)],'model',['hmm' num2str(itera)])) ;
	system(['HRest -A -T 1 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera) ' -H ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/macros -H ' rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera-1) '/hmm' num2str(id) ' -l syl' num2str(id) ' -L ' rootdir '/hmms/HMM' num2str(id) '/data/lab syl' num2str(id)]);
end
