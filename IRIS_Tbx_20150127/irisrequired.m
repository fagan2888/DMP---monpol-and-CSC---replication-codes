function irisrequired(Min)
% irisrequired  Throw error if the installed version of IRIS fails to comply with the required minimum.
%
% Syntax
% =======
%
%     irisrequired(V)
%
% Input arguments
% ================
%
% * `V` [ char ] - Text string describing the oldest acceptable
% distribution of IRIS.
%
% Description
% ============
%
% If the version of IRIS present on the computer does not comply with the
% minimum requirement `v`, an error is thrown.
%
% Example
% ========
%
% All of the three calls are valid:
%
%     irisrequired(20111222);
%     irisrequired('20111222');
%     irisrequired 20111222;
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Min)
    Min = str2double(Min);
end

[vChar,vNum] = irisversion();

if vNum < Min
    if round(Min) == Min
        dec = 0;
    else
        dec = 8;
    end
    utils.error('config', ...
        ['IRIS Toolbox #%.*f or later is required. ', ...
        'Your are currently using IRIS Toolbox #%s.'],dec,Min,vChar);
end

end