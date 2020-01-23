function [A,B,K,J,Cov] = mysystem(This,Alt)
% mysystem  [Not a public function] VAR system matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Alt; %#ok<VUNUS>
catch
    Alt = ':';
end

%--------------------------------------------------------------------------

A = This.A(:,:,Alt);
B = mybmatrix(This,Alt);
K = This.K(:,:,Alt);
J = This.J(:,:,Alt);
Cov = mycovmatrix(This,Alt);

end