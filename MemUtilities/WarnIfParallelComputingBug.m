% WARNIFPARALLELCOMPUTINGBUG warns about a particular bug that prevents
% Javas >= 1.6.0 -39 from using MATLAB's Parallel Computing Toolbox.
function pass = WarnIfParallelComputingBug()
  pass = true;
  v = ver();
  [installedToolboxes{1:length(v)}] = deal(v.Name);
  isParallelInstalled = ismember('Parallel Computing Toolbox', installedToolboxes);
  javaVersion = version('-java');
  i = min(strfind(javaVersion, '_'));
  javaVersionNumMinor = str2num(javaVersion((i+1):(i+2)));
  if(~isempty(strfind(javaVersion, 'Java 1.6.0')) && (javaVersionNumMinor >= 39) && isParallelInstalled)
   try
     if exist('gcp')
       gcp();
     else
       matlabpool('open');
     end
   catch
     pass = false;
     fprintf(['\nWarning: you are using a version of Java with a known bug\n' ...
     'that prevents using the Parallel Computing Toolbox, which would\n' ...
     'otherwise be available on your system. Please read the info at\n' ...
     'http://www.mathworks.com/support/bugreports/919688 to fix it.\n\n']);
    end
  end
end
