function dopwdist(filena1,htkdir)
% filena1: path to song.mat matlab data file
% htkdir: path to a directory containing the HTK tools

%%% get a song.mat file
if nargin>0 && numel(filena1>0)
    load(filena1) ;
    [pathstr] = fileparts(filena1) ;
elseif ~exist('song','var') 
    if usejava('desktop') % the desktop is available
        [filena1,pathstr] = uigetfile('','Select a songs.mat file') ;
        cd(pathstr) ;
        load(fullfile(pathstr,filena1)) ;
    end
end

if ~exist('song','var')
    error('song data is missing') ;
end

% if exist(fullfile(pathstr,'syllables.mat'),'file')
%     load(fullfile(pathstr,'syllables.mat')) ;
% else
    %%% get the parameters for syllable encoding
    %%% ASK USER
    % if nargin<2
    %     if usejava('desktop') % the desktop is available
    %         configdf = uigetfile(pathstr,'Select a configuration file') ;
    %     end
    % end
    % if ~exist('configdf','var')
    %     error('no configuration file(s) provided') ;
    % end
    %%% AUTOMATICALLY CREATE CONFIGURATION FILES
    % created in pathstr/analysis/config
    createcffiledist(pathstr,'analysis_dist') ;
    %%% encode the syllables
    syllab = GetHTKCoeffFromSong(song,fullfile(pathstr,'analysis_dist','syllables_dist.mat'),fullfile(pathstr,'analysis_dist'),htkdir) ;
% end

%%% compute the distances
%dmat = dsyllmat( syllab, 'seqvect', 'DTWaverage', fullfile(pathstr,'syllable_distances.mat') ) ;
dmat = dsyllmat( syllab, 'seqvect', 'DTWaverage3', fullfile(pathstr,'analysis_dist','syllable_distances.mat') ) ; % use D_euclid^2
WriteDistanceNexus( dmat, fullfile(pathstr,'analysis_dist','syllable_distances.nex'), song ) ;
csvwrite( fullfile(pathstr,'analysis_dist','syllable_distances.csv'), dmat ) ; % doesn't work in Octave why??

%%% construct a DTWcoal tree
%DTWcoal(pathstr,'',1,'',fullfile(pathstr,'syllables.mat'),dmat) ;

end
