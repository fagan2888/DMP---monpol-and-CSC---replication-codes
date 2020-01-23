classdef model < modelobj & estimateobj
    % model  Models (model Objects).
    %
    % Model objects are created by loading a [model file](modellang/Contents).
    % Once a model object exists, you can use model functions and standard
    % Matlab functions to write your own m-files to perform the desired tasks,
    % such calibrate or estimate the model, find its steady state, solve and
    % simulate it, produce forecasts, analyse its properties, and so on.
    %
    % Model methods:
    %
    % Constructor
    % ============
    %
    % * [`model`](model/model) - Create new model object based on model file.
    %
    % Getting information about models
    % =================================
    %
    % * [`addparam`](model/addparam) - Add model parameters to a database (struct).
    % * [`autocaption`](model/autocaption) - Create captions for graphs of model variables or parameters.
    % * [`autoexogenise`](model/autoexogenise) - Get or set variable/shock pairs for use in autoexogenised simulation plans.
    % * [`comment`](model/comment) - Get or set user comments in an IRIS object.
    % * [`eig`](model/eig) - Eigenvalues of the transition matrix.
    % * [`findeqtn`](model/findeqtn) - Find equations by the labels.
    % * [`findname`](model/findname) - Find names of variables, shocks, or parameters by their descriptors.
    % * [`get`](model/get) - Query model object properties.
    % * [`iscompatible`](model/iscompatible) - True if two models can occur together on the LHS and RHS in an assignment.
    % * [`islinear`](model/islinear) - True for models declared as linear.
    % * [`islog`](model/islog) - True for log-linearised variables.
    % * [`ismissing`](model/ismissing) - True if some initical conditions are missing from input database.
    % * [`isnan`](model/isnan) - Check for NaNs in model object.
    % * [`isname`](model/isname) - True for valid names of variables, parameters, or shocks in model object.
    % * [`issolved`](model/issolved) - True if a model solution exists.
    % * [`isstationary`](model/isstationary) - True if model or specified combination of variables is stationary.
    % * [`length`](model/length) - Number of alternative parameterisations.
    % * [`omega`](model/omega) - Get or set the covariance matrix of shocks.
    % * [`sspace`](model/sspace) - State-space matrices describing the model solution.
    % * [`system`](model/system) - System matrices for unsolved model.
    % * [`userdata`](model/userdata) - Get or set user data in an IRIS object.
    %
    % Referencing model objects
    % ==========================
    %
    % * [`subsasgn`](model/subsasgn) - Subscripted assignment for model and systemfit objects.
    % * [`subsref`](model/subsref) - Subscripted reference for model and systemfit objects.
    %
    % Changing model objects
    % =======================
    %
    % * [`alter`](model/alter) - Expand or reduce number of alternative parameterisations.
    % * [`assign`](model/assign) - Assign parameters, steady states, std deviations or cross-correlations.
    % * [`export`](model/export) - Save carry-around files to disk file.
    % * [`horzcat`](model/horzcat) - Combine two compatible model objects in one object with multiple parameterisations.
    % * [`refresh`](model/refresh) - Refresh dynamic links.
    % * [`reset`](model/reset) - Reset specific values within model object.
    % * [`stdscale`](model/stdscale) - Rescale all std deviations by the same factor.
    % * [`set`](model/set) - Change modifiable model object property.
    % * [`single`](model/single) - Convert solution matrices to single precision.
    %
    % Steady state
    % =============
    %
    % * [`blazer`](model/blazer) - Reorder steady-state equations into block-recursive structure.
    % * [`chksstate`](model/chksstate) - Check if equations hold for currently assigned steady-state values.
    % * [`sstate`](model/sstate) - Compute steady state or balance-growth path of the model.
    % * [`sstatefile`](model/sstatefile) - Create a steady-state file based on the model object's steady-state equations.
    %
    % Solution, simulation and forecasting
    % =====================================
    %
    % * [`chkmissing`](model/chkmissing) - Check for missing initial values in simulation database.
    % * [`diffsrf`](model/diffsrf) - Differentiate shock response functions w.r.t. specified parameters.
    % * [`expand`](model/expand) - Compute forward expansion of model solution for anticipated shocks.
    % * [`jforecast`](model/jforecast) - Forecast with judgmental adjustments (conditional forecasts).
    % * [`icrf`](model/icrf) - Initial-condition response functions.
    % * [`lhsmrhs`](model/lhsmrhs) - Evaluate the discrepancy between the LHS and RHS for each model equation and given data.
    % * [`resample`](model/resample) - Resample from the model implied distribution.
    % * [`reporting`](model/reporting) - Evaluate reporting equations from within model object.
    % * [`shockplot`](model/shockplot) - Short-cut for running and plotting plain shock simulation.
    % * [`simulate`](model/simulate) - Simulate model.
    % * [`solve`](model/solve) - Calculate first-order accurate solution of the model.
    % * [`srf`](model/srf) - Shock response functions, first-order solution only.
    %
    % Model data
    % ===========
    %
    % * [`data4lhsmrhs`](model/data4lhsmrhs) - Prepare data array for running `lhsmrhs`.
    % * [`emptydb`](model/emptydb) - Create model-specific database with empty tseries for all variables and shocks.
    % * [`rollback`](model/rollback) - Prepare database for a rollback run of Kalman filter.
    % * [`sstatedb`](model/sstatedb) - Create model-specific steady-state or balanced-growth-path database.
    % * [`zerodb`](model/zerodb) - Create model-specific zero-deviation database.
    %
    % Stochastic properties
    % ======================
    %
    % * [`acf`](model/acf) - Autocovariance and autocorrelation functions for model variables.
    % * [`ifrf`](model/ifrf) - Frequency response function to shocks.
    % * [`fevd`](model/fevd) - Forecast error variance decomposition for model variables.
    % * [`ffrf`](model/ffrf) - Filter frequency response function of transition variables to measurement variables.
    % * [`fmse`](model/fmse) - Forecast mean square error matrices.
    % * [`vma`](model/vma) - Vector moving average representation of the model.
    % * [`xsf`](model/xsf) - Power spectrum and spectral density of model variables.
    %
    % Identification, estimation and filtering
    % =========================================
    %
    % * [`bn`](model/bn) - Beveridge-Nelson trends.
    % * [`diffloglik`](model/diffloglik) - Approximate gradient and hessian of log-likelihood function.
    % * [`estimate`](model/estimate) - Estimate model parameters by optimising selected objective function.
    % * [`evalsystempriors`](model/evalsystempriors) - Evaluate minus log of system prior density.
    % * [`filter`](model/filter) - Kalman smoother and estimator of out-of-likelihood parameters.
    % * [`fisher`](model/fisher) - Approximate Fisher information matrix in frequency domain.
    % * [`lognormal`](model/lognormal) - Characteristics of log-normal distributions returned from filter of forecast.
    % * [`loglik`](model/loglik) - Evaluate minus the log-likelihood function in time or frequency domain.
    % * [`neighbourhood`](model/neighbourhood) - Evaluate the local behaviour of the objective function around the estimated parameter values.
    % * [`regress`](model/regress) - Centred population regression for selected model variables.
    % * [`VAR`](model/VAR) - Population VAR for selected model variables.
    %
    % Getting on-line help on model functions
    % ========================================
    %
    %     help model
    %     help model/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2015 IRIS Solutions Team.

    
    properties (GetAccess=public,SetAccess=protected,Hidden)
        % Vector [1-by-nname] of positions of shocks assigned to variables for
        % `autoexogenise`.
        Autoexogenise = nan(1,0);
        % Unit-root tolerance.
        Tolerance = NaN;
        % Anonymous function handles to streamlined full dynamic equations.
        eqtnF = cell(1,0);
        % Anonymous function handles to streamlined steady-state equations.
        EqtnS = cell(1,0);
        % A 1-by-nEqtn logical index of equations marked as non-linear.
        IxNonlin = false(1,0);
        % Block-recursive structure for variable names.
        NameBlk = cell(1,0);
        % Block recursive structure for steady-state equations.
        EqtnBlk = cell(1,0);
        % Anonymous function handles to derivatives.
        DEqtnF = cell(1,0);
        % Function handles to constant terms in linear models.
        CEqtnF = cell(1,0);
        % Reporting equations object.
        Reporting = rpteq();
        % Order of execution of dynamic links.
        Refresh = zeros(1,0);
        % Logical arrays with occurences of variables, shocks and parameters in full dynamic equations.
        occur = sparse(false(0));
        % Logical arrays with occurences of variables, shocks and parameters in steady-state equations.
        occurS = sparse(false(0));
        % Location of t=0 page in `occur`.
        % tzero = NaN;
        % Vector minT : maxT (min lag to max lead).
        Shift = [];
        % Vectors of measurement variables, transition variables, and shocks in columns of unsolved sysmtem matrices.
        systemid = { ...
            cell(1,0), ...
            cell(1,0), ...
            cell(1,0), ...
            };
        % Derivatives to system matrices.
        d2s = [];
        % Model eigenvalues.
        eigval = zeros(1,0);
        % Differentiation step when calculating numerical derivatives.
        epsilon = eps^(1/3);
        % Matrices necessary to generate forward expansion of model solution.
        Expand = {};
        % Model state-space matrices T, R, K, Z, H, D, U, Y, ZZ.
        solution = {[],[],[],[],[],[],[],[],[]};
        % Vectors of measurement variables, transition variables, and shocks in rows and columns of state-space matrices.
        solutionid = {[],[],[]};
        % True for predetermined variables for which initial condition is truly needed.
        icondix = false(1,0);
        % True for multipliers (optimal policy).
        multiplier = false(1,0);
    end
    
    
    % Transient properties are not saved to disk files, and need to be
    % recreated each time a model object is loaded. Use mytransient() to
    % recreate all transient properties.
    properties(GetAccess=public,SetAccess=protected,Hidden,Transient)
        % Anonymous function handles to equations evaluating the LHS-RHS.
        EqtnN = [];
        % Handle to last derivatives and system matrices.
        LastSyst = [];
    end
    
    
    methods
        varargout = acf(varargin)
        varargout = alter(varargin)
        varargout = assign(varargin)
        varargout = autoexogenise(varargin)
        varargout = blazer(varargin)        
        varargout = bn(varargin)
        varargout = chksstate(varargin)
        varargout = data4lhsmrhs(varargin)
        varargout = diffloglik(varargin)
        varargout = diffsrf(varargin)
        varargout = eig(varargin)
        varargout = estimate(varargin)
        varargout = evalsystempriors(varargin)
        varargout = expand(varargin)
        varargout = fevd(varargin)
        varargout = ffrf(varargin)
        varargout = filter(varargin)
        varargout = findeqtn(varargin)
        varargout = fisher(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = icrf(varargin)
        varargout = ifrf(varargin)
        varargout = irf(varargin)
        varargout = iscompatible(varargin)
        varargout = islog(varargin)
        varargout = ismissing(varargin)
        varargout = isnan(varargin)
        varargout = issolved(varargin)
        varargout = isstationary(varargin)
        varargout = jforecast(varargin)
        varargout = lhsmrhs(varargin)
        varargout = loglik(varargin)
        varargout = lognormal(varargin) %#
        varargout = refresh(varargin)
        varargout = reporting(varargin)
        varargout = resample(varargin)
        varargout = rollback(varargin)
        varargout = set(varargin)
        varargout = shockplot(varargin)
        varargout = simulate(varargin)
        varargout = single(varargin)
        varargout = solve(varargin)
        varargout = sprintf(varargin)
        varargout = srf(varargin)
        varargout = sspace(varargin)
        varargout = sstate(varargin)
        varargout = sstatedb(varargin)
        varargout = sstatefile(varargin)
        varargout = system(varargin)
        varargout = VAR(varargin)
        varargout = vma(varargin)
        varargout = xsf(varargin)
        varargout = zerodb(varargin)
    end
    
    
    methods (Hidden)
        varargout = hdatainit(varargin)
        varargout = mychk(varargin)
        varargout = myfdlik(varargin)
        varargout = myfindsspacepos(varargin)
        varargout = myget(varargin)
        varargout = mykalman(varargin)
        varargout = myupdatemodel(varargin)
        varargout = datarequest(varargin)
        varargout = disp(varargin)
        varargout = end(varargin)
        varargout = getnonlinobj(varargin)
        varargout = objfunc(varargin)
        varargout = isempty(varargin)
        varargout = saveobj(varargin)
        varargout = specget(varargin)
        varargout = tolerance(varargin)
    end
    
    
    methods (Access=protected,Hidden)
        varargout = myaffectedeqtn(varargin)
        varargout = myalpha2xb(varargin)
        varargout = myanchors(varargin)
        varargout = myautoexogenise(varargin)
        varargout = mychksstate(varargin)
        varargout = mychksstateopt(varargin)
        varargout = mychksyntax(varargin)
        varargout = myconsteqtn(varargin)
        varargout = myd2s(varargin)
        varargout = myderiv(varargin)
        varargout = mydiffloglik(varargin)
        varargout = mydtrendsrequest(varargin)
        varargout = mydtrends4lik(varargin)
        varargout = myeqtn2afcn(varargin)
        varargout = myfile2model(varargin)
        varargout = myfinaleqtns(varargin)
        varargout = myfind(varargin)
        varargout = myfindoccur(varargin)
        varargout = myforecastswap(varargin)
        varargout = mykalmanregoutp(varargin)
        varargout = mymodel2model(varargin)
        varargout = mynamepattrepl(varargin)
        varargout = mynunit(varargin)
        varargout = myoccurrence(varargin)
        varargout = myoptpolicy(varargin)
        varargout = myparamstruct(varargin)
        varargout = myparse(varargin)
        varargout = mypreploglik(varargin)
        varargout = myprepsimulate(varargin)
        varargout = myreshape(varargin)
        varargout = myshocktype(varargin)
        varargout = mysolve(varargin)
        varargout = mysolvefail(varargin)
        varargout = mysolveopt(varargin)
        varargout = mysourcedb(varargin)
        varargout = mysspace(varargin)
        varargout = mysstatelinear(varargin)
        varargout = mysstatenonlin(varargin)
        varargout = mysstateopt(varargin)
        varargout = mysstateswap(varargin)
        varargout = mystruct2obj(varargin)
        varargout = mysubsalt(varargin)
        varargout = mysymbdiff(varargin)
        varargout = mysystem(varargin)
        varargout = mytransient(varargin)
        varargout = mytrendarray(varargin)
        varargout = myvector(varargin)
        varargout = outputdbase(varargin)
    end
    
    
    methods (Static)
        varargout = failed(varargin)
    end
    
    
    methods (Static,Hidden)
        varargout = myexpand(varargin)
        varargout = myfourierdata(varargin)
        varargout = mymse2var(varargin)
        varargout = myoutoflik(varargin)
        varargout = loadobj(varargin)
    end
    
    
    % Constructor and dependent properties.
    methods
        function This = model(varargin)
            % model  Create new model object based on model file.
            %
            % Syntax
            % =======
            %
            %     M = model(FName,...)
            %     M = model(M,...)
            %
            % Input arguments
            % ================
            %
            % * `FName` [ char | cellstr ] - Name(s) of model file(s) that will be
            % loaded and converted to a new model object.
            %
            % * `M` [ model ] - Existing model object that will be rebuilt as if from a
            % model file.
            %
            % Output arguments
            % =================
            %
            % * `M` [ model ] - New model object based on the input model code file or
            % files.
            %
            % Options
            % ========
            %
            % * `'assign='` [ struct | *empty* ] - Assign model parameters and/or steady
            % states from this database at the time the model objects is being created.
            %
            % * `'baseYear='` [ numeric | *2000* ] - Base year for constructing
            % deterministic time trends.
            %
            % * `'blazer='` [ *`true`* | `false` ] - Perform
            % block-recursive analysis of steady-state equations at the
            % time the model object is being created; the option works only
            % in nonlinear models.
            %
            % * `'comment='` [ char | *empty* ] - Text comment attached to the model
            % object.
            %
            % * `'declareParameters='` [ *`true`* | `false` ] - If `false`, skip
            % parameter declaration in the model file, and determine the list of
            % parameters automatically as names found in equations but not declared.
            %
            % * `'epsilon='` [ numeric | *eps^(1/4)* ] - The minimum relative step size
            % for numerical differentiation.
            %
            % * `'linear='` [ `true` | *`false`* ] - Indicate linear models.
            %
            % * `'makeBkw='` [ *`@auto`* | `@all` | cellstr | char ] -
            % Variables included in the list will be made part of the
            % vector of backward-looking variables; `@auto` means
            % the variables that do not have any lag in model equations
            % will be put in the vector of forward-looking variables.
            %
            % * `'multiple='` [ true | *false* ] - Allow each variable, shock, or
            % parameter name to be declared (and assigned) more than once in the model
            % file.
            %
            % * `'optimal='` [ `'commitment'` | *`'discretion'`* ] - Type
            % of optimal policy calculated; only applies when the keyword
            % [`min`](modellang/min) is used in the model file.
            %
            % * `'removeLeads='` [ `true` | *`false`* ] - Remove all leads from the
            % state-space vector, keep included only current dates and lags.
            %
            % * `'sstateOnly='` [ `true` | *`false`* ] - Read in only the steady-state
            % versions of equations (if available).
            %
            % * `'std='` [ numeric | `@auto` ] - Default standard deviation for model
            % shocks; `@auto` means `1` for linear models and `log(1.01)` for nonlinear
            % models.
            %
            % * `'userdata='` [ ... | *empty* ] - Attach user data to the model object.
            %
            % Description
            % ============
            %
            % Loading a model file
            % ---------------------
            %
            % The `model` function can be used to read in a [model
            % file](modellang/Contents) named `fname`, and create a model object `m`
            % based on the model file. You can then work with the model object in your
            % own m-files, using using the IRIS [model functions](model/Contents) and
            % standard Matlab functions.
            %
            % If `fname` is a cell array of more than one file names then all files are
            % combined together in order of appearance.
            %
            % Re-building an existing model object
            % -------------------------------------
            %
            % The only instance where you may need to call a model function on an
            % existing model object is to change the `'removeLeads='` option. Of course,
            % you can always achieve the same by loading the original model file.
            %
            % Example
            % ========
            %
            % Read in a model code file named `my.model`, and declare the model as
            % linear:
            %
            %     m = model('my.model','linear',true);
            %
            % Example
            % ========
            %
            % Read in a model code file named `my.model`, declare the model as linear,
            % and assign some of the model parameters:
            %
            %     m = model('my.model','linear=',true,'assign=',P);
            %
            % Note that this is equivalent to
            %
            %     m = model('my.model','linear=',true);
            %     m = assign(m,P);
            %
            % unless some of the parameters passed in to the `model` fuction are needed
            % to evaluate [`if`](modellang/if) or [`!switch`](modellang/switch)
            % expressions.
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2015 IRIS Solutions Team.
            
            %--------------------------------------------------------------
            
            % Superclass constructors.
            This = This@modelobj();
            This = This@estimateobj();
            opt = struct();
            
            if nargin == 0
                % Empty model object.
                return
            elseif nargin == 1 && isa(varargin{1},'model')
                % Copy model object.
                This = varargin{1};
            elseif nargin == 1 && isstruct(varargin{1})
                % Convert struct (potentially based on old model object
                % syntax) to model object.
                This = mystruct2obj(This,varargin{1});
            elseif nargin > 0
                if ischar(varargin{1}) || iscellstr(varargin{1})
                    fileName = strtrim(varargin{1});
                    varargin(1) = [];
                    doOptions();
                    This.IsLinear = opt.linear;
                    [This,asgn] = myfile2model(This,fileName,opt);
                    This = mymodel2model(This,asgn,opt);
                elseif isa(varargin{1},'model')
                    This = varargin{1};
                    varargin(1) = [];
                    opt = doOptions();
                    This = mymodel2model(This,opt.assign,opt);
                end
            else
                utils.error('model:model', ...
                    'Incorrect number or type of input argument(s).');
            end
            
            
            function doOptions()
                [opt,varargin] = passvalopt('model.model',varargin{:});
                if isempty(opt.tolerance)
                    This.Tolerance(1) = getrealsmall();
                else
                    This.Tolerance(1) = opt.tolerance(1);
                    utils.warning('model:model', ...
                        ['You should NEVER reset the eigenvalue tolerance unless you are ', ...
                        'absolutely sure you know what you are doing!']);
                end
                if ~isstruct(opt.assign)
                    % Default for `'assign='` is an empty array.
                    opt.assign = struct();
                end
                opt.assign.sstateOnly = opt.sstateonly;
                opt.assign.linear = opt.linear;
                for iArg = 1 : 2 : length(varargin)
                    opt.assign.(varargin{iArg}) = varargin{iArg+1};
                end
            end % doOptions()
        end    
    end
end
