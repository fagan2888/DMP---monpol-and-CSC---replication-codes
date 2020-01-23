function This = parse(Func,varargin)
% parse  [Not a public function] Convert tseries function into tsydney.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

persistent TSYDNEY;

if ~isa(TSYDNEY,'tsydney')
    TSYDNEY = tsydney();
end

%--------------------------------------------------------------------------

This = TSYDNEY;
This.Func = Func;
This.args = varargin;

end
