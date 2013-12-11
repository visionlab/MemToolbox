% VALIDATEDATA checks to make sure that the data is in the expected format
%
% [data, pass] = ValidateData(data)
%
% e.g., it checks if it is in the range [-180,180]. if unsalvageable, it
% throws errors. Otherwise, throws warnings and does its best to massage
% data into the range (-180, 180).
%
function [data, pass] = ValidateData(data)
    pass = true; % always pass if you make it through without an error()

    % Rename according to MTB standards when appropriate
    if ~isfield(data, 'errors') && isfield(data, 'error')
      data.errors = data.error;
      data = rmfield(data, 'error');
    end

    if(~isDataStruct(data))
      error('Data should be passed in as a struct with a field data.errors or data.afcCorrect');
    end

    if isfield(data, 'errors') && isfield(data, 'afcCorrect')
      error('Your data struct specified both a .errors and a .afcCorrect. Please pass only one kind of data at a time.');
    end

    % Check that the error values are in the correct range, otherwise massage
    if isfield(data, 'errors')
      if(isempty(data.errors))
        error('The data vector should not be empty.');
      elseif(~isnumeric(data.errors))
        throwRangeError();
      elseif(any(data.errors < -180 | data.errors > 360)) % vomit if unintelligeble
        throwRangeError();
      elseif(any(data.errors > 180)) % then assume (0,360)
        throwRangeWarning('(0,360)');
        data.errors = data.errors-180;
      elseif(all(isInRange(data.errors,-pi,pi))) % then assume (-pi,pi)
        throwRangeWarning('(-pi,pi)');
        data.errors = rad2deg(data.errors);
      elseif(all(isInRange(data.errors,0,2*pi))) % then assume (0,2*pi)
        throwRangeWarning('(0,2*pi)');
        data.errors = rad2deg(data.errors-pi);
      elseif(all(isInRange(data.errors,0,180))) % then assume (0,180)
        throwRangeWarning('(0,180)');
        data.errors = 2*(data.errors-90);
      end
    end

    % Add in some checking of auxilliary data struct fields. for example,
    % it would probably be good to make sure that any field called RT has
    % only non-negative numbers.
end


function throwRangeError()
    error('Data should be in the range (-180,180)');
end

function throwRangeWarning(rangeString)
    fprintf(['\nWarning: MTB would prefer data in the range (-180,180),' ...
             ' but we''ll do our best to rescale your data appropriately.' ...
             ' It looks like you provided data in the range ' rangeString '.\n']);
end

% Is the object an MTB data struct? passes iff the object is a struct
% containing a field called 'errors'.
function pass = isDataStruct(object)
  pass = (isstruct(object) && (isfield(object,'errors') || isfield(object, 'afcCorrect')));
end

