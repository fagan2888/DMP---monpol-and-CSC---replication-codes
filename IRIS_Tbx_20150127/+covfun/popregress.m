function [B,COVRES] = popregress(YY,YX,XX)
% POPREGRESS  [Not a public function] Population regression.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%**************************************************************************

B = YX / XX;
COVRES = YY - YX*B.' - B*YX.' + B*XX*B.'; 

end