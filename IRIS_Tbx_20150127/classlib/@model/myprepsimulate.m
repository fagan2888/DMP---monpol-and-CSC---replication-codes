function S = myprepsimulate(This,S,IAlt)
% myprepsimulate  [Not a public function] Prepare the i-th simulation round.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% The input struct `S` must include the followin fields:
%
% * `.isnonlin` - true if a non-linear simulate is requested;
% * `.TPlusK` - farthest expansion needed;
%
% The output struct `S` returns the following new fields:
%
% * `.Assign` - current values of parameters and steady states;
% * `.T`...`.U` - solution matrices;
% * `.Expand` - expansion matrices;
% * `.Q` - effect of non-linear add-factors (empty for linear simulations);
%
% For non-linear simulations, the struct `S` is also added the following
% loop-indpendent fields from the model object
%
% * `nonlin` - index of non-linearised equations;
% * `eqtnN` - cell array of function handles to evaluate non-linear
% equations;
% * `eqtn` - cell str of user equations;
% * `nametype` - name types;
% * `label` - equation labels or trimmed equations.

%--------------------------------------------------------------------------

ne = sum(This.nametype == 3);
nn = sum(This.IxNonlin);

% Loop-dependet fields
%----------------------

% Current values of parameters and steady states.
S.Assign = This.Assign(1,:,IAlt);
S.IxLog = This.IxLog;

% Solution matrices.
S.T = This.solution{1}(:,:,IAlt);
S.R = This.solution{2}(:,:,IAlt);
S.K = This.solution{3}(:,:,IAlt);
S.Z = This.solution{4}(:,:,IAlt);
S.H = This.solution{5}(:,:,IAlt);
S.D = This.solution{6}(:,:,IAlt);
S.U = This.solution{7}(:,:,IAlt);

% Effect of non-linear add-factors.
S.Q = []; 
S.XBar = [];
if S.IsNonlin
    S.Q = This.solution{8}(:,:,IAlt);
    if S.IsDeviation && S.IsAddSstate
        % Get steady state lines that will be added to simulated paths to evaluate
        % non-linear equations.
        isDelog = false;
        S.XBar = mytrendarray(This,IAlt, ...
            isDelog,This.solutionid{2},0:S.NPerNonlin);
    end
    nPerMax = S.NPer + S.NPerNonlin - 1;
    minT = This.Shift(1);
    maxT = This.Shift(end);
    isDelog = true;
    id = 1 : length(This.name);
    tVec = (1+minT) : (nPerMax+maxT);
    S.L = mytrendarray(This,IAlt,isDelog,id,tVec);
    S.MinT = minT;
end

% Solution expansion matrices.
S.Expand = cell(size(This.Expand));
for ii = 1 : numel(S.Expand)
    S.Expand{ii} = This.Expand{ii}(:,:,IAlt);
end

% Expand solution forward up to t+k if needed.
if S.TPlusK > 0
    if S.IsNonlin && (ne > 0 || nn > 0)
        % Expand solution forward to t+k for both shocks and non-linear
        % add-factors.
        [S.R,S.Q] = model.myexpand(S.R,S.Q,S.TPlusK,S.Expand{1:6});
    elseif ne > 0
        % Expand solution forward to t+k for shocks only.
        S.R = model.myexpand(S.R,[],S.TPlusK,S.Expand{1:5},[]);
    end
end

if ~S.IsNonlin
    return
end

% Loop-independent fields added for non-linear simulations only
%---------------------------------------------------------------
S.IxNonlin = This.IxNonlin;
S.eqtn = This.eqtn;
S.EqtnN = This.EqtnN;
S.nametype = This.nametype;
S.label = myget(This,'canBeNonlinearised');

end
