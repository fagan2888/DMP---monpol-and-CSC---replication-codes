function [Year,Per,Freq] = dat2ypf(Dat)
% dat2ypf  Convert IRIS serial date number to year, period and frequency.
%
% Syntax
% =======
%
%     [Y,P,F] = dat2ypf(Dat)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Output arguments
% =================
%
% * `Y` [ numeric ] - Years.
%
% * `P` [ numeric ] - Periods within year.
%
% * `F` [ numeric ] - Date frequencies.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Freq = datfreq(Dat);
ixZero = Freq == 0;
ixWeekly = Freq == 52;
ixDaily =  Freq == 365;
ixRegular = ~ixZero & ~ixWeekly & ~ixDaily;

[Year,Per] = deal(nan(size(Dat)));

% Regular frequencies.
if any(ixRegular)
    yp = floor(Dat);
    Year(ixRegular)  = floor(yp(ixRegular) ./ Freq(ixRegular));
    Per(ixRegular) = ...
        round(yp(ixRegular) - Year(ixRegular).*Freq(ixRegular) + 1);
end

% Unspecified frequency.
if any(ixZero)
    Year(ixZero) = NaN;
    Per(ixZero) = Dat(ixZero);
end

% Daily frequency; dat2ypf not applicable.
if any(ixDaily)
    Year(ixDaily) = NaN;
    Per(ixDaily) = Dat(ixDaily);
end

% Weekly frequency.
if any(ixWeekly)
    x = ww2day(Dat(ixWeekly));
    [Year(ixWeekly),Per(ixWeekly)] = day2ypfweekly(x);
end

end
