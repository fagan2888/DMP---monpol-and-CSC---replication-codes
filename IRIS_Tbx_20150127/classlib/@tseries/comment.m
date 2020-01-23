function This = comment(This,varargin)
% comment  Get or set user comments in a tseries object.
%
% Syntax for getting user comments
% =================================
%
%     Cmt = comment(X)
%
% Syntax for assigning user comments
% ===================================
%
%     X = comment(X,Cmt)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% * `Cmt` [ char | cellstr ] - Comment or comments that will be assigned to
% each column in the input tseries object.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Tseries object with new comments.
%
% * `Cmt` [ cellstr ] - Comments from the tseries object.
%
% Description
% ============
%
% Multivariate tseries have comments for each of the columns. When
% assigning comments (using the syntax with two input arguments) you can
% either pass in a char (text string) or a cellstr (a cell array of
% strings). If `Cmt` is a char, then this same comment will be assigned to
% all of the tseries columns. If `Cmt` is a cellstr, its size in the 2nd
% and higher dimensions must match the size of the tseries data; the
% individual strings from `Cmt` will be then copied to the comments
% belonging to the individual tseries columns.
%
% Example
% ========
%
%     x = tseries(1:2,rand(2,2));
%     x = comment(x,'Comment')
%
%     x =
% 
%         tseries object: 2-by-2
% 
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%         'Comment'    'Comment'
% 
%         user data: empty
% 
%     x = comment(x,{'Comment 1','Comment 2'})
% 
%     x =
% 
%         tseries object: 2-by-2
% 
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%         'Comment 1'    'Comment 2'
% 
%         user data: empty
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if ~isempty(varargin)
    pp = inputParser();
    pp.addRequired('Cmt',@(x) ischar(x) || iscellstr(x));
    pp.parse(varargin{1});
end

%--------------------------------------------------------------------------

if isempty(varargin)
    % Get comments.
    This = This.Comment;
else
    % Set comments.
    varargin{1} = strrep(varargin{1},'"','');
    if ischar(varargin{1})
        This.Comment(:) = varargin(1);
    else
        s1 = size(This.data);
        s1(1) = 1;
        s2 = size(varargin{1});
        if length(s1) == length(s2) && all(s1 == s2)
            This.Comment = varargin{1};
        else
            utils.error('tseries:comment', ...
                'Incorrect size of comments attempted to be assigned.');
        end
    end
end

end
