% Runs a color working memory task, a la Zhang & Luck (2008).
%	Preferences can be found down at the bottom, beginning on line 182.
%
% To do:
%		1. add option for hsv vs. lab color space
%		2. ensure accurate timing (i.e., kill missed flip deadlines)
%		3. add option to remove contantly present color wheel
%		4. expand timing options
%		5. add optional data visualization and analysis
%

function colorworkingmemory()	

try
	prepareEnvironment;
	window = openWindow();
	prefs = getPreferences()
	
	% put up instructions and wait for keypress
	drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
	drawColorWheel(window, prefs);
	instruct(window);
	returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize)
	
	WaitSecs(1);
	
	% get rects for items
	rects = circularArrayRects([0, 0, prefs.squareSize, prefs.squareSize], prefs.nItems, prefs.radius, window.centerX, window.centerY)';

	% pick colors for every trial
	colorsInDegrees = random('Uniform', 0, 360, prefs.nTrials, prefs.nItems);
	colors = colorsInDegrees ./ 360;
	
	colorWheelLocations = [cosd([1:360]).*prefs.colorWheelRadius + window.centerX; sind([1:360]).*prefs.colorWheelRadius + window.centerY];
	colorWheelColors = [[1:360]/360; ones(1, 360); ones(1, 360)];
	
	itemToTest = RandSample(1:prefs.nItems, [1 prefs.nTrials]);

	for trialIndex = 1:prefs.nTrials
		
		colorsToDisplay = round(hsv2rgb([colors(trialIndex, :); ones(1, prefs.nItems); ones(1, prefs.nItems)]')*255)'; % degrees on color wheel
				
		% draw fixation
		drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
		
		% draw stimulus
		Screen('FillRect', window.onScreen, colorsToDisplay, rects);
		
		% post stimulus and wait
		Screen('Flip', window.onScreen);
		WaitSecs(prefs.stimulusDuration);
		
		% remove stimulus, return to blank, wait for retention interval to pass
		returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize);
		WaitSecs(prefs.retentionInterval);
		
		% choose a circle to test, then display response screen
		presentedColor(trialIndex) = colorsInDegrees(trialIndex, itemToTest(trialIndex));
		colorsOfTest = repmat([120 120 120], prefs.nItems, 1);
		colorsOfTest(itemToTest(trialIndex), :) = [145 145 145];
		drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
		Screen('FillRect', window.onScreen, colorsOfTest', rects);
		
		drawColorWheel(window, prefs);
		SetMouse(window.centerX, window.centerY);
		ShowCursor('Arrow');
		
		everMovedFromCenter = false;
		
		[x,y,buttons] = GetMouse(window.onScreen);
		while any(buttons) % if already down, wait for release
			[x,y,buttons] = GetMouse(window.onScreen);
		end
		while ~any(buttons) % wait for press
		
			drawColorWheel(window, prefs);

			[x,y,buttons] = GetMouse(window.onScreen);
			[minDistance, minDistanceIndex] = min(sqrt((colorWheelLocations(1, :) - x).^2 + (colorWheelLocations(2, :) - y).^2));
						
			if(minDistance < 250)
				everMovedFromCenter = true;
			end
			
			if(everMovedFromCenter)
				colorsOfTest(itemToTest(trialIndex), :) = round(hsv2rgb(colorWheelColors(:, minDistanceIndex)')*255);
			else
				colorsOfTest(itemToTest(trialIndex), :) = [145 145 145];
			end
			
			drawFixation(window, window.centerX, window.centerY, prefs.fixationSize);
			Screen('FillRect', window.onScreen, colorsOfTest', rects);
			drawColorWheel(window, prefs);
			Screen('Flip', window.onScreen);
		end
		reportedColor(trialIndex) = minDistanceIndex;
		while any(buttons) % wait for releasessssss
			[x,y,buttons] = GetMouse(window.onScreen);
		end
		
		HideCursor
		
		% return to fixation
		returnToFixation(window, window.centerX, window.centerY, prefs.fixationSize);
		WaitSecs(0.5);
	end
	
	clear ans buttons x y minDistance minDistanceIndex trialIndex everMovedFromCenter colorsOfTest
	whos

	save data.mat
	postpareEnvironment;	
catch
	postpareEnvironment;
	psychrethrow(psychlasterror);
end
	
function prepareEnvironment
	clear all;
	HideCursor;
	commandwindow;
	rand('twister', sum(100*clock)); % seed the random number generator
	ListenChar(2);

function postpareEnvironment
	ShowCursor;
	ListenChar(0);
	Screen('CloseAll');
	
function instruct(window)
	Screen('TextSize', window.onScreen, window.fontsize);
	Screen('DrawText', window.onScreen, 'Remember the colors. Click to begin.', 100, 100, 255);
	Screen('Flip', window.onScreen);
	[clicks,x,y,whichButton] = GetClicks(window.onScreen);
	
function drawFixation(window, fixationX, fixationY, fixationSize)
	Screen('DrawDots', window.onScreen, [fixationX, fixationY], fixationSize, 255);
	
function offsets = circularArrayOffsets(n, centerX, centerY, radius, rotation)
	degreeStep = 360/n;
	offsets = [sind([0:degreeStep:(360-degreeStep)] + rotation)'.* radius, cosd([0:degreeStep:(360-degreeStep)] + rotation)'.* radius];
	
function rects = circularArrayRects(rect, nItems, radius, centerX, centerY)
	coor = circularArrayOffsets(nItems, centerX, centerY, radius, 0) + repmat([centerX centerY], nItems, 1);	
	rects = [coor(:, 1)-rect(3)/2 , coor(:, 2)-rect(3)/2, coor(:, 1)+rect(3)/2, coor(:, 2)+rect(3)/2];

function returnToFixation(window, fixationX, fixationY, fixationSize)
	Screen('FillRect', window.onScreen, window.bcolor);
	Screen('DrawDots', window.onScreen, [fixationX, fixationY], fixationSize, 255);
	Screen('Flip', window.onScreen);	

function window = openWindow()
	window.screenNumber = max(Screen('Screens'));
	[window.onScreen rect] = Screen('OpenWindow', window.screenNumber, [128 128 128],[],[],[],[]);
	Screen('BlendFunction', window.onScreen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
	[window.screenX, window.screenY] = Screen('WindowSize', window.onScreen); % check resolution
	window.screenRect  = [0 0 window.screenX window.screenY]; % screen rect
	window.centerX = window.screenX * 0.5; % center of screen in X direction
	window.centerY = window.screenY * 0.5; % center of screen in Y direction
	window.centerXL = floor(mean([0 window.centerX])); % center of left half of screen in X direction
	window.centerXR = floor(mean([window.centerX window.screenX])); % center of right half of screen in X direction
	
	% basic drawing and screen variables
	window.black    = BlackIndex(window.onScreen);
	window.white    = WhiteIndex(window.onScreen);
	window.gray     = mean([window.black window.white]);
	window.fontsize = 24;
	window.bcolor   = window.gray;	
	
function drawColorWheel(window, prefs)
	colorWheelColors = [[1:360]/360; ones(1, 360); ones(1, 360)];
	colorWheelLocations = [cosd([1:360]).*prefs.colorWheelRadius + window.centerX; sind([1:360]).*prefs.colorWheelRadius + window.centerY];
	colorWheelSizes = round(random('Uniform', 20, 20, 1, 360));
	Screen('DrawDots', window.onScreen, colorWheelLocations, colorWheelSizes, round(hsv2rgb(colorWheelColors')*255)', [], 1);

function prefs = getPreferences()
	prefs.nTrials = 3;
	prefs.nItems = 5;
	prefs.stimulusDuration = 0.100;
	prefs.retentionInterval = 0.900;	
	prefs.squareSize = 75; % in pixels
	prefs.radius = 160;
	prefs.fixationSize = 3;
	prefs.colorWheelRadius = 350;

