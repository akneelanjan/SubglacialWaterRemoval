%% Formal Plotting: Figure 2 and Supplementary Figures S2 (profile column), S3, S4, S5, S6, S7, S9
% Every on-target simulation figure is produced from this one script.
%   Fig. 2  : four drainage modes, basal drag and ice surface speed
%   Fig. S3 : canal, 2D ice speed maps and profiles
%   Fig. S4 : R-channel, 2D ice speed maps and profiles
%   Fig. S5 : central canal without the two side canals (maps and profiles)
%   Fig. S6 : wider central canal, gamma_center = 0.1 (maps and profiles)
%   Fig. S7 : water film, four flux reductions
%   Fig. S9 : four drainage modes at one shared downstream slope
% A figure whose result files are not yet present is skipped with a message.
% Legend Q labels are read from each result file (the Q string set by the
% parameter generators). Profiles are plotted against sorted x.
clear all; clc;
addpath('cbrewer2')

R   = 'ResultsMatFiles';
pre = 'TempBedG100mW_';

%% Result files (one place to edit names)
F.film2  = {'WaterFilm_4000Pa','WaterFilm_5000Pa'};
F.film4  = {'WaterFilm_4000Pa','WaterFilm_4444Pa','WaterFilm_5000Pa','WaterFilm_8000Pa'};
F.cavity = {'LinkedCavity_250kPa','LinkedCavity_500kPa'};
F.rch    = {'RChannel_550kPa','RChannel_520kPa'};
F.canal  = {'Canal_50kPa','Canal_100kPa','Canal_150kPa'};
F.wider  = {'CenterCanalWider_50kPa','CenterCanalWider_100kPa','CenterCanalWider_150kPa'};
% Fig. S5 and S9 runs (all through WaterRemoval_OnTarget.m)
F.single = {'Only1CentralCanal_50kPa','Only1CentralCanal_100kPa','Only1CentralCanal_150kPa'};
F.same   = {{'SameSlope_WaterFilm_4000Pa','SameSlope_WaterFilm_5000Pa'}, ...
            {'SameSlope_LinkedCavity_250kPa','SameSlope_LinkedCavity_500kPa'}, ...
            {'SameSlope_RChannel_550kPa','SameSlope_RChannel_520kPa'}, ...
            {'Canal_50kPa','Canal_100kPa','Canal_150kPa'}};   % shared slope = the canal's own alpha, so reuse

%% Styles
S.blue  = cbrewer2('seq','Blues',5);
cm      = cbrewer2('seq','RdPu',100);  S.icespeed = cm(1:90,:);
S.fs = 12; S.tickGap = 9; S.rIcon = 0.09;
S.mDrag = [0 300 600 1000 1400 1700 2000];
S.mSurf = [0 620 1000 1380 2000];
S.lineStyle = {'-','--',':','-.'};          % baseline solid, then dashed, dotted, dash-dot
S.lineWidth = [3 2 2 1.5];                  % baseline thickest
S.arrowX    = [810 1190];                   % speed-profile arrows, between the markers

% per drainage mode: name, label icon, centre icon, markers (line styles follow S.lineStyle), colour indices, (unused)
M.film   = {'Water Film',    'line', '',     {'--','-o'},                [5 3],     [4 2]};
M.film4  = {'Water Film',    'line', '',     {'--','--^','-o','--'},     [5 4 3 2], [6 4 3 2]};
M.cavity = {'Linked Cavity', 'oval', 'oval', {'--s','-v'},               [5 3],     [3 3]};
M.rch    = {'R-channel',     'dome', 'dome', {'-d','-^'},                [5 3],     [3 3]};
M.canal  = {'Canal',         'bowl', 'bowl', {'--p','--o','-s'},         [5 4 3],   [4 3 2]};
sideCanals = [820 1180];

%% ------------------------------------------------------------- Fig. 2
rows = {F.film2, M.film; F.cavity, M.cavity; F.rch, M.rch; F.canal, M.canal};
C = loadRows(R, pre, rows(:,1));
if ~isempty(C)
    modeFigure(C, rows(:,2), sideCanals, S, 'speed', 'Fig2_drainage_modes.pdf');
else
    fprintf('Skipping Fig. 2: result files missing.\n');
end

