% MemToolbox demo 6: Using the parallel toolbox to speed up analysis
clear all;
if(~(matlabpool('size') > 0))
 matlabpool open;
end
