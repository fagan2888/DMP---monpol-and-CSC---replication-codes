function [Ax,hLhs,hRhs,RangeLhs,dataLhs,timeLhs,RangeRhs,dataRhs,timeRhs] ...
    = plotyy(varargin)
% plotyy  Line plot function with LHS and RHS axes for time series.
%
% Syntax
% =======
%
%     [Ax,Lhs,Rhs,Range] = plotyy(X,Y,...)
%     [Ax,Lhs,Rhs,Range] = plotyy(Range,X,Y,...)
%
% Input arguments
% ================
%
% * `Range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be plotted
% and labelled on the LHS.
%
% * `Y` [ tseries ] - Input tseries object whose columns will be plotted
% and labelled on the RHS.
%
% Output arguments
% =================
%
% * `Ax` [ handle | numeric ] - Handles to the LHS and RHS axes.
%
% * `Lhs` [ handle | numeric ] - Handles to series plotted on the LHS axis.
%
% * `Rhs` [ handle | numeric ] - Handles to series plotted on the RHS axis.
%
% * `Range` [ handle | numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'coincide='` [ `true` | *`false`* ] - Make the LHS and RHS y-axis
% grids coincide.
%
% * `'lhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the LHS data.
%
% * `'lhsTight='` [ `true` | *`false`* ] - Make the LHS y-axis tight.
%
% * `'rhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the RHS data.
%
% * `'rhsTight='` [ `true` | *`false`* ] - Make the RHS y-axis tight.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `plotyy` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% Range for LHS time series.
if isnumeric(varargin{1})
    RangeLhs = varargin{1};
    varargin(1) = [];
else
    RangeLhs = Inf;
end

% LHS time series.
XLhs = varargin{1};
varargin(1) = [];

% Range for RHS time series.
if isnumeric(varargin{1})
    RangeRhs = varargin{1};
    varargin(1) = [];
else
    RangeRhs = RangeLhs;
end

% RHS time series.
XRhs = varargin{1};
varargin(1) = [];

[opt,varargin] = passvalopt('tseries.plotyy',varargin{:});

%--------------------------------------------------------------------------

% Check consistency of ranges and time series.
% LHS.
if ~all(isinf(RangeLhs)) && ~isempty(RangeLhs) && ~isempty(XLhs) ...
        && isa(XLhs,'tseries')
    if datfreq(RangeLhs(1)) ~= get(XLhs,'freq')
        utils.error('tseries:plotyy', ...
            ['LHS range and LHS time series must have ', ...
            'the same date frequency.']);
    end
end
% RHS.
if ~all(isinf(RangeRhs)) && ~isempty(RangeRhs) && ~isempty(XRhs) ...
        && isa(XRhs,'tseries')
    if datfreq(RangeRhs(1)) ~= get(XRhs,'freq')
        utils.error('tseries:plotyy', ...
            ['RHS range and RHS time series must have ', ...
            'the same date frequency.']);
    end
end

% Mimic plotting the RHS graph without creating an axes object.
[~,~,~,~,RangeRhs,dataRhs,timeRhs,userRangeRhs,freqRhs] = ...
    tseries.myplot(0,[],RangeRhs,XRhs); %#ok<ASGLU>

% Mimic plotting the LHS graph without creating an axes object.
comprise = timeRhs([1,end]);
[~,~,~,~,RangeLhs,dataLhs,timeLhs,userRangeLhs,freqLhs] = ...
    tseries.myplot(0,[],{RangeLhs,comprise},XLhs);

% Plot now.
dataLhsPlot = grfun.myreplacenancols(dataLhs,Inf);
dataRhsPlot = grfun.myreplacenancols(dataRhs,Inf);
lhsPlotFuncStr = opt.lhsplotfunc;
rhsPlotFuncStr = opt.rhsplotfunc;
if isfunc(lhsPlotFuncStr)
    lhsPlotFuncStr = func2str(lhsPlotFuncStr);
end
if isfunc(rhsPlotFuncStr)
    rhsPlotFuncStr = func2str(rhsPlotFuncStr);
end
[Ax,hLhs,hRhs] = plotyy(timeLhs,dataLhsPlot,timeRhs,dataRhsPlot, ...
    lhsPlotFuncStr,rhsPlotFuncStr);

% Apply line properties passed in by the user as optional arguments. Do
% it separately for `hl` and `hr` because they each can be different types.
if ~isempty(varargin)
    try %#ok<*TRYNC>
        set(hLhs,varargin{:});
    end
    try
        set(hRhs,varargin{:});
    end
end

setappdata(Ax(1),'tseries',true);
setappdata(Ax(1),'freq',freqLhs);
setappdata(Ax(1),'range',RangeLhs);
setappdata(Ax(1),'datePosition',opt.dateposition);

setappdata(Ax(2),'tseries',true);
setappdata(Ax(2),'freq',freqRhs);
setappdata(Ax(2),'range',RangeRhs);
setappdata(Ax(2),'datePosition',opt.dateposition);

if strcmp(lhsPlotFuncStr,'bar') || strcmp(rhsPlotFuncStr,'bar')
    setappdata(Ax(1),'xLimAdjust',true);
    setappdata(Ax(2),'xLimAdjust',true);
end

% Prevent LHS y-axis tick marks on the RHS, and vice versa by turning the
% box off for both axis. To draw a complete box, add a top edge line by
% displaying the x-axis at the top in the first axes object (the x-axis is
% empty, has no ticks or labels).
set(Ax,'box','off');
set(Ax(2),'color','none', ...
    'xTickLabel','', ...
    'xTick',[], ...
    'xAxisLocation','top');
try
    Ax(2).XRuler.Visible = 'on';
end

mydatxtick(Ax(1),RangeLhs,timeLhs,freqLhs,userRangeLhs,opt);

% For bkw compatibility only, not documented. Use of `highlight` outside
% `plotyy` is now safe.
if ~isempty(opt.highlight)
    highlight(Ax(1),opt.highlight);
end

if opt.lhstight || opt.tight
    grfun.yaxistight(Ax(1));
end

if opt.rhstight || opt.tight
    grfun.yaxistight(Ax(2));
end

% Make sure the RHS axes object is on the background. We need this for e.g.
% `plotcmp` graphs.
grfun.swaplhsrhs(Ax(1),Ax(2));

if ~opt.coincide
    set(Ax,'yTickMode','auto');
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = hLhs(:).'
    setappdata(ih,'dateLine',RangeLhs);
end
for ih = hRhs(:).'
    setappdata(ih,'dateLine',RangeRhs);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in
    % `utils.datacursor', we also handle cases where the current figure
    % includes both tseries and non-tseries graphs.
    obj = datacursormode(gcf());
    set(obj,'updateFcn',@utils.datacursor);
else
    % Do nothing.
end
end
