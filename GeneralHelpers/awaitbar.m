function fout = awaitbar(x,whichbar,varargin)
  % AWAITBAR displays waitbar with abort button
  %
  % Clicking on the ABORT or the CLOSE button of the waitbar
  % figure will abort the loop and close the waitbar.
  %
  % USAGE:
  %   H = awaitbar(x,message) creates and displays a waitbar of fractional length X
  %   with the message text in the waitbar figure. The handle to the waitbar figure
  %   is returned in H. x should be between 0 and 1.
  %
  %   H = awaitbar(x,message,figTitle) displays string figTitle in the figure title
  %
  %   H = awaitbar(x,message,figTitle,figPosition) positions the figure according to
  %   the value specified in figPosition (x,y co-ordinates in Points of left bottom
  %   corner of the awaitbar)
  %
  %   abort = awaitbar(x) will update in the most recently created waitbar
  %   window. The output "abort" is either empty or has value true when user
  %   click the abort button of the awaitbar. You can use the variable
  %   "abort" to terminate the loop.
  %
  %   abort = awaitbar(x,H,...) will update in waitbar H
  %
  % FEATURES
  % 1.  Abort button to abort the loop and close the waitbar figure.
  % 1.  It stays on top of other figures. % Thanks to Peder Axensten(11398).
  % 2.  Only one waitbar window, so no old ones left around. Thanks to Peder Axensten(11398).
  % 5.  Elapsed time and Estimated Remaining time are shown in the figure.
  % 6.  Update of the progress is also shown in the figure title.
  % 7.  User defined figure position.
  %
  % EXAMPLES:
  %
  %   h = awaitbar(0,'Running Monte-Carlo, please wait...');
  %   for i=1:n
  %       pause(0.05); % Do stuff
  %       abort = awaitbar(i/n,h,['run :' num2str(i)]);  % with update message
  %       if abort; break; end
  %   end
  %
  % HISTORY:
  % version 1.0.0, Release 2007/06/07: Initial release
  % version 1.1.0, Release 2007/10/11: Some bug fixes and improvement of help text
  %    1. line 74, checking ishandle(f)
  %    2. Rearangement of codes for logical flow
  % version 1.2.0, Release 2008/03/15: If x==0 then it gives the message that output
  %                argument fout has not assigned during call. fout =f; has been added
  %                to the line 243. But it has not been uploaded to Mathworks
  % version 1.3.0, Release 2008/04/25: In previous verion abort button was not working
  %                when awaitbar is called from function. Now this was fixed
  %                with the use of setappdata and getappdata
  %
  % Modified by TFB, 8/15, to be less ugly.
  %
  % See also WAITBAR, WAITBAR(11398)

  % I appreciate the bug reports and suggestions.
  %
  % Copyright 2008 by Durga Lal Shrestha.
  % eMail: durgals@hotmail.com
  % $Date: 2007/06/07
  % $Revision: 1.3.0 $ $Date: 2008/04/25 $
  %
  %% Argument check
  error(nargchk(1,4,nargin))

  figTitle = 'Progress';             % default title

  if nargin>=2
    if ischar(whichbar)            % h =awaitbar(0,'Please wait...');
      % Delete all pre-existing waitbar graphical objects (Thanks to Peder Axensten(11398)
      showhid=get(0, 'showhid');
      set(0, 'showhid', 'on');
      try delete(findobj('Tag', 'TMWAWaitbar')); catch end
      set(0, 'showhid', showhid);
      type = 1;	% We are initializing
      name=whichbar;
      t0=clock;
      if nargin>=3               % h =awaitbar(0,'Please wait...','Figure Title');
        figTitle = varargin{1};
      end
    elseif isnumeric(whichbar)     % abort = awaitbar(i/n,h);
      type = 2;                  % We are updating, given a handle
      f=whichbar;
      if ~ishandle(f)            % if there is no awaitbar, then force to abort the loop as well
        fout = true;
        return
      end
    else
      error('AWaitbar:InvalidInputs', ['Input arguments of type ' class(whichbar) ' not valid.'])
    end

  elseif nargin==1                   % abort = awaitbar(i/n);
    f = findobj(allchild(0),'flat','Tag','TMWAWaitbar');
    if isempty(f)                  % if there is no awaitbar, then force to abort the loop as well
      fout = true;
      return
    else
      type = 2;                  % updating of the awaitbar
      f=f(1);
    end
  else
    error('AWaitbar:InvalidArguments', 'Input arguments not valid.');
  end

  % if completed the job, then close the figure
  if x==1;
    fout = true;
    if ishandle(f)
      delete(f);
    end
    return
  end

  x = max(0,min(100*x,100));

  switch type
    case 1
      %% Initialize
      oldRootUnits = get(0,'Units');
      set(0, 'Units', 'points');
      screenSize = get(0,'ScreenSize');
      axFontSize=get(0,'FactoryAxesFontSize');
      pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
      width = 360 * pointsPerPixel;
      height = 120 * pointsPerPixel;
      % Set figure position
      if nargin==4
        fig_pos = varargin{2};
        pos = [fig_pos(1) fig_pos(2) width height];
      else
        pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
      end

      % Main waitbar figure
      f = figure(...
        'Units', 'points', ...
        'Position', pos, ...
        'Resize','off', ...
        'CreateFcn','', ...
        'NumberTitle','off', ...
        'IntegerHandle','off', ...
        'MenuBar', 'none', ...
        'Tag','TMWAWaitbar',...
        'Visible','on',...
        'name',figTitle,...
        'UserData',t0);

      % Abort button
      uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'FontWeight','bold',...
        'FontSize',11,'units','Points','Position', [0.8.*width  3 50 30],...
        'Callback', 'setappdata(gcf, ''abort'', true)');
      colormap([]);
      axNorm=[.05 .55 .82 .2];
      axPos=axNorm.*[pos(3:4),pos(3:4)];

      % Label "Time Elapsed"
      uicontrol('Parent',f,...
        'Units','points',...
        'Position',[pos(3).*0.08 pos(4).*0.25 pos(3).*0.45 pos(4).*0.17],...
        'String','Time Elapsed:',...
        'BackgroundColor', [0.80 0.80 0.80],...
        'Style','text');

      % Label "Estimated Time Remaining"
      uicontrol('Parent',f,...
        'Units','points',...
        'Position',[pos(3).*0.00 pos(4).*0.05 pos(3).*0.45 pos(4).*0.17],...
        'String','Estimated Time Remaining:',...
        'BackgroundColor', [0.80 0.80 0.80],...
        'Style','text');

      % Tag for "Time Elapsed"
      uicontrol('Parent',f,...
        'Units','points',...
        'Position',[pos(3).*0.40 pos(4).*0.25 pos(3).*0.15 pos(4).*0.17],...
        'BackgroundColor', [0.80 0.80 0.80],...
        'Style','text',...
        'Tag','lapseTag');

      % Tag for "Estimated Time Remaining"
      uicontrol('Parent',f,...
        'Units','points',...
        'Position',[pos(3).*0.40 pos(4).*0.05 pos(3).*0.15 pos(4).*0.17],...
        'BackgroundColor', [0.80 0.80 0.80],...
        'Style','text',...
        'Tag','etaTag');

      % Tag for "Percentage completed"
      uicontrol('Parent',f,...
        'Units','points',...
        'Position',[pos(3).*0.88 pos(4).*0.55 pos(3).*.11 pos(4).*0.20],...
        'String','%',...
        'Style','text',...
        'BackgroundColor', [0.80 0.80 0.80],...
        'ForegroundColor',[1 0 0],...
        'FontSize',10,...
        'FontWeight','bold',...
        'Tag','percentTag');

      % Axis for waitbar
      h = axes('XLim',[0 100],...
        'YLim',[0 1],...
        'Box','on', ...
        'Units','Points',...
        'FontSize', axFontSize,...
        'Position',axPos,...
        'XTickMode','manual',...
        'YTickMode','manual',...
        'XTick',[],...
        'YTick',[],...
        'XTickLabelMode','manual',...
        'XTickLabel',[],...
        'YTickLabelMode','manual',...
        'YTickLabel',[]);

      tHandle=get(h,'title');
      set(tHandle,...
        'Units',      'points',...
        'String',     name,'FontSize',11);

      xpatch = [0 x x 0];
      ypatch = [0 0 1 1];
      xline = [100 0 0 100 100];
      yline = [0 0 1 1 0];
      patch(xpatch,ypatch,'r','EdgeColor','r','EraseMode','none');
      l = line(xline,yline,'EraseMode','none');
      set(l,'Color',get(gca,'XColor'));
      set(f,'HandleVisibility','callback','visible','on');
      set(0, 'Units', oldRootUnits);

      % save figTitle to load agian
      setappdata(f, 'figTitle', figTitle);

      %% UPDATE OF WAITBAR
    case 2,
      try
        p = findobj(f,'Type','patch');
        l = findobj(f,'Type','line');
        lapseObj = findobj(f,'Tag','lapseTag');
        etaObj = findobj(f,'Tag','etaTag');
        percentObj = findobj(f,'Tag','percentTag');
        if isempty(f) || isempty(p) || isempty(l) || isempty(lapseObj)||isempty(etaObj)||isempty(percentObj),
          error('Couldn''t find Awaitbar handles.');
        end
        % Showing progress in figure title as well
        % load figTitle
        figTitle=getappdata(f,'figTitle');
        set(f,  'Name',   [num2str(floor(x)) '% ' figTitle]);
        t0= get(f,'UserData');
        xpatch = [0 x x 0];
        set(p,'XData',xpatch')
        xline = get(l,'XData');
        set(l,'XData',xline);
        time_lapse = etime(clock,t0);
        time_lapse = round(time_lapse);

        if(x~=0),time_eta=(time_lapse/x)*(100-x);else fout = f;return; end;

        time_eta=round(time_eta);
        str_lapse= get_timestr(time_lapse);
        str_eta= get_timestr(time_eta);
        set(lapseObj,'String',str_lapse);
        set(etaObj,'String',str_eta);
        set(percentObj,'String',strcat(num2str(floor(x)),'%'));
        if nargin>2,
          % Update awaitbar title:
          hAxes = findobj(f,'type','axes');
          hTitle = get(hAxes,'title');
          set(hTitle,'string',varargin{1});
        end
      catch
        % Catch block
        close(findobj(allchild(0),'flat','Tag','TMWAWaitbar'));
        error('Awaitbar:InvalidArguments','Improper arguments for awaitbar');
      end
  end  % end case

  drawnow;

%   %% Put the waitbar window on top of all others (Thanks to Peder Axensten(11398).
%   children=allchild(0);
%   if((numel(children) > 1) && (children(1) ~= f))
%     uistack(f, 'top');
%   end

  %--------------------------------------------------------------------------
  % Handle the output correctly when clicking the abort button or
  % closing the figure or finishing the job etc.

  if type == 1;                      % initializing
    fout = f;
  elseif ishandle(f)                 % if figure is not closed, then check the
    fout = getappdata(f, 'abort'); % application data when the user click the abort button
    if fout; delete(f);end         % delete the figure if use click the abort button
    % and returns the true
  else
    fout=true;                    % if figure is close then also return true to abort the loop
  end

end % End of main function

%% Internal Function
function timestr= get_timestr(s) %(Thanks to Peder Axensten(11398).
  %Return a time string, given seconds.

  h = floor(s/3600);					% Hours.
  s = s - h*3600;
  m = floor(s/60);						% Minutes.
  s = s - m*60;							% Seconds.
  timestr=	sprintf('%0d:%02d:%02d', h, m, floor(s));
end
