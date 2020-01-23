function [Ans,Flag,Query] = specget(This,Query)
% specget  [Not a public function] Implement GET method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Call superclass `specget` first.
[Ans,Flag,Query] = specget@modelobj(This,Query);

% Call to superclass successful.
if Flag
    return
end

Ans = [];
Flag = true;

ssLevel = [];
ssGrowth = [];
dtLevel = [];
dtGrowth = [];
level = [];
growth = [];
sstateList = { ...
    'ss','sslevel','level','ssgrowth','growth', ...
    'dt','dtlevel','dtgrowth', ...
    'ss+dt','sslevel+dtlevel','ssgrowth+dtgrowth', ...
    };

% Query relates to steady state.
if any(strcmpi(Query,sstateList))
    [ssLevel,ssGrowth,dtLevel,dtGrowth,level,growth] = xxSstate(This);
end

nx = length(This.solutionid{2});
nb = size(This.solution{1},2);
nf = nx - nb;
nAlt = size(This.Assign,3);

eigValTol = This.Tolerance(1);
realSmall = getrealsmall();

cell2DbaseFunc = @(X) cell2struct( ...
    num2cell(permute(X,[2,3,1]),2), ...
    This.name(:),1);

% Check availability of solution.
chkSolution = false;
addParams = false;

switch lower(Query)
    
    case 'ss'
        Ans = cell2DbaseFunc(ssLevel+1i*ssGrowth);
        % addParams = true;
        
    case 'sslevel'
        Ans = cell2DbaseFunc(ssLevel);
        addParams = true;
        
    case 'ssgrowth'
        Ans = cell2DbaseFunc(ssGrowth);
        addParams = true;
        
    case 'dt'
        Ans = cell2DbaseFunc(dtLevel+1i*dtGrowth);
        addParams = true;
        
    case 'dtlevel'
        Ans = cell2DbaseFunc(dtLevel);
        addParams = true;
        
    case 'dtgrowth'
        ixNan = This.nametype == 1;
        Ans = cell2DbaseFunc(dtGrowth);
        addParams = true;
        
    case 'ss+dt'
        Ans = cell2DbaseFunc(level+1i*growth);
        addParams = true;
        
    case 'sslevel+dtlevel'
        Ans = cell2DbaseFunc(level);
        addParams = true;
        
    case 'ssgrowth+dtgrowth'
        Ans = cell2DbaseFunc(growth);
        addParams = true;
        
    case {'eig','eigval','roots'}
        Ans = eig(This);
        
    case 'rlist'
        Ans = specget(This.Reporting,'list');
        
    case {'deqtn'}
        Ans = This.eqtn(This.eqtntype == 3);
        Ans(cellfun(@isempty,Ans)) = [];
        
    case {'leqtn'}
        Ans = This.eqtn(This.eqtntype == 4);
        
    case 'reqtn'
        Ans = specget(This.Reporting,'eqtn');
        
    case {'neqtn','nonlineqtn'}
        Ans = This.eqtn(This.IxNonlin);
        
    case {'nlabel','nonlinlabel'}
        Ans = This.eqtnlabel(This.IxNonlin);
        
    case 'rlabel'
        Ans = specget(This.Reporting,'label');
        
    case 'yvector'
        Ans = myvector(This,'y');
        Ans = Ans.';
        
    case 'xvector'
        Ans = myvector(This,'x');
        Ans = Ans.';
        
    case 'xfvector'
        Ans = myvector(This,'x');
        Ans = Ans(1:nf);
        Ans = Ans.';
        
    case 'xbvector'
        Ans = myvector(This,'x');
        Ans = Ans(nf+1:end);
        Ans = Ans.';
        
    case 'evector'
        Ans = myvector(This,'e');
        Ans = Ans.';
        
    case {'ylog','xlog','elog'}
        ixNan = find(Query(1) == 'yxe');
        Ans = This.IxLog(This.nametype == ixNan);
        
    case 'yid'
        Ans = This.solutionid{1};
        
    case 'xid'
        Ans = This.solutionid{2};
        
    case 'eid'
        Ans = This.solutionid{3};
        
    case {'eylist','exlist'}
        t0 = find(This.Shift == 0);
        nname = length(This.name);
        ixNan = nname*(t0-1) + find(This.nametype == 3);
        eyoccur = This.occur(This.eqtntype == 1,ixNan);
        exoccur = This.occur(This.eqtntype == 2,ixNan);
        eyindex = any(eyoccur,1);
        exindex = any(exoccur,1);        
        elist = This.name(This.nametype == 3);
        if Query(2) == 'y'
            Ans = elist(eyindex);
        else
            Ans = elist(exindex);
        end

    case {'derivatives','xderivatives','yderivatives'}
        doDerivatives();
        
    case {'wrt','xwrt','ywrt'}
        doWrt();
        
    case {'dlabel','llabel'}
        type = find(Query(1) == 'xydl');
        Ans = This.eqtnlabel(This.eqtntype == type);

    case {'deqtnalias','leqtnalias'}
        type = find(Query(1) == 'xydl');
        Ans = This.eqtnalias(This.eqtntype == type);
        
    case 'link'
        Ans = cell2struct(This.eqtn(This.eqtntype == 4), ...
            This.name(This.Refresh),2);
        
    case {'diffuse','nonstationary','stationary', ...
            'stationarylist','nonstationarylist'}
        doStationary();
        
    case 'maxlag'
        Ans = min(imag(This.systemid{2}));
        
    case 'maxlead'
        Ans = max(imag(This.systemid{2})) + 1;
        
    case {'icond','initcond','required'}
        % List of intial conditions required at least for one parameterisation.
        id = This.solutionid{2}(nf+1:end);
        ixNan = any(This.icondix,3);
        id = id(ixNan) - 1i;
        Ans = myvector(This,id);
        
    case {'forward'}
        ne = sum(This.nametype == 3);
        Ans = size(This.solution{2},2)/ne - 1;
        chkSolution = true;
        
    case {'stableroots','unitroots','unstableroots'}
        switch Query
            case 'stableroots'
                ixNan = abs(This.eigval) < (1 - eigValTol);
            case 'unstableroots'
                ixNan = abs(This.eigval) > (1 + eigValTol);
            case 'unitroots'
                ixNan = abs(abs(This.eigval) - 1) <= eigValTol;
        end
        Ans = nan(size(This.eigval));
        for iAlt = 1 : nAlt
            n = sum(ixNan(1,:,iAlt));
            Ans(1,1:n,iAlt) = This.eigval(1,ixNan(1,:,iAlt),iAlt);
        end
        Ans(:,all(isnan(Ans),3),:) = [];
        
    case 'epsilon'
        Ans = This.epsilon;
        
    case 'userdata'
        Ans = userdata(This);
        
    % Database of autoexogenise definitions d.variable = 'shock';
    case {'autoexogenise','autoexogenised','autoexogenize','autoexogenized'}
        Ans = autoexogenise(This);
        
    case {'activeshocks','inactiveshocks'}
        Ans = cell([1,nAlt]);
        for iAlt = 1 : nAlt
            list = This.name(This.nametype == 3);
            stdvec = This.Assign(1, ...
                end-sum(This.nametype == 3)+1:end,iAlt);
            if Query(1) == 'a'
                list(stdvec == 0) = [];
            else
                list(stdvec ~= 0) = [];
            end
            Ans{iAlt} = list;
        end
        
    case {'reporting','rpteq'}
        Ans = This.Reporting;
        
    case 'nx'
        Ans = length(This.solutionid{2});
    case 'nb'
        Ans = size(This.solution{7},1);
    case 'nf'
        Ans = length(This.solutionid{2}) - size(This.solution{7},1);
    case 'ny'
        Ans = sum(This.nametype==1);
    case 'ne'
        Ans = sum(This.nametype==3);
        
    case 'lastsyst'
        Ans = This.LastSyst;
        
    case 'eqtnblk'
        Ans = blazer.human(This.eqtn,This.EqtnBlk);
        
    case 'nameblk'
        Ans = blazer.human(This.name,This.NameBlk);
        
    otherwise
        Flag = false;
        
