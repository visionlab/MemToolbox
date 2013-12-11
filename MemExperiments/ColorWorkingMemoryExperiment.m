% COLORWORKINGMEMORYEXPERIMENT Runs a color working memory task
% a la Zhang & Luck (2008). The task requires memory for the color of
% briefly presented squares. Participants then report the color of a single
% probed square using a continuous report task.
%
%   ColorWorkingMemoryExperiment();
%
%	Preferences can be found down at the bottom, beginning on line 197.
%

function ColorWorkingMemoryExperiment()

  try
    prepareEnvironment;
    window = openWindow();
    prefs = getPreferences()

    % Put up instructions and wait for keypress.
    instruct(window);
    returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize)

    WaitSecs(1);

    % Get rects for each item.
    rects = cell(1, max(prefs.setSizes));
    for i = 1:max(prefs.setSizes)
      rects{i} = circularArrayRects([0, 0, prefs.squareSize, prefs.squareSize], ...
        i, prefs.radius, window.centerX, window.centerY)';
    end

    colorWheelLocations = colorwheelLocations(window,prefs);

    for trialIndex = 1:length(prefs.fullFactorialDesign)

      % Determine how many items there are on this trial and the duration.
      nItems = prefs.setSizes(prefs.fullFactorialDesign(prefs.order(trialIndex), 1));
      retentionInterval = prefs.retentionIntervals(prefs.fullFactorialDesign(prefs.order(trialIndex), 2));

      % Pick an item to test.
      itemToTest(trialIndex) = RandSample(1:nItems);

      % Pick the colors for this trial.
      colorsInDegrees{trialIndex} = ceil(rand(1, nItems)*360);

      % Draw fixation.
      drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);

      % Draw the stimulus.
      colorsToDisplay = prefs.colorwheel(colorsInDegrees{trialIndex}, :)';
      Screen('FillRect', window.onScreen, colorsToDisplay, rects{nItems});

      % Post the stimulus and wait.
      Screen('Flip', window.onScreen);
      WaitSecs(prefs.stimulusDuration);

      % Remove stimulus, return to blank, wait for retention interval to pass.
      returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize);
      WaitSecs(retentionInterval);

      % Choose a circle to test, then display the response screen.
      data.presentedColor(trialIndex) = deg2rad(colorsInDegrees{trialIndex}(itemToTest(trialIndex)));
      colorsOfTest = repmat([120 120 120], nItems, 1);
      colorsOfTest(itemToTest(trialIndex), :) = [145 145 145];
      drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
      Screen('FillRect', window.onScreen, colorsOfTest', rects{nItems});

      drawColorWheel(window, prefs);

      % Wait for click.
      SetMouse(window.centerX, window.centerY);
      ShowCursor('Arrow');

      % If mouse button is already down, wait for release.
      GetMouse(window.onScreen);
      while any(buttons)
        [x, y, buttons] = GetMouse(window.onScreen);
      end

      everMovedFromCenter = false;
      while ~any(buttons)

        drawColorWheel(window, prefs);

        [x,y,buttons] = GetMouse(window.onScreen);
        [minDistance, minDistanceIndex] = min(sqrt((colorWheelLocations(1, :) - x).^2 + (colorWheelLocations(2, :) - y).^2));

        if(minDistance < 250)
          everMovedFromCenter = true;
        end

        if(everMovedFromCenter)
          colorsOfTest(itemToTest(trialIndex), :) = prefs.colorwheel(minDistanceIndex,:);
        else
          colorsOfTest(itemToTest(trialIndex), :) = [145 145 145];
        end

        drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
        Screen('FillRect', window.onScreen, colorsOfTest', rects{nItems});
        drawColorWheel(window, prefs);
        Screen('Flip', window.onScreen);
      end
      data.reportedColor(trialIndex) = deg2rad(minDistanceIndex);
      while any(buttons) % wait for release
        [x,y,buttons] = GetMouse(window.onScreen);
      end

      HideCursor

      % Return to fixation.
      returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize);
      WaitSecs(0.5);
    end

    % Preliminary analysis of results.
    data.error = (180/pi) .* (angle(exp(1i*data.reportedColor)./exp(1i*data.presentedColor)));
    data.setSize = prefs.setSizes(prefs.fullFactorialDesign(prefs.order, 1));
    data.retentionInterval = prefs.retentionIntervals(prefs.fullFactorialDesign(prefs.order,2));

    save data.mat data prefs
    postpareEnvironment;

  catch
    postpareEnvironment;
    psychrethrow(psychlasterror);

  end % end try/catch
end % end whole colorworkingmemoryscript

function prepareEnvironment

  clear all;
  HideCursor;

  commandwindow; % Select the command window to avoid typing in open scripts

  % Seed the random number generator.
  RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', sum(100*clock)));

  ListenChar(2); % Don't print to MATLAB command window
end

function postpareEnvironment
  ShowCursor;
  ListenChar(0);
  Screen('CloseAll');
end

function instruct(window)
  Screen('TextSize', window.onScreen, window.fontsize);
  Screen('DrawText', window.onScreen, 'Remember the colors. Click to begin.', 100, 100, 255);
  Screen('Flip', window.onScreen);
  GetClicks(window.onScreen);
end

function drawFixation(window, fixationX, fixationY, fixationSize)
  Screen('DrawDots', window.onScreen, [fixationX, fixationY], fixationSize, 255);
end

function offsets = circularArrayOffsets(n, centerX, centerY, radius, rotation)
  degreeStep = 360/n;
  offsets = [sind(0:degreeStep:(360-degreeStep) + rotation)'.* radius, ...
             cosd(0:degreeStep:(360-degreeStep) + rotation)'.* radius];
end

function rects = circularArrayRects(rect, nItems, radius, centerX, centerY)
  coor = circularArrayOffsets(nItems, centerX, centerY, radius, 0) + repmat([centerX centerY], nItems, 1);
  rects = [coor(:, 1)-rect(3)/2 , coor(:, 2)-rect(3)/2, coor(:, 1)+rect(3)/2, coor(:, 2)+rect(3)/2];
end

function returnToFixation(window, fixationX, fixationY, fixationSize)
  Screen('FillRect', window.onScreen, window.bcolor);
  Screen('DrawDots', window.onScreen, [fixationX, fixationY], fixationSize, 255);
  Screen('Flip', window.onScreen);
end

function window = openWindow()
  window.screenNumber = max(Screen('Screens'));
  window.onScreen = Screen('OpenWindow', window.screenNumber, [128 128 128]);
  Screen('BlendFunction', window.onScreen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
  [window.screenX, window.screenY] = Screen('WindowSize', window.onScreen); % check resolution
  window.screenRect  = [0, 0, window.screenX, window.screenY]; % screen rect
  window.centerX = window.screenX * 0.5; % center of screen in X direction
  window.centerY = window.screenY * 0.5; % center of screen in Y direction
  window.centerXL = floor(mean([0, window.centerX])); % center of left half of screen in X direction
  window.centerXR = floor(mean([window.centerX, window.screenX])); % center of right half of screen in X direction

  % Basic drawing and screen variables.
  window.black    = BlackIndex(window.onScreen);
  window.white    = WhiteIndex(window.onScreen);
  window.gray     = mean([window.black window.white]);
  window.fontsize = 24;
  window.bcolor   = window.gray;
end

function drawColorWheel(window, prefs)
  colorWheelLocations = [cosd(1:360).*prefs.colorWheelRadius + window.centerX; ...
    sind(1:360).*prefs.colorWheelRadius + window.centerY];
  colorWheelSizes = 20;
  Screen('DrawDots', window.onScreen, colorWheelLocations, colorWheelSizes, prefs.colorwheel', [], 1);
end

function L = colorwheelLocations(window,prefs)
  L = [cosd(1:360).*prefs.colorWheelRadius + window.centerX; ...
       sind(1:360).*prefs.colorWheelRadius + window.centerY];
end

function prefs = getPreferences
  prefs.nTrialsPerCondition = 2;
  prefs.setSizes = [2,4];
  prefs.retentionIntervals = [0.250, 0.5, 1];
  prefs.stimulusDuration = 0.250;
  prefs.squareSize = 75; % size of each stimulus object, in pixels
  prefs.radius = 180;
  prefs.fixationSize = 3;

  % Colorwheel details.
  prefs.colorWheelRadius = 350;
  prefs.colorwheel = load('colorwheel360.mat', 'fullcolormatrix');
  prefs.colorwheel = prefs.colorwheel.fullcolormatrix;

  % Randomize trial order of full factorial design order.
  prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
    length(prefs.retentionIntervals), ...
    prefs.nTrialsPerCondition]);

  prefs.order = Shuffle(1:length(prefs.fullFactorialDesign));
  prefs.nTrials = length(prefs.fullFactorialDesign);
end
