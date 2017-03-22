function [similarity, pval] = compare_label(filename1,filename2,binsiz,N,deletetmpfile)
% compare two LABEL files
% need to have the wav files in the same directory (to get the Fs)
% if N provided build a null distribution of similarity using N random countlab matrices
% binsiz: size of the bins to compare the two textgrid files in seconds
% example: [similarity] = compare_label('/Sounds/Todd_files/Todd_Meeting_23JAN10/manual_annotation/end_of_01_manual_annotation.label','/Sounds/Todd_files/Todd_Meeting_23JAN10/test_quackass_window100ms/end_of_01_manual_annotation.label');

    if nargin<5
        deletetmpfile=1 ;
        if nargin<4
            pval=NaN;
            N=0;
            if nargin<3
                % choose bin size in seconds
                binsiz = 30 ;
            end
        end
    end

    % get the Fs
    tmp1=regexprep(filename1(end:-1:1),'lebal.','vaw.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    tmp2=regexprep(filename2(end:-1:1),'lebal.','vaw.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
    if exist(tmp1, 'file')==2
        if is_octave()
            [y1, Fs1] = wavread(tmp1) ;
        else
            [y1, Fs1] = audioread(tmp1) ;
        end
        length1 = length(y1) ;
    end
    if exist(tmp2, 'file')==2
        if is_octave()
            [y2, Fs2] = wavread(tmp2) ;
        else
            [y2, Fs2] = audioread(tmp2) ;
        end
        length2 = length(y2) ;
    end
    if (exist(tmp1, 'file')==2) && (exist(tmp2, 'file')==2)
        if Fs1~=Fs2
            error('compare_label(): sampling frequencies are different');
        else
            Fs=Fs1;
        end
    elseif exist(tmp1, 'file')==2
        Fs=Fs1;
        length2=length1;
    elseif exist(tmp2, 'file')==2
        Fs=Fs2;
        length1=length2;
    end

    % check if Fs was found
    if exist('Fs','var')==0
        error('compare_label(): need both .label and .wav files in the same directory');
    end
    
    % create song structures
    tmp1=regexprep(filename1(end:-1:1),'lebal.','flm.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    if exist(tmp1, 'file')==0
      label2mlf( filename1, tmp1 ) ;
    end
    song1 = mlf2song( tmp1, [], 3, 0, 0, 0, 0, Fs) ;

    tmp2=regexprep(filename2(end:-1:1),'lebal.','flm.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
    if exist(tmp2, 'file')==0
      label2mlf( filename2, tmp2 ) ;
    end
    song2 = mlf2song( tmp2, [], 3, 0, 0, 0, 0, Fs) ;

    % check for compatibility between the songs, need exactly the same syllable types, if not add zero length syllables at the beginning
    for missing1 = setdiff( unique(song2.sequence),unique(song1.sequence) )
        song1.sequence = [ missing1 song1.sequence ] ;
        song1.sequencetxt = [ song2.sequencetxt(find(song2.sequence==missing1,1,'first')) song1.sequencetxt ] ;
        song1.SyllableS = [ 0 song1.SyllableS ] ;
        song1.SyllableE = [ 0 song1.SyllableE ] ;
    end
    for missing2 = setdiff( unique(song1.sequence),unique(song2.sequence) )
        song2.sequence = [ missing2 song2.sequence ] ;
        song2.sequencetxt = [ song1.sequencetxt(find(song1.sequence==missing2,1,'first')) song2.sequencetxt ] ;
        song2.SyllableS = [ 0 song2.SyllableS ] ;
        song2.SyllableE = [ 0 song2.SyllableE ] ;
    end
    
    % create tables to use in the comparison process
    syltable1 = song2table(song1) ;
    [countlab1, uniklabel1] = syltable_bins(syltable1,binsiz,Fs,length1(1)) ;

    syltable2 = song2table(song2) ;
    [countlab2, uniklabel2] = syltable_bins(syltable2,binsiz,Fs,length2(1)) ;

    % check conversion has been okay (allows 0.01 error)
    if sum( (sum(countlab1,2)>binsiz*1.01 | sum(countlab1,2)<binsiz*0.99)>0 )
        error('conversion problem on file 1');
    end
    if sum( (sum(countlab2,2)>binsiz*1.01 | sum(countlab2,2)<binsiz*0.99)>0 )
        error('conversion problem on file 2');
    end
    
    % check label are matching
    if sum(uniklabel1-uniklabel2)~=0, error('conversion problem syltable_bins()'); end

    % compute similarity
    similarity = simcountlab(countlab1,countlab2,binsiz) ;
    fprintf(1,'similarity = %.2f%%\n',similarity*100) ;

    % create confusion matrix
    cmat = confusionmatrix(countlab1,countlab2,uniklabel1) ;
    % discard first label which is 0 inserted by song2table for gaps between annotated sounds
    if (uniklabel1(1)==0)
        codelabel = uniklabel1(2:end) ;
        cmat = cmat(2:end,2:end) ;
    end
    % discard first label which is "0" (code 48) for sounds annotated as "0" by HTK
    % COMMENTED: need to be kept as some true annotation in one file may be label such as in the second
    %if (uniklabel1(1)==48)
    %    codelabel = uniklabel1(2:end) ;
    %    cmat = cmat(2:end,2:end) ;
    %end
    % get the character annotation labels
    annotlabel = cell(1,length(codelabel)) ;
    for l=1:length(codelabel)
        annotlabel{l} = song1.sequencetxt{find(song1.sequence==codelabel(l),1)} ;
    end
    % write to file
    outid = fopen([filename2 '_confusion.csv'], 'w+');
    [~,f1]=fileparts(filename1);
    [~,f2]=fileparts(filename2);
    %[ repmat({f2},1,numel(annotlabel)); annotlabel ]
    fprintf(outid, ',,');
    for i = 1:length(annotlabel)
        fprintf(outid, '%s,', f2); % the second filename annotation is in column
    end
    fprintf(outid, '\n,,');
    for i = 1:length(annotlabel)
        fprintf(outid, '%s,', annotlabel{i});
    end
    fprintf(outid, '\n');
    for i = 1:length(annotlabel)
        fprintf(outid, '%s,%s,', f1, annotlabel{i});
        for j = 1:length(annotlabel)
            fprintf(outid, '%f,', cmat(i,j));
        end
        fprintf(outid, '\n');
    end
    fclose(outid);
    %dlmwrite([filename2 '_confusion.csv'],cmat,'roffset',1,'-append') ;
    %T = table(cmat,'RowNames',annotlabel) ;
    %writetable(T,[filename2 '.csv'],'WriteRowNames',true) ;
    
    % do randomization test?
    if N>0
        nullsim = zeros(1,N) ;
        for permut=1:N
            % randomly shuffle the second matrix
            cntlabrand  =zeros(size(countlab2,1),size(countlab2,2)) ;
            for size1=1:size(countlab2,1)
                cntlabrand(size1,:) = countlab2(size1,randperm(size(countlab2,2))) ;
            end
            % randomly permute the rows and columns of the second matrix
            % cntlabrand = countlab2(randperm(size(countlab2,1)),randperm(size(countlab2,2))) ;
            % randomly fill up a new matrix
%             cntlabrand = rand(size(countlab2,1),size(countlab2,2)) ;
%             cntlabrand = cntlabrand ./ repmat(sum(cntlabrand,2),1,size(countlab2,2)) ;
%             cntlabrand = cntlabrand.*binsiz ;
            % compute the similarity score with the random matrix
            nullsim(permut) = simcountlab(countlab1,cntlabrand,binsiz) ;
        end
        % pvalue computated with alpha=5%
        pval = sum(nullsim>=similarity)/N ;
        fprintf(1,'p-value = %.4f (%.0f random permutations, mean=%.2f%%)\n',pval,N,mean(nullsim)*100) ;
    end
    
    %% clean up
    if deletetmpfile
      delete(tmp1) ;
      delete(tmp2) ;
    end
    
    
    %% Private functions
    
    function [simscore] = simcountlab(cntlab1,cntlab2,binsiz)
        % euclidean distance of each row vector
        %eucldist = sqrt( sum( (cntlab1(:,2:end)-cntlab2(:,2:end)).^2 ,2) ) ;
        eucldist = ( sum((cntlab1(:,2:end)-cntlab2(:,2:end)).^2 ,2) ).^(1/2) ;
        % divide each euclidean distance by the maximum distance possible which is the size of the bin times two
        simscore = 1 - (sum(eucldist)/numel(eucldist))/(binsiz*2) ;
    end

    function [cmat] = confusionmatrix(cntlab1,cntlab2,uniklabel)
        % compute confusion matrix, the first table is considered the
        % reference, give the percentage of each annotation being
        % recognised as each possible annotation
        cmat=zeros(length(uniklabel));
        labsum=zeros(1,length(uniklabel)); % record the total number of annotation for each label in the reference
        % for each time bin, find the most common annotation in each label
        % table
        for tb=1:size(cntlab1,1)
            [~,lab1] = max(cntlab1(tb,:)) ;
            labsum(lab1) =  labsum(lab1) + 1 ;
            [~,lab2] = max(cntlab2(tb,:)) ;
            cmat(lab1,lab2) = cmat(lab1,lab2) + 1 ;
        end
        % divide each annotation by the total time in the reference
        for lab=1:length(uniklabel)
            if labsum(lab)>0
                cmat(lab,:) = cmat(lab,:)/labsum(lab) ;
            end
        end
    end

end
