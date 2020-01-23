function detail(This,Data)
% detail  Display details of a simulation plan.
%
% Syntax
% =======
%
%     detail(P)
%     detail(P,Data)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `Data` [ struct ] - Input database.
%
% Description
% ============
%
% If you supply also the second input argument, the input database `D`,
% both the dates and the respective values will be reported for exogenised
% and conditioning data points, and the values will be checked for the
% presence of NaNs (with a warning should there be found any).
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

try
    Data;
catch 
    Data = [];
end

if isfield(Data,'mean') && isstruct(Data.mean)
    Data = Data.mean;
end
    
%--------------------------------------------------------------------------

nx = nnzexog(This);
[ans,nnreal,nnimag] = nnzendog(This); %#ok<NOANS,ASGLU>
nq = nnznonlin(This);
nc = nnzcond(This);

disp(' ');
range = This.Start:This.End;
dates = dat2str(range);

printDates = @(index) sprintf(' %s',dates{index});

[xDetail,xNan] = xxDetail(This.XAnch,This.XList,range,[],Data);
nRealDetail = ...
    xxDetail(This.NAnchReal,This.NList,range,This.NWghtReal,[]);
nImagDetail = ...
    xxDetail(This.NAnchImag,This.NList,range,This.NWghtImag,[]);
[cDetail,cNan] = xxDetail(This.CAnch,This.CList,range,[],Data);

qList = {};
for i = find(any(This.QAnch,2)).'
    temp = printDates(This.QAnch(i,:));
    qList = [qList,{strfun.ellipsis(This.QList{i},20),temp}];
end

checkList = [ ...
    xDetail(1:2:end), ...
    nRealDetail(1:2:end), ...
    nImagDetail(1:2:end), ...
    cDetail(1:2:end)];
maxLen = max(cellfun(@length,checkList));
format = ['\t\t%-',sprintf('%g',maxLen+1),'s%s\n'];
empty = @() fprintf('\t-\n');

fprintf('\tExogenised %g\n',nx);
if ~isempty(xDetail)
    fprintf(format,xDetail{:});
else
    empty();
end

fprintf('\tEndogenised real %g\n',nnreal);
if ~isempty(nRealDetail)
    fprintf(format,nRealDetail{:});
else
    empty();
end

fprintf('\tEndogenised imag %g\n',nnimag);
if ~isempty(nImagDetail)
    fprintf(format,nImagDetail{:});
else
    empty();
end

fprintf('\tConditioned upon %g\n',nc);
if ~isempty(cDetail)
    fprintf(format,cDetail{:});
else
    empty();
end

fprintf('\tNon-linearised %g\n',nq);
if ~isempty(qList)
    fprintf(format,qList{:});
else
    empty();
end

disp(' ');

if xNan > 0
    utils.warning('plan', ...
        ['A total of %g exogenised data points refer(s) to NaN(s) ', ...
        'in the input database.'], ...
        xNan);
end

if cNan > 0
    utils.warning('plan', ...
        ['A total of %g conditioning data points refer(s) to NaN(s) ', ...
        'in the input database.'], ...
        cNan);
end

end


% Subfunctions...


%**************************************************************************


function [Det,NNan] = xxDetail(Anch,List,Range,W,D)

isData = ~isempty(D) && isstruct(D);
isWeight = ~isempty(W) && isnumeric(W);

dates = dat2str(Range);
Det = {};
NNan = 0;
for irow = find(any(Anch,2)).'
    index = Anch(irow,:);
    name = List{irow};
    if isData
        if isfield(D,name) && isa(D.(name),'tseries')
            [~,ndata] = size(D.(name).data);
            values = nan(ndata,size(Anch,2));
            for idata = 1 : ndata
                values(idata,index) = D.(name)(Range(index),idata).';
                NNan = NNan + sum(isnan(values(idata,index)));
            end
        else
            ndata = 1;
            values = nan(ndata,size(Anch,2));
        end            
        row = '';
        for icol = find(index)
            row = [row,' *',dates{icol},'[=',num2str(values(:,icol).',' %g'),']'];
        end
    elseif isWeight
        row = '';
        for icol = find(index)
            row = [row,' *',dates{icol},'[@',num2str(W(irow,icol).',' %g'),']'];
        end
    else        
        row = sprintf(' *%s',dates{index});
    end
    Det = [Det,List(irow),{row}]; %#ok<*AGROW>
end

end % xxDetail()
