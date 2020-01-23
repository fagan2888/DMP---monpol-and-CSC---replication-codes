function default = IRIS()
% IRIS  [Not a public function] Default options for general IRIS functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%**************************************************************************

default = struct();

default.irisremove = { ...
   'display',true,@islogical, ...
   'removeroot',false,@islogical, ...
};

end