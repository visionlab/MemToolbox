function ptr = Memoize(func)
% Memoize - Cache return values of long-running functions 
% Takes a function pointer and returns a new function pointer that is a
% memoized version of that function. If you call the memoized function with
% a set of parameters it has seen before, it returns immediately from an
% internal cache. Otherwise, it calls the original function.
%
% Caveats: containers.Map() requires R2008b or greater. I assume that's OK. 
% Could add a version check such that if matlab ver < 7.7, just returns func()
% itself (no memoization)
%
  % Make our map function and have it 
  m = containers.Map();
  nOut = nargout(func);
    
  % Create the memoized function. Some logic differences for 1 output
  % argument and >1 output arguments
  function varargout = r(varargin)
    hash = DataHash(varargin);
    if m.isKey(hash)
      result = m(hash);
      if nOut > 1
        varargout = result(1:nargout);
      else
        varargout = {result};
      end
    else
      if nOut > 1
        [result{1:nOut}] = func(varargin{:});
        varargout = result(1:nargout);
      else
        result = func(varargin{:});
        varargout = {result};
      end
      m(hash) = result;
    end
  end
  ptr = @r;
end

