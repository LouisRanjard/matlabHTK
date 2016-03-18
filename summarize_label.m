function [] = summarize_label(dirna,wavfile,binsiz)
% merge several label file from a directory
% need to have the wav files in the same directory (to get the Fs)
% binsiz: size of the bins to compare the two textgrid files in seconds
% example: 
% summarize_label('/home/louis/share/Ivan/summary','/home/louis/share/Ivan/summary/Ten_minutes_file_to_test_14_09_2015_5sp_ANU.wav',1)

    if nargin<3
        % choose bin size in seconds
        binsiz = 0.1 ;
    end
    
    if is_octave()
        [y, Fs] = wavread(wavfile) ;
    else
        [y, Fs] = audioread(wavfile) ;
    end
    
    labfiles = dir(fullfile(dirna,'*.label')) ;
    % check wav files found
    if isempty(labfiles)==1 
        fprintf(1,'No label file found in %s\n',dirna); return
    end
    
    % check that sizes are consistent
    
    % collect each file annotation label for each time bin
    uniklabel=[]; % store all label codes encountered
    countlab=cell(1,numel(labfiles)) ; % store all countlab matrices
    labelset=cell(1,numel(labfiles)) ; % store all label codes
    annotlabel=cell(1,numel(labfiles)) ; % store all text label encountered
    for lf=1:numel(labfiles)
        % create song structures
        tmp=regexprep(labfiles(lf).name(end:-1:1),'lebal.','flm.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
        label2mlf( fullfile(dirna,labfiles(lf).name), fullfile(dirna,tmp) ) ;
        song = mlf2song( fullfile(dirna,tmp), [], 3, 0, 0, 0, 0, Fs) ;
        % create tables to use the comparison process
        syltable = song2table(song) ;
        [countlab{lf}, labelset{lf}] = syltable_bins(syltable,binsiz,Fs,length(y)) ;
        uniklabel = unique(union(uniklabel,labelset{lf})) ;
        annotlabel{lf} = cell(1,length(labelset{lf})) ;
        for l=1:length(labelset{lf})
            idlabtext = find(song.sequence==labelset{lf}(l),1) ;
            if numel(idlabtext)>0
                annotlabel{lf}{l} = song.sequencetxt{idlabtext} ;
            end
        end
    end
    
    % for each time bin check consistency between annotation label files
    % output a new sequence
    outseq = cell(1,size(countlab{1},1)) ;
    for t=1:size(countlab{1},1)
        recoglab = cell(1,numel(labfiles)) ;
        for l=1:numel(labfiles)
            % find label with maximum length
            [~,I] = max(countlab{l}(t,:)) ;
            recoglab(l) = annotlabel{l}(I) ;
        end
        recoglab = unique(recoglab) ;
        nnoise = numel(find(strcmp(recoglab,'noise'))) ;
        nbackground = numel(find(strcmp(recoglab,'background'))) ;
        nother_sb = numel(find(strcmp(recoglab,'other_sb'))) ;
        nseabird = numel(recoglab)-(nnoise+nbackground+nother_sb) ;
        if numel(recoglab)==1
            outseq{t} = recoglab{1} ;
        elseif nbackground>0
            if nnoise>0
                outseq{t} = 'noise' ;
            elseif nseabird>=2
                outseq{t} = 'other_sb' ;
            else 
                outseq{t} = 'background' ;
            end
        elseif nnoise>0
            outseq{t} = 'noise' ;
        elseif nother_sb==1 && nseabird==1
            outseq{t} = recoglab{setdiff(1:numel(recoglab),find(strcmp(recoglab,'other_sb')))} ;
        elseif numel(recoglab)>=3
            outseq{t} = 'other_sb' ;
        end
    end
    
    % convert to label file while merging
    fid = fopen(fullfile(dirna,'summarized.label'),'w') ;
    t = 1 ;
    while (t+1)<=size(outseq,2)
        current_label = outseq{t} ;
        fprintf(fid,'%f\t',(t-1)*binsiz) ;
        while t<=size(outseq,2) && strcmp(current_label,outseq{t}) 
            t=t+1 ;
        end
        fprintf(fid,'%f\t%s\n',(t-1)*binsiz,current_label) ;
    end
    fclose(fid) ;
    