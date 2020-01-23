function LikOpt = mypreploglik(This,Range,Dom,Tune,varargin)
% mypreploglik  [Not a public function] Prepare for likelihood function evaluation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if strncmpi(Dom,'t',1)
    % Time domain opt.
    LikOpt = passvalopt('model.kalman',varargin{:});
    LikOpt.domain = 't';
    LikOpt.minusLogLikFunc = @mykalman;
elseif strncmpi(Dom,'f',1)
    % Freq domain opt.
    LikOpt = passvalopt('model.fdlik',varargin{:});
    LikOpt.domain = 'f';
    LikOpt.minusLogLikFunc = @myfdlik;
end

%--------------------------------------------------------------------------

nper = length(Range);
ny = sum(This.nametype == 1);

% Time trend for dtrend equations.
LikOpt.ttrend = dat2ttrend(Range,This);

% Conditioning measurement variables.
if LikOpt.domain == 't'
    LikOpt.condition = myselect(This,'y',LikOpt.condition);
elseif LikOpt.domain == 'f'
    LikOpt.exclude = myselect(This,'y',LikOpt.exclude);
end

% Out-of-lik parameters.
if isempty(LikOpt.outoflik)
    LikOpt.outoflik = [];
else
    if ischar(LikOpt.outoflik)
        LikOpt.outoflik = regexp(LikOpt.outoflik,'\w+','match');
    end
    LikOpt.outoflik = LikOpt.outoflik(:)';
    offset = sum(This.nametype < 4);
    pos = offset + ...
        strfun.findnames(This.name(This.nametype == 4), ...
        LikOpt.outoflik);
    ixNan = isnan(pos);
    if any(ixNan)
        % Unknown parameter names.
        utils.error('model:mypreploglik', ...
            ['This parameter name does not exist ', ...
            'in the model object: ''%s''.'], ...
            LikOpt.outoflik{ixNan});
    end
    LikOpt.outoflik = pos;
end
LikOpt.outoflik = LikOpt.outoflik(:).';
npout = length(LikOpt.outoflik);
if npout > 0 && ~LikOpt.dtrends
    utils.error('model:mypreploglik', ...
        ['Cannot estimate out-of-likelihood parameters ', ...
        'with the option ''dtrends='' false.']);
end

% Options for time domain only
%------------------------------

if LikOpt.domain == 't'
    % Time-varying stdcorr vector; 'clip' means the stdcorr vector will
    % be cut at the last user-supplied period.
    LikOpt.stdcorr = mytune2stdcorr(This,Range,Tune,LikOpt,'clip');
    
    % User-supplied tunes on the mean of shocks.
    if isfield(LikOpt,'vary')
        Tune = LikOpt.vary;
    end
    if ~isempty(Tune) && isstruct(Tune)
        % Request shock data.
        Tune = datarequest('e',This,Tune,Range);
        if all(Tune(:) == 0)
            Tune = [];
        end
    end
    LikOpt.tune = Tune;
    
end

% Objective function.
if LikOpt.domain == 't'
    switch lower(LikOpt.objfunc)
        case {'prederr'}
            % Weighted prediction errors.
            LikOpt.objfunc = 2;
            if isempty(LikOpt.weighting)
                LikOpt.weighting = sparse(eye(ny));
            elseif numel(LikOpt.weighting) == 1
                LikOpt.weighting = sparse(eye(ny)*LikOpt.weighting);
            elseif any(size(LikOpt.weighting) == 1)
                LikOpt.weighting = sparse(diag(LikOpt.weighting(:)));
            end
            if ndims(LikOpt.weighting) > 2 ...
                    || any(size(LikOpt.weighting) ~= ny) %#ok<ISMAT>
                utils.error('model:mypreploglik', ...
                    ['Size of prediction error weighting matrix ', ...
                    'must match number of observables.']);
            end
        case {'loglik','mloglik','-loglik'}
            % Minus log likelihood.
            LikOpt.objfunc = 1;
        otherwise
            utils.error('model:mypreploglik', ...
                'Unknown objective function: ''%s''.', ...
                LikOpt.objfunc);
    end
end

% Range on which the objective function will be evaluated. The
% `'objrange='` option gives the range from which sample information will
% be used to calculate the objective function and estimate the out-of-lik
% parameters.
if LikOpt.domain == 't'
    if isequal(LikOpt.objrange,@all)
        LikOpt.objrange = true(1,nper);
    else
        start = max(1,round(LikOpt.objrange(1) - Range(1) + 1));
        End = min(nper,round(LikOpt.objrange(end) - Range(1) + 1));
        LikOpt.objrange = false(1,nper);
        LikOpt.objrange(start : End) = true;
    end
end

% User-supplied initial conditions.
if LikOpt.domain == 't'
    if isstruct(LikOpt.initcond)
        [xbInitMean,isNanInitMean,xbInitMse,isNanInitMse] = ...
            datarequest('xbInit',This,LikOpt.initcond,Range);
        if isempty(xbInitMse)
            nb = size(This.solution{1},2);
            xbInitMse = zeros(nb,nb,size(xbInitMean,3));
        end
        doChkNanInit();
        LikOpt.initcond = {xbInitMean,xbInitMse};
    end
    % Initial mean for unit root elements of Alpha.
    if isstruct(LikOpt.initmeanunit)
        [xbInitMean,isNanInitMean] = ...
            datarequest('xbInit',This,LikOpt.initmeanunit,Range);
        isNanInitMse = [];
        doChkNanInit();
        LikOpt.initmeanunit = xbInitMean;
    end
end

% Last backward smoothing period. The option  lastsmooth will not be
% adjusted after we add one pre-sample init condition in `kalman`. This
% way, one extra period before user-requested lastsmooth will smoothed,
% which can be then used in `simulate` or `jforecast`.
if LikOpt.domain == 't'
    if isempty(LikOpt.lastsmooth) || isequal(LikOpt.lastsmooth,Inf)
        LikOpt.lastsmooth = 1;
    else
        LikOpt.lastsmooth = round(LikOpt.lastsmooth - Range(1)) + 1;
        if LikOpt.lastsmooth > nper
            LikOpt.lastsmooth = nper;
        elseif LikOpt.lastsmooth < 1
            LikOpt.lastsmooth = 1;
        end
    end
end

% Nested functions.

%**************************************************************************
    function doChkNanInit()
        if ~isempty(isNanInitMean)
            utils.error('model:mypreploglik', ...
                ['This initial condition is not available: ', ...
                'Mean ''%s''.'], ...
                isNanInitMean{:});
        end
        if ~isempty(isNanInitMse)
            utils.error('model:mypreploglik', ...
                ['This initial condition is not available: ', ...
                'MSE ''%s''.'], ...
                isNanInitMse{:});
        end        
    end % doChkNanInit().

end
