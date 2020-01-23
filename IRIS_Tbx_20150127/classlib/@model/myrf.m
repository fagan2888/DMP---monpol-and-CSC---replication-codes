function [S,Range,EList] = myrf(This,Time,Func,EList,Opt)
% myrf  [Not a public function] Response function backend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser();
pp.addRequired('M',@(x) isa(This,'model'));
pp.addRequired('Time',@isnumeric);
pp.parse(This,Time);

% Tell whether time is nper or range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    Range = 1 : Time;
else
    Range = Time(1) : Time(end);
end
nPer = length(Range);

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nAlt = size(This.Assign,3);
nRun = length(EList);

% Simulate response function
%----------------------------
% Output data from `timedom.srf` and `timedom.icrf` include the pre-sample
% period.
Phi = nan(ny+nx,nRun,nPer+1,nAlt);

isSol = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,K,Z,H,D,U] = mysspace(This,iAlt,false); %#ok<ASGLU>
    
    % Continue immediately if solution is not available.
    isSol(iAlt) = all(~isnan(T(:)));
    if ~isSol(iAlt)
        continue
    end    
    
    Phi(:,:,:,iAlt) = Func(T,R,[],Z,H,[],U,[],iAlt,nPer);
end

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model:myrf', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Create output data
%--------------------
S = struct();
maxLag = -min(imag(This.solutionid{2}));

% Permute Phi so that Phi(k,t,m,n) is the response of the k-th variable to
% m-th init condition at time t in parameterisation n.
Phi = permute(Phi,[1,3,2,4]);

templ = tseries();

% Measurement variables.
Y = Phi(1:ny,:,:,:);
for i = find(This.nametype == 1)
    y = permute(Y(i,:,:,:),[2,3,4,1]);
    if Opt.delog && This.IxLog(i)
        y = realexp(y);
    end
    name = This.name{i};
    c = utils.concomment(name,EList,This.IxLog(i));
    % @@@@@ MOSW.
    % Matlab accepts repmat(c,1,1,nAlt), too.
    c = repmat(c,[1,1,nAlt]);
    S.(name) = replace(templ,y,Range(1)-1,c);
end

% Transition variables.
X = myreshape(This,Phi(ny+1:end,:,:,:));
offset = sum(This.nametype == 1);
for i = find(This.nametype == 2)
    x = permute(X(i-offset,:,:,:),[2,3,4,1]);
    if Opt.delog && This.IxLog(i)
        x = realexp(x);
    end
    name = This.name{i};
    c = utils.concomment(name,EList,This.IxLog(i));
     % @@@@@ MOSW.
    c = repmat(c,[1,1,nAlt]);
    S.(name) = replace(templ,x,Range(1)-1-maxLag,c);
end

% Shocks.
e = zeros(nPer,nRun,nAlt);
for i = find(This.nametype == 3)
    name = This.name{i};    
    c = utils.concomment(name,EList,false);
    % @@@@@ MOSW.
    c = repmat(c,[1,1,nAlt]);
    S.(name) = replace(templ,e,Range(1),c);
end

% Parameters.
S = addparam(This,S);

end
