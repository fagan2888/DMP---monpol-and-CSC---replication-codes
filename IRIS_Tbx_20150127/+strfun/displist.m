function L = displist(C)
% displist  [Not a public function] Print cell array of names as quoted list.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

L = sprintf('''%s'' ',C{:});

end