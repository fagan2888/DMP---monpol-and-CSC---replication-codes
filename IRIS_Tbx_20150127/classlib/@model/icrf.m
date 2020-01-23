function [S,Range,Select] = icrf(This,Time,varargin)
% icrf  Initial-condition response functions.
%
% Syntax
% =======
%
%     S = icrf(M,NPer,...)
%     S = icrf(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the initial condition responses
% will be simulated.
%
% * `Range` [ numeric ] - Date range with the first date being the shock
% date.
%
% * `NPer` [ numeric ] - Number of periods.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with initial condition response series.
%
% Options
% ========
%
% * `'delog='` [ *`true`* | `false` ] - Delogarithmise the responses for
% variables declared as `!log_variables`.
%
% * `'size='` [ numeric | *`1`* for linear models | *`log(1.01)`* for non-linear
% models ] - Size of the deviation in initial conditions.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.icrf',varargin{:});

% TODO: Introduce `'select='` option.

%--------------------------------------------------------------------------

nb = size(This.solution{1},2);

% Set the size of the initial conditions.
if isempty(opt.size)
    % Default.
    if This.IsLinear
        icSize = ones(1,nb);
    else
        icSize = ones(1,nb)*log(1.01);
    end
else
    % User supplied.
    icSize = ones(1,nb)*opt.size;
end

Select = get(This,'initCond');
Select = regexprep(Select,'log\((.*?)\)','$1','once');
icIx = any(This.icondix,3);

func = @(T,R,K,Z,H,D,U,Omg,~,NPer) ...
    timedom.icrf(T,[],[],Z,[],[],U,[], ...
    NPer,icSize,icIx);

[S,Range] = myrf(This,Time,func,Select,opt);

end