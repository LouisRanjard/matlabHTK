function [handles] = getsyllabiseparameter(dirnameA,dirnameB,gapminlength,sylminlength)
% return parameters for running syllabise() from a GUI
% dirnameA
% dirnameB
% gapminlength
% sylminlength

%%% get the variable panel of the main figure
varpanel = getappdata(gcf,'varpanel') ;
posf = get(varpanel,'Position') ;
handles = guihandles(varpanel) ;
handles.figure = gcf ;

% dirnameA, containing manually annotated wav files
uicontrol(varpanel,'Style','text','Position',[0 posf(4)-20 300 20],'FontSize',12,...
    'HorizontalAlign','left','String', 'Annotated files directory') ;
handles.dirname1 = uicontrol(varpanel,'Style','edit','Units','pixels','FontSize',12,'String',dirnameA,...
    'Position',[300 posf(4)-20 280 20],'BackgroundColor','white') ;
uicontrol(varpanel,'Style','pushbutton','Position',[580 posf(4)-20 20 20],'String','?','Callback',{@cb_setdir,handles,1}) ;

% dirnameB, containing wav files to be processed
uicontrol(varpanel,'Style','text','Position',[0 posf(4)-40 300 20],'FontSize',12,...
    'HorizontalAlign','left','String', 'Files to process directory') ;
handles.dirname2 = uicontrol(varpanel,'Style','edit','Units','pixels','FontSize',12,'String',dirnameB,...
    'Position',[300 posf(4)-40 280 20],'BackgroundColor','white') ;
uicontrol(varpanel,'Style','pushbutton','Position',[580 posf(4)-40 20 20],'String','?','Callback',{@cb_setdir,handles,2}) ;

function cb_setdir(src,eventdata,handles,songid)
    [pathstr] = fileparts(get(handles.(['dirname' num2str(songid)]),'String')) ;
    dirname = uigetdir(pathstr,'Select directory') ;
    cd(dirname) ;
    set(handles.(['dirname' num2str(songid)]),'String',dirname) ;
end

% gap minimum length
uicontrol(varpanel,'Style','text','Position',[0 posf(4)-60 300 20],'FontSize',12,...
    'HorizontalAlign','left','String', 'minimum length for gaps (ms)');
handles.gapminlength = uicontrol(varpanel,'Style','edit','Units','pixels','FontSize',12,'String',gapminlength,...
    'Position',[300 posf(4)-60 100 20],'BackgroundColor','white');

% syllable minimum length
uicontrol(varpanel,'Style','text','Position',[0 posf(4)-80 300 20],'FontSize',12,...
    'HorizontalAlign','left','String', 'minimum length for syllables (ms)');
handles.sylminlength = uicontrol(varpanel,'Style','edit','Units','pixels','FontSize',12,'String',sylminlength,...
    'Position',[300 posf(4)-80 100 20],'BackgroundColor','white');

% Run analysis button
uicontrol(varpanel,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[500 0 100 20],...
        'String','Run Analysis',...
        'BackgroundColor','white',...
        'Callback',{@Run,handles});

uiwait(gcf) ;

% get parameters
function Run(src,evt,handles)
   uiresume(handles.figure) ;
end

end