%% ------------------------------------------------------------- Fig. S2 (profile column only)
% Basal yield strength near the bed centre for the four baseline cases, stacked, to replace
% the profile column of the Fig. S2 schematic (the sketches on the left stay as they are).
C = loadRows(R, pre, {{F.film2{1}}, {F.cavity{1}}, {F.rch{1}}, {F.canal{1}}});
if ~isempty(C)
    figW = 3.6; figH = 6.4;
    fig = figure('Units','inches','Position',[1 1 figW figH],'Color','w');
    names = {'Water Film','Linked Cavity','R-Channel','Sedimentary Canal'};
    for m = 1:4
        d = C{m};
        P = inPos(fig, 0.75, 0.55 + (4-m)*1.45, 2.6, 1.2);
        ax = axes('Position', P); hold(ax,'on'); box(ax,'on');
        h = plot(ax, d.xb, d.tb, '-', 'LineWidth',2, 'Color',S.blue(5,:));
        yl = max(d.tb(d.xb >= 900 & d.xb <= 1100));
        xlim(ax,[900 1100]);  ylim(ax,[0 1.15*max(yl, 10)]);
        set(ax,'FontSize',S.fs-3,'Layer','top','XTick',900:50:1100);
        if m < 4, set(ax,'XTickLabel',[]); else, xlabel(ax,'Lateral direction, y [m]'); end
        legend(ax, h, {d.lab}, 'Location','northeast', 'FontSize',S.fs-4);
        title(ax, names{m}, 'FontSize',S.fs-3, 'FontWeight','normal');
    end
    axY = axes('Position',[0 0 1 1], 'Visible','off');             % shared y-label
    text(axY, 0.06, 0.5, 'Basal yield strength [kPa]', 'Rotation',90, 'HorizontalAlignment','center', ...
         'FontSize',S.fs-3);
    exportgraphics(fig, 'FigS2_profiles.pdf', 'ContentType','vector');
else
    fprintf('Skipping Fig. S2 profiles: result files missing.\n');
end

%% ------------------------------------------------------------- Figs. S3-S6 (maps + profiles)
mapFigs = {
  'Fig. S3', F.canal,  M.canal, sideCanals, 'FigS3_canal.pdf'
  'Fig. S4', F.rch,    M.rch,   sideCanals, 'FigS4_Rchannel.pdf'
  'Fig. S5', F.single, M.canal, [],         'FigS5_single_central_canal.pdf'
  'Fig. S6', F.wider,  M.canal, sideCanals, 'FigS6_wider_canal.pdf'
};
for k = 1:size(mapFigs,1)
    C = loadRows(R, pre, mapFigs(k,2), true);
    if isempty(C), fprintf('Skipping %s: result files missing.\n', mapFigs{k,1}); continue; end
    mapFigure(C{1}, mapFigs{k,3}, mapFigs{k,4}, S, mapFigs{k,5});
end

%% ------------------------------------------------------------- Fig. S7 (film, four flux reductions)
C = loadRows(R, pre, {F.film4});
if ~isempty(C)
    figW = 11; figH = 5.35;
    fig = figure('Units','inches','Position',[1 1 figW figH],'Color','w');
    P1 = inPos(fig, 0.9, 1.1, 4.2, 3.8);  P2 = inPos(fig, 6.3, 1.1, 4.2, 3.8);
    ax = profilePanel(fig, P1, C{1}, M.film4, sideCanals, S, 'drag', true, 'northwest');
    filmInset(fig, ax, P1, C{1}, M.film4, S, [3.5 8.5], [4 6 8]);
    profilePanel(fig, P2, C{1}, M.film4, sideCanals, S, 'speed', true, 'south');
    panelLetter(fig, P1, '(a)', S);  panelLetter(fig, P2, '(b)', S);
    iconLegend(fig, [{'line','Water Film'}; iconItems(sideCanals, '')], S, 0.12);
    exportgraphics(fig, 'FigS7_water_film.pdf', 'ContentType','vector');
else
    fprintf('Skipping Fig. S7: result files missing.\n');
end

%% ------------------------------------------------------------- Fig. S9 (shared slope)
rows = {F.same{1}, M.film; F.same{2}, M.cavity; F.same{3}, M.rch; F.same{4}, M.canal};
C = loadRows(R, pre, rows(:,1));
if ~isempty(C)
    modeFigure(C, rows(:,2), sideCanals, S, 'speed+normalized', 'FigS9_same_slope.pdf');
