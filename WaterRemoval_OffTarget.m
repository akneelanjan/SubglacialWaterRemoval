% =========================================================================
% CVX SETUP NOTES
% =========================================================================
% This code requires CVX. If CVX is not already installed on this computer,
% download the current official CVX bundle and place it in a clean, permanent
% location outside this project folder. A good default location is:
%
%   macOS/Linux:   ~/MATLAB/cvx
%   Windows:       C:\Users\<username>\Documents\MATLAB\cvx
%
% Example command-line installation:
%
% macOS/Linux Terminal:
%   cd ~/Downloads
%   curl -L -o cvx.zip https://github.com/cvxr/CVX/releases/download/2.2.2/cvx.zip
%   unzip cvx.zip
%   mkdir -p ~/MATLAB
%   mv cvx ~/MATLAB/cvx
%
% Windows PowerShell:
%   cd $HOME\Downloads
%   Invoke-WebRequest -Uri "https://github.com/cvxr/CVX/releases/download/2.2.2/cvx.zip" -OutFile "cvx.zip"
%   Expand-Archive -Path "cvx.zip" -DestinationPath "."
%   New-Item -ItemType Directory -Force "$HOME\Documents\MATLAB"
%   Move-Item ".\cvx" "$HOME\Documents\MATLAB\cvx"
%
% Then, inside MATLAB, run:
%
%   restoredefaultpath
%   rehash toolboxcache
%
%   cd ~/MATLAB/cvx              % macOS/Linux
%   % cd(fullfile(getenv('USERPROFILE'),'Documents','MATLAB','cvx'))  % Windows
%
%   cvx_setup
%   savepath
%   cvx_version
%
% After setup, MATLAB should recognize CVX from its permanent installation
% path. Avoid using a CVX folder copied directly inside this project directory,
% because it may be incomplete or incompatible with the current computer.
% =========================================================================

% =========================================================================
% CBREWER2 SETUP NOTES
% =========================================================================
% This code also uses cbrewer2 for perceptually balanced colormaps.
% If cbrewer2 is not already installed on this computer, download it from
% MATLAB File Exchange:
%
%   https://www.mathworks.com/matlabcentral/fileexchange/58350-cbrewer2
%
% After downloading, place the cbrewer2 folder in the same directory as this code.
% =========================================================================
%% Runs Ortholine v1.0 on depth cross section. 
% Adjust bed properties for geometry and peak flow speed. Change driving force too using alpha.

clearvars; clc;

% Download the DistMesh v1.2 package from the github repository 
% https://github.com/popersson/DistMesh
% Add the following folders in the current path or run startup.m

addpath('DistMesh-main')
addpath(fullfile('DistMesh-main','src'));
addpath(fullfile('DistMesh-main','examples'));
fprintf('DistMesh paths added.\n');

addpath('cbrewer2')
load iceColorMap.mat

%% Off-target cases: matched withdrawal rate dQ, film strength perturbation, and site
% N_wfblip = N_wf*(1 - dQ/Q_0)^(-1/3) - N_wf, with film footprint flux
% Q_0 = 2*delta*T_wf*alpha = 2.86 L/min (delta = 10 m, T_wf = 1e-4 m^2/s, alpha = 0.02383).
% Matched on-target canal cases: Canal_50.44kPa (dQ = 0.5 L/min), Canal_50.88kPa (dQ = 1 L/min).
% Offsets of 50 and 100 m only: at 10-20 m the film perturbation (decay length delta = 10 m)
% overlaps the central canal's strength footprint.
% caseID selects a row; batch (Slurm array) runs take caseID from SLURM_ARRAY_TASK_ID.
offCases = [
    % dQ [L/min]   N_wfblip [Pa]   Xsuction [m]
      0.5          264.6           1050
      0.5          264.6           1100
      1.0          617.0           1050
      1.0          617.0           1100
    ];

caseID = 1;   % interactive default: row of offCases
if ~isempty(getenv('SLURM_ARRAY_TASK_ID'))
    caseID = str2double(getenv('SLURM_ARRAY_TASK_ID'));
end
dQ       = offCases(caseID,1);
N_wfblip = offCases(caseID,2);
Xsuction = offCases(caseID,3);
modeCase = "OffTarget_dQ"+string(dQ)+"Lmin_Blip"+string(N_wfblip)+"Pa_Y"+string(Xsuction);
fprintf('Case %d: %s\n', caseID, modeCase);

