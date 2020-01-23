function irisreset(varargin)
% irisreset  Reset IRIS configuration options to start-up values.
%
% Syntax
% =======
%
%     irisreset
%
% Description
% ============
%
% The `irisreset` function resets all configuration options to their
% default factory values, or to those in the active `irisuserconfig.m` file
% (if one exists).

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

irisconfig(varargin{:});

end