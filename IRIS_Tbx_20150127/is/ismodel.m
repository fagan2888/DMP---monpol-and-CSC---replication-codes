function Flag = ismodel(X)
% ismodel  True if variable is model object.
%
% Syntax 
% =======
%
%     Flag = ismodel(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a model
% object.
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

% @@@@@ MOSW
Flag = isa(X,'model') || isa(X,'modelobj');

end
