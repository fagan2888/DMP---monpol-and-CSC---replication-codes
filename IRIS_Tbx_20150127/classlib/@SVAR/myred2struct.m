function Outp = myred2struct(This,Inp,Opt)
% myred2struct  [Not a public function] Convert reduced-form VAR residuals to structural VAR shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% Panel SVARs.
if ispanel(This)
    Outp = mygroupmethod(@myred2struct,This,Inp,Opt);
    return
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

% Input data.
req = datarequest('y*,e',This,Inp,Inf,Opt);
outpFmt = req.Format;
range = req.Range;
y = req.Y;
e = req.E;

if size(e,3) == 1 && nAlt > 1
    e = e(:,:,ones(1,nAlt));
end

for iAlt = 1 : nAlt
    if This.Rank < ny
        e(:,:,iAlt) = pinv(This.B(:,:,iAlt)) * e(:,:,iAlt);
    else
        e(:,:,iAlt) = This.B(:,:,iAlt) \ e(:,:,iAlt);
    end
end

% Output data.
yList = get(This,'yList');
eList = get(This,'eList');

if strcmpi(outpFmt,'tseries')
    % For tseries input/output data, we need to combine again both the y
    % and e data.
    Outp = myoutpdata(This,outpFmt,range,[y;e],[],[yList,eList]);
else
    % For dbase input/output data, simply replace the e data in the output
    % database.
    Outp = myoutpdata(This,outpFmt,range,e,[],eList,Inp);
end

end
