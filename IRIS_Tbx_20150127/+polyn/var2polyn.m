function A = var2polyn(A)
% var2polyn  [Not a public function] Convert VAR style matrix to 3D polynomial.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isVAR(A)
   A = get(A,'A');
end

[ny,p,nAlt] = size(A);
p = p/ny;
x = eye(ny);
x = x(:,:,1,ones(1,nAlt));
A = cat(3,x,reshape(-A,[ny,ny,p,nAlt]));

end
