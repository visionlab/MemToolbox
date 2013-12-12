% Install the MemToolbox in the current location. Note that this does not
% copy any files -- you must first put MemToolbox where you want it to
% be located, then run this file to add the files to the path.
addpath(genpath(pwd));
rmpath(genpath(fullfile(pwd, '.git')));
if savepath() == 0
  fprintf(['\nMemToolbox successfully added to PATH!\n' ...
    'You are ready to go!\n\n' ...
    'Try calling MemFit() to get started.\n\n']);
else
  fprintf(['\nMemToolbox failed to add itself to the path!\n' ...
    'Probably this means you don''t have write permissions\n' ...
    'for the pathdef.m file. Here is MATLAB''s error:\n\n']);
  savepath();
end
