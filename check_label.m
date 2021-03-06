function [] = check_label( filename, repair )
% read a LABEL file generated by AUDACITY
% tells if some label are overlapping, if they do, repair them by merging
% boundaries
%
% repair: if==1, try to repair the files
%
% example: 
% files = dir(fullfile(dirna,'*.label')) ;
% for nf=1:numel(files), check_label(fullfile(dirna,files(nf).name)), end

if nargin<2, repair=0; end

%if is_octave()
[a, b, labelt] = textread(filename,'%f %f %s');
%else
%    [a, b, labelt] = textread(filename,'%f\t%f\t%s');
%end

fprintf(1,'%s ',filename) ;
labeltu = sort(unique(labelt)) ;
for n=1:size(labeltu,1)
    fprintf(1,'%s ',labeltu{n});
end
fprintf(1,'\n') ;
for n=1:numel(a)
    if (a(n)<0), fprintf(1,'negative boundary found at %.2f sec\n',a(n)); end
    if (b(n)<0), fprintf(1,'negative boundary found at %.2f sec\n',b(n)); end
    if (n<numel(a))
        if (b(n)~=a(n+1))
            if (a(n+1)<b(n))
                fprintf(1,'overlapping labels found at %.2f sec',a(n+1)) ;
                if (repair==1)
                    a(n+1) = b(n) ; % simple fix
                    fprintf(1,' - fixed\n');
                else
                    fprintf(1,'\n');
                end
            end
        end
    end
end

if (repair==1)
    fid = fopen(filename,'w') ;
    for n=1:numel(a)
        fprintf(fid,'%s\t%s\t%s\t\n',num2str(a(n)),num2str(b(n)),labelt{n});
    end
    fclose(fid) ;
end
