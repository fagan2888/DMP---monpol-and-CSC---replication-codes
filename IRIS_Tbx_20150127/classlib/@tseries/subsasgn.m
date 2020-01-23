function This = subsasgn(This,S,Y,varargin)
% subsasgn  Subscripted assignment for tseries objects.
%
% Syntax
% =======
%
%     X(Dates) = Values;
%     X(Dates,I,J,K,...) = Values;
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object that will be assigned new
% observations.
%
% * `Dates` [ numeric ] - Dates for which the new observations will be
% assigned.
%
% * `I`, `J`, `K`, ... [ numeric ] - References to 2nd and higher
% dimensions of the tseries object.
%
% * `Values` [ numeric ] - New observations that will assigned at specified
% dates.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Tseries object with newly assigned observations.
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

if ~isstruct(S)
    % Simplified syntax: subsasgn(X,Dates,Y,Ref2,Ref3,...)
    dates = S;
    S = struct();
    S.type = '()';
    S.subs = [{dates},varargin];
end

% Time-recursive assignment.
isTRec = isanystr(S(1).type,{'{}','()'}) && isa(S(1).subs{1},'trec');
isSydney = isa(Y,'sydney');
if isTRec || isSydney
    This = xxTRecExp(This,S,Y,inputname(1),isTRec,isSydney);
    return
end

switch S(1).type
    case {'()' '{}'}
        % Run `mylagorlead` to tell if the first reference is a lag/lead. If yes,
        % the startdate of `x` will be adjusted within `mylagorlead`.
        sh = 0;
        if length(S) > 1 || isa(Y,'tseries')
            [This,S,sh] = mylagorlead(This,S);
        end
        % After a lag or lead, only one ()-reference is allowed.
        if length(S) ~= 1 || ~isequal(S(1).type,'()')
            utils.error('tseries:subsasgn', ...
                ['Invalid subscripted assignment ', ...
                'to tseries object.']);
        end
        This = xxSetData(This,S,Y);
        This = mytrim(This);
        % Shift start date back.
        if sh ~= 0
            This.start = This.start + sh;
        end
    otherwise
        % Give standard access to public properties.
        This = builtin('subsasgn',This,S,Y);
end

end


% Subfunctions...


%**************************************************************************


function This = xxSetData(This,S,Y)
% Pad LHS tseries data with NaNs to comply with references.
% Remove the rows from dates that do not pass the frequency test.
[This,S,dates,freqTest] = xxExpand(This,S);

% Get RHS tseries object data.
if istseries(Y)
    Y = mygetdata(Y,dates);
end

% Convert LHS tseries NaNs to complex if LHS is real and RHS is complex.
if isreal(This.data) && ~isreal(Y)
    This.data(isnan(This.data)) = NaN + 1i*NaN;
end

% If RHS has only one row but multiple cols (or size > 1 in other dims),
% tseries is multivariate, and assigned are multiple dates, then expand RHS
% in 1st dimension.
xSize = size(This.data);
ySize = size(Y);
if length(Y) > 1 && size(Y,1) == 1 ...
        && length(S.subs{1}) > 1 ...
        && any(xSize(2:end) > 1)
    n = length(S.subs{1});
    Y = reshape(Y(ones(1,n),:),[n,ySize(2:end)]);
end

% Report frequency mismatch.
% Remove the rows from RHS that do not pass the frequency test.
ySize = size(Y);
if any(~freqTest)
    utils.warning('tseries:subsasgn', ...
        'Date frequency mismatch in assignment to tseries object.');
    if ySize(1) == length(freqTest)
        Y = Y(freqTest,:);
        Y = reshape(Y,[size(Y,1),ySize(2:end)]);
    end
end

try
    This.data = subsasgn(This.data,S,Y);
catch Err
    msg = Err.message;
    if ~isempty(msg) && msg(end) == '.'
        msg(end) = '.';
    end
    utils.error('tseries:subsasgn', ...
        ['Error in tseries assignment.\n', ...
        '\tUncle says: %s.'], ...
        msg);
end

% Make sure empty tseries have start date set to NaN no matter what.
if isempty(This.data)
    This.start = NaN;
end

% If RHS is empty and first index is ':', then some of the columns could
% have been deleted, and the comments must be adjusted accordingly.
if isempty(Y) && strcmp(S.subs{1},':')
    This.Comment = subsasgn(This.Comment,S,Y);
end
end % xxSetData()


%**************************************************************************


function [This,S,Dates,FreqTest] = xxExpand(This,S)

% If LHS data are complex, use NaN+NaNi to pad missing observations.
if isreal(This.data)
    unit = 1;
else
    unit = 1 + 1i;
end

