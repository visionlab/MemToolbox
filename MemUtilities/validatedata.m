% checks to make sure that the data is in the expected format (in the range 
% [-180,180]. if unsalvageable, it throws errors. otherwise, throws warnings
% and does its best to massage data into the range (-180, 180)
function [data, pass] = ValidateData(data)

    pass = false; % assume failure, unless...
        
    if(~isDataStruct(data))
        error('Data should be passed in as a struct with a field data.errors');
    
    elseif(~isnumeric(data.errors))
        throwRangeError();   
   
    elseif(any(data.errors < -180 | data.errors > 360)) % vomit if unintelligeble
        throwRangeError();      
        
    elseif(any(data.errors > 180)) % then assume (0,360)
        throwRangeWarning('(0,360)');
        data.errors = data.errors - 180;
        
    elseif(all((data.errors < pi) & (data.errors > -pi))) % then assume (-pi,pi)
        throwRangeWarning('(-pi,pi)');
        data.errors = rad2deg(data.errors);
        
    elseif(all((data.errors < 2*pi) & (data.errors > 0))) % then assume (0,2*pi)
        throwRangeWarning('(0,2*pi)');
        data.errors = rad2deg(data.errors-pi);

    else
        pass = true;
    end
    
    % add in some checking of auxilliary data struct fields. for example,
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

% is the object an MTB data struct? passes iff the object is a struct
% containing a field called 'errors'.
function pass = isDataStruct(object)
    pass = (isstruct(object) && isfield(object,'errors'));
end