else
    fprintf('Skipping Fig. S9: result files missing.\n');
end


%% ================================================================= helpers
function C = loadRows(R, pre, rows, withMap)
% load each row's cases; returns {} if any file is missing
if nargin < 4, withMap = false; end
C = cell(size(rows));
for r = 1:numel(rows)
    names = rows{r};
    for c = 1:numel(names)
        f = fullfile(R, sprintf('%s%s.mat', pre, names{c}));
        if ~isfile(f), fprintf('  missing: %s\n', f); C = {}; return; end
        vars = {'x_base','basal_tau_c_specific','x_surf','u_surf','Q'};
        if withMap, vars = [vars, {'xy','t','b','u'}]; end
        s = load(f, vars{:});
        [d.xb, i] = sort(s.x_base(:));  t = s.basal_tau_c_specific(i); d.tb = t(:)/1000;
        [d.xs, i] = sort(s.x_surf(:));  u = s.u_surf(i);               d.us = u(:);
        d.lab = sprintf('Q = %s m^3/s', char(s.Q));
        q = strtrim(strrep(char(s.Q), 'Q_0', ''));             % numeric flowrate, or multiple of Q_0
        if isempty(q), d.q = 1; else, d.q = str2double(q); end
        if withMap, d.xy = s.xy; d.t = s.t; d.b = s.b; d.u = s.u(:); end
        C{r}(c) = d;
    end
end
end

function modeFigure(C, modes, sideCanals, S, rightKind, outFile)
% four rows (film, cavity, R-channel, canal): drag | label | speed [| normalized speed]
nCol = 2 + strcmp(rightKind,'speed+normalized');
% panel width/height and label column [in]; three columns use narrower panels so the
% figure (about 14.4 in wide) still fits on a laptop screen without MATLAB shrinking it
if nCol == 3, pw = 3.3; gap3 = 0.8; else, pw = 3.8; gap3 = 1.0; end
ph = 2.9; lab = 2.4;
xL = [0.9, 0.9 + pw + lab, 0.9 + 2*pw + lab + gap3];
figW = xL(nCol) + pw + 0.4; figH = 0.75 + 4*ph + 3*0.75 + 0.45;
fig = figure('Units','inches','Position',[1 1 figW figH],'Color','w');
yB = 0.75 + (3:-1:0)*(ph + 0.75);
letters = 'abcdefghijkl'; li = 0; PLs = cell(1,numel(C));
for m = 1:numel(C)
    d = C{m}; md = modes{m};
    last = (m == numel(C));
    P = inPos(fig, xL(1), yB(m), pw, ph);
    ax = profilePanel(fig, P, d, md, sideCanals, S, 'drag', last, 'northwest');
    if m == 1, filmInset(fig, ax, P, d, md, S, [3.5 6], [4 5 6]); end
    li = li+1; panelLetter(fig, P, ['(' letters(li) ')'], S);

    P = inPos(fig, xL(2), yB(m), pw, ph);
    axs = profilePanel(fig, P, d, md, sideCanals, S, 'speed', last, 'northeast');
    if nCol == 2                                 % Fig. 2: change in maximum speed, in the speed panel
        yl = ylim(axs);  text(axs, 1000, 0.25*yl(2), changeText(d), 'HorizontalAlignment','center', 'FontSize',S.fs);
    end
    li = li+1; panelLetter(fig, P, ['(' letters(li) ')'], S);

    if nCol == 3
        P = inPos(fig, xL(3), yB(m), pw, ph);
        axn = profilePanel(fig, P, d, md, sideCanals, S, 'normalized', last, 'northeast');
        text(axn, 1000, 0.4, changeText(d), 'HorizontalAlignment','center', 'FontSize',S.fs);
        li = li+1; panelLetter(fig, P, ['(' letters(li) ')'], S);
    end

    % mode label between drag and speed columns, level with the x-axis (placed after the loop)
    gl = xL(1) + pw;  gw = lab - 0.75;           % gap between the drag panel and the speed panel's y-label
    PLs{m} = inPos(fig, gl, yB(m), gw, 0.4);
