function data = MemData(whichData)    

    if(nargin < 1)
        whichData = 1;
    end

    switch whichData

    % sperling (1960) partial report data.
    case 1
        data.times = [0 150 300 1000];
        data.n = 12;
        data.numStored = [9.3, 7.3, 6.2, 4.5];
        data.goodFitMoran = [16, 12.3, -1.28, 0.71];

    % adelson & jonides (1980) patial report figure 2 panel a
    % this panel is special because its stimuli were displayed at a
    % luminance low enough that it affected visibility.
    case 2
        data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
        data.n = 8;
        data.numStored = [6.4, 5.9, 5.7, 4.8, 4.6, 3.7];
    
    % adelson & jonides (1980) patial report figure 2 panel b
    case 3
        data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
        data.n = 8;
        data.numStored = [7.7, 7.0, 6.3, 5.2, 4.7, 3.9];

    % adelson & jonides (1980) patial report figure 2 panel c
    case 4
        data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
        data.n = 8;
        data.numStored = [7.9, 6.9, 6.3, 5.8, 5.0, 4.5];

    % adelson & jonides (1980) patial report figure 2 panel c
    case 5
        data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
        data.n = 8;
        data.numStored = [7.9, 7.0, 6.9, 5.7, 5.1, 4.1];
        
    % zhang & luck (2008) working memory figure 2
    case 6
        data.times = [900];
        data.n = [1, 2, 3, 6];
        data.numStored = [0.99, 1.9, 2.49, 2.28]; 
        data.precision = [13.9, 19.4, 21.9, 22.3];
        
    % bays & husain (2008) figure 2b, location
    case 7
        data.times = [500];
        data.n = [1, 2, 4, 6];
        data.precision = [0.96, 1.6, 2.9, 6.3];
        
    % bays & husain (2008) figure 2b, orientation
    case 8
        data.times = [500];
        data.n = [1, 2, 4, 6];
        data.precision = [18.9, 28.6, 52.6, 55.6];
        
    % hahn (2010), figure 2, healthy controls
    % excludes -200 ms precue
    case 9
        data.times = [0, 33, 67, 100, 150, 200, 250, 350, 500, 750, 1000];
        data.n = 6;
        data.proportionCorrect = [.871, .845, .827, .819, .778, .759, .716, .662, .568, .572, .499];
        data.m = 15; % number of alternatives (15 possible letters)
        data.numStored = [5.17, 5.00, 4.89, 4.84, 4.57, 4.45, 4.17, 3.83, 3.22, 3.25, 2.78];

    % hahn (2010), figure 2, people with schizophrenia
    % excludes -200 ms precue
    case 10
        data.times = [0, 33, 67, 100, 150, 200, 250, 350, 500, 750, 1000];
        data.n = 6;
        data.proportionCorrect = [0.791, 0.737, 0.716, 0.701, 0.678, 0.641, 0.611, 0.563, 0.485, 0.487, 0.434];
        data.m = 15;
        data.numStored = [4.66, 4.31, 4.17, 4.08, 3.93, 3.69, 3.51, 3.19, 2.69, 2.70, 2.36];
        data.goodFitMoran = [9,3.25,-4.02,3]; % nQ, tC, tau, s
    
    % yang (1999), fig. 3.11, subject LX
    case 11
        data.times = [67, 341, 536, 744, 1140, 1936, 2932];
        data.n = 8;
        data.proportionCorrect = [0.938, 0.735, 0.652, 0.587, 0.507, 0.416, 0.351];
        data.m = 4;
        data.numStored = [7.34, 5.17, 4.29, 3.59, 2.74, 1.77, 1.08];
    
    % yang (1999), fig. 3.11, subject YS
    case 12
        data.times = [62, 163, 261, 366, 564, 960, 1462];
        data.n = 8;
        data.proportionCorrect = [0.792, 0.695, 0.607, 0.536, 0.472, 0.415, 0.410];
        data.m = 4;
        data.numStored = [5.78, 4.75, 3.81, 3.05, 2.37, 1.76, 1.71];
        data.goodFitMoran = [9, 20, 0, 15.5510];
        
    % yang (1999), fig. 3.11, subject WY
    case 13
        data.times = [62, 163, 261, 366, 564, 960, 1462];
        data.n = 8;
        data.proportionCorrect = [0.860, 0.759, 0.682, 0.643, 0.580, 0.505, 0.468];
        data.m = 4;
        data.numStored = [6.51, 5.43, 4.61, 4.19, 3.52, 2.72, 2.33];
        data.goodFitMoran = [10, 22, -0.75, 15.5510];
    
    % yang (1999), fig. 3.11, subject KB
    case 14
        data.times = [62, 163, 261, 366, 564, 960, 1462];
        data.n = 8;
        data.proportionCorrect = [0.906, 0.810, 0.728, 0.697, 0.584, 0.526, 0.496];
        data.m = 4;
        data.numStored = [7.00, 5.97, 5.10, 4.77, 3.56, 2.94, 2.62];
        data.goodFitMoran = [11, 32.5478, 0.3903, 23.0860];
        
    % in house zhang & luck (2009) replication
    % moves -100 ms precue to 0 ms
    case 15 
        data.times = [0, 150, 300, 1000, 4000, 10000];
        data.n = 3;
        data.numStored = [2.8263, 2.6732, 2.4895, 2.5741, 2.1076, 1.8662];
    
    % zhang & luck (2009) sudden death, color
    case 16
        data.times = [1000, 4000, 10000];
        data.n = 3;
        data.numStored = [2.22, 2.22, 1.83];
        data.precision = [22.9, 24.4, 24.4];
        
    % zhang & luck (2009) sudden death, shape
    case 17
        data.times = [1000, 4000, 10000];
        data.n = 3;
        data.numStored = [1.80, 1.74, 1.38];
        data.precision = [29.0, 34.0, 37.0];
    
    % simulated from standard model
    case 18
        data.n = 12;
        data.times =  [0.10, 0.167, 0.2783, 0.4642, 0.7743, 1.2915, 2.1544, 3.5938, 5.9948, 10];
        data.numStored = [11, 10.7, 9.9, 8.6, 7, 5.4, 3.9, 3.0, 2.6, 2.3];
   
    otherwise
        error('Sorry, that''s not one of the available datasets.')
    end