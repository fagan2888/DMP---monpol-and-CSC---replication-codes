function X = interp(X,varargin)
% interp  Interpolate missing observations.
%
% Syntax
% =======
%
%     X = interp(X,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ tseries ] - Date range on which any missing, i.e. NaN,
% observations will be interpolated.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Tseries object with the missing observations
% interpolated.
%
% Options
% ========
%
% * `'method='` [ char | *`'cubic'`* ] - Any valid method accepted by the
% built-in `interp1` function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if ~isempty(varargin) && ~ischar(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

opt = passvalopt('tseries.interp',varargin{:});

if isempty(X)
    return
end

%--------------------------------------------------------------------------

if isequal(Range,Inf)
    Range = get(X,'range');
elseif ~isempty(Range)
    Range = Range(1) : Range(end);
    X.data = rangedata(X,Range);
    X.start = Range(1);
else
    X = empty(X);
    return
end

data = X.data(:,:);
grid = dat2dec(Range,'centre');
grid = grid - grid(1);
for i = 1 : size(data,2)
    inx = ~isnan(data(:,i));
    if any(~inx)
        data(~inx,i) = interp1(...
            grid(inx),data(inx,i),grid(~inx),opt.method,'extrap');
    end
end

X.data(:,:) = data;

end