end
% labels: icons in one vertical column, the icon+label block centred in the gap
axLs = cell(1,numel(C)); txs = gobjects(1,numel(C)); wmax = 0;
for m = 1:numel(C)
    axLs{m} = axes('Position', PLs{m}, 'XLim',[0 1], 'YLim',[0 1], 'Visible','off'); hold(axLs{m},'on');
    txs(m) = text(axLs{m}, 0, 0.5, modes{m}{1}, 'FontSize',S.fs, 'VerticalAlignment','middle');
    e = get(txs(m),'Extent');  wmax = max(wmax, e(3));
end
iw = S.rIcon/gw;  gap = 0.08/gw;
x0 = 0.5 - (2*iw + gap + wmax)/2;                 % same icon position in every row
for m = 1:numel(C)
    md = modes{m};
    if strcmp(md{2},'line')
        plot(axLs{m}, x0 + [0 2*iw], [0.5 0.5], '-', 'Color',[0 0 0], 'LineWidth',1);
    else
        yc = 0.5 + strcmp(md{2},'bowl')*0.25 - strcmp(md{2},'dome')*0.25;     % centre the half-discs on the text
        drawIcon(axLs{m}, PLs{m}, md{2}, x0 + iw, yc, S);
    end
    set(txs(m),'Position',[x0 + 2*iw + gap, 0.5, 0]);
end
exportgraphics(fig, outFile, 'ContentType','vector');
end

function mapFigure(d, md, sideCanals, S, outFile)
% one 2D ice speed map per case, stacked, then drag and speed profiles side by side
n = numel(d);
mw = 8.7; mapH = mw*150/2000;               % map width/height [in], domain is 2000 m x 150 m
mh = 1.5; figW = 11; figH = 5.25 + 0.45 + mapH + (n-1)*mh;   % 0.45 in above the first map for its legend and letter
fig = figure('Units','inches','Position',[1 1 figW figH],'Color','w');
letters = 'abcdefgh';
for c = 1:n
    P = inPos(fig, 0.9, figH - 0.45 - mapH - (c-1)*mh, mw, mapH);
    ax = axes('Position', P); hold(ax,'on');
    patch(ax, 'Faces',d(c).t, 'Vertices',d(c).xy, 'FaceVertexCData',d(c).u, 'FaceColor','interp', 'EdgeColor','none');
    colormap(ax, S.icespeed); caxis(ax, [0 100]);
    xlim(ax, [0 2000]); ylim(ax, [850 1000]);
    for yc = sideCanals, drawIcon(ax, P, 'bowl', yc, 850, S); end               % drainage elements along the bed
    if strcmp(md{3},'bowl'), drawIcon(ax, P, 'bowl', 1000, 850, S); end
    x = d(c).xy(:,1); y = d(c).xy(:,2); b = d(c).b(:); ub = d(c).u(b);
    halfLine = (1.5/72)/mapH*150;                % half the 3-pt bed line width, in metres
    w = b(ub < 1e-6 & (x(b) == min(x) | x(b) == max(x)));
    hL = gobjects(0); nm = {};
    for side = [min(x) max(x)]
        ww = w(x(w) == side); [~, o] = sort(y(ww));
        hw = plot(ax, x(ww(o)), y(ww(o)), '-', 'LineWidth',3, 'Color',[0.35 0.35 0.35]);
    end
    hL(end+1) = hw; nm{end+1} = 'No slip BC';
    ib = b(ub < 1e-6 & y(b) == min(y));
    if ~isempty(ib)
        [~, o] = sort(x(ib));
        hL(end+1) = plot(ax, x(ib(o)), y(ib(o)), '-', 'LineWidth',3, 'Color',[0.7 0.7 0.7]);
        nm{end+1} = 'Induced no slip';
    end
    if strcmp(md{3},'dome'), drawIcon(ax, P, 'dome', 1000, 850 + 1.3*halfLine, S, 0.6); end   % smaller, just above the bed line
    set(ax, 'FontSize',S.fs-1, 'Layer','top', 'Box','on', 'YTick',[850 900 950 1000]);
    ax.XRuler.TickLabelGapOffset = S.tickGap;                                   % tick labels clear the icons
    ylabel(ax, 'z [m]'); xlabel(ax, 'Lateral direction, y [m]');
    lg = legend(ax, hL, nm, 'Orientation','horizontal', 'FontSize',S.fs-3, 'Box','off');
    drawnow;  lp = get(lg,'Position');                                           % legend size after layout
    set(lg,'Position',[P(1)+P(3)-lp(3), P(2)+P(4)+0.004, lp(3), lp(4)]);          % above the map, right-aligned
    P0 = get(ax,'Position');
    cb = colorbar(ax);  set(ax,'Position',P0);
    set(cb,'Position',[P(1)+P(3)+0.012, P(2)+0.1*P(4), 0.012, 0.8*P(4)], 'Ticks',[25 50 75 100], 'FontSize',S.fs-3);
    annotation(fig,'textbox',[P(1)+P(3)+0.005, P(2)+P(4)-0.005, 0.06, 0.02], 'String','u [m/yr]', ...
               'LineStyle','none','FontSize',S.fs-3,'VerticalAlignment','bottom');
    panelLetter(fig, P, ['(' letters(c) ')'], S);
