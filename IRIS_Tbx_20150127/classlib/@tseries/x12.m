function varargout = x12(x,varargin)
% x12  Access to X13-ARIMA-SEATS seasonal adjustment program.
%
% Syntax with a single type of output requested
% ==============================================
%
%     [Y,OutpFile,ErrFile,Model,X] = x12(X,...)
%     [Y,OutpFile,ErrFile,Model,X] = x12(X,Range,...)
%
% Syntax with mutliple types of output requested
% ===============================================
%
%     [Y1,Y2,...,OutpFile,ErrFile,Model,X] = x12(X,Range,...)
%
% See the option `'output='` for the types of output data available from
% X12.
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input data that will seasonally adjusted or filtered
% by the Census X12 Arima.
%
% * `Range` [ numeric ] - Date range on which the X12 will be run; if not
% specified or Inf the entire available range will be used.
%
% Output arguments
% =================
%
% * `Y`, `Y1`, `Y2`, ... [ tseries ] - Requested output data, by default
% only one type of output is returned, the seasonlly adjusted data; see the
% option `'output='`.
%
% * `OutpFile` [ cellstr ] - Contents of the output log files produced by
% X12; each cell contains the log file for one type of output requested.
%
% * `ErrFile` [ cellstr ] - Contents of the error files produced by X12;
% each cell contains the error file for one type of output requested.
%
% * `Model` [ struct ] - Struct array with model specifications and parameter
% estimates for each of the ARIMA models fitted; `Model` matches the size
% of `X` is 2nd and higher dimensions.
%
% * `X` [ tseries ] - Original input data with forecasts and/or backcasts
% appended if the options `'forecast='` and/or `'backcast='` are used.
%
% Options
% ========
%
% * `'backcast='` [ numeric | *`0`* ] - Run a backcast based on the fitted
% ARIMA model for this number of periods back to improve on the seasonal
% adjustment; see help on the `x11` specs in the X13-ARIMA-SEATS manual. The
% backcast is included in the output argument `X`.
%
% * `'cleanup='` [ *`true`* | `false` ] - Delete temporary X12 files
% when done; the temporary files are named `iris_x12a.*`.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the input data before,
% and de-logarithmise the output data back after, running `x12`.
%
% * `'forecast='` [ numeric | *`0`* ] - Run a forecast based on the fitted
% ARIMA model for this number of periods ahead to improve on the seasonal
% adjustment; see help on the `x11` specs in the X13-ARIMA-SEATS manual. The
% forecast is included in the output argument `X`.
%
% * `'display='` [ `true` | *`false`* ] - Display X12 output messages in
% command window; if false the messages will be saved in a TXT file.
%
% * `'dummy='` [ tseries | *empty* ] - User dummy variable or variables (in
% case of a multivariate tseries object) used in X13-ARIMA-SEATS regression; the
% dummy variables must also include values for forecasts and backcasts if
% you request them; the type of the dummy can be specified in the option
% `'dummyType='`.
%
% * `'dummyType='` [ `'ao'` | *`'holiday'`* | `'td'` ] - Type of the user
% dummy (which is specified through the option `'dummy='`); the three basic
% types of dummies are additive outlier (`'ao'`), holiday flows
% (`'holiday'`), and trading days (`'td'`); see the X13-ARIMA-SEATS or X13-ARIMA
% documentation for more details (available from the U.S.Census Bureau
% website), look for the section on the REGRESSION spec, options 'user' and
% 'usertype'.
%
% * `'mode='` [ *`'auto'`* | `'add'` | `'logadd'` | `'mult'` |
% `'pseudoadd'` | `'sign'` ] - Seasonal adjustment mode (see help on the
% `x11` specs in the X13-ARIMA-SEATS manual); `'auto'` means that series
% with only positive or only negative numbers will be adjusted in the
% `'mult'` (multiplicative) mode, while series with combined positive and
% negative numbers in the `'add'` (additive) mode.
%
% * `'maxIter='` [ numeric | *`1500`* ] - Maximum number of iterations for
% the X12 estimation procedure. See help on the `estimation` specs in the
% X13-ARIMA-SEATS manual.
%
% * `'maxOrder='` [ numeric | *`[2,1]`* ] - A 1-by-2 vector with maximum
% order for the regular ARMA model (can be `1`, `2`, `3`, or `4`) and
% maximum order for the seasonal ARMA model (can be `1` or `2`). See help
% on the `automdl` specs in the X13-ARIMA-SEATS manual.
%
% * 'missing=' [ `true` | *`false`* ] - Allow for in-sample missing
% observations, and fill in values predicted by an estimated ARIMA process;
% if `false`, the seasonal adjustment will not run and a warning will be
% thrown.
%
% * `'output='` [ char | cellstr | *`'SA'`* ] - List of requested output
% data; the cellstr or comma-separated list can combine any number of the
% request specifications listed below in subsection Output request; See
% also help on the `x11` specs in the X13-ARIMA-SEATS manual.
%
% * `'saveAs='` [ char | *empty* ] - Name (or a whole path) under which
% X13-ARIMA-SEATS output files will be saved.
%
% * `'specFile='` [ char | *`'default'`* ] - Name of the X13-ARIMA-SEATS spec
% file; if `'default'` the IRIS default spec file will be used, see
% description.
%
% * `'tdays='` [ `true` | *`false`* ] - Correct for the number of trading
% days. See help on the `x11regression` specs in the X13-ARIMA-SEATS manual.
%
% * `'tempDir='` [ char | function_handle | `'.'` ] - Directory in which
% X13-ARIMA-SEATS temporary files will be created; if the directory does
% not exist, it will be created at the beginning and deleted at the end of
% the execution (unless `'cleanup=' false`).
%
% * `'tolerance='` [ numeric | *`1e-5`* ] - Convergence tolerance for the
% X13 estimation procedure. See help on the `estimation` specs in the
% X13-ARIMA-SEATS manual.
%
% Description
% ============
%
% Output requests
% ----------------
% 
% The option `'output=' can combine any number of the following requests:
%
% * `'SA'` - seasonally adjusted series;
%
% * `'SF'` - seasonal factors;
%
% * `'TC'` - trend-cycle component;
%
% * `'IR'` - irregular component;
%
% * `'MV'` - the original input series with missing values fitted by
% running an estimated ARIMA model.
%
% Missing observations
% ---------------------
%
% If you keep `'missing=' false` (this is the default for backward
% compatibility), `x12` will not run on series with in-sample missing
% observations, and a warning will be thrown.
%
% If you set `'missing=' true`, you allow for in-sample missing
% observations. The X13-ARIMA-SEATS program handles missing observations by
% filling in values predicted by the estimated ARIMA process. You can
% request the series with missing values filled in by including `MV` in the
% option `'output='`.
%
% Spec file
% ----------
%
% The default X13-ARIMA-SEATS spec file is `+thirdparty/x12/default.spc`. You can
% create your own spec file to include options that are not available
% through the IRIS interface. You can use the following pre-defined
% placeholders letting IRIS fill in some of the information needed (check
% out the default file):
%
% * `$series_data$` is replaced with a column vector of input observations;
% * `$series_freq$` is replaced with a number representing the date
% frequency: either 4 for quarterly, or 12 for monthly (other frequencies
% are currenlty not supported by X13-ARIMA-SEATS);
% * `$series_startyear$` is replaced with the start year of the input
% series;
% * `$series_startper$` is replaced with the start quarter or month of the
% input series;
% * `$transform_function$` is replaced with `log` or `none` depending on
% the mode selected by the user;
% * `$forecast_maxlead$` is replaced with the requested number of ARIMA
% forecast periods used to extend the series before seasonal adjustment.
% * `$forecast_maxlead$` is replaced with the requested number of ARIMA
% forecast periods used to extend the series before seasonal adjustment.
% * `$tolerance$` is replaced with the requested convergence tolerance in
% the `estimation` spec.
% * `$maxiter$` is replaced with the requested maximum number of iterations
% in the `estimation` spec.
% * `$maxorder$` is replaced with two numbers separated by a blank space:
% maximum order of regular ARIMA, and maximum order of seasonal ARIMA.
% * `$x11_mode$` is replaced with the requested mode: `'add'` for additive,
% `'mult'` for multiplicative, `'pseudoadd'` for pseudo-additive, or
% `'logadd'` for log-additive;
% * `$x12_save$` is replaced with the list of the requested output
% series: `'d10'` for seasonals, `'d11'` for final seasonally adjusted
% series, `'d12'` for trend-cycle, `'d13'` for irregular component.
%
% Two of the placeholders, `'$series_data$` and `$x12_output$`, are
% required; if they are not found in the spec file, IRIS throws an error.
%
% Estimates of ARIMA model parameters
% ------------------------------------
%
% The ARIMA model specification, `Model`, is a struct with three fields:
%
% * `.spec` - a cell array with the first cell giving the structure of the
% non-seasonal ARIMA, and the second cell giving the
% structure of the seasonal ARIMA; both specifications follow the usual
% Box-Jenkins notation, e.g. `[0 1 1]`.
%
% * `.ar` - a numeric array with the point estimates of the AR coefficients
% (non-seasonal and seasonal).
%
% * `.ma` - a numeric array with the point estimates of the MA coefficients
% (non-seasonal and seasonal).
%
% Example
% ========
%
% If you wish to run `x12` on the entire range on which the input time
% series is defined, and do not use any options, you can omit the second
% input argument (the date range). These following three calls to `x12` do
% exactly the same:
%
%     xsa = x12(x);
%     xsa = x12(x,Inf);
%     xsa = x12(x,get(x,'range'));
%
% Example
% ========
%
% If you wish to specify some of the options, you have to enter a date
% range or use `Inf`:
%
%     xsa = x12(x,Inf,'mode=','add');
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.


