function varargout = subsasgn(this,varargin)
% subsasgn  [Not a public function] Subscripted assignment for namedmat objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = subsasgn(double(this),varargin{:});

end
