function [] = song2textGrid( song, filename2, modd )
% read a song file
% write a TEXTGRID file readable in PRAAT
% if modd==1, use song.sequence
% elseif modd==2, use song.sequencetxt (cells)

if nargin<3, modd=1; end

fid2 = fopen(filename2,'w') ;

numsyl = 1 ; % count the number of syl
seglist = '' ; % store the string containaing all the segments

% need to find the total length of the song file
%[status, filename] = system(['locate -n1 -r ?*/' song.filename '$']);
%if numel(strfind(filename,song.filename)==1)
%        filename=filename(1:end-1) ; %remove the \n at the end
%else
%	 error('file not found, please give the directory path (might need to update the database for locate)');
filename = which(song.filename);
if numel(strfind(filename,song.filename))==0
        error(['file not found ' song.filename ':' filename]);
end
fprintf(1,filename);
siz = wavread(filename,'size') ;
% need to get the Fs from the wav file
[~, Fs] = wavread(filename,1); % only read the first sample

maxlen = siz(1)/Fs ;

for nsyl=1:numel(song.SyllableS)
    % first insert the gap before the syllable; if there is a gap between two syllables it will insert a gap labelled "0" in the TextGrid file
    if nsyl>1, a = song.SyllableE(nsyl-1); else a = 1 ; end
    b = song.SyllableS(nsyl) ;
    if b>a
        c = '0' ;
        seglist = [seglist sprintf('\t\tintervals [%i]:\n\t\t\txmin = %f\n\t\t\txmax = %f\n\t\t\ttext = "%s"\n',numsyl,a/Fs,b/Fs,char(c)')] ;
        numsyl = numsyl + 1 ;
    end
    % second insert the actual syllable
    a = song.SyllableS(nsyl) ;
    b = song.SyllableE(nsyl) ;
    %c = '1' ;
    if modd==1
        c = num2str(song.sequence(nsyl)) ;
        c = char(c)' ;
    elseif modd==2
        c = song.sequencetxt{nsyl} ;
    end
    % add the time in hour:minute:second format as a comment
    seglist = [seglist sprintf('\t\tintervals [%i]:\n\t\t\txmin = %f :%s\n\t\t\txmax = %f :%s\n\t\t\ttext = "%s"\n',...
        numsyl, a/Fs,...
        msecondtostring(a*1000/Fs),...
        b/Fs,...
        msecondtostring(b*1000/Fs),...
        c)] ;
    numsyl = numsyl + 1 ;
    % add the last gap if reached end
    if nsyl==numel(song.SyllableS) && b<siz(1)
        a = b ;
        b = siz(1) ;
        c = '0' ;
        seglist = [seglist sprintf('\t\tintervals [%i]:\n\t\t\txmin = %f\n\t\t\txmax = %f\n\t\t\ttext = "%s"\n',numsyl,a/Fs,b/Fs,char(c)')] ;
        numsyl = numsyl + 1 ;
    end
end

% write the header to the file, knowing the number of syl NUMSYL and the max length MAXLEN
fprintf(fid2,'File type = "ooTextFile"\nObject class = "TextGrid"\n\nxmin = 0\nxmax = %s\ntiers? <exists>\nsize = 1\nitem []:\n    item [1]:\n        class = "IntervalTier"\n        name = "syl"\n        xmin = 0\n        xmax = %s\n        intervals: size = %g\n',num2str(maxlen),num2str(maxlen),numsyl-1) ;
fprintf(fid2,seglist) ;

fclose(fid2) ;

end
