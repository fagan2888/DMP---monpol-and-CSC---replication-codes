function Flag = isSVAR(X)
% isSVAR  True if variable SVAR object.
%
% Syntax 
% =======
%
%     Flag = isSVAR(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a SVAR
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

Flag = isa(X,'SVAR');

end
