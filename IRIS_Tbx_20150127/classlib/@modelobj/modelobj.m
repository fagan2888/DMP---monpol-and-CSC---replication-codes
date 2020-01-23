classdef modelobj < getsetobj & userdataobj
    % modelobj  [Not a public class] Base class for model type of objects.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2015 IRIS Solutions Team.
    
    properties (GetAccess=public,SetAccess=protected,Hidden)
        % Model function name from which the modelobj was created.
        FName = '';
        % IRIS version in which the model object was last built.
        Build = '';
        % Linear or non-linear model.
        IsLinear = false;
        % Names of variables, shocks, parameters.
        name = cell(1,0);
        % Name types:
        % 1=measurement, 2=transition, 3=shock, 4=parameter, 5=exogenous.
        nametype = zeros(1,0);
        % Name labels.
        namelabel = cell(1,0);
        % Name aliases.
        namealias = cell(1,0);
        % Parameter and steady-state values.
        Assign = zeros(1,0,0);
        % Std devs and cross-correlations.
        stdcorr = zeros(1,0,0);
        % Log status of variables.
        IxLog = false(1,0);
        % List of equations in user form.
        eqtn = cell(1,0);
        % Equation labels.
        eqtnlabel = cell(1,0);
        % Equation aliases.
        eqtnalias = cell(1,0);
        % Equation types:
        % 1=measurement, 2=transition, 3=deterministic trend, 4=dynamic link.
        eqtntype = zeros(1,0);
    end
    
    methods
        
        % Constructor
        %-------------
        function This = modelobj(varargin)
            This = This@getsetobj();
            This = This@userdataobj();
        end
        
    end
       
    
    methods
        varargout = assign(varargin)
        varargout = autocaption(varargin)
        varargout = chkpriors(varargin)        
        varargout = emptydb(varargin)
        varargout = horzcat(varargin)
        varargout = iscompatible(varargin)
        varargout = islinear(varargin)
        varargout = isname(varargin)
        varargout = length(varargin)
        varargout = omega(varargin)
        varargout = reset(varargin)
        varargout = stdscale(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
    end
    
    
    methods (Hidden)
        varargout = mynameposition(varargin)
        varargout = saveobj(varargin)
        varargout = size(varargin)
        varargout = specget(varargin)
        varargout = vertcat(varargin)

        
        % Overwrite the method `properties( )` for autocompletion.
        function List = properties(This)
            List = [This.name,mygetstd(This),mygetcorr(This)];
        end        
    end
    
    
    methods (Access=protected,Hidden)
        varargout = mygetcorr(varargin)
        varargout = mygetstd(varargin)
        varargout = mytune2stdcorr(varargin)             
        varargout = mysubsalt(varargin)
    end
    
    
    methods (Static,Hidden)
        varargout = loadobj(varargin)
        varargout = mycombinestdcorr(varargin)
        varargout = mynameindex(varargin);
        varargout = myalias(varargin)
    end
    
end
