function [This,Assigned] = assign(This,varargin)
% assign  [Not a public function] Assign values to names in modelobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

persistent ASSIGNPOS ASSIGNRHS STDCORRPOS STDCORRRHS;

if isempty(varargin)
    return
end

isLevel = false;
isGrowth = false;
doLevelGrowthFlags();

% Number of input arguments with the growth label removed.
n = length(varargin);

nAlt = size(This.Assign,3);

% `Assign` and `stdcorr` are logical indices of values that have been
% assigned.
Assign = false(size(This.name));
stdcorr = false(size(This.stdcorr));

if isempty(varargin)
    % @@@@@ MOSW
    ASSIGNPOS = [];
    ASSIGNRHS = [];
    STDCORRPOS = [];
    STDCORRRHS = [];
    Assigned = cell(1,0);
    return
    
elseif n == 1 && ismodel(varargin{1})
    % Assign from another model object.
    doModelobj2Modelobj();
    
elseif n == 1 && isnumeric(varargin{1})
    % m = assign(m,array).
    if isempty(ASSIGNPOS) && isempty(STDCORRPOS)
        utils.error('modelobj:assign', ...
            ['Function assign() must be initiliased before used ', ...
            'with a single numeric input.']);
    end
    Assign(ASSIGNPOS) = true;
    stdcorr(STDCORRPOS) = true;
    This.Assign(1,ASSIGNPOS,:) = varargin{1}(ASSIGNRHS);
    This.stdcorr(1,STDCORRPOS,:) = varargin{1}(STDCORRRHS);
    if nargout == 1
        return
    end
    
elseif n <= 2 && iscellstr(varargin{1})
    % assign(m,cellstr) initialises quick-assign function.
    % m = assign(m,cellstr,array)
    list = varargin{1}(:).';
    varargin(1) = [];
    nList = length(list);
    [ASSIGNPOS,STDCORRPOS] = mynameposition(This,list);
    ASSIGNRHS = ~isnan(ASSIGNPOS);
    ASSIGNPOS = ASSIGNPOS(ASSIGNRHS);
    STDCORRRHS = ~isnan(STDCORRPOS);
    STDCORRPOS = STDCORRPOS(STDCORRRHS);
    
    if isempty(varargin)
        % Initialise quick-assign access and return.
        return
    end
    
    value = varargin{1};
    if size(value,2) == 1 && nList > 1
        value = value(1,ones(1,nList),:);
    end
    if size(value,3) == 1 && nAlt > 1
        value = value(1,:,ones(1,nAlt));
    end
    if (isGrowth || isLevel) && any(imag(value(:)) ~= 0)
        utils.error('modelobj:assign', ...
            ['Cannot assign non-zero imag numbers ', ...
            'with ''-level'' or ''-growth'' options.']);
    end
    if isGrowth
        value(1,ASSIGNRHS,:) = real(This.Assign(1,ASSIGNPOS,:)) ...
            + 1i*value(1,ASSIGNRHS,:);
    elseif isLevel
        value(1,ASSIGNRHS,:) = value(1,ASSIGNRHS,:) ...
            + 1i*imag(This.Assign(1,ASSIGNPOS,:));
    end
    if any(ASSIGNRHS)
        Assign(ASSIGNPOS) = true;
        This.Assign(1,ASSIGNPOS,:) = value(1,ASSIGNRHS,:);
    end
    if any(STDCORRRHS)
        stdcorr(STDCORRPOS) = true;
        This.stdcorr(1,STDCORRPOS,:) = value(1,STDCORRRHS,:);
    end
    ASSIGNPOS = [];
    ASSIGNRHS = [];
    STDCORRPOS = [];
    STDCORRRHS = [];
    
elseif n <= 2 && isstruct(varargin{1})
    % m = assign(m,struct), or
    % m = assign(m,struct,clone).
    d = varargin{1};
    varargin(1) = [];
    c = fieldnames(d);
    allName = c;
    if ~isempty(varargin) && ~isempty(varargin{1})
        clone = varargin{1};
        if ~preparser.mychkclonestring(clone)
            utils.error('modelobj:assign', ...
                'Invalid clone string: ''%s''.', ...
                clone);
        end
        allName = strrep(clone,'?',c);
    end
    [assignPos,stdcorrPos] = mynameposition(This,allName);
    ixValidLen = true(1,length(allName));
    ixValidImag = true(1,length(allName));
    % Update .Assign.
    for i = find(~isnan(assignPos))
        x = d.(c{i});
        x = permute(x(:),[2,3,1]);
        ixValidImag(i) = all(imag(x) == 0) || (~isGrowth && ~isLevel);
        if ~ixValidImag(i)
            continue
        end
        ixValidLen(i) = any(numel(x) == [1,nAlt]);
        if ~ixValidLen(i)
            continue
        end
        x = permute(x,[2,3,1]);
        if isGrowth
            x = real(This.Assign(1,assignPos(i),:)) + 1i*x;
        elseif isLevel
            x = x + 1i*imag(This.Assign(1,assignPos(i),:));
        end
        This.Assign(1,assignPos(i),:) = x;
        Assign(assignPos(i)) = true;
    end
    % Update .stdcorr.
    for i = find(~isnan(stdcorrPos))
        x = d.(c{i});
        x = permute(x(:),[2,3,1]);
        ixValidImag(i) = all(imag(x) == 0);
        if ~ixValidImag(i)
            continue
        end
        ixValidLen(i) = any(numel(x) == [1,nAlt]);
        if ~ixValidLen(i)
            continue
        end
        This.stdcorr(1,stdcorrPos(i),:) = x;
        stdcorr(stdcorrPos(i)) = true;
    end
    doChkValid();
    ASSIGNPOS = [];
    ASSIGNRHS = [];
    STDCORRPOS = [];
    STDCORRRHS = [];
    if nargout == 1
        return
    end
    
