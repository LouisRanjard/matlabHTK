function [ song ] = reencode_song(song,nsample,id,convseq)
% reencode the song sequences, adding a boundary syllable of size nsample
% the id of this syllable is "id"

if nargin<2
	nsample=512;
	id=0;
	convseq=1;
end

for sg=1:numel(song)
	%fprintf(1,'%s\n',song(sg).filename);
	sy = 1 ;
	if convseq==1
		% convert the sequence into a "1" sequences, thus all syllable have the same id
		song(sg).sequence = (song(sg).sequence.*0)+1 ;
	end
	while sy<=numel(song(sg).SyllableS)
		if (song(sg).SyllableE(sy)-song(sg).SyllableS(sy))<=nsample % not enough room to fit a boundary syllable
			sy = sy+1 ;
			continue ;
		end
		% add a boundary before
		endlast = (sy>1)*song(sg).SyllableE(sy-1*(sy>1)) ; % end of the last syllable (0 if it is the first)
		if (song(sg).SyllableS(sy)-endlast)>(nsample/2) % is there enough room to add a syllable before?
			%fprintf(1,'%i S\n',sy);
			newbound1 = song(sg).SyllableS(sy)-(nsample/2);
			newbound2 = song(sg).SyllableS(sy)+(nsample/2);
			song(sg).SyllableS = [song(sg).SyllableS(1:sy-1) newbound1 newbound2 song(sg).SyllableS(sy+1:end)];
			song(sg).SyllableE = [song(sg).SyllableE(1:sy-1) newbound2 song(sg).SyllableE(sy:end)];
			song(sg).sequence = [song(sg).sequence(1:sy-1) id song(sg).sequence(sy:end)];
			sy = sy+1 ;
		end
		% add a boundary after
		if sy<numel(song(sg).SyllableE) % do not use the last noise chunk at the end of the songs because we don't know if there is enough room after
			if song(sg).SyllableS(sy+1)-song(sg).SyllableE(sy)>(nsample/2) % check if there is enough room after
				%fprintf(1,'%i E\n',sy);
				newbound1 = song(sg).SyllableE(sy)-(nsample/2);
				newbound2 = song(sg).SyllableE(sy)+(nsample/2);
				song(sg).SyllableS = [song(sg).SyllableS(1:sy) newbound1 song(sg).SyllableS(sy+1:end)];
				song(sg).SyllableE = [song(sg).SyllableE(1:sy-1) newbound1 newbound2 song(sg).SyllableE(sy+1:end)];
				song(sg).sequence = [song(sg).sequence(1:sy) id song(sg).sequence(sy+1:end)];
				sy = sy+1 ;
			end
		end
		sy = sy+1 ;
	end
end
