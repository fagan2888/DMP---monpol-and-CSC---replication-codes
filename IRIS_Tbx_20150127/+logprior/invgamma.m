function varargout = invgamma(varargin)
utils.warning('obsolete', ...
    ['The package name logprior is obsolete and will be removed from future versions of IRIS. ', ...
    'Use logdist.invgamma instead.']);
[varargout{1:nargout}] = logdist.invgamma(varargin{:});
end