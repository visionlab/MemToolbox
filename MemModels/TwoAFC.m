% TWOAFC converts a model so that can be fit to 2AFC data
%
% Once a model has been converted, it no longer uses data.errors, but instead
% requires two new fields in the data struct:
%   data.afcCorrect - a sequence of zeros and ones, saying whether observers
%        got a 2AFC trial correct or incorrect
%   data.changeSize - size in degrees of the difference between correct and
%        foil item in the 2AFC trials. Should correspond to .afcCorrect.
%
% TwoAFC can be wrapped around any model. However, it is much slower if wrapped
% around a model that requires additional fields of data, like data.n or
% data.distractors (because then it must calculate a cdf for each datapoint
% separately).
%
function model = TwoAFC(model, samplesToApproxCDF)
  % How many samples of pdf to take to estimate the cdf with
  if nargin < 2
    samplesToApproxCDF = 1000;
  end

  % Check if we need extra information to call the pdf
  model.requiresSeparateCDFs = DoesModelRequireExtraInfo(model);
  model.isTwoAFC = true;

  % Take model and turn it into a 2AFC-model
  model.name = ['2AFC ' model.name];
  model.oldPdf = model.pdf;
  model.interpVals = linspace(-180, 180, samplesToApproxCDF);
  model.pdf = @NewPDF;
  model.generator = @NewGenerator;

  % Make a generator of afcCorrect given changeSize
  function samples = NewGenerator(params, dims, displayInfo)
    displayInfo.afcCorrect = ones(size(displayInfo.changeSize));
    [p, thetas] = model.pdf(displayInfo, params{:});
    samples = binornd(1,thetas);
  end

  % Convert pdf into a 2AFC pdf
  function [p,thetas] = NewPDF(data, varargin)

    % Take integral from data.changeSize/2 to 180+data.changeSize/2 (the
    % area of the pdf that is closer to the target than the changed item)
    leftPt = data.changeSize./2;
    rightPt  = data.changeSize./2 + 180;
    rightPt(rightPt>180) = rightPt(rightPt>180)-360;

    if ~model.requiresSeparateCDFs
      % Fast way
      % Get cdf for model
      data.errors = model.interpVals;
      y = model.oldPdf(data, varargin{:});
      cdfVals = cumtrapz(model.interpVals, y);

      % Get area between the two points
      leftCDF = qinterp1(model.interpVals, cdfVals, leftPt);
      rightCDF = qinterp1(model.interpVals, cdfVals, rightPt);

      % This area is the chance of getting it correct
      thetas = abs(rightCDF-leftCDF);
    else
      % Slow way
      % Get separate pdf matrices for each data point
      for i=1:length(model.interpVals)
        data.errors = repmat(model.interpVals(i), size(data.changeSize));
        y(i,:) = model.oldPdf(data, varargin{:});
      end
      cdfVals = cumtrapz(model.interpVals, y);

      % Could probably be vectorized
      for i=1:length(data.changeSize)
        leftCDF = qinterp1(model.interpVals, cdfVals(:,i), leftPt(i));
        rightCDF = qinterp1(model.interpVals, cdfVals(:,i), rightPt(i));
        thetas(i,1) = abs(rightCDF-leftCDF);
      end
    end

    thetas(thetas>1) = 1;
    thetas(thetas<0) = 0;
    p = binopdf(data.afcCorrect(:), 1, thetas(:));
  end
end
