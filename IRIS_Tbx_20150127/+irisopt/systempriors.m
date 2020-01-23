function def = systempriors()
% systempriors  [Not a public function] Default options for systempriors class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct();

def.prior = { ...
    'lowerbound,lower',-Inf,@(x) isnumericscalar(x), ...
    'upperbound,upper',Inf,@(x) isnumericscalar(x), ...
    };

end