%% Formal Plotting Figures 2, S3, S4, S5, S6, S7
clear all; clc;
addpath('cbrewer2')

icespeed = cbrewer2('seq','RdPu',100);
icespeedmod3 = icespeed(1:90,:);

surfacespeed = cbrewer2('seq','Blues',5);
basalstrength = cbrewer2('seq','Blues',5);
%% Load results

ResultsMatDir = "ResultsMatFiles";

load(fullfile(ResultsMatDir,"TempBed_Canal_50kPa.mat"),"xy","t","b","x_surf","x_base"); % Load essential independent variables for plotting

%%% Load essential dependent variables for plotting
Canal50kPa = load(fullfile(ResultsMatDir,"TempBed_Canal_50kPa.mat"),"u","u_surf","basal_tau_c_specific");

Canal100kPa = load(fullfile(ResultsMatDir,"TempBed_Canal_100kPa.mat"),"u","u_surf","basal_tau_c_specific");

Canal150kPa = load(fullfile(ResultsMatDir,"TempBed_Canal_150kPa.mat"),"u","u_surf","basal_tau_c_specific");

Canal200kPa = load(fullfile(ResultsMatDir,"TempBed_Canal_200kPa.mat"),"u","u_surf","basal_tau_c_specific");

RChannel550kPa = load(fullfile(ResultsMatDir,"TempBed_RChannel_550kPa.mat"),"xy","t","b","x_surf","x_base","u","u_surf","basal_tau_c_specific");

RChannel520kPa = load(fullfile(ResultsMatDir,"TempBed_RChannel_520kPa.mat"),"xy","t","b","x_surf","x_base","u","u_surf","basal_tau_c_specific");

LinkedCavity250kPa = load(fullfile(ResultsMatDir,"TempBed_LinkedCavity_250kPa.mat"),"u","u_surf","basal_tau_c_specific");

LinkedCavity500kPa = load(fullfile(ResultsMatDir,"TempBed_LinkedCavity_500kPa.mat"),"u","u_surf","basal_tau_c_specific");

WaterFilm4000Pa = load(fullfile(ResultsMatDir,"TempBed_WaterFilm_4000Pa.mat"),"u","u_surf","basal_tau_c_specific");

WaterFilm5333Pa = load(fullfile(ResultsMatDir,"TempBed_WaterFilm_5333Pa.mat"),"u","u_surf","basal_tau_c_specific");

WaterFilm4444Pa = load(fullfile(ResultsMatDir,"TempBed_WaterFilm_4444Pa.mat"),"u","u_surf","basal_tau_c_specific");

WaterFilm8000Pa = load(fullfile(ResultsMatDir,"TempBed_WaterFilm_8000Pa.mat"),"u","u_surf","basal_tau_c_specific");

SingleCanal50kPa = load(fullfile(ResultsMatDir,"TempBed_only1CentralCanal_50kPa.mat"),"u","u_surf","basal_tau_c_specific");

SingleCanal100kPa = load(fullfile(ResultsMatDir,"TempBed_only1CentralCanal_100kPa.mat"),"u","u_surf","basal_tau_c_specific");

SingleCanal150kPa = load(fullfile(ResultsMatDir,"TempBed_only1CentralCanal_150kPa.mat"),"u","u_surf","basal_tau_c_specific");

SingleCanal200kPa = load(fullfile(ResultsMatDir,"TempBed_only1CentralCanal_200kPa.mat"),"u","u_surf","basal_tau_c_specific");

WiderCanal50kPa = load(fullfile(ResultsMatDir,"TempBed_CenterCanalWider_50kPa.mat"),"u","u_surf","basal_tau_c_specific");

WiderCanal100kPa = load(fullfile(ResultsMatDir,"TempBed_CenterCanalWider_100kPa.mat"),"u","u_surf","basal_tau_c_specific");

WiderCanal150kPa = load(fullfile(ResultsMatDir,"TempBed_CenterCanalWider_150kPa.mat"),"u","u_surf","basal_tau_c_specific");

WiderCanal200kPa = load(fullfile(ResultsMatDir,"TempBed_CenterCanalWider_200kPa.mat"),"u","u_surf","basal_tau_c_specific");


