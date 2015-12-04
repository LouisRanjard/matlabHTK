function [] = extract_wav(song,directo)
% write the selected syllables to the directory directo as wav files

mkdir(directo,'extracted') ;

%%% get the variable panel of the main figure
varpanel = getappdata(gcf,'varpanel') ;
posf = get(varpanel,'Position') ;
handles = guihandles(varpanel) ;
handles.figure = gcf ;

AllSyllab = unique([song.sequence]) ;

uicontrol(varpanel,'Style','text',...
    'Position',[0 450 300 20],...
    'String','Select the sounds to extract') ;

syllistbox = uicontrol(varpanel,'Style','listbox',...
    'Position',[0 150 150 300],...
    'FontSize',12,...
    'HorizontalAlign','left',...
    'Max',2,'Min',0,...
    'String',AllSyllab) ;

uicontrol(varpanel,'Style','pushbutton','Units','pixels','FontSize',12,...
        'Position',[500 0 100 20],...
        'String','Extract',...
        'BackgroundColor','white',...
        'Callback',@Extract);

% get parameters
function Extract(src,evt)
    syllab2extract = get(syllistbox,'value') ;
    for n=1:numel(song)
        for s=1:numel(song(n).sequence)
            if sum(song(n).sequence(s)==syllab2extract)>0
                [y, Fs, nbits] = wavread(song(n).filename,[song(n).SyllableS(s) song(n).SyllableE(s)]) ;
                deb = msecondtostring(song(n).SyllableS(s)*1000/Fs) ;
                fin = msecondtostring(song(n).SyllableE(s)*1000/Fs) ;
                wavwrite(y,Fs,nbits,fullfile(directo,'extracted',[song(n).filename '_' deb '_' fin '_' num2str(song(n).sequence(s)) '.wav'])) ;
            end
        end
    end
end

end
