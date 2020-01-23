function InclGraph = mycompilepdf(This,Opt)
% mycompilepdf  [Not a public function] Publish figure to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

set(This.handle,'paperType',This.options.papertype);

% Set orientation, rotation, and raise box.
if (isequal(Opt.orientation,'landscape') && ~This.options.sideways) ...
        || (isequal(Opt.orientation,'portrait') && This.options.sideways)
    orient(This.handle,'landscape');
    angle = 0;
    raise = 10;
else
    orient(This.handle,'tall');
    angle = 0;
    raise = 0;
end

% Fill in the entire page.
paperSize = get(This.handle,'PaperSize');
set(This.handle,'PaperPosition',[0,0,paperSize]);

% Print figure to EPSC and PDF.
pdfName = '';
pdfTitle = '';
doPrintFigure();

if strcmpi(This.options.figurescale,'auto')
    switch class(This.parent)
        case 'report.reportobj'
            if isanystri(This.options.papertype,{'usletter','uslegal'})
                This.options.figurescale = 0.8;
            else
                This.options.figurescale = 0.85;
            end
        case 'report.alignobj'
            This.options.figurescale = 0.3;
        otherwise
            This.options.figurescale = 1;
    end
end

trim = This.options.figuretrim;
if length(trim) == 1
    trim = trim*[1,1,1,1];
end

This.hInfo.package.graphicx = true;
InclGraph = [ ...
    '\raisebox{',sprintf('%gpt',raise),'}{', ...
    '\includegraphics', ...
    sprintf('[scale=%g,angle=%g,trim=%gpt %gpt %gpt %gpt,clip=true]{%s}', ...
    This.options.figurescale,angle,trim,pdfTitle), ...
    '}'];


% Nested functions...


%**************************************************************************


    function doPrintFigure()
        tempDir = This.hInfo.tempDir;
        h = This.handle;
        % Create graphics file path and title.
        if isempty(This.options.saveas)
            pdfName = tempname(tempDir);
            [~,pdfTitle] = fileparts(pdfName);
        else
            [saveAsPath,saveAsTitle] = fileparts(This.options.saveas);
            pdfName = fullfile(tempDir,saveAsTitle);
            pdfTitle = saveAsTitle;
        end
        
        % Apply user aspect ratio to all axes objects except legends.
        doAspectRatio();
        
        % Print the figure window to PDF.
        try
            if true % ##### MOSW
                % Matlab only
                %-------------
                print(h,'-dpdf','-painters',pdfName);
            else
                % Octave only
                %-------------
                print(h,'-dpdf',pdfName); %#ok<UNRCH>
            end
            addtempfile(This,[pdfName,'.pdf']);
        catch Err
            utils.error('report:mycompilepdf', ...
                ['Cannot print figure #%g to PDF: ''%s''.\n', ...
                '\tUncle says: %s'], ...
                double(h),pdfName,Err.message);
        end

        % Save under the temporary name (which will be referred to in
        % the tex file) in the current or user-supplied directory.
        if ~isempty(This.options.saveas)
            % Use try-end because the temporary directory can be the same
            % as the current working directory, in which case `copyfile`
            % throws an error (Cannot copy or move a file or directory onto
            % itself).
            try %#ok<TRYNC>
                copyfile([pdfName,'.pdf'], ...
                    fullfile(saveAsPath,[pdfTitle,'.pdf']));
            end
        end
    end % doPrintFigure()


%**************************************************************************


    function doAspectRatio()
        if isequal(This.options.aspectratio,@auto)
            return
        end
        ch = get(This.handle,'children');
        for i = ch(:).'
            if isequal(get(i,'tag'),'legend') ...
                    || ~isequal(get(i,'type'),'axes')
                continue
            end
            try %#ok<TRYNC>
                set(i,'PlotBoxAspectRatio', ...
                    [This.options.aspectratio(:).',1]);
            end
        end
    end % doAspectRatio()


end
