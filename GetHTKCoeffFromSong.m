function [syllab] = GetHTKCoeffFromSong(song,filena,analysisdir,htkdir,filtering,normavec)
% 
% song is the song datastructure to extract the syllables from
% filena is the syllab.mat datastructure file to save the syllab in
% analysisdir contains 1 or more configuration files for HCopy
% htkdir i sthe path to the HTK directory containing the HTK tools
% if filtering==1, then wavelet filtering is applied
% if normavec, then each coefficient (or group of coeff) is normalised so that it scales from 0 to 1
%
% example:
% load('/home/louis/Sounds/Tieke/K_01_2007/allpart/songs');
% [syllab] = GetHTKCoeffFromSong(song,'/home/louis/Sounds/Tieke/K_01_2007/allpart/syllab.mat','~/htk/config','/usr/local/bin/',);

if nargin<5, filtering=0; end
if numel(filtering)==0, filtering=0; end

syllab = [] ;

if isdir(fullfile(analysisdir))
    conffiles = dir(fullfile(analysisdir,'*')) ;
else
    conffiles = analysisdir;
end

for sg=1:numel(song)
    %[status, filename] = system(['locate -n1 -r ?*/' song(sg).filename '$']);
    filename = which(song(sg).filename);
    if numel(strfind(filename,song(sg).filename)==1)
	%fprintf('%s\n',song(sg).filename);
	%filename=filename(1:end-1) ; % remove the \n at the end
        [ y ] = wavread(filename);
        y = reshape(y,1,[]) ; % make sure the first dimension is 1
                  % DeNoise the whole recording
%                 QMF = MakeONFilter('Daubechies',8);
%                 scaledsong  = NormNoise(y,QMF);
%                 % find the difference between the song length and the closest factor of 2 number
%                 dif2 = 2^(ceil(log2(length(scaledsong))))-length(scaledsong) ;
%                 scaledsong = [ scaledsong zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
%                 [sylsig,wcoef] = WaveShrink(scaledsong,'Visu',5,QMF);
%                 y = sylsig(1:end-dif2) ;
        m = 1 ; % index of syllables for this particular song
        for k = (length(syllab)+1) : (length(syllab)+length(song(sg).SyllableS))
            seqvect = [] ;
            sylfilename0 = fullfile('/tmp','/syltmp.wav') ;
            sylfilename1 = fullfile('/tmp','/syltmp.coeff') ;
            sylsig = y(floor(song(sg).SyllableS(m)):floor(song(sg).SyllableE(m))) ;
            % FILTERING
            if filtering>0
                % Wavelet DeNoising
                % USING WaveShrink
                % QMF = MakeONFilter('Symmlet',8);
                % QMF = MakeONFilter('Daubechies',20);
                % QMF = MakeONFilter('Haar',8);
%                 QMF = MakeONFilter('Daubechies',8);
%                 scaledsong  = NormNoise(sylsig,QMF);
%                 % find the difference between the song length and the closest factor of 2 number
%                 dif2 = 2^(ceil(log2(length(scaledsong))))-length(scaledsong) ;
%                 scaledsong = [ scaledsong zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
%                 [sylsig,wcoef] = WaveShrink(scaledsong,'Visu',5,QMF);
%                 sylsig = sylsig(1:end-dif2) ;
                % USING CohWave
%                 longueur = length(sylsig) ;
%                 sylsig = CohWave([reshape(sylsig,1,[]) zeros(1,2^ceil(log2(length(sylsig)))-length(sylsig))],5,MakeONFilter('Beylkin'));
%                 sylsig = sylsig(1:longueur) ;
                % USING WPDeNoise coiflet
%                 dif2 = 2^(ceil(log2(length(sylsig))))-length(sylsig) ;
%                 scaledsong = [ sylsig zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
%                 D = 5;
%                 QCoif8 = MakeONFilter('Coiflet',8);
%                 sylsig = WPDeNoise(scaledsong,D,QCoif8);
                % USING WPDeNoise daubechies
%                 QMF = MakeONFilter('Daubechies',8);
%                 sylsig  = NormNoise(sylsig,QMF);
%                 dif2 = 2^(ceil(log2(length(sylsig))))-length(sylsig) ;
%                 scaledsong = [ sylsig zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
%                 D = 5;
%                 sylsig = WPDeNoise(scaledsong,D,QMF);
                 %sylsig = CPDeNoise(scaledsong,D,'Sine');
                % USING Short Course 28: Robust De-Noising
%                 dif2 = 2^(ceil(log2(length(sylsig))))-length(sylsig) ;
%                 scaledsong = [ sylsig zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
%                 wc = FHT_Med(scaledsong);
%                 wc(triad(6)) = 0 .* wc(triad(6)) ;
%                 sylsig = IHT_Med(wc);
                % USING wavelet thresholding
                dif2 = 2^(ceil(log2(length(sylsig))))-length(sylsig) ;
                scaledsong = [ sylsig zeros(1,dif2) ] ; % watch out scaledsong length must be a power of 2
                sylsig = ThreshWave(scaledsong) ;
            end
            wavwrite(sylsig,44100,16,sylfilename0) ;
            % ENCODE WITH HTK CONFIG FILES
            for cff=1:numel(conffiles)
                if isdir(fullfile(analysisdir,conffiles(cff).name)), continue; end % avoid directories (. ..)
                % USING HTK TO GET THE COEFF
                %system([fullfile(htkdir,'HCopy') ' -A -C ' fullfile(analysisdir,conffiles(cff).name) ' ' sylfilename0 ' ' sylfilename1]) ;
                system([fullfile(htkdir,'HCopy') ' -C ' fullfile(analysisdir,conffiles(cff).name) ' ' sylfilename0 ' ' sylfilename1]) ; % same but suppress output
                [coeffseq,fp] = readhtk(sylfilename1) ;
                seqvect = [seqvect coeffseq]; % matrix transposed with readhtk (compared to readmfcc)
                delete(sylfilename1) ;
            end
            % NORMALISE EACH COEFF
            if nargin>5
                % normalise from 0 to 1 according to a vector giving the structure, e.g. [1 12; 13 13; 14 25]
                seqvect = norma_seqvect(seqvect',normavec) ; % NEED TO TRANSPOSE THE MATRIX
            end
            syllab(k).seqvect = seqvect' ;
            delete(sylfilename0) ;
            m = m+1 ;
        end
	else
		fprintf('file not found %s\n',song(sg).filename);
    end
    % save( [filena '.tmp'] , 'syllab' ) ;
end

% check if it is required to transpose the matrices, DTWaverage needs the time in the second dimension
tmp = struct2cell(syllab) ;
sizdim1 = cellfun(@(x) size(x,1),tmp) ;
if var(sizdim1)>0 % transpose every matrices
    tmp = cellfun(@(x) x',tmp,'UniformOutput',false) ;
end
syllab = cell2struct(tmp,'seqvect') ;

% normalization (no need, HTK performs E normalisation)
%syllab = cell2struct( cellfun(@(x) norma(x,0,1),{syllab.htkmfcc}, 'UniformOutput', false) , 'htkmfcc' , 1 )' ;
if numel(filena)>0
    save( '-v7', filena , 'syllab' ) ;
end