%% cbrewer2
icespeed = cbrewer2('seq','RdPu',100);

icespeedmod3 = icespeed(1:90,:);
surfacespeed = cbrewer2('seq','Blues',5);
basalstrength = cbrewer2('seq','Blues',5);
%% Initialization
% Physical parameters
p = 4/3;
rho = 900;
g = 9.8;

% bedrock = 10 kPa
% downstream slope
alpha = 0.02383; % for Canal (locked: 100.12 m/yr baseline)

f = rho*g*sin(alpha); % Gravitational stresses [Pa]

factor1 = 1;
%factor2 = 0.5;

% Domain parameters
dx = 10;                     %dx: nominal grid spacing
vert_scale = 1;
dy = vert_scale*dx;

x_max = 2E3*factor1;
y_max = 1000;

% Boundary parameters
T_surfBC = 268; % surface ice temperature [K]
G_geo = 0.100; % uniform geothermal heat flux [W/m^2] 

%% Depth cross-section domain design (Idealized mountain glacier on a piecewise-linear bed, 2 inclined symmetrical flanks enclosing a flat center)

x_bed = [2:-0.05:0]';
y_hardrock2_down = 0.0625*[2:-0.05:1.2]'+0.775;
%y_hardrock2_up = -0.3*1.45+1.30;
y_sediment = 0.85*ones(size([1.15:-0.05:0.85]',1),1);
%y_hardrock1_down = 0.3*0.55+0.70;
y_hardrock1_up = -0.0625*[0.8:-0.05:0]'+0.90;
%y_disc = 0.05*x_disc.^2 -0.1*x_disc + 0.9;

y_bed = [y_hardrock2_down;y_sediment;y_hardrock1_up];

topedge = [0:0.05:2]';
pv5 = zeros(size(x_bed,1)+size(topedge,1)+1,2);
pv5(1:size(topedge,1),1) = 0:0.05:2;
pv5(1:size(topedge,1),2) = 1;
pv5(size(topedge,1)+1:end-1,1) = x_bed;
pv5(size(topedge,1)+1:end-1,2) = y_bed;
pv5(end,:) = [0,1];

figure;
plot(x_bed,y_bed);

pv6 = factor1*1E3.*pv5;
%% Mesh Generation using DistMesh v1.2

pfix_extra = [820 850; 1180 850];   % side-canal centres
%[xy,t] = distmesh2d(@dpoly,@huniform,dx,factor1*1E3.*[-0.1,0.84;2.1,1.1],[pv6; pfix_extra],pv6);
% Graded mesh: h_fine within d_min of the bed centre, ramping to h_bg by d_max
h_fine = 1;  h_bg = 5;  d_min = 25;  d_max = 100;
fh = @(p,varargin) min(h_bg/h_fine, max(1, 1 + ...
     (sqrt((p(:,1)-1000).^2 + (p(:,2)-850).^2) - d_min)/(d_max - d_min)*(h_bg/h_fine - 1)));
meshFile = sprintf('Mesh_hf%g_hbg%g_dmin%g_dmax%g.mat', h_fine, h_bg, d_min, d_max);
if isfile(meshFile)
    load(meshFile, 'xy', 't');
else
    rng(0);   % DistMesh's rejection step uses rand once h is non-uniform
    [xy,t] = distmesh2d(@dpoly,fh,h_fine,factor1*1E3.*[-0.1,0.84;2.1,1.1],[pv6; pfix_extra],pv6);
    save(meshFile, 'xy', 't');
end

nN = size(xy,1);                     %nN: number of nodes
nE = size(t,1);                      %nE: number of elements
b = unique(boundedges(xy,t));        %b:  boundary node numbers
nB = size(b,1);                      %nB: number of boundary nodes
e = [t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];
e = sort(e,2);
[foo,~,ifoo] = unique(e,'rows');
eB = foo(accumarray(ifoo,1) == 1,:); %eB: boundary edges

%% Hydrology-informed mixed bed drag experiments

sed_l = 0.8e3; % Rock-sediment interface on the left
sed_r = 1.2e3; % Rock-sediment interface on the right
N_bedrock = 100e3; % Film Effective pressure at the Ice-Bedrock contact [Pa]
Cf = 0.1; % Sliding Coefficient
As = 10e3; % [m yr^(-1) MPa^(-3)] % Hard-bed drag parameter
u_0 = As*((0.01)^3); % [m yr^-1] % Threshold to verify Coulomb-Slip regime

N_wf = 4e3; % Sediment Cohesion [Pa]
% N_wfblip: strength perturbation at the off-target site [Pa], set from offCases above
delta = 10; % [m] Exponential decay length for the local rise in water film basal strength

% Canal
N_infi = 4e3; % far-field effective pressure away from canal [Pa]
N_canal_side = 50e3; % Side Canal effective pressure corresponding to baseline flowrate of 0.005 [m^3/s]
N_canal_center = 50e3; % Center Canal effective pressure
gamma_side = 0.2; % spatial scale parameter for side Canals
gamma_center = 0.2; % spatial scale parameter for center Canal

a_canal = -0.118/1000; % [m/Pa] from Damsgaard et. al. 2017
b_canal = 4.6; % [m] from Damsgaard et. al. 2017
W_max = a_canal*N_infi + b_canal; % Maximum width of canal, [m], from Damsgaard et. al. 2017

X_canal_center = 1e3; % [m] Location of center Canal (center of the bed)
X_canal_sed_l = 0.8e3+20; % [m] Location of side canal on the left
X_canal_sed_r = 1.2e3-20; % [m] Location of side canal on the right

% Basal-drag, tau_bed formulation as per Coulomb-Slip on hard-bedrock
tau_c =@(x,y,u) (heaviside(sed_l - x).*(Cf*N_bedrock).*abs(u) ...
                 + heaviside(sed_r - x).*heaviside(x - sed_l).* ...
                 ((N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_l)/W_max))+ ...
                 (N_canal_center-N_infi)*(1-erf(gamma_center*abs(x-X_canal_center)/W_max))+ ...
                 (N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_r)/W_max))+ ...
                 N_wfblip*exp(-abs(x-Xsuction)/delta)+N_infi).*abs(u) ...
                 + heaviside(x - sed_r).*(Cf*N_bedrock).*abs(u) ...
                 ).*heaviside((901) - y);