end

if chkSolution
    % Report solution(s) not available.
    [solutionFlag,ixNan] = isnan(This,'solution');
    if solutionFlag
        utils.warning('model:specget', ...
            'Solution(s) not available %s.', ...
            preparser.alt2str(ixNan));
    end
end

% Add parameters, std devs and non-zero cross-corrs.
if addParams
    Ans = addparam(This,Ans);
end


% Nested functions...


%**************************************************************************

    
    function doStationary()
        chkSolution = true;
        id = [This.solutionid{1:2}];
        t0 = imag(id) == 0;
        name = This.name(real(id(t0)));
        [~,ixNan] = isnan(This,'solution');
        status = nan([sum(t0),nAlt]);
        for iialt = find(~ixNan)
            unit = abs(abs(This.eigval(1,1:nb,iialt)) - 1) <= eigValTol;
            dy = any(abs(This.solution{4}(:,unit,iialt)) > realSmall,2).';
            df = any(abs(This.solution{1}(1:nf,unit,iialt)) > realSmall,2).';
            db = any(abs(This.solution{7}(:,unit,iialt)) > realSmall,2).';
            d = [dy,df,db];
            if strncmp(Query,'s',1)
                % Stationary.
                status(:,iialt) = transpose(double(~d(t0)));
            else
                % Non-stationary.
                status(:,iialt) = transpose(double(d(t0)));
            end
        end
        try %#ok<TRYNC>
            status = logical(status);
        end
        if ~isempty(strfind(Query,'list'))
            % List.
            if nAlt == 1
                Ans = name(status == true | status == 1);
                Ans = Ans(:)';
            else
                Ans = cell([1,nAlt]);
                for ii = 1 : nAlt
                    Ans{ii} = name(status(:,ii) == true | status(:,ii) == 1);
                    Ans{ii} = Ans{ii}(:)';
                end
            end
        else
            % Database.
            Ans = cell2struct(num2cell(status,2),name(:),1);
        end
    end % doStationary()