end
P1 = inPos(fig, 0.9, 1.1, 4.2, 3.2);  P2 = inPos(fig, 6.3, 1.1, 4.2, 3.2);
profilePanel(fig, P1, d, md, sideCanals, S, 'drag', true, 'northwest');
profilePanel(fig, P2, d, md, sideCanals, S, 'speed', true, 'south');
panelLetter(fig, P1, ['(' letters(n+1) ')'], S);  panelLetter(fig, P2, ['(' letters(n+2) ')'], S);
iconLegend(fig, iconItems(sideCanals, md{3}), S, 0.12);
exportgraphics(fig, outFile, 'ContentType','image', 'Resolution',600);
end

function ax = profilePanel(fig, P, d, md, sideCanals, S, kind, withXlabel, legLoc)
% kind: 'drag' | 'speed' | 'normalized'
% baseline solid and thickest, later cases dashed/dotted/dash-dot and thinner, so overlapping curves stay visible
sty = md{4}; ci = md{5}; n = numel(d);
mkIdx = @(xs, pos) unique(arrayfun(@(p) find(abs(xs - p) == min(abs(xs - p)), 1), pos));
ax = axes('Position', P); hold(ax,'on'); box(ax,'on');
h = gobjects(1,n);
for c = 1:n
    [~, mk] = splitStyle(sty{c});
    switch kind
        case 'drag',       X = d(c).xb; Y = d(c).tb;               mp = S.mDrag;
        case 'speed',      X = d(c).xs; Y = d(c).us;               mp = S.mSurf;
        case 'normalized', X = d(c).xs; Y = d(c).us/max(d(1).us);  mp = S.mSurf;   % by the baseline maximum
    end
    h(c) = plot(ax, X, Y, S.lineStyle{c}, 'LineWidth',S.lineWidth(c), 'Color',S.blue(ci(c),:), 'Marker',mk, ...
                'MarkerFaceColor',S.blue(ci(c),:), 'MarkerSize',8-2*(c>1), 'MarkerIndices', mkIdx(X, mp));
end
xlim(ax,[0 2000]);
ytop = max(arrayfun(@(e) max(e.tb), d));
switch kind
    case 'drag'
        % central peak (x = 1000) is clear of a top-left legend; the film's tallest peaks are the
        % side canals at 820/1180, so give its legend headroom above them
        if strcmp(md{1},'Water Film'), ylim(ax,[0 (1.35 + 0.12*n)*ytop]); else, ylim(ax,[0 1.12*ytop]); end
        ylabel(ax,'Basal drag [kPa]');
    case 'speed'
        ylim(ax,[0 1.6*max(arrayfun(@(e) max(e.us), d))]); ylabel(ax,'Ice surface speed [m/yr]');
    case 'normalized'
        ylim(ax,[0 1.5]); ylabel(ax,'Normalized speed, u/u_{max,0}');
end
set(ax,'FontSize',S.fs,'Layer','top'); ax.XRuler.TickLabelGapOffset = S.tickGap;
if withXlabel, xlabel(ax,'Lateral direction, y [m]'); end
legend(ax, h, {d.lab}, 'Location',legLoc, 'FontSize',S.fs-2);
for yc = sideCanals, drawIcon(ax, P, 'bowl', yc, 0, S); end
if ~isempty(md{3}), drawIcon(ax, P, md{3}, 1000, 0, S); end
% sequential arrows: baseline -> 1st reduction -> 2nd reduction ...
if n > 1 && ~strcmp(md{1},'Water Film')
    if strcmp(kind,'drag')
        pk = @(c) max(d(c).tb(abs(d(c).xb - 1000) < 2));
        for c = 2:n, dataArrow(fig, ax, P, [1060 1060], [pk(c-1) pk(c)]); end
    else
        if strcmp(kind,'normalized'), sc = max(d(1).us); else, sc = 1; end
        for xa = S.arrowX
            for c = 2:n
                dataArrow(fig, ax, P, [xa xa], [interp1(d(c-1).xs, d(c-1).us, xa), interp1(d(c).xs, d(c).us, xa)]/sc);
            end
        end
    end
end
end

function filmInset(fig, ax, P, d, md, S, yl, yt)
% zoom on the film's local strength rise at the bed centre, placed right of the side canal at 1180 m,
% with zoom box, connectors and sequential arrows (baseline -> each flux reduction)
sty = md{4}; ci = md{5};
Pin = [P(1)+0.635*P(3), P(2)+0.40*P(4), 0.29*P(3), 0.48*P(4)];
axi = axes('Position', Pin); hold(axi,'on'); box(axi,'on');
for c = 1:numel(d)
    [~, mk] = splitStyle(sty{c});
    plot(axi, d(c).xb, d(c).tb, S.lineStyle{c}, 'LineWidth',max(1,S.lineWidth(c)-0.5), 'Color',S.blue(ci(c),:), 'Marker',mk, ...
         'MarkerFaceColor',S.blue(ci(c),:), 'MarkerSize',5, 'MarkerIndices', find(abs(d(c).xb-1000) == min(abs(d(c).xb-1000)),1));
end
xlim(axi,[900 1100]); ylim(axi,yl);
set(axi,'FontSize',S.fs-3,'XTick',[900 1000 1100],'YTick',yt,'YAxisLocation','right','Layer','top');
pk = @(c) max(d(c).tb(abs(d(c).xb - 1000) < 2));
for c = 2:numel(d), dataArrow(fig, axi, Pin, [1018 1018], [pk(c-1) pk(c)]); end
plot(ax, [900 1100 1100 900 900], [yl(1) yl(1) yl(2) yl(2) yl(1)], '-', 'Color',[0.5 0.5 0.5], ...
     'LineWidth',0.75, 'HandleVisibility','off');
yA = ylim(ax);
d2f = @(x, y) [P(1) + x/2000*P(3), P(2) + (y - yA(1))/diff(yA)*P(4)];
b1 = d2f(1100, yl(1)); b2 = d2f(1100, yl(2));
annotation(fig,'line',[Pin(1) b1(1)],[Pin(2) b1(2)],'Color',[0.5 0.5 0.5],'LineStyle','--');
annotation(fig,'line',[Pin(1) b2(1)],[Pin(2)+Pin(4) b2(2)],'Color',[0.5 0.5 0.5],'LineStyle','--');
end

function items = iconItems(sideCanals, centre)
% icons that appear in a figure, as {type, name} rows
items = cell(0,2);
if ~isempty(sideCanals) || strcmp(centre,'bowl'), items(end+1,:) = {'bowl','Canal'}; end
if strcmp(centre,'dome'), items(end+1,:) = {'dome','R-channel'}; end
if strcmp(centre,'oval'), items(end+1,:) = {'oval','Linked cavity'}; end
end

function iconLegend(fig, items, S, bottomIn)
% centred legend of drainage-element icons along the bottom of the figure
fp = get(fig,'Position');
PL = [0, bottomIn/fp(4), 1, 0.3/fp(4)];
axL = axes('Position', PL, 'XLim',[0 1], 'YLim',[0 1], 'Visible','off'); hold(axL,'on');
n = size(items,1);  tx = gobjects(1,n);  w = zeros(1,n);
for k = 1:n
    tx(k) = text(axL, 0, 0.5, items{k,2}, 'FontSize',S.fs, 'VerticalAlignment','middle');
    e = get(tx(k),'Extent');  w(k) = e(3);