% Replace x(dates) with x(dates,:,...,:).
if length(S.subs) == 1
    S.subs(2:ndims(This.data)) = {':'};
end

% * Inf and ':' produce the entire tseries range.
% * Convert subscripts in 1st dimension from dates to indices.
% * We cannot use `isequal(S.subs{1},':')` because `isequal(58,':')`
% produces `true`.
if (ischar(S.subs{1}) && strcmp(S.subs{1},':')) ...
        || isequal(S.subs{1},Inf)
    S.subs{1} = ':';
    if isnan(This.start)
        % LHS is empty.
        Dates = [];
    else
        Dates = This.start + (0 : size(This.data,1)-1);
    end
    FreqTest = true(size(Dates));
elseif isnumeric(S.subs{1}) && ~isempty(S.subs{1})
    Dates = S.subs{1};
    if ~isempty(Dates)
        f2 = Dates - floor(Dates);
        if isnan(This.start)
            % If LHS series is empty tseries, set start date to the minimum
            % date with the same frequency as the first date.
            This.start = min(Dates(f2 == f2(1)));
        end
        f1 = This.start - floor(This.start);
        FreqTest = abs(f1 - f2) < 1e-2;
        Dates(~FreqTest) = [];
        S.subs{1} = round(Dates - This.start + 1);
    end
else
    Dates = [];
    FreqTest = [];
end

% Reshape tseries data to reduce number of dimensions if called with
% fewer dimensions. Eg x.data is Nx2x2, and assignment is for x(:,3).
% This mimicks standard Matlab behaviour.
nSubs = length(S.subs);
isReshaped = false;
if nSubs < ndims(This.data)
    tempSubs = cell([1,nSubs]);
    tempSubs(:) = {':'};
    tempSize = size(This.data);
    This.data = This.data(tempSubs{:});
    This.Comment = This.Comment(tempSubs{:});
    isReshaped = true;
end

% Add NaNs to data when user indices go beyond the data size.
% Add NaNs to 1st dimension when user indices are non-positive.
% Add empty strings for comments to comply with the new size.
% This modifies standard Matlab matrix assignment, which produces zeros.
for i = find(~strcmp(':',S.subs))
    % Non-positive index in 1st dimension.
    if i == 1 && any(S.subs{1} < 1)
        n = 1 - min(S.subs{1});
        currentSize = size(This.data);
        currentSize(1) = n;
        This.data = [nan(currentSize)*unit;This.data];
        This.start = This.start - n;
        S.subs{1} = S.subs{1} + n;
    end
    % If index exceeds current size, add NaNs. This is different than
    % standard Matlab behaviour: Matlab adds zeros.
    if any(S.subs{i} > size(This.data,i))
        currentSize = size(This.data);
        currentSize(end+1:nSubs) = 1;
        addSize = currentSize;
        addSize(i) = max(S.subs{i}) - addSize(i);
        This.data = cat(i,This.data,nan(addSize)*unit);
        if i > 1
            % Add an appropriate empty cellstr to comments if tseries data
            % are expanded in 2nd or higher dimensions.
            comment = cell([1,addSize(2:end)]);
            comment(:) = {''};
            This.Comment = cat(i,This.Comment,comment);
        end
    end
end

% Try to reshape tseries data array back.
if isReshaped
    try
        This.data = reshape(This.data,tempSize);
        This.Comment = reshape(This.Comment,[1,tempSize(2:end)]);
    catch %#ok<CTCH>
        utils.error('tseries:subsasgn', ...
            'Attempt to grow tseries data array along ambiguous dimension.');
    end
end
end % xxExpand()


%**************************************************************************


function This = xxTRecExp(This,S,Y,InpName,IsTRec,IsSydney)
if ~IsTRec
    utils.error('tseries:subsasgn', ...
        'Invalid left-hand side in time-recursive expression.');
end
if ~IsSydney && ~isnumeric(Y)
    utils.error('tseries:subsasgn', ...
        'Invalid right-hand side in time-recursive expression.');
end
tr = S(1).subs{1};
if ~isempty(tr.Dates) && ~isnan(This.start) ...
        && ~freqcmp(tr.Dates(1),This.start)
    utils.error('tseries:subsasgn', ...
        'Frequency mismatch in recursive expression.');
end
ref = S(1).subs(2:end);
stamp = This.Stamp;

% TODO: Pre-evaluate functions on tseries other than LHS tseries.

s = struct();
s.type = '()';
s.subs = [{NaN},ref];

for t = tr.Dates(:).'
    if IsSydney
        x = myeval(Y,t,This,InpName,stamp);
    else
        x = Y;
    end
    s.subs{1} = t;
    This = xxSetData(This,s,x);
end
This = mytrim(This);
end % xxTRecExp()