if ~isempty(varargin) && ~ischar(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

opt = passvalopt('tseries.x12',varargin{:});

if strcmp(opt.mode,'sign')
    opt.mode = 'auto';
end

if nargin > 1 && ~isnumeric(Range)
    error('Incorrect type of input argument(s).');
end

if nargin < 2
    Range = Inf;
end
Range = specrange(x,Range);

doOutput();

%--------------------------------------------------------------------------

nOutp = length(opt.output);
co = comment(x);
tmpsize = size(x.data);
x.data = x.data(:,:);
[data,Range] = rangedata(x,Range);

% Extended range with backcasts and forecasts.
xRange = Range(1)-opt.backcast : Range(end)+opt.forecast;

% Fill in zeros for NaNs in dummy variables on the extended range.
dummy = [];
if ~isempty(opt.dummy) && isa(opt.dummy,'tseries')
    dummy = rangedata(opt.dummy,xRange);
    dummy = dummy(:,:);
    doChkDummy();
end

if opt.log
    data = log(data);
end

[data,varargout{1:nOutp},varargout{nOutp+(1:3)}] = ...
    thirdparty.x12.x12(data,Range(1),dummy,opt);

for i = 1 : nOutp
    if opt.log
        varargout{i} = exp(varargout{i});
    end
    varargout{i} = ...
        reshape(varargout{i},[size(varargout{i},1),tmpsize(2:end)]);
    varargout{i} = replace(x,varargout{i},Range(1),co);
end

% Reshape the model spec struct to match the dimensions and size of input
% and output tseries.
if length(tmpsize) > 2
    varargout{nOutp+3} = ...
        reshape(varargout{nOutp+3},[1,tmpsize(2:end)]);
end

% Return original series with forecasts and backcasts.
if nargout >= nOutp+3
    x.start = x.start - opt.backcast;
    x.data = data;
    if length(tmpsize) > 2
        x.data = reshape(x.data,[size(x.data,1),tmpsize(2:end)]);
    end
    x = mytrim(x);
    varargout{nOutp+4} = x;
end


% Nested functions...


%**************************************************************************


    function doOutput()
        subs = struct();
        subs.d10 = 'sf|seasonals|seasonal|seasfactors|seasfact';
        subs.d11 = 'sa|seasadj';
        subs.d12 = 'tc|trend|trendcycle';
        subs.d13 = 'ir|irregular';
        subs.mv = 'missing|missingvaladj';
        
        opt.output = lower(opt.output);
        list = fieldnames(subs);
        for ii = 1 : length(list)
            repl = list{ii};
            patt = ['\<(',subs.(repl),')\>'];
            opt.output = regexprep(opt.output,patt,repl);
        end
        opt.output = strtrim(opt.output);
        % Handle comma-separated char lists.
        if ischar(opt.output)
            opt.output = regexp(opt.output,'\w+','match');
        end
    end % doOutput()


%**************************************************************************


    function doChkDummy()
        dummyIn = dummy(opt.backcast+1:end-opt.forecast,:);
        dummyFcast = dummy(end-opt.forecast+1:end,:);
        dummyBcast = dummy(1:opt.backcast,:);
        if any(isnan(dummyIn(:)))
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) in-sample ', ...
                'missing observations or NaNs. ', ...
                'The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyFcast(:)))
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the forecast range. The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyBcast(:)))
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the backcast range. The NaNs will be replaced with zeros.']);
        end
        dummy(isnan(dummy)) = 0;
    end % doChkDummy()


end