end
iw = S.rIcon/(PL(3)*fp(3));  gap = 0.08/fp(3);  sep = 0.45/fp(3);
x = 0.5 - (n*(2*iw + gap) + sum(w) + (n-1)*sep)/2;
for k = 1:n
    if strcmp(items{k,1},'line')
        plot(axL, x + [0 2*iw], [0.5 0.5], '-', 'Color',[0 0 0], 'LineWidth',1);
    else
        yc = 0.5 + strcmp(items{k,1},'bowl')*0.25 - strcmp(items{k,1},'dome')*0.25;   % centre the half-discs on the text
        drawIcon(axL, PL, items{k,1}, x + iw, yc, S);
    end
    set(tx(k),'Position',[x + 2*iw + gap, 0.5, 0]);
    x = x + 2*iw + gap + w(k) + sep;
end
end

function txt = changeText(d)
% one line per reduced-flow case: flowrate reduction and the change in maximum ice surface speed,
% e.g. {'21% flow reduction: 12.9% slowdown'; '50% flow reduction: 24.4% slowdown'}
du = arrayfun(@(e) 100*(max(e.us) - max(d(1).us))/max(d(1).us), d(2:end));
dq = arrayfun(@(e) 100*(1 - e.q/d(1).q), d(2:end));
if all(abs(du) < 0.5), txt = {'No change'}; return; end
txt = cell(numel(du),1);
for k = 1:numel(du)
    if du(k) < 0, w = 'slowdown'; else, w = 'speed-up'; end
    txt{k} = sprintf('%.0f%% flow reduction: %.1f%% %s', dq(k), abs(du(k)), w);
end
end

function [ls, mk] = splitStyle(st)
% split a style such as '--s' into line style '--' and marker 's'
mk = regexprep(st, '[-:.]', '');  if isempty(mk), mk = 'none'; end
ls = regexprep(st, '[^-:.]', ''); if isempty(ls), ls = '-'; end
end

function drawIcon(ax, Pax, type, xc, y0, S, scale)
% drainage-element icon of fixed size on paper (S.rIcon, inches) at (xc, y0):
% bowl = canal (hangs below), dome = R-channel (sits above), oval = linked cavity
if nargin < 7, scale = 1; end
fp = get(ancestor(ax,'figure'),'Position');  figW = fp(3); figH = fp(4);
r = scale*S.rIcon;
rx = r/(Pax(3)*figW)*diff(xlim(ax));  ry = r/(Pax(4)*figH)*diff(ylim(ax));
switch type
    case 'bowl', th = linspace(pi, 2*pi, 30);  X = xc + rx*cos(th); Y = y0 + ry*sin(th);
    case 'dome', th = linspace(0, pi, 30);     X = xc + rx*cos(th); Y = y0 + ry*sin(th);
    case 'oval', th = linspace(0, 2*pi, 40);   X = xc + rx*cos(th); Y = y0 + 0.55*ry*sin(th);
end
patch(ax, X, Y, S.blue(4,:), 'EdgeColor',[0.15 0.25 0.45], 'LineWidth',0.75, 'Clipping','off', 'HandleVisibility','off');
end

function dataArrow(fig, ax, Pax, xd, yd)
% figure-level arrow between two points given in the data coordinates of ax
xl = xlim(ax); yl = ylim(ax);
fx = Pax(1) + (xd - xl(1))/diff(xl)*Pax(3);
fy = Pax(2) + (yd - yl(1))/diff(yl)*Pax(4);
if abs(diff(fy)) > 2e-3
    annotation(fig,'arrow',fx,fy,'HeadLength',6,'HeadWidth',6,'Color',[0.1 0.1 0.1]);
end
end

function P = inPos(fig, l, b, w, h)
% normalized position from inches; stops with a clear message if the figure is smaller
% than the layout needs (MATLAB shrinks figures that do not fit on the screen)
fp = get(fig,'Position');  P = [l/fp(3), b/fp(4), w/fp(3), h/fp(4)];
if any(P(1:2) + P(3:4) > 1 + 1e-6)
    error('Figure is %.1f x %.1f in, too small for this layout (screen too small?).', fp(3), fp(4));
end
end

function panelLetter(fig, P, s, S)
annotation(fig,'textbox',[P(1)-0.06, P(2)+P(4)+0.002, 0.05, 0.03], 'String',s, ...
           'LineStyle','none','FontSize',S.fs+2);
end
