function [] = plot_Label(filenameL, filenameW, label, binsiz, timestart)
% plot activity versus time for the label input
% example:
% plot_Label('~/Documents/Students/Ben_Reed/MOKO1_20140925_180000.label','~/Documents/bioacoustics/recordings/Burgess_Sept2014/Plot1/MOKO1_20140925_180000.wav','diving_petrel',60,'25/09/2014 18:00:00');
% plot_Label('~/Documents/Students/Ben_Reed/MOKO1_20140926_004553.label','~/Documents/bioacoustics/recordings/Burgess_Sept2014/Plot1/MOKO1_20140926_004553.wav','diving_petrel',60,'26/09/2014 00:45:53');
% binsiz: size of windows in seconds

if nargin<5
    timestart = 0;
    if nargin<4
        % choose bin size in seconds
        binsiz = 60 ;
        if nargin<3
            label = 'diving_petrel' ;
        end
    end
else
    timestart = datenum(timestart,'dd/mm/yyyy HH:MM:SS') ;
end

% get the Fs
%tmp = regexprep(filename(end:-1:1),'dirGtxeT.','vaw.','once');
%tmp = tmp(end:-1:1);
%fprintf(1,tmp);% allows to replace just once, the last one
%ainfo = audioinfo(filenameW) ; % not implemented in Octave
%Fs = ainfo.SampleRate ;
%length1 = ainfo.TotalSamples ;
if is_octave()
    [~, Fs] = wavread(filenameW,1) ;
    length1 = wavread(filenameW, 'size');
else
    info = audioinfo(filenameW) ;
    Fs = info.SampleRate ;
    length1 = info.TotalSamples ;
end

tmp = regexprep(filenameL(end:-1:1),'lebal.','flm.','once');
tmp = tmp(end:-1:1); % allows to replace just once, the last one
label2mlf( filenameL, tmp ) ;
song = mlf2song( tmp, [], 3, 0, 0, 0, 0, Fs) ;


% create tables
syltable = song2table(song) ;
[countlab, uniklabel] = syltable_bins(syltable,binsiz,Fs,length1(1)) ;

% find column of countlab that match the required label
colnum = find(uniklabel==sum(double(label))) ;

% plot the column activity as percentage time labelled "label" during each time bin 
activity =  countlab(:,colnum) ./ sum(countlab, 2) ;


% plotting
figure('Units', 'pixels', 'Position', [0, 0, 1000, 400], 'PaperPositionMode', 'auto');
timeaxsec = round(cumsum(sum(countlab,2))) ;
timeax = zeros(numel(timeaxsec),1);
for i=1:numel(timeaxsec)
    timeax(i) = addtodate(timestart,timeaxsec(i),'second') ;
end
bar( timeax, activity, 1, 'FaceColor', [.25 .6 .9], 'EdgeColor', [.25 .6 .9]) ;
ylim([0 1]);
set(gca,'TickLength',[0 0],...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',14,...
    'FontName','Times');
datetick('x','HH:MM:SS','keeplimits') ;
xlabel(datestr(timestart)) ;
ylabel(['Proportion "' strrep(label,'_','\_') '"']);
if is_octave()
  set(gcf, 'papersize', [10, 3]);
  set(gcf, 'paperposition', [0,0,[10 4]]);
end
orient landscape;
%print([filenameW '.pdf'],'-dpdf');
print([filenameW '.eps'],'-depsc2');

% save to csv
datatable = horzcat(timeaxsec,activity);
fid = fopen([filenameW '.plot_Label.csv'],'w+');
fprintf(fid,'%s,%s\n','Second',['Percentage_' label]);
for n=1:size(datatable,1)
  fprintf(fid,'%s,%s\n',num2str(datatable(n,1)),num2str(datatable(n,2)));
end
fclose(fid);

% clean up
delete(fullfile(tmp)) ;
