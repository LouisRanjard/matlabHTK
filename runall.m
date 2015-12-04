function [] = runall()
% interface for calling syllabise(), etann(), dolibrary()

% main window
screensiz = get(0,'ScreenSize');
f = figure('Position',[screensiz(3)/2-200 screensiz(4)/2-30 600 550],...
        'HandleVisibility','callback',...
        'IntegerHandle','off',...
        'Renderer','painters',...
        'NumberTitle','off',...
        'Name','Menu') ;
        %'Toolbar','none',...
        %'Menubar','none',...
posf = get(f,'Position') ;

% variable panel
varpanel = uipanel('Parent',f,'Position',[0 0 600 460]);
setappdata(f,'varpanel',varpanel) ;

% syllabise button
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[0 posf(4)-20 133.33 20],...
        'String','Find syllables',...
        'BackgroundColor','white',...
        'Callback',{@runsyllabise}) ;
function runsyllabise(src,evt)
   delete(get(varpanel,'Children')) ;
   [songsmatfile song] = syllabise('','',100,120,varpanel) ;
   setappdata(get(src,'Parent'),'songsmatfile',songsmatfile) ;
   setappdata(get(src,'Parent'),'song',song) ;
   uicontrol(f,'Style','text','String',[num2str(numel([song.sequence])) ' syllables loaded'],'Position',[400 posf(4)-20 200 20]);
   if strcmp(questdlg('Do you want to extract syllables as .wav files?','Extraction','Yes'),'Yes')
       delete(get(varpanel,'Children')) ;
       extract_wav(song,fileparts(songsmatfile)) ;
   end
end

% create song structure from wav files button
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[133.33 posf(4)-20 133.33 20],...
        'String','Use wav files',...
        'BackgroundColor','white',...
        'Callback',{@runcreatesongfromwav}) ;
function runcreatesongfromwav(src,evt)
   delete(get(varpanel,'Children')) ;
    if usejava('desktop') % the desktop is available
        directo = uigetdir('','Select a directory containing .wav files') ;
        if directo~=0
            [song syllab] = createsongfromwav(directo) ;
            setappdata(get(src,'Parent'),'song',song) ;
            setappdata(get(src,'Parent'),'songsmatfile',fullfile(directo,'songs.mat')) ;
            setappdata(get(src,'Parent'),'syllab',syllab) ;
        end
    end
    if exist('song','var') && exist('syllab','var')
        uicontrol(f,'Style','text','String',[num2str(numel(song)) ' syllables loaded'],'Position',[400 posf(4)-20 200 20]);
    end
end

% direct loading of a songs.mat file
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[266.66 posf(4)-20 133.33 20],...
        'String','Load a song file',...
        'BackgroundColor','white',...
        'Callback',{@runloadsongs}) ;
function runloadsongs(src,evt)
    if usejava('desktop') % the desktop is available
        [filena1,pathstr] = uigetfile('','Select a songs.mat file') ;
        cd(pathstr) ;
        loadedstruct = load(fullfile(pathstr,filena1)) ;
        song = loadedstruct(1).song ;
    end
    setappdata(get(src,'Parent'),'song',song) ;
    setappdata(get(src,'Parent'),'songsmatfile',fullfile(pathstr,filena1)) ;
    uicontrol(f,'Style','text','String',[num2str(numel([song.sequence])) ' syllables loaded'],'Position',[400 posf(4)-20 200 20]);
end

% etree button
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[0 posf(4)-40 200 20],...
        'String','Classify syllables',...
        'BackgroundColor','white',...
        'Callback',{@runetann}) ;
function runetann(src,evt)
   delete(get(varpanel,'Children')) ;
   songsmatfile = getappdata(get(src,'Parent'),'songsmatfile') ;
   if numel(songsmatfile)>0
       etreematfile = etann(songsmatfile,'') ; % no htkdir specified
       if numel(etreematfile)>0
           setappdata(get(src,'Parent'),'etreematfile',etreematfile) ;
           close(gcf) ;
       else
           errordlg('no classification file loaded, use "Classify syllables" function first');
       end
   else
       errordlg('no song data file loaded, use "Find syllables" or "Use wav files" functions first');
   end
end

% distance button
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[200 posf(4)-40 200 20],...
        'String','Syllables pairwise distance',...
        'BackgroundColor','white',...
        'Callback',{@runpwdist}) ;
function runpwdist(src,evt)
   delete(get(varpanel,'Children')) ;
   songsmatfile = getappdata(get(src,'Parent'),'songsmatfile') ;
   if numel(songsmatfile)>0
       dopwdist(songsmatfile,'') ; % no htkdir specified
   else
       errordlg('no song data file loaded, use "Find syllables" or "Use wav files" functions first');
   end
end

% create library button
uicontrol(f,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[0 posf(4)-60 200 20],...
        'String','Create a library',...
        'BackgroundColor','white',...
        'Callback',{@runlibrary}) ;
function runlibrary(src,evt)
   delete(get(varpanel,'Children')) ;
   songsmatfile = getappdata(get(src,'Parent'),'songsmatfile') ;
   if numel(songsmatfile)>0
       etreematfile = getappdata(get(src,'Parent'),'etreematfile') ;
       if numel(etreematfile)>0
            dolibrary(songsmatfile,etreematfile) ;
       else
           errordlg('no classification file loaded, use "Classify syllables" function first');
       end
   else
       errordlg('no song data file loaded, use "Find syllables" or "Use wav files" functions first');
   end
end

end