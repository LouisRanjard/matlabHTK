function [] = createcffile_grammar(dirname,sylid)
% create files required to build the network, basically grammar and dictionary


%%% dirname/def/configvar
mkdir(fullfile(dirname,'def')) ;
fid = fopen(fullfile(dirname,'def','configvar.txt'),'w') ;
fprintf(fid,'# force HVite to output a partial hypothesis\n') ;
fprintf(fid,'# in case of error "No tokens survived to final node of network"\n') ;
fprintf(fid,'HREC:FORCEOUT = TRUE\n') ;
fclose(fid) ;

% %%% dirname/def/dict.txt
% fid = fopen(fullfile(dirname,'def','dict.txt'),'w') ;
% fprintf(fid,'NOISE [syl0] syl0\n') ;
% for sid=sylid
%     fprintf(fid,['SYLLABLE' num2str(sid) ' [syl' num2str(sid) '] syl' num2str(sid) '\n']) ;
% end
% fclose(fid) ;
% 
% %%% dirname/def/gram.txt
% fid = fopen(fullfile(dirname,'def','gram.txt'),'w') ;
% fprintf(fid,'( {NOISE') ;
% for sid=sylid
%     fprintf(fid,['|SYLLABLE' num2str(sid)]);
% end
% fprintf(fid,'} )\n') ;
% fclose(fid) ;

%%% dirname/def/dict.txt
fid = fopen(fullfile(dirname,'def','dict.txt'),'w') ;
for sid=sylid
    fprintf(fid,['SYLLABLE' num2str(sid) ' [syl' num2str(sid) '] syl' num2str(sid) '\n']) ;
end
fclose(fid) ;

%%% dirname/def/gram.txt
fid = fopen(fullfile(dirname,'def','gram.txt'),'w') ;
fprintf(fid,'( {') ;
for sid=1:numel(sylid)
    fprintf(fid,['SYLLABLE' num2str(sylid(sid))]);
    if sid~=sylid(end)
        fprintf(fid,'|');
    end
end
fprintf(fid,'} )\n') ;
fclose(fid) ;
