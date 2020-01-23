function Affected = myaffectedeqtn(This,iAlt,Opt)
% myaffectedeqtn  [Not a public function] Equations affected by parameter changes since last system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if isequal(Opt.linear,@auto)
    Opt.linear = This.IsLinear;
end

%--------------------------------------------------------------------------

Affected = true(size(This.eqtn));
if ~Opt.select
    return
end

Assign0 = This.LastSyst.Asgn;

% If last system does not exist, we must select all equations.
if nnz(This.LastSyst.Derv.f) == 0
    return
end

% Changes in steady states and parameters.
changed = This.Assign(1,:,iAlt) ~= Assign0 ...
    & (~isnan(This.Assign(1,:,iAlt)) | ~isnan(Assign0));
if Opt.linear
    % Only parameter changes matter in linear models.
    changed = changed & This.nametype == 4;
end

% Affected equations.
nname = length(This.name);
t0 = find(This.Shift == 0);
occur0 = This.occur(:,(t0-1)*nname+(1:nname));
Affected = any(occur0(:,changed),2).';

end
