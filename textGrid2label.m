function [] = textGrid2label( filename1, filename2 )

filename3 = [filename2 '.mlf'];

textGrid2mlf( filename1, filename3 );

mlf2label( filename3, filename2 );

delete(filename3);

