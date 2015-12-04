function [song] = song_fill_seq(song,uniksequencetxt,modd)
% fill up the song.sequence or song.sequencetxt structure according to the table uniksequencetxt
% modd indicates which to fill up:
%    1_ fill up song.sequence
%    2_ fill up song.sequencetxt

switch modd
    case 1
        for n=1:numel(song)
            song(n).sequence=[] ;
            for b=1:size(song(n).sequencetxt,2)
                for c=1:size(uniksequencetxt,2)
                    if strcmp(song(n).sequencetxt(b),uniksequencetxt(c))
                        song(n).sequence = [song(n).sequence c] ;
                    end
                end
            end
        end
    case 2
        for n=1:numel(song)
            song(n).sequencetxt={} ;
            for b=1:size(song(n).sequence,2)
                song(n).sequencetxt{b} = uniksequencetxt{song(n).sequence(b)} ;
            end
        end
end
