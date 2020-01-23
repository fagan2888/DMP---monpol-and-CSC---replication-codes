function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubsalt [Not a public function] Implement SUBSREF and SUBSASGN for VAR objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    This = mysubsalt@varobj(This,Lhs);
    This.K = This.K(:,:,Lhs);
    This.J = This.J(:,:,Lhs);
    This.G = This.G(:,:,Lhs);
    This.Aic = This.Aic(1,Lhs);
    This.Sbc = This.Sbc(1,Lhs);
    This.T = This.T(:,:,Lhs);
    This.U = This.U(:,:,Lhs);
    This.X0 = This.X0(:,:,Lhs);
    if ~isempty(This.Sigma)
        This.Sigma = This.Sigma(:,:,Lhs);
    end
elseif nargin == 3 && isempty(Obj)
    % Empty subscripted assignment This(Lhs) = empty.
    This = mysubsalt@varobj(This,Lhs,Obj);
    This.K(:,:,Lhs) = [];
    This.J(:,:,Lhs) = [];
    This.G(:,:,Lhs) = [];
    This.Aic(:,Lhs) = [];
    This.Sbc(:,Lhs) = [];
    This.T(:,:,Lhs) = [];
    This.U(:,:,Lhs) = [];
    This.X0(:,:,Lhs) = [];
    if ~isempty(This.Sigma) && ~isempty(x.Sigma)
        This.Sigma(:,:,Lhs) = [];
    end
elseif nargin == 4 && mycompatible(This,Obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    This = mysubsalt@varobj(This,Lhs,Obj,Rhs);
    try
        This.K(:,:,Lhs) = Obj.K(:,:,Rhs);
        This.J(:,:,Lhs) = Obj.J(:,:,Rhs);
        This.G(:,:,Lhs) = Obj.G(:,:,Rhs);
        This.Aic(:,Lhs) = Obj.Aic(:,Rhs);
        This.Sbc(:,Lhs) = Obj.Sbc(:,Rhs);
        This.T(:,:,Lhs) = Obj.T(:,:,Rhs);
        This.U(:,:,Lhs) = Obj.U(:,:,Rhs);
        This.X0(:,:,Lhs) = Obj.X0(:,:,Rhs);
        if ~isempty(This.Sigma) && ~isempty(Obj.Sigma)
            This.Sigma(:,:,Lhs) = Obj.Sigma(:,:,Rhs);
        end
    catch %#ok<CTCH>
        utils.error('VAR:mysubsalt', ...
            ['Subscripted assignment to %s object failed, ', ...
            'LHS and RHS objects are incompatible.'], ...
            class(This));
    end
else
    utils.error('VAR:mysubsalt', ...
        'Invalid assignment to %s object.', ...
        class(This));
end

end
