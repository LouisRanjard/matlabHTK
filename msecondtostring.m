function [datestring]=msecondtostring(nmsec)
% convert a number of milliseconds into the string hour'h'minute'm'seconds's'msec'ms'

nmsec = round(nmsec) ;

nhour = floor(nmsec/3600000) ;
nminute = floor(nmsec/60000) - nhour*60 ;
nsecond = floor(nmsec/1000) - nhour*3600 - nminute*60 ;
nmsecond = nmsec - nhour*3600000 - nminute*60000 - nsecond*1000 ;

datestring = [sprintf('%02i',nhour) 'h'...
    sprintf('%02i',nminute) 'm'...
    sprintf('%02i',nsecond) 's'...
    sprintf('%03i',nmsecond) 'ms'] ;
