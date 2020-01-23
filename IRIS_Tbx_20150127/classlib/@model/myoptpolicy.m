function [NewEqtn,NewEqtnF,NewEqtnS,NewNonlin] ...
    = myoptpolicy(This,LossPos,LossDisc,Type)
% myoptpolicy  [Not a public function] Calculate equations for discretionary optimal policy.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = sydney();
flNameType = floor(This.nametype);
t0 = find(This.Shift == 0);

% Make the model names visible inside dynamic regexps.
name = This.name;

eqtn = cell(size(This.eqtnF));
eqtn(:) = {''};
eqtn(flNameType == 2) = This.eqtnF(flNameType == 2);

% Replace x(:,n,t+k) with xN, xNpK, or xNmK, and &x(n) with Ln.
eqtn = sydney.myeqtn2symb(eqtn);
LossDisc = sydney.myeqtn2symb(LossDisc);

% First transition equation.
first = find(This.eqtntype == 2,1);

% The loss function is always the last equation. After the loss function,
% there are empty place holders. The new equations will be put in place of
% the loss function and the placeholders.
NewEqtn = cell(size(eqtn));
NewEqtn(:) = {''};
NewEqtnF = NewEqtn;
NewEqtnS = NewEqtn;
NewNonlin = false(size(eqtn));
zd = sydney(LossDisc,{});

% The lagrangian is
%
%     Mu_Eq1*eqtn1 + Mu_Eq2*eqtn2 + ... + lossfunc.
%
% The new k-th (k runs only for the original transition variables) equation
% is the derivative of the lagrangian wrt to the k-th variable, and is
% given by
%
%     Mu_Eq1*diff(eqtn1,namek) + Mu_Eq2*diff(eqtn2,namek) + ...
%     + diff(lossfunc,namek) = 0.
%
% We loop over the equations, and build gradually the new equations from
% the individual derivatives.

for eq = first : LossPos
    
    % Get the list of all variables and shocks (current dates, lags, leads) in
    % this equation.
    [tmOcc,nmOcc] = myfindoccur(This,eq,'variables_shocks');
    tmOcc = tmOcc(:).';
    nmOcc = nmOcc(:).';

    % Find the index of transition variables.
    inx = flNameType(nmOcc) == 2;
    if strcmpi(Type,'consistent') || strcmpi(Type,'discretion')
        % This is a consistent (discretionary) policy. We only
        % differentiate wrt to current dates or lags of transition
        % variables. Remove leads from the list of variables we will
        % differentiate wrt.
        inx = inx & tmOcc <= t0;
    end
    
    tmOcc = tmOcc(inx);
    nmOcc = nmOcc(inx);
    nOcc = length(tmOcc);
    
    % Write a cellstr with the symbolic names of variables wrt which we will
    % differentiate.
    unknown = cell(1,nOcc);
    for j = 1 : nOcc
        if tmOcc(j) == t0
            % Time index == 0: replace x(1,23,t) with x23.
            unknown{j} = sprintf('x%g',nmOcc(j));
        elseif tmOcc(j) < t0
            % Time index < 0: replace x(1,23,t-1) with x23m1.
            unknown{j} = sprintf('x%gm%g', ...
                nmOcc(j),round(t0-tmOcc(j)));
        elseif tmOcc(j) > t0
            % Time index > 0: replace x(1,23,t+1) with x23p1.
            unknown{j} = sprintf('x%gp%g', ...
                nmOcc(j),round(tmOcc(j)-t0));
        end
    end
    
    z = sydney(eqtn{eq},unknown);
    
    % Differentiate this equation wrt to all variables and return a cell array
    % of separate sydney objects for each derivative.
    diffz = derv(z,'separate',unknown);
  
    for j = 1 : nOcc

        sh = tmOcc(j) - t0;
        newEq = nmOcc(j);
        
        % Multiply derivatives wrt lags and leads by the discount factor.
        if sh == 0
            % Do nothing.
        elseif sh == -1
            diffz{j} = zd * diffz{j};
        elseif sh == 1
            diffz{j} = diffz{j} / zd;
        else
            diffz{j} = power(zd,-sh) * diffz{j};
        end
        
        % If this is not the loss function, multiply the derivative by
        % the multiplier. The appropriate lag or lead of the multiplier
        % will be introduced together with other variables in <?Shift?>.
        if eq < LossPos
            mult = template;
            mult.args = sprintf('x%g',eq);
            diffz{j} = diffz{j}*mult;
        end

        dEqtn = char(reduce(diffz{j}));
        
        % Shift lags and leads of variables (but not parameters) in the
        % derivative by -sh if sh ~= 0.
        if sh ~= 0
            dEqtn = sydney.myshift(dEqtn,-sh,flNameType <= 2);
        end
        
        dEqtnF = sydney.mysymb2eqtn(dEqtn);
        if ~This.IsLinear
            dEqtnS = sydney.mysymb2eqtn(dEqtn,'sstate');
        end

        % Create human equations: `x10m3` -> `Name{-3}`, `L10m3` -> `&Name{-3}`.
        ptn = '([xL])(\d+)(([pm]\d+)?)';
        if true % ##### MOSW
            replFunc = @doReplaceNames; %#ok<NASGU>
            dEqtn = regexprep(dEqtn,ptn,'${replFunc($1,$2,$3)}');
        else
            dEqtn = mosw.dregexprep(dEqtn,ptn,@doReplaceNames,[1,2,3]); %#ok<UNRCH>
        end
        
        % Put together the derivative of the Lagrangian wrt to variable
        % #neweq.
        if isempty(NewEqtn{newEq})
            NewEqtn{newEq} = '=0;';
            NewEqtnF{newEq} = ';';
            if ~This.IsLinear
                NewEqtnS{newEq} = ';';
            end
        end
        
        sign = '+';
        if strncmp(NewEqtn{newEq},'-',1) ...
                || strncmp(NewEqtn{newEq},'+',1) ...
                || strncmp(NewEqtn{newEq},'=',1)
            sign = '';
        end
        NewEqtn{newEq} = [dEqtn,sign,NewEqtn{newEq}];
        NewEqtnF{newEq} = [dEqtnF,sign,NewEqtnF{newEq}];
        if ~This.IsLinear
            NewEqtnS{newEq} = [dEqtnS,sign,NewEqtnS{newEq}];
            % Earmark the derivative for non-linear simulation if at least one equation
            % in it is non-linear and the derivative is non-zero. The derivative of the
            % loss function is supposed to be treated as non-linear if the loss
            % function itself has been introduced by min#() and not min().
            isNonlin = This.IxNonlin(eq) && ~isequal(dEqtn,'0');
            NewNonlin(newEq) = NewNonlin(newEq) || isNonlin;
        end
        
    end
end

if ~This.IsLinear
    % Replace = with #= in non-linear human equations.
    NewEqtn(NewNonlin) = strrep(NewEqtn(NewNonlin),'=0;','=#0;');
end


% Nested functions...


        function C = doReplaceNames(C1,C2,C3)
            C = name{sscanf(C2,'%g')};
            if strcmp(C1,'L')
                % C1 is either 'x' or 'L'. 'L' means a sstate reference; add an '&' in
                % front of the variable name.
                C = ['&',C];
            end
            if isempty(C3)
                return
            end
            if C3(1) == 'p'
                C = [C,'{+',C3(2:end),'}'];
            elseif C3(1) == 'm'
                C = [C,'{-',C3(2:end),'}'];
            end
        end

    
end
