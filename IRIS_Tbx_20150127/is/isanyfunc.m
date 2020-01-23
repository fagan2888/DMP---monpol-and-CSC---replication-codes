function Flag = isanyfunc(X,List)
% isanyfunc  [Not a public function] True if function handle or char is found in list, case sensitive.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isfunc(X)
    X = func2str(X);
end

Flag = ischar(X) && isanystr(X,List);

end
