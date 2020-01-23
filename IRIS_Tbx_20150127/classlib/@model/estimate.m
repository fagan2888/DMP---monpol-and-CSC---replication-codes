function [PStar,Pos,PCov,Hess,This,V,Delta,PDelta,Delta1,PDelta1] ...
    = estimate(This,Data,Range,E,varargin)
% estimate  Estimate model parameters by optimising selected objective function.
%
% Syntax
% =======
%
%     [PEst,Pos,Cov,Hess,M,V,Delta,PDelta] = estimate(M,D,Range,Est,...)
%     [PEst,Pos,Cov,Hess,M,V,Delta,PDelta] = estimate(M,D,Range,Est,SPr,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `D` [ struct | cell ] - Input database or datapack from which the
% measurement variables will be taken.
%
% * `Range` [ struct ] - Date range.
%
% * `Est` [ struct ] - Database with the list of paremeters that will be
% estimated, and the parameter prior specifications (see below).
%
% * `SPr` [ empty | systempriors ] - System priors object,
% [`systempriors`](systempriors/Contents).
%
% Output arguments
% =================
%
% * `PEst` [ struct ] - Database with point estimates of requested
% parameters.
%
% * `Pos` [ poster ] - Posterior, [`poster`](poster/Contents), object; this
% object also gives you access to the value of the objective function at
% optimum or at any point in the parameter space, see the
% [`poster/eval`](poster/eval) function.
%
% * `Cov` [ numeric ] - Approximate covariance matrix for the estimates of
% parameters with slack bounds based on the asymptotic Fisher information
% matrix (not on the Hessian returned from the optimization routine).
%
% * `Hess` [ cell ] - `Hess{1}` is the total hessian of the objective
% function; `Hess{2}` is the contributions of the priors to the hessian.
%
% * `M` [ model ] - Model object solved with the estimated parameters
% (including out-of-likelihood parameters and common variance factor).
%
% The remaining three output arguments, `V`, `Delta`, `PDelta`, are the
% same as the [`model/loglik`](model/loglik) output arguments of the same
% names.
%
% Options
% ========
%
% * `'chkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'evalFrfPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% frequency response function prior density, and include it to the overall
% objective function to be optimised.
%
% * `'evalLik='` [ *`true`* | `false` ] - In each iteration, evaluate
% likelihood (or another data based criterion), and include it to the
% overall objective function to be optimised.
%
% * `'evalPPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% parameter prior density, and include it to the overall objective function
% to be optimised.
%
% * `'evalSPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% system prior density, and include it to the overall objective function to
% be optimised.
%
% * `'filter='` [ cell | *empty* ] - Cell array of options that will be
% passed on to the Kalman filter including the type of objective function;
% see help on [`model/filter`](model/filter) for the options available.
%
% * `'initVal='` [ `model` | *`struct`* | struct ] - If `struct` use the
% values in the input struct `Est` to start the iteration; if `model` use
% the currently assigned parameter values in the input model, `M`.
%
% * `'maxIter='` [ numeric | *`500`* ] - Maximum number of iterations
% allowed.
%
% * `'maxFunEvals='` [ numeric | *`2000`* ] - Maximum number of objective
% function calls allowed.
%
% * `'noSolution='` [ *`'error'`* | `'penalty'` | numeric ] - Specifies
% what happens if solution or steady state fails to solve in an iteration:
% `'error='` stops the execution with an error message, `'penalty='`
% returns an extreme value, `1e10`, back into the minimization routine; or
% a user-supplied penalty can be specified as a numeric scalar greater than
% `1e10`.
%
% * `'optimSet='` [ cell | *empty* ] - Cell array used to create the
% Optimization Toolbox options structure; works only with the option
% `'optimiser='` `'default'`.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links in each
% iteration.
%
% * `'solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution in
% each iteration; you can specify a cell array with options for the `solve`
% function.
%
% * `'optimiser='` [ *`'default'`* | `'pso'` | cell | function_handle ] -
% Minimiz ation procedure.
%
%     * `'default'`: The Optimization Toolbox function `fminunc` or
%     `fmincon` will be called depending on the presence or absence of
%     lower and/or upper bounds.
%
%     * `'pso'`: The Particle Swarm Optimizer will be called; use the
%     option `'pso='` to specify further options to control the optimizer
%     (see Options for Particle Swarm Optimizer below).
%
%     * function_handle or cell: Enter a function handle to your own
%     optimization procedure, or a cell array with a function handle and
%     additional input arguments (see below).
%
% * `'sstate='` [ `true` | *`false`* | cell | function_handle ] -
% Re-compute steady state in each iteration; you can specify a cell array
% with options for the `sstate` function, or a function handle whose
% behaviour is described below.
%
% * `'tolFun='` [ numeric | *`1e-6`* ] - Termination tolerance on the
% objective function.
%
% * `'tolX='` [ numeric | *`1e-6`* ] - Termination tolerance on the
% estimated parameters.
%
% Options for Particle Swarm Optimizer
% =====================================
%
% The following options can be specified through the main option
% `'optimset='` when `'optimiser=pso'`.
%
% * `'cognitiveAttraction='` [ numeric | *`0.5`* ] -  Scalar between `0`
% and `1` to control the relative attraction to the best location a
% particle can remember.
%
% * `'constrBoundary='` [ `absorb` | *`reflect`* | `soft` ] - Controls the
% way imposed constraints are handled when violated.
%
%     * `'soft'`: Particles are allowed to travel outside the bounds but
%     get bad fitness function (likelihood) values when they do;
%
%     * `'reflect'`: Particle velocity is changed such that when the
%     particle encounters the bound its velocity is changed to effectively
%     make it bounce off of the boundary;
%
%     * `'absorb'`: Particles hit the bound and stay at the bound until
%     attracted elsewhere because its velocity is set to zero.
%
% * `'display='` [ `'off'` | `'final'` | *`'iter'`* ] - Level of display in
% order of increasing verbosity; `'iter'` will only produce output at most
% `'updateInterval='` seconds.
%
% * `'fitnessLimit='` [ numeric | *`-Inf`* ] - Algorithm will terminate
% when a function value this low is encountered.
%
% * `'generations='` [ numeric | *`1000`* ] - Positive integer describing
% the maximum length of swarm evolution.
%
% * `'hybridFcn='` [ `true` | *`false`* | `'fmincon'` | `'fminunc'` | cell
% ] - Run a second stage optimization after PSO (only available with the
% Optimization Tbx installed):
%
%     * `false`: No second stage optimization, run the particle swarm only.
%
%     * `true`: After PSO, run either `fminunc` or `fmincon`, the
%     Optimization Toolbox routines, depending on the presence or absence
%     of lower and upper bounds on estimated parameters.
%
%     * `'fminunc'`, `'fmincon'`: After PSO, run the specified Optimization
%     Toolbox routine.
%
%     * cell: A cell array in which the first argument specifies the
%     function as previously and the second argument contains the options
%     structure for that function; for instance
%     `{@fmincon,optimset('Display','iter')}`.
%
% * `'includeInitialValue='` [ *`true`* | `false` ] - Include the initial
% vector of parameters in the initial population.
%
% * `'initialPopulation=`' [ numeric | *empty* ] - An NPar-by-NPop array
% containing the initial distribution of particles, where NPar is the
% number of estimated parameters, and NPop is the size of population. If
% empty, a population will be created containing the initial parameter
% vector and the rest of the particles will be randomly generated according
% to `'popInitRange='`. Use the option `'includeInitialValue=' false` oo
% exclude the initial value from the initial population so that the entire
% population is randomly generated.
%
% * `'socialAttraction='` [ numeric | *`1.25`* ] - Positive scalar to
% control the relative attraction of each particle to the best location
% they have heard about from other particles.
%
% * `'plotFcns='` [ cell | *empty* ] - Cell array of function handles to
% functions which accept `(options,state,flag)` values as input arguments.
% The only built-in general-purpose plotting function is
% `@optim.scoreDiversity`.
%
% * `'populationSize='` [ numeric | *`40`* ] - Positive integer which
% determines the number of particles in the swarm.
%
% * `'popInitRange='` [ numeric | *empty* ] - A 2-by-NPar array which sets
% the range over which the initial population will be distributed, where
% NPar is the number of estimated parameters, or a 2-by-1 array with the
% range for all parameters. If empty and `'PopInitRange='` is not set, the
% upper and lower bounds will be used if both are finite. If either of the
% bounds are infinite, the range will be `[0;1]`.
%
% * `'stallGenLimit='` [ numeric | *`100`* ] - Maximum number of swarm
% iterations which result in no improvement in the fitness function
% (likelihood) value before the algorithm terminates.
%
% * `'timeLimit='` [ numeric | *`Inf`* ] - Maximum running time in seconds.
%
% * `'tolCon='` [ numeric | *`1e-6`* ] - Largest tolerated constraint
% violation.
%
% * `'tolFun='` [ numeric | *`1e-6`* ] - Function tolerance; when the
% change in the best fitness function value (likelihood) improvement per
% generation falls below this value the algorithm will terminate.
%
% * `'velocityLimit='` [ numeric | *`Inf`* ] - Positive scalar to bound
% particle intertia from above.
%
% * `'updateInterval='`* [ numeric | `5` ] - Minimum length of time in
% seconds which must pass before new command window output will be
% produced.
%
% * `'useParallel='` [ `true` | *`false`* ] - Use a `parfor` loop which
% requires you already have a `matlabpool` open. Overhead is slightly
% higher for constrained problems than unconstrained problems.
%
% Description
% ============
%
% The parameters that are to be estimated are specified in the input
% parameter estimation database, `E` in which you can provide the following
% specifications for each parameter:
%
%     E.parameter_name = { start, lower, upper, logpriorFunc };
%
% where `start` is the value from which the numerical optimization will
% start, `lower` is the lower bound, `upper` is the upper bound, and
% `logpriorFunc` is a function handle expected to return the log of the
% prior density. You can use the [`logdist`](logdist/Contents) package to
% create function handles for some of the basic prior distributions.
%
% You can use `NaN` for `start` if you wish to use the value currently
% assigned in the model object. You can use `-Inf` and `Inf` for the
% bounds, or leave the bounds empty or not specify them at all. You can
% leave the prior distribution empty or not specify it at all.
%
% Estimating nonlinear models
% ----------------------------
%
% By default, only the first-order solution, but not the steady state is
% updated (recomputed) in each iteration before the likelihood is
% evaluated. This behavior is controled by two options, `'solve='` (`true`
% by default) and `'sstate='` (`false` by default). If some of the
% estimated parameters do affect the steady state of the model, the option
% '`sstate='` needs to be set to `true` or to a cell array with
% steady-state options, as in the function [`sstate`](model/sstate),
% otherwise the results will be groslly inaccurate or a valid first-order
% solution will be impossible to find.
%
% When steady state is recomputed in each iteration, you may also want to
% use the option `'chksstate='` to require that a steady-state check for
% all model equations be performed.
%
% User-supplied optimization (minimization) routine
% --------------------------------------------------
%
% You can supply a function handle to your own minimization routine through
% the option `'optimiser='`. This routine will be used instead of the Optim
% Tbx's `fminunc` or `fmincon` functions. The user-supplied function is
% expected to take at least five input arguments and return three output
% arguments:
%
%     [PEst,ObjEst,Hess] = yourminfunc(F,P0,PLow,PHigh,OptimSet)
%
% with the following input arguments:
%
% * `F` is a function handle to the function minimised;
% * `P0` is a 1-by-N vector of initial parameter values;
% * `PLow` is a 1-by-N vector of lower bounds (with `-Inf` indicating no
% lower bound);
% * `PHigh` is a 1-by-N vector of upper bounds (with `Inf` indicating no
% upper bounds);
% * `OptimSet` is a cell array with name-value pairs entered by the user
% through the option `'optimSet='`. This option can be used to modify
% various settings related to the optimization routine, such as tolerance,
% number of iterations, etc. Of course, you may simply ignore it and leave
% this input argument unused;
%
% and the following output arguments:
%
% * `PEst` is a 1-by-N vector of estimated parameters;
% * `ObjEst` is the value of the objective function at optimum;
% * `Hess` is a N-by-N approximate Hessian matrix at optimum.
%
% If you need to use extra input arguments in your minimization function,
% enter a cell array instead of a plain function handle:
%
%     {@yourminfunc,Arg1,Arg2,...}
%
% In that case, the optimiser will be called the following way:
%
%     [PEst,ObjEst,Hess] = yourminfunc(F,P0,PLow,PHigh,Opt,Arg1,Arg2,...)
%
% User-supplied steady-state solver
% ----------------------------------
%
% You can supply a function handle to your own steady-state solver (i.e. a
% function that finds the steady state for given parameters) through the
% `'sstate='` option.
%
% The function is expected to take one input argument, the model object
% with newly assigned parameters, and return at least two output arguments,
% the model object with a new steady state (or balanced-growth path) and a
% success flag. The flag is `true` if the steady state has been successfully
% computed, and `false` if not:
%
%     [M,Success] = mysstatesolver(M)
%
% It is your responsibility to add the growth characteristics if some of
% the model variables drift over time. In other words, you need to take
% care of the imaginary parts of the steady state values in the model
% object returned by the solver.
%
% Alternatively, you can also run the steady-state solver with extra input
% arguments (with the model object still being the first input argument).
% In that case, you need to set the option `'sstate='` to a cell array with
% the function handle in the first cell, and the other input arguments
% afterwards, e.g.
%
%     'sstate=',{@mysstatesolver,1,'a',X}
%
% The actual function call will have the following form:
%
%     [M,Success] = mysstatesolver(M,1,'a',X)
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% Fifth input argument can be a systempriors object.
if isempty(varargin) || ischar(varargin{1})
    SP = [];
else
    SP = varargin{1};
    varargin(1) = [];
end

% Validate required input arguments.
pp = inputParser();
pp.addRequired('Data',@(x) isstruct(x) || iscell(x) || isempty(x));
pp.addRequired('Range',@(x) isnumeric(x) || isempty(x));
pp.addRequired('Est',@(x) isstruct(x) || iscell(x));
pp.addRequired('SysPri',@(x) isempty(x) || isa(x,'systempriors'));
pp.parse(Data,Range,E,SP);

estOpt = passvalopt('model.estimate',varargin{:});

% Initialise and pre-process sstate and chksstate options.
[estOpt.sstate,This] = mysstateopt(This,'silent',estOpt.sstate);
estOpt.chksstate = mychksstateopt(This,'silent',estOpt.chksstate);
estOpt.solve = mysolveopt(This,'silent',estOpt.solve);

if isempty(This.Refresh)
    estOpt.refresh = false;
end

% Process likelihood function options and create a likstruct.
Range = Range(1) : Range(end);
likOpt = mypreploglik(This,Range,estOpt.domain,[],estOpt.filter{:});
estOpt = rmfield(estOpt,'filter');

% Get the first column of measurement and exogenous variables.
if estOpt.evallik
    % `Data` includes pre-sample.
    Data = datarequest('yg*',This,Data,Range,1,likOpt);
else
    Data = [];
end

%--------------------------------------------------------------------------

% Check prior consistency.
doChkPriors();

if ~any(This.nametype == 1)
    utils.warning('model:estimate', ...
        'Model does not have any measurement variables.');
end

% Multiple parameterizations not allowed.
nAlt = size(This.Assign,3);
if nAlt > 1
    utils.error('model:estimate', ...
        ['Cannot run estimate(...) on models ', ...
        'with multiple parameterizations or multiple data sets.']);
end

% Retrieve names of parameters to be estimated, initial values, lower
% and upper bounds, penalties, and prior distributions.
pri = myparamstruct(This,E,SP,estOpt.penalty,estOpt.initval);

% Backend `myestimate`
%----------------------
[This,pStar,objStar,PCov,Hess] = myestimate(This,Data,pri,estOpt,likOpt);

% Assign estimated parameters, refresh dynamic links, and re-compute steady
% state, solution, and expansion matrices.
throwError = true;
estOpt.solve.fast = false;
This = myupdatemodel(This,pStar,pri,estOpt,throwError);

% Set up posterior object
%-------------------------
% Set up posterior object before we assign out-of-liks and scale std
% errors in the model object.

Pos = poster();
doPopulatePosterObj();

% Re-run loglik for out-of-lik params
%-------------------------------------
% Re-run the Kalman filter or FD likelihood to get the estimates of V
% and out-of-lik parameters.
V = 1;
Delta = [];
PDelta = [];
if estOpt.evallik && (nargout >= 5 || likOpt.relative)
    [~,regOutp] = likOpt.minusLogLikFunc(This,Data,[],likOpt);
    % Post-process the regular output arguments, update the std parameter
    % in the model object, and refresh if needed.
    xRange = Range(1)-1 : Range(end);
    [~,~,V,Delta,PDelta,~,This] ...
        = mykalmanregoutp(This,regOutp,xRange,likOpt,estOpt);
end

% Database with point estimates.
PStar = cell2struct(num2cell(pStar),pri.plist,2);

% Backward compatibility.
if nargout > 8
    Delta1 = Delta;
    PDelta1 = PDelta;
end

% Nested functions...


%**************************************************************************
    
    
    function doChkPriors()
        [flag,invalidBound,invalidPrior] = chkpriors(This,E);
        if ~flag
            if ~isempty(invalidBound)
                utils.error('model:estimate',...
                    ['Initial condition is inconsistent with ', ...
                    'lower/upper bounds: ''%s''.'], ...
                    invalidBound{:});
            end
            if ~isempty(invalidBound)
                utils.error('model:estimate',...
                    ['Initial condition is inconsistent with ', ...
                    'prior distribution: ''%s''.'], ...
                    invalidPrior{:});
            end
        end
    end % doChkPriors()


%**************************************************************************

    
    function doPopulatePosterObj()
        % Make sure that draws that fail to solve do not cause an error
        % and hence do not interupt the posterior simulator.
        if ~isequal(estOpt.nosolution,Inf)
            estOpt.nosolution = Inf;
%             utils.warning('model:estimate', ...
%                 ['Changing the option ''noSolution='' to Inf in the ', ...
%                 'posterior simulation object.']);
        end
        
        Pos.ParamList = pri.plist;
        Pos.MinusLogPostFunc = @objfunc;
        Pos.MinusLogPostFuncArgs = {This,Data,pri,estOpt,likOpt};
        Pos.InitLogPost = -objStar;
        Pos.InitParam = pStar;
        try
            Pos.InitProposalCov = PCov;
        catch Error
            utils.warning('model:estimate', ...
                ['Posterior simulator object cannot be initialised.', ...
                '\nThe following error occurs:\n\n%s'], ...
                Error.message);
        end
        Pos.LowerBounds = pri.pl;
        Pos.UpperBounds = pri.pu;
    end % doPopulatePosterObj()


end
