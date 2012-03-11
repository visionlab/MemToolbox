% Test a general purpose memoizer for any matlab function
% - tim

function Memoize()
  clc;
  
  % Generate new function handle for the fa() function, that only calls it
  % if the results aren't cached. fa takes complex arguments (array, struct).
  f = memoize(@fa);
  
  s.a = 1;
  a(1) = f(1, [1 2 3], s);
  a(2) = f(2, [9 2 3], s);
  a(3) = f(1, [1 2 3], s);
  disp(a);

  % Generate new function handle for the fNew() function, that only calls it
  % if the results aren't cached. fNew has more than one output argument. 
  fN = memoize(@fNew);
  fN(1)
  [b(1),c(1)] = fN(1);
  [b(2),c(2)] = fN(2);
  [b(3),c(3)] = fN(1);
  disp(b);
  disp(c);
end


function p = fa(a,b,c)
  % This is a "long-running" function -- don't call it again if we have
  % already called it with these arguments
  disp('in f');
  WaitSecs(2);
  p = a*10;
end

function [c,a] = fNew(b)
  % This is a "long-running" function
  disp('in fnew');
  c = b * 100;
  a = 8;
  n = 6;
  WaitSecs(2);
end

% containers.Map() requires R2008b or greater. I assume that's OK. Could
% add a version check such that if matlab ver < 7.7, just returns func()
% itself (no memoization)
function ptr = memoize(func)
  m = containers.Map();
  nOut = nargout(func);
  function varargout = r(varargin)
    disp('in r');
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


