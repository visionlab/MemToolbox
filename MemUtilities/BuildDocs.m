function BuildDocs()
  parentFolder = 'MemUtilities';
	MTBfolder = fileparts(fileparts(which(mfilename)));
	options.evalCode = false;
  options.format = 'html';
  options.outputDir = 'docs';
	cd(MTBfolder);
	d = rdir(fullfile('**', filesep, '**.m'));
	for i = 1:length(d)
    publish(d(i).name, options);
  end
end