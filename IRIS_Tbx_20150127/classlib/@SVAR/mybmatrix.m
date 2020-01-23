function [B,Flag] = mybmatrix(This,Alt)
% mybmatrix  [Not a public function] Matrix of instantaneous effects.
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

Flag = true;
B = This.B(:,:,Alt);

end