%% Basal Drag Profiles Fig. 2 (a) water film
figure
%yyaxis left
plot(x_base,WaterFilm4000Pa.basal_tau_c_specific/1000, ...
    '--','LineWidth',4,'DisplayName','Q = Q_0 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WaterFilm5333Pa.basal_tau_c_specific/1000, ...
    '-o','LineWidth',2,'DisplayName','Q = 0.5 Q_0 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(WaterFilm4000Pa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend

%% Ice Surface Speed profiles Fig. 2 (b) water film
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,WaterFilm4000Pa.u_surf, ...
    '--','LineWidth',4,'DisplayName','Q = Q_0 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,WaterFilm5333Pa.u_surf, ...
    '-o','LineWidth',2,'DisplayName','Q = 0.5 Q_0 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(WaterFilm4000Pa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% Basal Drag Profiles Fig. 2 (c) linked cavity
figure
%yyaxis left
plot(x_base,LinkedCavity250kPa.basal_tau_c_specific/1000, ...
    '--square','LineWidth',3,'DisplayName','Q = 0.010 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,LinkedCavity500kPa.basal_tau_c_specific/1000, ...
    '-v','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(LinkedCavity500kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend



%% Ice Surface Speed profiles Fig. 2 (d) linked cavity
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,LinkedCavity250kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.010 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,LinkedCavity500kPa.u_surf, ...
    '-v','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(LinkedCavity250kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% Basal Drag Profiles Fig. 2(e) and Fig. S4(c) R-Channel
figure
%yyaxis left
plot(x_base,RChannel550kPa.basal_tau_c_specific/1000, ...
    '-diamond','LineWidth',3,'DisplayName','Q = 0.086 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,RChannel520kPa.basal_tau_c_specific/1000, ...
    '-^','LineWidth',3,'DisplayName','Q = 0.043 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(RChannel550kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend


%% Ice Surface Speed profiles Fig. 2(f) and Fig. S4(d) R-Channel
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,RChannel550kPa.u_surf, ...
    '-diamond','LineWidth',3,'DisplayName','Q = 0.086 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,RChannel520kPa.u_surf, ...
    '-^','LineWidth',3,'DisplayName','Q = 0.043 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(RChannel520kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% Basal Drag Profiles Fig. 2(g) Canal
figure
%yyaxis left
plot(x_base,Canal50kPa.basal_tau_c_specific/1000, ...
    '--pentagram','LineWidth',4,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,Canal100kPa.basal_tau_c_specific/1000, ...
    '--o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',basalstrength(4,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,Canal150kPa.basal_tau_c_specific/1000, ...
    '-square','LineWidth',2,'DisplayName','Q = 0.0025 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(Canal150kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend

%% Ice Surface Speed profiles Fig. 2(h) Canal
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,Canal50kPa.u_surf, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,Canal100kPa.u_surf, ...
    '-o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,Canal150kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.0025 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(Canal50kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% 2D ice speed map Canal 50 kPa Fig. S3(a)
figure;
trisurf(t,xy(:,1),xy(:,2),Canal50kPa.u,Canal50kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = Canal50kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Canal 100 kPa Fig. S3(b)
figure;
trisurf(t,xy(:,1),xy(:,2),Canal100kPa.u,Canal100kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = Canal100kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Canal 150 kPa Fig. S3(c)
figure;
trisurf(t,xy(:,1),xy(:,2),Canal150kPa.u,Canal150kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = Canal150kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Canal 200 kPa Fig. S3(d)
figure;
trisurf(t,xy(:,1),xy(:,2),Canal200kPa.u,Canal200kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = Canal200kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% Basal Drag Profiles Fig. S3(e) Canal
figure
%yyaxis left
plot(x_base,Canal50kPa.basal_tau_c_specific/1000, ...
    '--pentagram','LineWidth',4,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,Canal100kPa.basal_tau_c_specific/1000, ...
    '--o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',basalstrength(4,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,Canal150kPa.basal_tau_c_specific/1000, ...
    '-square','LineWidth',2,'DisplayName','Q = 0.0025 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,Canal200kPa.basal_tau_c_specific/1000, ...
    '--v','LineWidth',2,'DisplayName','Q = 0.002 m^3/s','Color',basalstrength(2,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(Canal200kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend


%% Ice Surface Speed profiles Fig. S3(f) Canal
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,Canal50kPa.u_surf, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,Canal100kPa.u_surf, ...
    '-o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,Canal150kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.0025 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,Canal200kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.002 m^3/s','Color',surfacespeed(2,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(Canal50kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend


%% 2D ice speed map R-Channel 550 kPa Fig. S4(a)
figure;
trisurf(RChannel550kPa.t,RChannel550kPa.xy(:,1),RChannel550kPa.xy(:,2),RChannel550kPa.u,RChannel550kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 110])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 110];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = RChannel550kPa.u;
xy = RChannel550kPa.xy;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map R-Channel 520 kPa Fig. S4(b)
figure;
trisurf(RChannel520kPa.t,RChannel520kPa.xy(:,1),RChannel520kPa.xy(:,2),RChannel520kPa.u,RChannel520kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 110])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 110];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = RChannel520kPa.u;
xy = RChannel520kPa.xy;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S5(a) Only 1 central Canal 50 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),SingleCanal50kPa.u,SingleCanal50kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = SingleCanal50kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S5(b) Only 1 central Canal 100 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),SingleCanal100kPa.u,SingleCanal100kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = SingleCanal100kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S5(c) Only 1 central Canal 150 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),SingleCanal150kPa.u,SingleCanal150kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = SingleCanal150kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S5(d) Only 1 central Canal 200 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),SingleCanal200kPa.u,SingleCanal200kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = SingleCanal200kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% Basal Drag Profiles Fig. S5(e) Only 1 central Canal
figure
%yyaxis left
plot(x_base,SingleCanal50kPa.basal_tau_c_specific/1000, ...
    '--pentagram','LineWidth',4,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,SingleCanal100kPa.basal_tau_c_specific/1000, ...
    '--o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',basalstrength(4,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,SingleCanal150kPa.basal_tau_c_specific/1000, ...
    '-square','LineWidth',2,'DisplayName','Q = 0.0025 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,SingleCanal200kPa.basal_tau_c_specific/1000, ...
    '--v','LineWidth',2,'DisplayName','Q = 0.002 m^3/s','Color',basalstrength(2,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(SingleCanal200kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend


%% Ice Surface Speed profiles Fig. S5(f) Only 1 central Canal
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,SingleCanal50kPa.u_surf, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,SingleCanal100kPa.u_surf, ...
    '-o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,SingleCanal150kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.0025 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,SingleCanal200kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.002 m^3/s','Color',surfacespeed(2,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(SingleCanal50kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% 2D ice speed map Fig. S6(a) Wider central Canal 50 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),WiderCanal50kPa.u,WiderCanal50kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = WiderCanal50kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S6(b) Wider central Canal 100 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),WiderCanal100kPa.u,WiderCanal100kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = WiderCanal100kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S6(c) Wider central Canal 150 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),WiderCanal150kPa.u,WiderCanal150kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = WiderCanal150kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% 2D ice speed map Fig. S6(d) Wider central Canal 200 kPa
figure;
trisurf(t,xy(:,1),xy(:,2),WiderCanal200kPa.u,WiderCanal200kPa.u,'edgecolor','none','facecolor','interp'); hold on
cmap = colormap(icespeedmod3);
set(gca,'ColorScale','linear')
caxis([0 100])
%set(gca,'ColorScale','log')
%colormap(viridis)
clims = [0 100];
%colormap(flipud(cmap));
h = colorbar;
h.Ticks = [25 50 75 100];
h.TickLabels = [25 50 75 100];
h.Label.String = 'u [m/yr]';
h.Label.Position = [1.5 clims(2)+50];
h.Label.Rotation = 0;
h.Label.FontSize = 12;
%view([0 90]); %daspect([2 1 1])

u = WiderCanal200kPa.u;
% left edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==0),1),xy(b(u(b) < 1e-6 & xy(b,1)==0),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==0), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% right edge no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,1)==2000),1),xy(b(u(b) < 1e-6 & xy(b,1)==2000),2),max(u)+0*b(u(b) < 1e-6 & xy(b,1)==2000), ...
    'LineWidth',3,'Color',[0.4 0.4 0.4])

% bottom edge induced no-slip marking
plot3(xy(b(u(b) < 1e-6 & xy(b,2)==850),1),xy(b(u(b) < 1e-6 & xy(b,2)==850),2),max(u)+0*b(u(b) < 1e-6 & xy(b,2)==850), ...
    'LineWidth',3,'Color',[0.6 0.6 0.6])

view(2)
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Vertical direction, z [m]", FontSize=16)
%title("Antiplane ice flow speed map")
axis equal tight

%% Basal Drag Profiles Fig. S6(e) Wider Center  Canal
figure
%yyaxis left
plot(x_base,WiderCanal50kPa.basal_tau_c_specific/1000, ...
    '--pentagram','LineWidth',4,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WiderCanal100kPa.basal_tau_c_specific/1000, ...
    '--o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',basalstrength(4,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WiderCanal150kPa.basal_tau_c_specific/1000, ...
    '-square','LineWidth',2,'DisplayName','Q = 0.0025 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WiderCanal200kPa.basal_tau_c_specific/1000, ...
    '--v','LineWidth',2,'DisplayName','Q = 0.002 m^3/s','Color',basalstrength(2,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(WiderCanal200kPa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend


%% Ice Surface Speed profiles Fig. S6(f) Wider Center Canal
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,WiderCanal50kPa.u_surf, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,WiderCanal100kPa.u_surf, ...
    '-o','LineWidth',3,'DisplayName','Q = 0.004 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,WiderCanal150kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.0025 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

plot(x_surf,WiderCanal200kPa.u_surf, ...
    '-square','LineWidth',3,'DisplayName','Q = 0.002 m^3/s','Color',surfacespeed(2,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(Canal50kPa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

%% Basal Drag Profiles Fig. S7 (a) water film
figure
%yyaxis left
plot(x_base,WaterFilm4000Pa.basal_tau_c_specific/1000, ...
    '--','LineWidth',8,'DisplayName','Q = Q_0 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WaterFilm4444Pa.basal_tau_c_specific/1000, ...
    '--^','LineWidth',6,'DisplayName','Q = 0.7 Q_0 m^3/s','Color',basalstrength(4,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WaterFilm5333Pa.basal_tau_c_specific/1000, ...
    '-o','LineWidth',4,'DisplayName','Q = 0.5 Q_0 m^3/s','Color',basalstrength(3,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on
plot(x_base,WaterFilm8000Pa.basal_tau_c_specific/1000, ...
    '--','LineWidth',2,'DisplayName','Q = 0.1 Q_0 m^3/s','Color',basalstrength(2,:), ...
    'MarkerIndices', [1 1+0.5*(size(x_base,1)-1)-40 1+0.5*(size(x_base,1)-1) 1+0.5*(size(x_base,1)-1)+40 size(x_base,1)]); hold on

axis([min(x_base),max(x_base),0,1.1*max(WaterFilm4000Pa.basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend

%% Ice Surface Speed profiles Fig. S7 (b) water film
figure;
%x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
%u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,WaterFilm4000Pa.u_surf, ...
    '--','LineWidth',8,'DisplayName','Q = Q_0 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,WaterFilm4444Pa.u_surf, ...
    '--^','LineWidth',6,'DisplayName','Q = 0.7 Q_0 m^3/s','Color',surfacespeed(4,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,WaterFilm5333Pa.u_surf, ...
    '-o','LineWidth',4,'DisplayName','Q = 0.5 Q_0 m^3/s','Color',surfacespeed(3,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on
plot(x_surf,WaterFilm8000Pa.u_surf, ...
    '--','LineWidth',2,'DisplayName','Q = 0.1 Q_0 m^3/s','Color',surfacespeed(2,:), ...
    'MarkerIndices', [1 ...
    1+0.5*(length(x_surf)-1)-40 ...
    1+0.5*(length(x_surf)-1) ...
    1+0.5*(length(x_surf)-1)+40 ...
    length(x_surf)]); hold on

axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(WaterFilm4000Pa.u_surf)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend

