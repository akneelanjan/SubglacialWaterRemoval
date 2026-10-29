%% Formal Plotting Figure 3 (6 panels)
% Matched-rate on-target vs off-target water removal.
% Rows: dQ = 0.5 L/min (a-c) and dQ = 1 L/min (d-f).
% Columns: basal drag profile (with inset at y = 1000-1100 m), change in ice
% surface speed relative to the baseline, and ice speed reduction efficiency.
% On-target: central canal at N_c = 50.44 / 50.89 kPa.
% Off-target: adjacent water film at y_off = 50 and 100 m (Y = 1050, 1100 m).
% Efficiencies use the area under the ice surface speed profile, integrated over
% x_surf sorted in increasing order.
clear all; clc;
addpath('cbrewer2')

R   = "ResultsMatFiles";
pre = "TempBedG100mW_";

blue = cbrewer2('seq','Blues',5);
reds = cbrewer2('seq','Reds',6);
grey = [0.6 0.6 0.6];

%          dQ [L/min]   on-target file      off-target blip   on-target Q label
dQcases = {"0.5",       "Canal_50.44kPa",   "Blip264.6Pa",    "0.004992";
           "1",         "Canal_50.89kPa",   "Blip617Pa",      "0.004983"};
offsets   = [50 100];                       % [m]
offMarks  = {'o','diamond'};
offColors = {reds(5,:), reds(4,:)};       % y_off = 50 m darker red, 100 m lighter
canalY    = [820 1000 1180];                % canal locations [m]

% nearest node to each requested position (for sparse markers along a profile)
mkIdx = @(xs, pos) unique(arrayfun(@(p) find(abs(xs - p) == min(abs(xs - p)), 1), pos));
mPos  = linspace(0, 2000, 12);

%% Baseline
b = load(fullfile(R, sprintf('%s%s.mat', pre, 'Canal_50kPa')), "x_surf","u_surf","x_base","basal_tau_c_specific");
[xs0,is] = sort(b.x_surf(:)); us0 = b.u_surf(is); us0 = us0(:);  I0 = trapz(xs0, us0);
[xb0,ib] = sort(b.x_base(:)); tb0 = b.basal_tau_c_specific(ib); tb0 = tb0(:)/1000;

%% Figure layout (normalized figure units)
fig = figure('Units','inches','Position',[1 1 15 10],'Color','w');
colL = [0.065 0.395 0.725];  colW = 0.255;
rowB = [0.580 0.115];        rowH = 0.345;
letters = {'(a)','(b)','(c)';'(d)','(e)','(f)'};
fs = 12;
tickGap = 9;                                % gap between x-axis and its tick labels [pt], clears the canal icons
th = linspace(pi, 2*pi, 30);                % lower half-disc for canal markers
figW = 15; figH = 10;                       % figure size [in], as set in figure() above
rIcon = 0.09;                               % canal icon radius on paper [in]
% half-disc hanging below y0 at xc, in axes ax with normalized position Pax
halfDisc = @(ax, Pax, xc, y0) patch(ax, xc + rIcon/(Pax(3)*figW)*diff(xlim(ax))*cos(th), ...
    y0 + rIcon/(Pax(4)*figH)*diff(ylim(ax))*sin(th), blue(4,:), 'EdgeColor',[0.15 0.25 0.45], ...
    'LineWidth',0.75, 'Clipping','off', 'HandleVisibility','off');

for k = 1:size(dQcases,1)
    dQ = dQcases{k,1};
    ttl = sprintf('\\DeltaQ = %s L/min', dQ);

    %% Load on-target and off-target cases
    on = load(fullfile(R, sprintf('%s%s.mat', pre, dQcases{k,2})), "x_surf","u_surf","x_base","basal_tau_c_specific");
    [xs,is] = sort(on.x_surf(:)); us = on.u_surf(is); us = us(:);
    duOn = interp1(xs, us, xs0) - us0;   reduction = I0 - trapz(xs, us);
    [xbOn,ib] = sort(on.x_base(:)); tbOn = on.basal_tau_c_specific(ib); tbOn = tbOn(:)/1000;

    duOff = cell(1,numel(offsets)); xbOff = cell(1,numel(offsets)); tbOff = cell(1,numel(offsets));
    for j = 1:numel(offsets)
        off = load(fullfile(R, sprintf('%sOffTarget_dQ%sLmin_%s_Y%d.mat', pre, dQ, dQcases{k,3}, 1000+offsets(j))), ...
                   "x_surf","u_surf","x_base","basal_tau_c_specific");
        [xs,is] = sort(off.x_surf(:)); us = off.u_surf(is); us = us(:);
        duOff{j} = interp1(xs, us, xs0) - us0;   reduction(end+1) = I0 - trapz(xs, us);
        [xbOff{j},ib] = sort(off.x_base(:)); t = off.basal_tau_c_specific(ib); tbOff{j} = t(:)/1000;
    end
    y_labels = [1000, 1000 + offsets];
    eff = reduction/reduction(1)*100;
    fprintf('dQ = %s L/min: efficiency = %s %%\n', dQ, mat2str(round(eff,1)));

    labBase = 'Q = 0.005 m^3/s';
    labOn   = sprintf('Q = %s m^3/s', dQcases{k,4});
    labOff  = arrayfun(@(o) sprintf('y_{off} = %d m', o), offsets, 'UniformOutput', false);

    %% Panel 1: basal drag profile, with insets on the canal peak and the film blips
    P = [colL(1) rowB(k) colW rowH];
    ax = axes('Position', P); hold(ax,'on'); box(ax,'on');
    ymax = 10*ceil(2.2*max(tbOn)/10);
    h = gobjects(1, 2+numel(offsets));
    h(1) = plot(ax, xb0, tb0, '-', 'LineWidth',2.5, 'Color',blue(5,:), 'Marker','pentagram', 'MarkerSize',12, ...
                'MarkerFaceColor',blue(5,:), 'MarkerIndices', mkIdx(xb0, mPos));
    h(2) = plot(ax, xbOn, tbOn, '--', 'LineWidth',1.5, 'Color',blue(4,:), 'Marker','pentagram', 'MarkerSize',7, ...
                'MarkerFaceColor',blue(4,:), 'MarkerIndices', mkIdx(xbOn, mPos));
    for j = 1:numel(offsets)
        h(2+j) = plot(ax, xbOff{j}, tbOff{j}, '-', 'LineWidth',1, 'Color',offColors{j}, 'Marker',offMarks{j}, ...
                      'MarkerSize',6, 'MarkerFaceColor',offColors{j}, 'MarkerIndices', mkIdx(xbOff{j}, mPos));
    end
    xlim(ax,[0 2000]); ylim(ax,[0 ymax]); set(ax,'FontSize',fs,'Layer','top'); ax.XRuler.TickLabelGapOffset = tickGap;
    plot(ax, 1000+offsets, 0*offsets, 'x', 'Color',[1 0 0], 'MarkerSize',8, 'LineWidth',1.5, ...
         'Clipping','off', 'HandleVisibility','off');
    for c = canalY, halfDisc(ax, P, c, 0); end
    xlabel(ax,'Lateral direction [m]'); ylabel(ax,'Basal drag profile [kPa]'); title(ax, ttl);
    legend(ax, h, [{labBase, labOn}, labOff], 'Location','northeast', 'FontSize',fs-2);

    % inset: change in basal drag from the baseline, so the canal increase (on-target)
    % and the film blips (off-target) are both visible on one scale
    [xu, iu] = unique(xb0);  t0u = tb0(iu);
    [xo, io] = unique(xbOn); dOn = interp1(xo, tbOn(io), xu) - t0u;
    dOff = cell(1,numel(offsets));
    for j = 1:numel(offsets)
        [xo, io] = unique(xbOff{j}); dOff{j} = interp1(xo, tbOff{j}(io), xu) - t0u;
    end
    blipkPa = str2double(erase(dQcases{k,3},["Blip","Pa"]))/1000;
    m  = max([max(dOn), blipkPa]);
    yIn = [-0.08*m, 1.3*m];
    Pin = [P(1)+0.08*P(3), P(2)+0.50*P(4), 0.34*P(3), 0.34*P(4)];
    axi = axes('Position', Pin); hold(axi,'on'); box(axi,'on');
    plot(axi, xu, 0*xu, '-', 'LineWidth',2.5, 'Color',blue(5,:));
    plot(axi, xu, dOn, '--', 'LineWidth',1.5, 'Color',blue(4,:));
    for j = 1:numel(offsets)
        plot(axi, xu, dOff{j}, '-', 'LineWidth',1.25, 'Color',offColors{j});
    end
    xlim(axi,[960 1120]); ylim(axi, yIn);
    set(axi,'FontSize',fs-3,'XTick',[1000 1050 1100],'Layer','top'); axi.XRuler.TickLabelGapOffset = tickGap;
    text(axi, 0, 1.03, '\Delta from baseline [kPa]', 'Units','normalized', 'HorizontalAlignment','left', ...
         'VerticalAlignment','bottom', 'FontSize',fs-3);
    plot(axi, 1000+offsets, yIn(1)*[1 1], 'x', 'Color',[1 0 0], 'MarkerSize',7, 'LineWidth',1.5, 'Clipping','off');
    halfDisc(axi, Pin, 1000, yIn(1));

    %% Panel 2: change in ice surface speed
    P = [colL(2) rowB(k) colW rowH];
    ax = axes('Position', P); hold(ax,'on'); box(ax,'on');
    h = gobjects(1, 2+numel(offsets));
    h(1) = plot(ax, xs0, 0*xs0, '-', 'LineWidth',2.5, 'Color',blue(5,:));
    h(2) = plot(ax, xs0, duOn, '--', 'LineWidth',1.5, 'Color',blue(4,:), 'Marker','pentagram', 'MarkerSize',7, ...
                'MarkerFaceColor',blue(4,:), 'MarkerIndices', mkIdx(xs0, mPos(2:end-1)));
    for j = 1:numel(offsets)
        h(2+j) = plot(ax, xs0, duOff{j}, '-', 'LineWidth',1, 'Color',offColors{j}, 'Marker',offMarks{j}, ...
                      'MarkerSize',6, 'MarkerFaceColor',offColors{j}, 'MarkerIndices', mkIdx(xs0, mPos));
    end
    xlim(ax,[0 2000]); ylim(ax,[2*min(duOn), 0.1*abs(min(duOn))]); set(ax,'FontSize',fs,'Layer','top'); ax.XRuler.TickLabelGapOffset = tickGap;
    xlabel(ax,'Lateral direction [m]'); ylabel(ax,'Change in ice surface speed [m/yr]'); title(ax, ttl);
    legend(ax, h, [{labBase, labOn}, labOff], 'Location','south', 'FontSize',fs-2);

    %% Panel 3: ice speed reduction efficiency
    P = [colL(3) rowB(k) colW rowH];
    ax = axes('Position', P); hold(ax,'on'); box(ax,'on');
    h = gobjects(1, 1+numel(offsets));
    h(1) = scatter(ax, y_labels(1), eff(1), 60, blue(4,:), 'filled', 'o');
    for j = 1:numel(offsets)
        h(1+j) = scatter(ax, y_labels(j+1), eff(j+1), 70, offColors{j}, 'filled', offMarks{j});
        if y_labels(j+1) >= 1100, ha = 'right'; else, ha = 'center'; end
        text(ax, y_labels(j+1), eff(j+1)+4, sprintf('%.1f%%', eff(j+1)), 'Color',offColors{j}, ...
             'HorizontalAlignment',ha, 'FontSize',fs-2);
    end
    plot(ax, 1000+offsets, 0*offsets, 'x', 'Color',[1 0 0], 'MarkerSize',8, 'LineWidth',1.5, ...
         'Clipping','off', 'HandleVisibility','off');
    xlim(ax,[1000 1100]); ylim(ax,[0 100]); set(ax,'FontSize',fs,'XTick',1000:20:1100,'Layer','top'); ax.XRuler.TickLabelGapOffset = tickGap;
    halfDisc(ax, P, 1000, 0);
    xlabel(ax,'Lateral direction [m]'); ylabel(ax,'Ice speed reduction efficiency %'); title(ax, ttl);
    legend(ax, h, [{'y_{off} = 0 m'}, labOff], 'Location','northeast', 'FontSize',fs-2);

    %% Panel letters
    for c = 1:3
        annotation(fig, 'textbox', [colL(c)-0.06, rowB(k)+rowH+0.005, 0.04, 0.03], 'String', letters{k,c}, ...
                   'LineStyle','none', 'FontSize',fs+1);
    end
end

%% Shared legend for site markers (drawn by hand so the canal symbol matches),
%  Canal first, then off-target sites, centred as one group under the figure
PL = [0 0.008 1 0.035];
axL = axes('Position', PL, 'XLim',[0 1], 'YLim',[0 1], 'Visible','off'); hold(axL,'on');
tC = text(axL, 0, 0.5, 'Canal', 'FontSize',fs, 'VerticalAlignment','middle');
tX = text(axL, 0, 0.5, 'Off-target flux reduction sites', 'FontSize',fs, 'VerticalAlignment','middle');
iw = rIcon/(PL(3)*figW);                    % icon half-width in legend-axes units
mw = 0.10/(PL(3)*figW);                     % width of the x marker (~0.1 in)
gap = 0.08/(PL(3)*figW);  sep = 0.45/(PL(3)*figW);
wC = tC.Extent(3);  wX = tX.Extent(3);
x0 = 0.5 - (2*iw + gap + wC + sep + mw + gap + wX)/2;
halfDisc(axL, PL, x0 + iw, 0.63);
tC.Position = [x0 + 2*iw + gap, 0.5, 0];
xm = x0 + 2*iw + gap + wC + sep + mw/2;
plot(axL, xm, 0.5, 'x', 'Color',[1 0 0], 'MarkerSize',10, 'LineWidth',1.5);
tX.Position = [xm + mw/2 + gap, 0.5, 0];

%% Export
exportgraphics(fig, 'Fig3_matched_dQ.pdf', 'ContentType','vector');
