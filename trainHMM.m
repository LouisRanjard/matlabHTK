function [] = trainHMM( song, rootdir, id, protofile, macrofile )
% allows to specify a specific prototype "protofile" file in the subdir "rootdir/hmmprototype/"
% also allows to use a macro file "rootdir/hmmprototype/macrofile"

if nargin<5
	macrofile = '' ;
	macrofilec = '' ;
else
	macrofilec = [' -H ' rootdir '/hmmprototype/' macrofile] ;
end

% create the HMM prototype and train it
system(['cp ' rootdir '/hmmprototype/' protofile ' ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_']) ; % copy the appropriate prototype
% setstr(39) is ASCII code for single quote "'"
% replace the "" at the beginning of the protofile by "syl+id"
system(['sed ' setstr(39) 's/""/"syl' num2str(id) '"/g' setstr(39) ' ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_ > ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id)]) ; % change the name for this particular hmm
system(['rm -f ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) '_']) ;

% initialise the HMM parameters
mkdir([rootdir '/hmms/HMM' num2str(id) '/model/hmm0']) ;
system(['HInit -A -T 2 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0' macrofilec ' -H ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) ' -l syl' num2str(id) ' -L ' rootdir '/hmms/HMM' num2str(id) '/data/lab syl' num2str(id)]);

% use HCompV to get the global floor variance vector
mkdir([rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat']) ;
system(['HCompV -A -T 1 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat' macrofilec ' -H ' rootdir '/hmms/HMM' num2str(id) '/model/proto/hmm' num2str(id) ' -f 0.01 syl' num2str(id)]);
% make a macros file to be used later
% find the parameter target kind and vector size in analysis.conf
[status, output] = system(['grep -E *VecSize* ' rootdir '/hmmprototype/' protofile]) ;
fidmacros = fopen([rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/macros'],'w') ;
fprintf(fidmacros,'~o %s',output) ;
fclose(fidmacros) ;
system(['cat ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/vFloors >> ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/macros']) ;

% training, re-estimation using Baum-Welch
for itera=1:10
	mkdir([rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera)]) ;
	macrofilec = [' -H ' rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera-1) '/' macrofile] ;
	system(['HRest -A -T 1 -S ' rootdir '/hmms/HMM' num2str(id) '/model/trainlist.txt -M ' rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera) macrofilec ' -H ' rootdir '/hmms/HMM' num2str(id) '/model/hmm0flat/macros -H ' rootdir '/hmms/HMM' num2str(id) '/model/hmm' num2str(itera-1) '/hmm' num2str(id) ' -l syl' num2str(id) ' -L ' rootdir '/hmms/HMM' num2str(id) '/data/lab syl' num2str(id)]);
end
