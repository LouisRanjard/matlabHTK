function [] = check_labeldir( dirname, Fs, check, repair )
% check the set of label files in a directory and count the time for each
% label that is found
% 
% check: if==1, run check_label() on each file
% repair: if==1, use repair=1 when calling check_label() on each file

if nargin<4
    repair=0;
    if nargin<3
        check=0;
        if nargin<2
            Fs=44100; 
        end
    end
end

files = dir(fullfile(dirname,'*.label')) ;
all_label = cell(0,2) ;
for n = 1:numel(files)
    if check==1
        if repair==1
            check_label(fullfile(dirname,files(n).name),1);
        else
            check_label(fullfile(dirname,files(n).name))  ;
        end
    end
    % create song structures
    tmp1=regexprep(files(n).name(end:-1:1),'lebal.','flm.','once');tmp1=tmp1(end:-1:1); % allows to replace just once, the last one
    label2mlf( files(n).name, tmp1 ) ;
    song = mlf2song( tmp1, [], 3, 0, 0, 0, 0, Fs) ;
    % find duration of each unique label in the file
    uniklabel = sort(unique(song.sequencetxt)) ;
    label_dure = zeros(1,length(uniklabel)) ;
    s=1;
    while s<=numel(song.SyllableS)
        ind=find(strcmp([uniklabel], song.sequencetxt{s}));
        label_dure(ind) = label_dure(ind) + ( song.SyllableE(s)-song.SyllableS(s) ) ;
        s = s+1 ;
    end
    % merge with label that have already been identified
    for m=1:numel(uniklabel)
        id = find(strcmp(all_label(:,1), uniklabel{m}));
        if ( numel(id)>0 )
            all_label{id,2} = all_label{id,2} + label_dure(m) ;
        else
            next_id = size(all_label,1)+1 ;
            all_label{next_id,1} = uniklabel{m}  ;
            all_label{next_id,2} = label_dure(m) ;
            %all_label = { [ all_label{:,1} uniklabel{m} ] [ all_label{:,2} label_dure(m) ] } ;
        end
    end
end

% print the total duration of each label
fprintf(1,'--------------------------------------------------\n');
fprintf(1,'label \t|\t number_of_samples\n');
fprintf(1,'--------------------------------------------------\n');
for c = 1:size(all_label,1)
    fprintf(1,'%s \t|\t %s\n',all_label{c,1},all_label{c,2});
end
fprintf(1,'--------------------------------------------------\n');


