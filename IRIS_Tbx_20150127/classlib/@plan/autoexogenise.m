function This = autoexogenise(This,List,Dates,Sigma)
% autoexogenise  Exogenise variables and automatically endogenise corresponding shocks.
%
% Syntax
% =======
%
%     P = autoexogenise(P,List,Dates)
%     P = autoexogenise(P,List,Dates,Sigma)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char | `@all` ] - List of variables that will be
% exogenised; these variables must have their corresponding shocks
% assigned, see [`!autoexogenise`](modellang/autoexogenise); `@all` means
% all autoexogenised variables defined in the model object will be
% exogenised.
%
% * `Dates` [ numeric ] - Dates at which the variables will be exogenised.
%
% * `Sigma` [ `1` | `1i` | numeric ] - Anticipation mode (real or
% imaginary) for endogenized shocks, and their numerical weight (used
% in underdetermined simulation plans); if omitted, `Sigma = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenised
% variables and endogenised shocks included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Sigma;
catch
    Sigma = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('List',@(x) ischar(x) || iscellstr(x) || isequal(x,@all));
pp.addRequired('Dates',@isnumeric);
pp.addRequired('Sigma', ...
    @(x) isnumericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 && x ~= 0);
pp.parse(List,Dates,Sigma);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

n = length(This.XList);
nList = numel(List);
valid = true(1,nList);
ixX = false(1,n);
ixN = false(1,n);

if isequal(List,@all)
    ixX = ~isnan(This.AutoX);
else
    for i = 1 : nList
        xPos = find(strcmp(This.XList,List{i}));
        if isempty(xPos)
            valid(i) = false;
            continue
        end
        ixX(xPos) = true;
    end
end

for i = find(ixX)
    nPos = This.AutoX(i);
    if isnan(nPos)
        valid(i) = false;
        continue
    end
    ixN(nPos) = true;
end

if any(~valid)
    utils.error('plan:autoexogenise', ...
        'Cannot autoexogenise this name: ''%s''.', ...
        List{~valid});
end

if any(ixX)
    This = exogenise(This,This.XList(ixX),Dates);
    This = endogenise(This,This.NList(ixN),Dates,Sigma);
end

end
