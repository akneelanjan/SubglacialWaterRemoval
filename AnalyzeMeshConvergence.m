function AnalyzeMeshConvergence
% AnalyzeMeshConvergence  Mesh convergence of the canal baseline and resolvability of the off-target cases.
%
% Reads ResultsConvergence/<configuration>/TempBedG100mW_<case>.mat, written by run_convergence.sbatch, then
%   1. prints the canal baseline speed and the 50% slowdown for each configuration, against production;
%   2. prints the peak speed change of the matched on-target and off-target cases, and the off-target
%      efficiency (integrated speed change, off-target over on-target);
%   3. prints the resolvability of the off-target signal: the mesh noise floor zeta and the resulting
%      signal-to-noise ratio (SNR);
%   4. reproduces Fig. S11 (FigS11_convergence.pdf) and writes mesh_convergence_summary.csv.
%
% The mesh noise floor, zeta, is the largest departure of a signal from its production value among all
% configurations at or finer than h_bg = 10 m, and SNR = signal/zeta.
%
% Missing cases are NaN, so this can be run while jobs are still finishing; the figure is drawn only
% when every case it needs is present.

R   = 'ResultsConvergence';
pre = 'TempBedG100mW_';

% folder, label, h_fine, h_bg, d_min, d_max  (production first)
cfg = {'hf1_hbg5_dmin25_dmax100_tol1e-3',   'production',       1,   5,  25, 100
       'hf2_hbg5_dmin25_dmax100_tol1e-3',   'h_fine 2 m',       2,   5,  25, 100
       'hf0.5_hbg5_dmin25_dmax100_tol1e-3', 'h_fine 0.5 m',     0.5, 5,  25, 100
       'hf1_hbg10_dmin25_dmax100_tol1e-3',  'h_bg 10 m',        1,  10,  25, 100
       'hf1_hbg20_dmin25_dmax100_tol1e-3',  'h_bg 20 m',        1,  20,  25, 100
       'hf1_hbg5_dmin50_dmax150_tol1e-3',   'grading 50-150 m', 1,   5,  50, 150};
base   = 'Canal_50kPa';
cut50  = 'Canal_150kPa';
onCase = {'Canal_50.44kPa','Canal_50.89kPa'};                 % matched on-target, dQ = 0.5 and 1 L/min
off = {'OffTarget_dQ0.5Lmin_Blip264.6Pa_Y1050', 1, '\DeltaQ=0.5, y_{off}=50 m'
       'OffTarget_dQ0.5Lmin_Blip264.6Pa_Y1100', 1, '\DeltaQ=0.5, y_{off}=100 m'
       'OffTarget_dQ1Lmin_Blip617Pa_Y1050',     2, '\DeltaQ=1, y_{off}=50 m'
       'OffTarget_dQ1Lmin_Blip617Pa_Y1100',     2, '\DeltaQ=1, y_{off}=100 m'};
