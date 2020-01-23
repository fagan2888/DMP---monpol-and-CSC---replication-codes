function [Flag,varargout] = chksstate(This,varargin)
% chksstate  Check if equations hold for currently assigned steady-state values.
%
% Syntax
% =======
%
%     [Flag,List] = chksstate(M,...)
%     [Flag,Discr,List] = chksstate(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if discrepancy between LHS and RHS
% is smaller than `'tolerance='` in each equation.
%
% * `Discr` [ numeric ] - Discrepancies between LHS and RHS evaluated for
% each equation at two consecutive times, and returned as two column
% vectors.
%
% * `List` [ cellstr ] - List of equations in which the discrepancy between
% LHS and RHS is greater than `'tolerance='`.
%
% Options
% ========
%
% * `'error='` [ *`true`* | `false` ] - Throw an error if one or more
% equations fail to hold up to tolerance level.
%
% * `'eqtn='` [ *`'full'`* | `'sstate'` ] - Evaluate either full or
% steady-state equations on steady-state values.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links before
% evaluating the equations.
%
% * `'tolerance='` [ numeric | `getrealsmall()` ] - Tolerance level.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

[opt,varargin] = passvalopt('model.chksstate',varargin{:});
isSort = nargout > 3;

%--------------------------------------------------------------------------

% Refresh dynamic links.
if opt.refresh && ~isempty(This.Refresh)
    This = refresh(This);
end

if opt.warning
    mychk(This,Inf,'parameters','sstate','log');
end

nAlt = size(This.Assign,3);

% Pre-process options passed to `mychksstate`.
mychksstateOpt = mychksstateopt(This,'verbose',varargin{:});

% `discr` is a matrix of discrepancies; it has two columns when we
% evalulate full dynamic equations, and one column when we evaluate sstate
% equations.
[Flag,discr,maxAbsDiscr,list] = mychksstate(This,mychksstateOpt);

if any(~Flag) && opt.error
    tmp = {};
    for i = find(~Flag)
        for j = 1 : length(list{i})
            tmp{end+1} = preparser.alt2str(i); %#ok<AGROW>
            tmp{end+1} = list{i}{j}; %#ok<AGROW>
        end
    end
    utils.error('model:chksstate', ...
        'Steady-state error in this equation %s: ''%s''', ...
        tmp{:});
end

if isSort
    sortList = cell(1,nAlt);
    for iAlt = 1 : nAlt
        [~,inx] = sort(maxAbsDiscr(:,iAlt),1,'descend');
        discr(:,:,iAlt) = discr(inx,:,iAlt);
        sortList{iAlt} = This.eqtn(inx);
    end
end

if nAlt == 1
    list = list{1};
    if isSort
        sortList = sortList{1};
    end
end

if nargout == 2
    varargout{1} = list;
elseif nargout > 2
    varargout{1} = discr;
    varargout{2} = list;
    if isSort
        varargout{3} = sortList;
    end
end

end
