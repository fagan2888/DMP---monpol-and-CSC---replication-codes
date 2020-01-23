function N = length(This)
% length  Number of alternative parameterisations in VAR object.
%
% Syntax
% =======
%
%     N = length(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
%
% * `N` [ numeric ]  - Number of alternative parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = size(This.A,3);

end