elseif iscellstr(varargin(1:2:end))
    % m = assign(m,name,value,name,value,...)
    Assign = false(1,size(This.Assign,2));
    stdcorr = false(1,size(This.stdcorr,2));
    allName = strtrim(varargin(1:2:end));
    % Allow for equal signs in `assign(m,'alpha=',1)`.
    allName = regexprep(allName,'=$','');
    allValue = varargin(2:2:end);
    nName = length(allName);
    ixValidLen = true(1,nName);
    ixValidImag = true(1,nName);
    for j = 1 : nName
        name = allName{j};
        if isempty(name)
            continue
        end
        value = allValue{j};
        value = permute(value(:),[2,3,1]);
        ixValidLen(j) = any(numel(value) == [1,nAlt]);
        if ~ixValidLen(j)
            continue
        end
        [assignInx,stdcorrInx] = mynameposition(This,name);
        assignInx = assignInx(:).';
        stdcorrInx = stdcorrInx(:).';
        ixValidImag(j) = all(imag(value) == 0) ...
            || (~isGrowth && ~isLevel && ~any(stdcorrInx));
        if ~ixValidImag(j)
            continue
        end
        % Update .Assign.
        for i = find(assignInx)
            if isGrowth
                value = real(This.Assign(1,i,:)) + 1i*value;
            elseif isLevel
                value = value + 1i*imag(This.Assign(1,i,:));
            end
            This.Assign(1,i,:) = value;
            Assign(i) = true;
        end
        % Update .stdcorr.
        for i = find(stdcorrInx)
            This.stdcorr(1,i,:) = value;
            stdcorr(i) = true;
        end
    end
    doChkValid();
    ASSIGNPOS = [];
    ASSIGNRHS = [];
    STDCORRPOS = [];
    STDCORRRHS = [];
    
else
    % Throw an invalid assignment error.
    utils.error('modelobj:assign', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end


if nargout > 1
    % Put together list of parameters, steady states, std deviations, and
    % correlations that have been assigned.
    doAssigned();
end


% Nested functions...


%**************************************************************************


    function doLevelGrowthFlags()
        if ischar(varargin{1})
            if strcmp(varargin{1},'-level')
                isLevel = true;
                varargin(1) = [];
            elseif strcmp(varargin{1},'-growth')
                isGrowth = true;
                varargin(1) = [];
            end
        end
    end % doLevelGrowthFlags()


%**************************************************************************


    function doModelobj2Modelobj()
        rhs = varargin{1};
        nAltRhs = size(rhs.Assign,3);
        if nAltRhs ~= 1 && nAltRhs ~= nAlt
            utils.error('modelobj:assign', ...
                ['Cannot assign from object ', ...
                'with different number of paratemeterisations.']);
        end
        matchingTypeIx = true(size(This.name));
        for ii = 1 : length(This.name)
            rhsIx = strcmpi(This.name{ii},rhs.name);
            if ~any(rhsIx)
                continue
            end
            if rhs.nametype(rhsIx) == This.nametype(ii)
                oldValue = This.Assign(1,rhsIx,:);
                newValue = rhs.Assign(1,rhsIx,:);
                if isGrowth
                    asgnValue = real(oldValue) + 1i*imag(newValue);
                elseif isLevel
                    asgnValue = real(newValue) + 1i*imag(oldValue);
                else
                    asgnValue = newValue;
                end
                This.Assign(1,ii,:) = asgnValue;
                Assign(ii) = true;
            else
                matchingTypeIx(ii) = false;
            end
        end
        list = [ mygetstd(This), mygetcorr(This) ];
        listRhs = [ mygetstd(rhs), mygetcorr(rhs) ];
        for ii = 1 : length(list)
            rhsIx = strcmpi(list{ii},listRhs);
            if ~any(rhsIx)
                continue
            end
            This.stdcorr(1,ii,:) = rhs.stdcorr(1,rhsIx,:);
            stdcorr(ii) = true;
        end
        if any(~matchingTypeIx)
            utils.warning('modelobj:assign', ...
                ['This name not assigned because ', ...
                'of type mismatch: ''%s''.'], ...
                This.name{~matchingTypeIx});
        end
    end % doModelobj2Modelobj()


%**************************************************************************


    function doChkValid()
        if any(~ixValidLen)
            utils.error('modelobj:assign', ...
                ['Incorrect number of alternative values assigned ', ...
                'to this name: ''%s''.'], ...
                allName{~ixValidLen});
        end
        if any(~ixValidImag)
            utils.error('modelobj:assign', ...
                'Cannot assign non-zero imag number to this name: ''%s''.', ...
                allName{~ixValidImag});
        end
    end % doChkValid()


%**************************************************************************


    function doAssigned()
        Assigned = This.name(Assign);
        ne = sum(This.nametype == 3);
        eList = This.name(This.nametype == 3);
        Assigned = [Assigned,strcat('std_',eList(stdcorr(1:ne)))];
        pos = find(tril(ones(ne),-1) == 1);
        temp = zeros(ne);
        temp(pos(stdcorr(ne+1:end))) = 1;
        [row,col] = find(temp == 1);
        Assigned = [ Assigned, ...
            strcat('corr_',eList(row),'__',eList(col)) ];
    end % doAssigned()
end
