function X = mynanstd(X,Flag,Dim)
% mynanstd  [Not a public function] Std deviation implemented for data with in-sample NaNs.
%
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = tseries.mynanvar(X,Flag,Dim);
X = sqrt(X);

end