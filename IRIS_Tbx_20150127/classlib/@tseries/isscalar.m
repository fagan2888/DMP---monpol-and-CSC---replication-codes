function flag = isscalar(x)
% isscalar  True for scalar tseries objects.
%
% Syntax
% =======
%
%     flag = isscalar(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Input tseries object.
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True for tseries objects that have only one
% column.


% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%**************************************************************************

flag = ndims(x.data) == 2 && size(x.data,2) == 1;

end