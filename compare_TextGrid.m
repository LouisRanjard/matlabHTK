function [similarity] = compare_TextGrid(filename1,filename2,binsiz,N)
% compare two TextGrid files
% need to have the wav files in the same directory (to get the Fs)
% if N provided build a null distribution of similarity using N random countlab matrices
% binsiz: size of the bins to compare the two textgrid files in seconds
% example: [similarity] = compare_TextGrid('/Sounds/Todd_files/Todd_Meeting_23JAN10/manual_annotation/end_of_01_manual_annotation.TextGrid','/Sounds/Todd_files/Todd_Meeting_23JAN10/test_quackass_window100ms/end_of_01_manual_annotation.TextGrid');

    if nargin<3
        % choose bin size in seconds
        binsiz = 30 ;
    end

    % get the Fs
    tmp1=regexprep(filename1(end:-1:1),'dirGtxeT.','vaw.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    [y1, Fs1] = wavread(tmp1,1) ;
    length1 = wavread(tmp1,'size') ;
    tmp2=regexprep(filename2(end:-1:1),'dirGtxeT.','vaw.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
    [y2, Fs2] = wavread(tmp2,1) ;
    length2 = wavread(tmp2,'size') ;
    if Fs1~=Fs2
        error('sampling frequencies are different');
    else
        Fs=Fs1;
    end

    % create song structures
    tmp1=regexprep(filename1(end:-1:1),'dirGtxeT.','flm.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    textGrid2mlf( filename1, tmp1 ) ;
    song1 = mlf2song( tmp1, [], 3) ;

    tmp2=regexprep(filename2(end:-1:1),'dirGtxeT.','flm.','once');tmp2=tmp2(end:-1:1); % allows to replace just once, the last one
    textGrid2mlf( filename2, tmp2 ) ;
    song2 = mlf2song( tmp2, [], 3) ;

    % check for compatibility between the songs, need exactly the same syllable types, if not add zero length syllables at the end
    for missing = setdiff( unique(song2.sequence),unique(song1.sequence) )
        song1.sequence = [song1.sequence missing] ;
        song1.sequencetxt = [song1.sequencetxt song2.sequencetxt(find(song2.sequence==missing,1,'first')) ] ;
        song1.SyllableS = [song1.SyllableS song1.SyllableE(end)] ;
        song1.SyllableE = [song1.SyllableE song1.SyllableE(end)] ;
    end
    for missing = setdiff( unique(song1.sequence),unique(song2.sequence) )
        song2.sequence = [song2.sequence missing] ;
        song2.sequencetxt = [song2.sequencetxt song1.sequencetxt(find(song1.sequence==missing,1,'first')) ] ;
        song2.SyllableS = [song2.SyllableS song2.SyllableE(end)] ;
        song2.SyllableE = [song2.SyllableE song2.SyllableE(end)] ;
    end
    
    % create tables to use the comparison process
    syltable1 = song2table(song1) ;
    countlab1 = syltable_bins(syltable1,binsiz,Fs,length1(1)) ;

    syltable2 = song2table(song2) ;
    countlab2 = syltable_bins(syltable2,binsiz,Fs,length2(1)) ;

    % check conversion has been okay (allows 0.01 error)
    if sum( (sum(countlab1,2)>binsiz*1.01 | sum(countlab1,2)<binsiz*0.99)>0 )
        error('conversion problem on file 1');
    end
    if sum( (sum(countlab2,2)>binsiz*1.01 | sum(countlab2,2)<binsiz*0.99)>0 )
        error('conversion problem on file 2');
    end

    similarity = simcountlab(countlab1,countlab2,binsiz) ;
    fprintf(1,'similarity = %.2f%%\n',similarity*100) ;

    % do randomization test?
    if nargin>3
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
        fprintf(1,'p-value = %.4f (%.0f random permutations, mean=%.2f%%)\n',sum(nullsim>=similarity)/N,N,mean(nullsim)*100) ;
    end
    
    function [simscore] = simcountlab(cntlab1,cntlab2,binsiz)
        % euclidean distance of each row vector
        %eucldist = sqrt( sum( (cntlab1(:,2:end)-cntlab2(:,2:end)).^2 ,2) ) ;
        eucldist = ( sum( (cntlab1(:,2:end)-cntlab2(:,2:end)).^2 ,2) ) .^ (1/2) ;
        % divide each euclidean distance by the maximum distance possible which is the size of the bin times two
        simscore = 1 - (sum(eucldist)/numel(eucldist))/(binsiz*2) ;
    end

end
