function [countlab uniklabel numlabel] = syltable_bins(syltable,binsiz,Fs,lengthy)
% syltable is the output of song2table()
% binsiz is that size of the bin in seconds
% Fs is the sampling frequency in Hz
% lengthy is the total length of the recording in samples

    % convert in seconds
    syltable(:,1) = syltable(:,1)/Fs ;

    % find the different labels and sort
    uniklabel = sort(unique(syltable(:,2))) ;

    % sum by bins
    numbins = ceil((lengthy/Fs)/binsiz) ;
    numlabel = numel(uniklabel) ;
    countlab = zeros(numbins,numlabel) ;
    for nbins=1:numbins
        for currlabel = 1:numlabel
            % index of the segments starting in the current time bins with the current label
            idx = find(syltable(:,1)>=(nbins-1)*binsiz & syltable(:,1)<nbins*binsiz & syltable(:,2)==uniklabel(currlabel)) ;
            % need to check the last segment of the previous time bin
            if nbins>1
                lastone = find(syltable(:,1)<(nbins-1)*binsiz,1,'last') ;
                if syltable(lastone,2)==uniklabel(currlabel)
                    idx = [lastone; idx] ;
                end
            end
            % count the duration of each label
            idxl = zeros(1,numel(idx)) ;
            for n=1:numel(idx)
                if idx(n)<size(syltable,1)
                    idxl(n) = min(nbins*binsiz,syltable(min(idx(n)+1,size(syltable,1)),1))...
                              - max((nbins-1)*binsiz,syltable(idx(n),1)) ;
                else
                    idxl(n) = nbins*binsiz - max((nbins-1)*binsiz,syltable(idx(n),1)) ;
                end
            end
            countlab(nbins,currlabel) = sum( idxl ) ;
        end
    end
    
end
