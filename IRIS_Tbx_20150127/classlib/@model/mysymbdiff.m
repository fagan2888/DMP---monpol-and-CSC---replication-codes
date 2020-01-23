function This = mysymbdiff(This,IsSymbDiff)
% mysymbdiff  [Not a public function] Evaluate symbolic derivatives for model equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    IsSymbDiff; %#ok<VUNUS>
catch
    IsSymbDiff = true;
end

%--------------------------------------------------------------------------

% No derivatives computed for dynamic links.

nEqtn = length(This.eqtn);
This.DEqtnF = cell(1,nEqtn);
This.CEqtnF = cell(1,nEqtn);
t0 = find(This.Shift == 0);

% Deterministic trends
%----------------------
% Differentiate dtrends w.r.t. parameters; do this even if the user
% requested symbDiff=false.
for iEq = find(This.eqtntype == 3)
    [~,nmOcc] = myfindoccur(This,iEq,'parameters');
    tmOcc = zeros(size(nmOcc));
    eqtn = This.eqtnF{iEq};
    d = sydney.mydiffeqtn(eqtn,'separate',nmOcc,tmOcc);
    This.DEqtnF{iEq} = d;
end

% Return now if user requested symbDiff=false.
if ~IsSymbDiff
    return
end

% Measurement and transition equations
%--------------------------------------
% Differentiate equations w.r.t.
% variables and shocks.

for iEq = find(This.eqtntype <= 2)
    
    [tmOcc,nmOcc] = myfindoccur(This,iEq,'variables_shocks');
    tmOcc = tmOcc - t0;
    
    % Differentiate one equation wrt all names at a time. The result will be
    % one multivariate derivative (`mode`==1) or several separate derivatives
    % (`mode`==Inf).
    eqtn = This.eqtnF{iEq};

    d = sydney.mydiffeqtn(eqtn,'enbloc',nmOcc,tmOcc);
    
    % Store strings; the strings are converted to anonymous functions later.
    This.DEqtnF{iEq} = d;
    
    % Create function for evaluating the constant term in each equation in
    % linear models. Do this also in non-linear models because `solve` can be
    % now called with `'linear=' true`.
    cEqtn = myconsteqtn(This,This.eqtnF{iEq});
    This.CEqtnF{iEq} = cEqtn;

end

end