% with speed multiplied

%% Thermal Parameters and CVX Solver, simultaneously minimizing Mechanical and Thermal Energy Functionals

T = (273-T_surfBC)/y_max*(y_max-xy(:,2)) + T_surfBC;
T_old = (273-T_surfBC)/y_max*(y_max-xy(:,2)) + T_surfBC;

cvx_solver mosek
secpy = 365*24*3600;   % [s/yr]

res = 1;
while(res > 1E-3)
T = .3*T + (1-.3)*T_old;

T_mech = T; % for viscosity calculations after the loop

A = 3.5e-25; %A: preexponential constant[1/s*Pa^3]
E = 1; %E: enhancement factor[]
Q_h = 0*xy(:,1); %Q_h: melting point adjusted activation energy[J/mol]
R = 8.314; %R: gas constant[J/K*mol]
Tstar = 263.15; %Tstar: activation threshold[K] (-10C)
p0 = 7e-8; %p0: pressure heating coef[K/Pa]
P = rho*g*(y_max-xy(:,2)); %P: hydrostatic pressure[Pa]
T_h = T + p0*P; %T_h: melting point adjusted temperature[K]
Tstar_h = Tstar*(0*xy(:,1) + 1) + p0*P; %Tstar_h: adjusted activation threshold[K]
Q2 = 60e3; %Q2: lower activation energy[J/mol]
Q3 = 115e3; %Q3: higher activation energy[J/mol]
Q_h(heaviside(T_h-Tstar_h)==0) = Q2;
Q_h(heaviside(T_h-Tstar_h)==1) = Q3;
%Cooper %a = 1/2*(A*E*exp((-Q_h./R).*((1./T_h)-(1./Tstar_h)))).^(-1/3); %a = A^(-1/n)

%%% Correct pre-factor for E = 1. Neelanjan October 8, 2026
a = 2^(-1/3)*(A*E*exp((-Q_h./R).*((1./T_h)-(1./Tstar_h)))).^(-1/3);

%% Build System
A = sparse(nE,nN);
B = sparse(nE,nN);
D = sparse(nE,nN);
F = zeros(1,nN);

tau_area = zeros(nE,1);
for E = 1:nE  % integration over each element
  nodes = t(E,:);
  xyE = [ones(3,1),xy(nodes,:)];
  Area = abs(det(xyE))/2;
  tau_area(E) = Area;
  C = inv(xyE);
  A_E = C(2,:);
  B_E = C(3,:);
  D_E = 1/3*ones(1,3);
  F_E = f*Area/3*ones(1,3);
  A(E,nodes) = A(E,nodes) + A_E;
  B(E,nodes) = B(E,nodes) + B_E;
  D(E,nodes) = D(E,nodes) + D_E;
  F(nodes) = F(nodes) + F_E;
