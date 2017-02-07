function [] = textGrid2label( filename1, filename2 )
% convert TextGrid HTK file format to label Audacity annotation format
% 

filename3 = [filename2 '.mlf'];

textGrid2mlf( filename1, filename3 );

mlf2label( filename3, filename2 );

delete(filename3);

