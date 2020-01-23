function ColNames = colnames(This)
% colnames  Names of columns in namedmat object.
%
% Syntax
% =======
%
%     ColNames = colnames(X)
%
% Input arguments
% ================
%
% * `X` [ namedmat ] - A namedmat object (array with named rows and
% columns) returned as output argument from some model functions.
%
% Output arguments
% =================
%
% * `ColNames` [ cellstr ] - Names of columns in `X`.
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

ColNames = This.ColNames;

end