end

b_dx = zeros(size(b,1),1);
for N = 1:size(b,1) % integration over each boundary node
    edges = eB(sum(eB == b(N),2) == 1,:);
    for i = 1:size(edges,1)
        edge = edges(i,:);
        b_dx(N) = b_dx(N) + .5*sqrt(sum(diff(xy(edge,:),1).^2,2));
    end
end

%% Solve

cvx_begin
cvx_quiet true
    variables v(nN)   % ice speed [m/yr] (well scaled for the solver)
    obj = (1/p)*sum((D*a).*tau_area.*secpy^(1-p).*pow_pos(norms([A*v,B*v],2,2),p)) - F*v + sum(b_dx.*tau_c(xy(b,1),xy(b,2),v(b)));
    subject to
        v >= 0;
        v(xy(:,1) == 0) == 0;
        v(xy(:,1) == x_max) == 0;
    %minimize(obj)
    minimize(obj/sum(F))
cvx_end

if ~strcmp(cvx_status,'Solved'), error('Momentum solve: %s', cvx_status); end

u = v/secpy;   % back to [m/s] for tau_E, epsilon_E and the thermal solve

fprintf('mom:   %s | optval %.3e | max u = %.3e m/yr\n', cvx_status, cvx_optval, max(v));

u_x = A*u;
u_y = B*u;
%mu = (D*a).*(sqrt((u_x).^2 + (u_y).^2)).^(1/2); % Cooper
%tau_E = sqrt((mu.*u_x).^2 + (mu.*u_y).^2); %tau_E: effective stress[Pa] % Cooper

%%% Glen's effective viscosity
%%% Neelanjan October 2, 2026
tau_E = (D*a).*(sqrt((u_x).^2 + (u_y).^2)).^(p-1);

epsilon_E = sqrt((u_x/2).^2 + (u_y/2).^2); %epsilon_E: effective strain rate[1/s]

f_therm = 2*tau_E.*epsilon_E;

k1 = 9.828; %k1: conductivity preexponential[W/m*K]
k2 = 5.7; %k2: conductivity postexponential[1/K]
k = k1*exp(-k2*1e-3.*T);

% tau_T =@(y) (60./(max(xy(:,2))-y.*heaviside(905 - y))).*heaviside(905 - y); % Cooper

%%% uniform geothermal flux on the bed
tau_T =@(y) G_geo.*heaviside(901 - y);

F_therm = zeros(1,nN);
for E = 1:nE  % integration over each element
  nodes = t(E,:);
  xyE = [ones(3,1),xy(nodes,:)];
  Area = abs(det(xyE))/2;
  F_therm_E = f_therm(E)*Area/3*ones(1,3);
  F_therm(nodes) = F_therm(nodes) + F_therm_E;
end

T_old = T;
cvx_begin
cvx_quiet true
    variables T(nN)
    %Cooper %obj = sum((D*k).*tau_area.*pow_pos(norms([A*T,B*T],2,2),2)) - 2E10*F_therm*T/40 - sum(b_dx.*k(b).*tau_T(xy(b,2)).*T(b));
    
    %%% Standard Variational Formulation Neelanjan-Jenny October 2, 2026
    %%% 0.5 factor on the conduction term. no k(b) in the Geothermal heat
    %%% flux term because tau_T already specified in terms of G_geo.

    obj = 0.5*sum((D*k).*tau_area.*pow_pos(norms([A*T,B*T],2,2),2)) - F_therm*T - sum(b_dx.*tau_T(xy(b,2)).*T(b));
    subject to
        T <= 273;
        %T(xy(:,2) > max(xy(:,2))-10) == T_surfBC;
        T(xy(:,2) == max(xy(:,2))) == T_surfBC;
    minimize(obj)
cvx_end

if ~strcmp(cvx_status,'Solved'), error('Thermal solve: %s', cvx_status); end

res = norm(T-T_old)/norm(T);

fprintf('therm: %s | T in [%.2f, %.2f] K | res = %.2e\n', cvx_status, min(T), max(T), res);

%Cooper %disp(res)
end

