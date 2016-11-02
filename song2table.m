function outtable = song2table(song)
% convert a song with SyllableS, SyllableE and sequence to a table (considering the gaps)
% first column: the time of start of the time interval
% second column: the sequence ID of the interval i.e.  song.sequence(i) if annotated, otherwise 0 

% find the intervals between the annotated syllables
diffSE = [song.SyllableS 0]-[0 song.SyllableE] ;
totinter = numel(song.SyllableS) + sum(diffSE>0) ;
outtable = zeros(totinter,2) ;

numsyl = 1 ; % count the number of syl

for nsyl=1:numel(song.SyllableS)
    
    % is there a gap before this syllable?
    if diffSE(nsyl)>0
        % watch out the first syllable
        if nsyl>1
            outtable(numsyl,:) = [song.SyllableE(nsyl-1) 0] ;
        else
            outtable(numsyl,:) = [0 0] ;
        end
        numsyl = numsyl + 1 ;
    end
        
    outtable(numsyl,:) = [song.SyllableS(nsyl) song.sequence(nsyl)] ;
    numsyl = numsyl + 1 ;
    
end
%fprintf(1,'song2table finishes');