nc = size(cfg,1);  noff = size(off,1);
names = [{base, cut50}, onCase, off(:,1)'];                   % every case, in one list
noiseRows = find([cfg{:,4}] <= 10 & (1:nc) > 1);              % configurations that define zeta: h_bg <= 10 m, not production

%% read every case of every configuration
nn = numel(names);
umax = nan(nc,nn);  Iu = nan(nc,nn);  nodes = nan(nc,1);
for i = 1:nc
    for k = 1:nn
        f = fullfile(R, cfg{i,1}, [pre names{k} '.mat']);
        if exist(f,'file') ~= 2, continue; end
        s = load(f, 'v', 'x_surf', 'u_surf', 'xy');
        [xs, is] = sort(s.x_surf(:));  us = s.u_surf(:);  us = us(is);
        umax(i,k) = max(s.v(:));  Iu(i,k) = trapz(xs, us);  nodes(i) = size(s.xy,1);
    end
end
col  = @(n) find(strcmp(names, n), 1);
du   = @(i,n) umax(i,col(base)) - umax(i,col(n));             % peak speed change from the baseline [m/yr]
dI   = @(i,n) Iu(i,col(base))   - Iu(i,col(n));               % integrated speed change [m^2/yr]
slow = @(i)   100*du(i,cut50)/umax(i,col(base));              % canal slowdown at 50% flow reduction [%]

eff = nan(nc,noff);                                           % off-target efficiency [%]
for i = 1:nc
    for k = 1:noff, eff(i,k) = 100*dI(i,off{k,1})/dI(i,onCase{off{k,2}}); end
end

%% 1. canal baseline and the 50% slowdown
fprintf('\n1. Canal baseline (alpha = 0.02383) and the 50%% flowrate reduction\n');
fprintf('%-18s %8s %10s %9s %10s %9s\n','configuration','nodes','u_max','vs prod','slowdown','vs prod');
for i = 1:nc
    fprintf('%-18s %8d %10.3f %8.2f%% %9.2f%% %8.2fpp\n', cfg{i,2}, nodes(i), umax(i,col(base)), ...
        100*(umax(i,col(base)) - umax(1,col(base)))/umax(1,col(base)), slow(i), slow(i) - slow(1));
end

%% 2. peak speed change and off-target efficiency
fprintf('\n2. Peak speed change, baseline minus case [m/yr]\n');
fprintf('%-18s %10s %10s %11s %10s %10s %11s\n','configuration','on 0.5','off .5/50','off .5/100','on 1','off 1/50','off 1/100');
for i = 1:nc
    fprintf('%-18s %10.4f %10.4f %11.4f %10.4f %10.4f %11.4f\n', cfg{i,2}, du(i,onCase{1}), du(i,off{1,1}), ...
        du(i,off{2,1}), du(i,onCase{2}), du(i,off{3,1}), du(i,off{4,1}));
end
fprintf('\n   Off-target efficiency [%%]\n%-18s', 'configuration');
fprintf(' %24s', off{:,3}); fprintf('\n');
for i = 1:nc
    fprintf('%-18s', cfg{i,2}); fprintf(' %24.1f', eff(i,:)); fprintf('\n');
end

%% 3. resolvability: mesh noise floor zeta and SNR (configurations at or finer than h_bg = 10 m)
fprintf('\n3. Resolvability of the off-target signal (zeta: largest departure from production, h_bg <= 10 m)\n');
fprintf('%-28s %10s %10s %8s %12s\n','case','signal','zeta','SNR','eff spread');
zeta = nan(1,noff);
for k = 1:noff
    sig     = du(1,off{k,1});
    zeta(k) = max(abs(arrayfun(@(i) du(i,off{k,1}), noiseRows) - sig));
    es      = max(abs(eff(noiseRows,k) - eff(1,k)));
    fprintf('%-28s %10.4f %10.4f %8.0f %10.2fpp\n', off{k,3}, sig, zeta(k), sig/zeta(k), es);
end

%% csv
fid = fopen('mesh_convergence_summary.csv','w');
fprintf(fid, ['configuration,h_fine,h_bg,d_min,d_max,nodes,umax,slowdown50,dU_on_0.5,dU_on_1,' ...
              'dU_off_0.5_50,dU_off_0.5_100,dU_off_1_50,dU_off_1_100,eff_0.5_50,eff_0.5_100,eff_1_50,eff_1_100\n']);
for i = 1:nc
    fprintf(fid, '%s,%g,%g,%g,%g,%d,%.6f,%.4f', cfg{i,2}, cfg{i,3}, cfg{i,4}, cfg{i,5}, cfg{i,6}, nodes(i), umax(i,col(base)), slow(i));
    fprintf(fid, ',%.6f,%.6f', du(i,onCase{1}), du(i,onCase{2}));
    for k = 1:noff, fprintf(fid, ',%.6f', du(i,off{k,1})); end
    fprintf(fid, ',%.3f', eff(i,:)); fprintf(fid, '\n');
end
fclose(fid);
fprintf('\nWrote mesh_convergence_summary.csv\n');

%% 4. Figure S11
if any(any(isnan(umax)))
    fprintf('Fig. S11 not drawn: some cases are still missing.\n'); return
end
blue = [8 81 156]/255;  red = [203 24 29]/255;
reds = [203 24 29; 239 59 44; 251 106 74; 252 146 114]/255;
lightblue = [66 146 198]/255;
fig = figure('Units','inches','Position',[1 1 10.4 8.0],'Color','w');

lab = cell(1,nc);
for i = 1:nc
    lab{i} = sprintf('%g\n%g\n%g-%g', cfg{i,3}, cfg{i,4}, cfg{i,5}, cfg{i,6});   % multi-line tick label
    if i == 1, lab{i} = sprintf('%s\n(production)', lab{i}); end
end

% (a) background sweep and (b) central sweep, coarse to fine; production is one of the points
bgRows   = [5 4 1];   bgX   = [cfg{bgRows,4}];
fineRows = [2 1 3];   fineX = [cfg{fineRows,3}];
key = off{1,1};                                               % the smallest signal: dQ = 0.5 L/min, y_off = 50 m
sweep([0.075 0.575 0.37 0.37], bgX,   arrayfun(@(i) slow(i), bgRows),   arrayfun(@(i) du(i,key), bgRows), ...
      find(bgRows == 1),   zeta(1), 'background edge length, h_{bg} [m]',          '(a) background mesh, at h_{fine} = 1 m', blue, red);
sweep([0.575 0.575 0.37 0.37], fineX, arrayfun(@(i) slow(i), fineRows), arrayfun(@(i) du(i,key), fineRows), ...
      find(fineRows == 1), zeta(1), 'edge length at the bed center, h_{fine} [m]', '(b) central mesh, at h_{bg} = 5 m', blue, red);

% (c) peak speed change of every case, across configurations
ax = axes('Position',[0.075 0.075 0.37 0.37]); hold(ax,'on'); box(ax,'on');
patch(ax, [0.6 1.4 1.4 0.6], [0 0 0.32 0.32], [0.85 0.85 0.85], 'EdgeColor','none');
hC = gobjects(1,2+noff);  lC = cell(1,2+noff);
hC(1) = plot(ax, 1:nc, arrayfun(@(i) du(i,onCase{2}), 1:nc), '--^', 'Color',blue, 'MarkerFaceColor',blue, 'MarkerSize',5);
lC{1} = 'on-target, \DeltaQ=1';
hC(2) = plot(ax, 1:nc, arrayfun(@(i) du(i,onCase{1}), 1:nc), '--v', 'Color',lightblue, 'MarkerFaceColor',lightblue, 'MarkerSize',5);
lC{2} = 'on-target, \DeltaQ=0.5';
for k = 1:noff
    hC(2+k) = plot(ax, 1:nc, arrayfun(@(i) du(i,off{k,1}), 1:nc), '-o', 'Color',reds(k,:), ...
                   'MarkerFaceColor',reds(k,:), 'MarkerSize',5);
    lC{2+k} = off{k,3};
end
finishpanel(ax, hC, lC, nc, lab, '\Deltau_{max} from baseline [m yr^{-1}]', '(c) resolvability of the withdrawal signal', [0 0.32]);

% (d) off-target efficiency across configurations
ax = axes('Position',[0.575 0.075 0.37 0.37]); hold(ax,'on'); box(ax,'on');
patch(ax, [0.6 1.4 1.4 0.6], [40 40 75 75], [0.85 0.85 0.85], 'EdgeColor','none');
hD = gobjects(1,noff);
for k = 1:noff
    hD(k) = plot(ax, 1:nc, eff(:,k), '-o', 'Color',reds(k,:), 'MarkerFaceColor',reds(k,:), 'MarkerSize',5);
end
finishpanel(ax, hD, off(:,3)', nc, lab, 'off-target efficiency [%]', '(d) off-target efficiency', [40 75]);

exportgraphics(fig, 'FigS11_convergence.pdf', 'ContentType','vector');
fprintf('Wrote FigS11_convergence.pdf\n');
end


%% ---------------------------------------------------------------- local functions
function sweep(pos, xv, y1, y2, ip, zeta, xlab, ttl, blue, red)
% canal slowdown on the left axis; on the right, the smallest off-target signal (dQ = 0.5 L/min at
% y_off = 50 m) with the mesh noise floor zeta as a band around its production value, and its SNR.
sig = y2(ip);

a = axes('Position', pos); hold(a,'on'); box(a,'on');
yyaxis(a,'left');
hL = gobjects(1,4);  lL = cell(1,4);
hL(1) = plot(a, xv, y1, '-o', 'Color',blue, 'MarkerFaceColor',blue, 'MarkerSize',5);
lL{1} = 'canal slowdown, 50% flow reduction (left)';
hL(2) = plot(a, xv(ip), y1(ip), 'o', 'Color','k', 'MarkerSize',13, 'LineWidth',1.4);
lL{2} = 'production: h_{fine} = 1 m, h_{bg} = 5 m';
plot(a, [min(xv) max(xv)], [y1(ip) y1(ip)], ':', 'Color',blue);
ylim(a,[24.30 24.80]); ylabel(a,'canal slowdown [%]'); set(a,'YColor',blue);

yyaxis(a,'right');
hL(3) = patch(a, [min(xv) max(xv) max(xv) min(xv)], [sig-zeta sig-zeta sig+zeta sig+zeta], red, ...
              'FaceAlpha',0.16, 'EdgeColor','none');
lL{3} = sprintf('noise floor, \\zeta = %.4f m yr^{-1}', zeta);
hL(4) = plot(a, xv, y2, '--s', 'Color',red, 'MarkerFaceColor',red, 'MarkerSize',5);
lL{4} = 'off-target \Deltau_{max}, \DeltaQ = 0.5 L min^{-1}, y_{off} = 50 m (right)';
plot(a, xv(ip), y2(ip), 's', 'Color','k', 'MarkerSize',13, 'LineWidth',1.4);
plot(a, [min(xv) max(xv)], [y2(ip) y2(ip)], ':', 'Color',red);
ylim(a,[0.0600 0.0680]); set(a,'YColor',red);
ylabel(a,'off-target \Deltau_{max} [m yr^{-1}]  (smallest signal)');
text(a, 0.70, 0.09, sprintf('SNR > %.0f', floor(sig/zeta)), 'Units','normalized', 'Color',red, ...
     'FontSize',7.5, 'HorizontalAlignment','center');

xt = sort(xv);
set(a, 'XScale','log', 'XTick',xt, 'XTickLabel',arrayfun(@(v) sprintf('%g',v), xt, 'UniformOutput',false), ...
    'XDir','reverse', 'FontSize',10, 'Layer','top');
xlabel(a, {xlab, '(coarser \rightarrow finer)'});
title(a, ttl, 'FontWeight','normal', 'FontSize',10);
legend(a, hL, lL, 'Location','northwest', 'FontSize',7);
end

function finishpanel(a, h, labs, nc, lab, ylab, ttl, yl)
set(a, 'XTick',1:nc, 'XTickLabel',lab, 'FontSize',9, 'TickLabelInterpreter','tex', 'Layer','top');
xlim(a,[0.6 nc+0.4]); ylim(a, yl);
ylabel(a, ylab); xlabel(a, 'rows:  h_{fine} [m];  h_{bg} [m];  grading zone [m]', 'FontSize',9);
title(a, ttl, 'FontWeight','normal', 'FontSize',10);
legend(a, h, labs, 'Location','best', 'FontSize',7.5);
end