%%% Neelanjan edits, October 8, 2026
mu = tau_E./(2*epsilon_E);              % model viscosity [Pa s] = (D*a).*|grad u|.^(p-2)
mu(epsilon_E == 0) = NaN;

% Independent Glen's-law viscosity (Eq. 6, E = 1), rebuilt from the constants.
% Fresh names: inside the loop A and E were overwritten by the gradient matrix and the element index.
A_glen = 3.5e-25; E_glen = 1;
P_h = rho*g*(y_max - xy(:,2));
Th = T_mech + p0*P_h;  Tsh = Tstar + p0*P_h;
Qh = zeros(nN,1);
Qh(heaviside(Th - Tsh) == 0) = Q2;
Qh(heaviside(Th - Tsh) == 1) = Q3;
Aprime = A_glen*E_glen*exp((-Qh./R).*((1./Th) - (1./Tsh)));
mu_Glen = 0.5*(D*Aprime.^(-1/3)).*epsilon_E.^(-2/3);   % eta = 1/2 A'^(-1/3) eps_E^(-2/3)
mu_Glen(epsilon_E == 0) = NaN;

ok = ~isnan(mu);
fprintf('max |mu/mu_Glen - 1| = %.2e\n', max(abs(mu(ok)./mu_Glen(ok) - 1)));

%%
u = u*secpy; %conversion from [m/s] to [m/yr]
T = T - 273; %conversion from K to deg. C

%% Visualization
x_base = xy(b(xy(b,2)<901),1);
y_base = xy(b(xy(b,2)<901),2);
u_base = u(b(xy(b,2)<901));

%% 2D speed map
figure;
trisurf(t,xy(:,1),xy(:,2),u,u,'edgecolor','none','facecolor','interp'); hold on
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

%% Ice Surface Speed profile
figure;
x_surf = xy(xy(:,2) > max(xy(:,2))-dx/100,1);
u_surf = u(xy(:,2) > max(xy(:,2))-dx/100);
plot(x_surf,u_surf, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',surfacespeed(5,:), ...
    'MarkerIndices', round(1 + [0 0.25 0.5 0.75 1]*(length(x_surf)-1))); hold on
axis([min(xy(:,1)),max(xy(:,1)),0,1.5*max(u)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Ice surface speed [m/yr]", FontSize=16)
legend
%% 2D Temperature Contour
figure('Position',[10 10 1000 200])
load iceColorMap
colormap(iceColorMap)
% tricontf(xy(:,1),xy(:,2),t,T,...
%          [0,-5,-10,-15,-20,-25]);
trisurf(t,xy(:,1),xy(:,2),T,T,...
       'edgecolor','none','facecolor','interp');
axis off
view(2)
xlabel("Lateral direction [m]", FontSize=16)
ylabel("Vertical direction [m]", FontSize=16)


%% Basal Drag formulation (without speed-multiplication)
% Coulomb-slip
basal_tau_c =@(x,u) heaviside(sed_l - x).*(Cf*N_bedrock) ...
                 + heaviside(sed_r - x).*heaviside(x - sed_l).* ...
                 ((N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_l)/W_max))+ ...
                 (N_canal_center-N_infi)*(1-erf(gamma_center*abs(x-X_canal_center)/W_max))+ ...
                 (N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_r)/W_max))+ ...
                 N_wfblip*exp(-abs(x-Xsuction)/delta)+N_infi) ...
                 + heaviside(x - sed_r).*(Cf*N_bedrock);

basal_tau_c_specific = basal_tau_c(x_base,u_base);

%% Basal Drag Profile
figure
plot(x_base,basal_tau_c_specific/1000, ...
    '-pentagram','LineWidth',3,'DisplayName','Q = 0.005 m^3/s','Color',basalstrength(5,:), ...
    'MarkerIndices', round(1 + [0 0.25 0.5 0.75 1]*(size(x_base,1)-1))); hold on

axis([min(x_base),max(x_base),0,1.1*max(basal_tau_c_specific/1000)])
setFontSize(14)
xlabel("Lateral direction, y [m]", FontSize=16)
ylabel("Basal drag [kPa]", FontSize=16)
legend
%% Area under the ice surface speed profile, and basal drag profile, for this case
IceFlux = trapz(x_surf,u_surf);
basaltauc = basal_tau_c_specific;

%% Save to .mat file
filepath = "ResultsMatFiles";
filename = fullfile(filepath,"TempBedG100mW_"+modeCase+".mat");
save(filename)