%**************************************************************************


    function doDerivatives()
        if strncmpi(Query,'y',1)
            select = This.eqtntype == 1;
        elseif strncmpi(Query,'x',1)
            select = This.eqtntype == 2;
        else
            select = This.eqtntype <= 2;
        end
        nEqtn = sum(select);
        Ans = cell(1,nEqtn);
        for iieq = find(select)
            u = This.DEqtnF{iieq};
            if isfunc(u)
                u = func2str(u);
            end
            u = regexprep(u,'^@\(.*?\)','','once');
            
            ptn = '\<x\>\(:,(\d+),t([+\-]\d+)\)';
            if true % ##### MOSW
                replacePlusMinus = @doReplacePlusMinus; %#ok<NASGU>
                u = regexprep(u,ptn,'${replacePlusMinus($1,$2)}');
            else
                u = mosw.dregexprep(u,ptn,@doReplacePlusMinus,[1,2]); %#ok<UNRCH>
            end
            
            ptn = '\<x\>\(:,(\d+),t\)';
            if true % ##### MOSW
                replaceZero = @doReplaceZero; %#ok<NASGU>
                u = regexprep(u,ptn,'${replaceZero($1)}');
            else
                u = regexprep(u,ptn,@doReplaceZero,1); %#ok<UNRCH>
            end
            
            Ans{iieq} = u;
        end
        
        function c = doReplacePlusMinus(c1,c2)
            ixNan = sscanf(c1,'%g');
            c = [This.name{ixNan},'{',c2,'}'];
        end % doReplacePlusMinus().
        
        function c = doReplaceZero(c1)
            ixNan = sscanf(c1,'%g');
            c = This.name{ixNan};
        end % doReplaceZero().
        
    end % doDerivatives()

   
%**************************************************************************


    function doWrt()
        if strncmpi(Query,'y',1)
            select = This.eqtntype == 1;
        elseif strncmpi(Query,'x',1)
            select = This.eqtntype == 2;
        else
            select = This.eqtntype <= 2;
        end        
        neqtn = sum(select);
        Ans = cell(1,neqtn);
        t0 = find(This.Shift == 0);
        for iieq = find(select)
            [tmOcc,nmOcc] = myfindoccur(This,iieq,'variables_shocks');
            tmOcc = tmOcc - t0;
            nOcc = length(tmOcc);
            Ans{iieq} = cell(1,nOcc);
            for iiOcc = 1 : nOcc
                c = This.name{nmOcc(iiOcc)};
                if tmOcc(iiOcc) ~= 0
                    c = sprintf('%s{%+g}',c,tmOcc(iiOcc));
                end
                if This.IxLog(nmOcc(iiOcc))
                    c = ['log(',c,')']; %#ok<AGROW>
                end
                Ans{iieq}{iiOcc} = c;
            end
        end
    end % doWrt()


end


% Subfunctions...


%**************************************************************************


function [ssLevel,ssGrowth,dtLevel,dtGrowth,ssDtLevel,ssDtGrowth] ...
    = xxSstate(This)

realexp = @(x) real(exp(x));
Assign = This.Assign;
ny = sum(This.nametype == 1);
nAlt = size(Assign,3);
nName = size(This.Assign,2);

% Steady states.
ssLevel = real(Assign);
ssGrowth = imag(Assign);

% Fix missing (=zero) growth in steady states of log variables.
ssGrowth(ssGrowth == 0 & This.IxLog(1,:,ones(1,nAlt))) = 1;

% Retrieve dtrends.
[dtLevel,dtGrowth] = mydtrendsrequest(This,'sstate');
dtLevel = permute(dtLevel,[3,1,2]);
dtGrowth = permute(dtGrowth,[3,1,2]);
dtLevel(:,ny+1:nName,:) = 0;
dtGrowth(:,ny+1:nName,:) = 0;

dtLevel(1,This.IxLog,:) = realexp(dtLevel(1,This.IxLog,:));
dtGrowth(1,This.IxLog,:) = exp(dtGrowth(1,This.IxLog,:));

% Steady state plus dtrends.
ssDtLevel = ssLevel;
ssDtLevel(1,~This.IxLog,:) = ssDtLevel(1,~This.IxLog,:) + dtLevel(1,~This.IxLog,:);
ssDtLevel(1,This.IxLog,:) = ssDtLevel(1,This.IxLog,:) .* dtLevel(1,This.IxLog,:);

ssDtGrowth = ssGrowth;
ssDtGrowth(1,~This.IxLog,:) = ssDtGrowth(1,~This.IxLog,:) + dtGrowth(1,~This.IxLog,:);
ssDtGrowth(1,This.IxLog,:) = ssDtGrowth(1,This.IxLog,:) .* dtGrowth(1,This.IxLog,:);

end % xxSstate()
