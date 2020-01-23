function [Ln,Cp] = zeroline(varargin)
% zeroline  Add zero line if Y-axis limits include zero.
%
% Syntax
% =======
%
%     Ln = zeroline(...)
%     Ln = zeroline(H,...)
%
% Input arguments
% ================
%
% * `H` [ numeric ] - Handle to an axes object (graph) or to a figure
% window in which the the line will be added; if not specified the line
% will be added to the current axes.
%
% Output arguments
% =================
%
% * `Ln` [ numeric ] - Handle to the line ploted (line object).
%
% Options
% ========
%
% Any options valid for the standard `plot` function.
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

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [];
else
    Ax = gca();
end

[Ln,Cp] = grfun.myinfline(Ax,'h',0,varargin{:});

% Tag the line for `qstyle`.
set(Ln,'tag','zeroline');

end