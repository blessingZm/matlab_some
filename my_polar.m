function hpol = my_polar(varargin)
    %绘制风向频率玫瑰图
    %参数1：必须为theta相应风向对应的风向频率值（不包括静风，0和360均对应'N'）
    %参数2：玫瑰图的标题，主要用来显示静风频率
    %参数3：LineStyle
    theta = 0: 22.5 : 360;
    theta = theta * pi / 180;
    
    single_text = { 'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE',...
        'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
    sigles = 22.5: 22.5 : 360;
    [cax, args, nargs] = axescheck(varargin{:});
    
    if nargs < 2
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 3
        error(message('MATLAB:narginchk:tooManyInputs'));
    end
    
    if nargs < 2 || nargs > 3
        error(message('MATLAB:polar:InvalidDataInputs'));
    elseif nargs == 1
        rho = args{1};
        title_string = '';
        line_style = 'auto';
    elseif nargs == 2
        rho = args{1};
        title_string = args{2};
        line_style = 'auto';  
    else % nargs == 3
        [rho, title_string, line_style] = deal(args{:});
    end
    
    try
        rho = full(double(rho));
    catch
        error(message('MATLAB:specgraph:private:specgraph:nonNumericInput'));
    end
    
    % get hold state
    cax = newplot(cax);
    
    next = lower(get(cax, 'NextPlot'));
    hold_state = ishold(cax);

    if isa(handle(cax),'matlab.graphics.axis.PolarAxes')
        error(message('MATLAB:polar:PolarAxes'));
    end
    
    % get x-axis text color so grid is in same color
    % get the axis gridColor
    axColor = get(cax, 'Color');
    gridAlpha = get(cax, 'GridAlpha');
    axGridColor = get(cax,'GridColor').*gridAlpha + axColor.*(1-gridAlpha);
    tc = axGridColor;
    ls = get(cax, 'GridLineStyle');
    
    % Hold on to current Text defaults, reset them to the
    % Axes' font attributes so tick marks use them.
    fAngle = get(cax, 'DefaultTextFontAngle');
    fName = get(cax, 'DefaultTextFontName');
    fSize = get(cax, 'DefaultTextFontSize');
    fWeight = get(cax, 'DefaultTextFontWeight');
    fUnits = get(cax, 'DefaultTextUnits');
    set(cax, ...
        'DefaultTextFontAngle', get(cax, 'FontAngle'), ...
        'DefaultTextFontName', get(cax, 'FontName'), ...
        'DefaultTextFontSize', get(cax, 'FontSize'), ...
        'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
        'DefaultTextUnits', 'data');
    
    % only do grids if hold is off
    if ~hold_state
        
        % make a radial grid
        hold(cax, 'on');
        % ensure that Inf values don't enter into the limit calculation.
        arho = abs(rho(:));
        maxrho = max(arho(arho ~= Inf));
        hhh = line([-maxrho, -maxrho, maxrho, maxrho], [-maxrho, maxrho, maxrho, -maxrho], 'Parent', cax);
        set(cax, 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatioMode', 'auto');
        v = [get(cax, 'XLim') get(cax, 'YLim')];
        ticks = sum(get(cax, 'YTick') >= 0);
        delete(hhh);
        % check radial limits and ticks
        rmin = 0;
        rmax = v(4);
        rticks = max(ticks - 1, 2);
        if rticks > 5   % see if we can reduce the number
            if rem(rticks, 2) == 0
                rticks = rticks / 2;
            elseif rem(rticks, 3) == 0
                rticks = rticks / 3;
            end
        end
        
        % define a circle
        th = 0 : pi / 50 : 2 * pi;
        xunit = cos(th);
        yunit = sin(th);
        % now really force points on x/y axes to lie on them exactly
        inds = 1 : (length(th) - 1) / 4 : length(th);
        xunit(inds(2 : 2 : 4)) = zeros(2, 1);
        yunit(inds(1 : 2 : 5)) = zeros(3, 1);
        % plot background if necessary
        if ~ischar(get(cax, 'Color'))
            patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
                'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
                'HandleVisibility', 'off', 'Parent', cax);
        end
        
        % draw radial circles
        c82 = cos(82 * pi / 180);
        s82 = sin(82 * pi / 180);
        rinc = (rmax - rmin) / rticks;
        for i = (rmin + rinc) : rinc : rmax
            hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
                'HandleVisibility', 'off', 'Parent', cax);
            text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ...
                ['  ' num2str(i)], 'VerticalAlignment', 'bottom', ...
                'HandleVisibility', 'off', 'Parent', cax);
        end
        set(hhh, 'LineStyle', '-'); % Make outer circle solid
        
        % plot spokes
        th = (0 : 7) * 2 * pi / 16;
        cst = cos(th);
        snt = sin(th);
        cs = [-cst; cst];
        sn = [-snt; snt];
        line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
        
        % annotate spokes in degrees
        rt = 1.1 * rmax;
        for i = 1 : length(th)
            text(rt * cst(i), rt * snt(i), single_text{i},...
                'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax);
%             if i == length(th)
%                 loc = 'N';
%             else
            i_loc = sigles == 180 + i * 22.5;
            loc = single_text{i_loc};
%             end
            text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax);
        end
        text(rt * cst(1) + 1.5, rt * snt(1), title_string, ...
            'HorizontalAlignment', 'center', 'FontSize', 13, ...
            'HandleVisibility', 'off', 'Parent', cax);
        
        % set view to 2-D
        view(cax, 2);
        % set axis limits
        axis(cax, rmax * [-1, 1, -1.15, 1.15]);
    end
    
    % Reset defaults.
    set(cax, ...
        'DefaultTextFontAngle', fAngle , ...
        'DefaultTextFontName', fName , ...
        'DefaultTextFontSize', fSize, ...
        'DefaultTextFontWeight', fWeight, ...
        'DefaultTextUnits', fUnits );
    
    % transform data to Cartesian coordinates.
    xx = rho .* cos(theta);
    yy = rho .* sin(theta);
    
    % plot data on top of grid
    if strcmp(line_style, 'auto')
        q = plot(xx, yy, 'Parent', cax);
    else
        q = plot(xx, yy, line_style, 'Parent', cax);
    end
    
    if nargout == 1
        hpol = q;
    end
    
    if ~hold_state
        set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
        set(cax, 'NextPlot', next);
    end
    set(get(cax, 'XLabel'), 'Visible', 'on');
    set(get(cax, 'YLabel'), 'Visible', 'on');
    
    % Disable pan and zoom
    p = hggetbehavior(cax, 'Pan');
    p.Enable = false;
    z = hggetbehavior(cax, 'Zoom');
    z.Enable = false;
    
    if ~isempty(q) && ~isdeployed
        makemcode('RegisterHandle', cax, 'IgnoreHandle', q, 'FunctionName', 'polar');
    end
    
    az = 90;
    el =-90;
    view(az, el);
end
