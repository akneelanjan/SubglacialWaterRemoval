%% Parameters for 2 side canals and On-Target flowrate reduction in central Linked Cavity
clear all; clc
%%
addpath(fullfile("..","cbrewer2"));

% Cbrewer2 colorscales, perceptually uniform, color-blind friendly
surfacespeed = cbrewer2('seq','Blues',5);
basalstrength = cbrewer2('seq','Blues',5);

%%
alpha = 0.0275; % for Linked Cavity
Q = '0.010'; % Linked Cavity flowrate [m^3/s]

sed_l = 0.8e3; % Rock-sediment interface on the left
sed_r = 1.2e3; % Rock-sediment interface on the right
N_bedrock = 100e3; % [100 kPa] % Film Effective pressure at the Ice-Bedrock contact
Cf = 0.1; % Sliding Coefficient
As = 10e3; % [m yr^(-1) MPa^(-3)] % Hard-bed drag parameter
u_0 = As*((0.01)^3); % [m yr^-1] % Threshold to verify Coulomb-Slip regime

N_wf = 4e3; %[in kPa] % Sediment Cohesion

% Canal parameters
N_infi = 4e3; % far-field effective pressure away from canal [Pa]
N_canal_side = 50e3; % Side Canal effective pressure [Pa]
gamma_side = 0.2; % spatial scale parameter for side Canals

% N_canal = {50,100,150,200} [kPa] corresponding to flowrates:
% Q = {0.005,0.004,0.0025,0.002} [m^3/s] (baseline, 20% flowrate reduction, 50% flowrate reduction, 60% flowrate reduction)

a_canal = -0.118/1000; % [m/Pa] from Damsgaard et. al. 2017
b_canal = 4.6; % [m] from Damsgaard et. al. 2017
W_max = a_canal*N_infi + b_canal; % Maximum width of canal, [m], from Damsgaard et. al. 2017

X_canal_sed_l = 0.8e3+20; % Location of side canal on the left
X_canal_sed_r = 1.2e3-20; % Location of side canal on the right

% Linked Cavity parameters
N_lc = 250e3; % Linked Cavity Effective Pressure [Pa]
%250 kPa for 0.010 m3/s (Baseline), 500 kPa for 0.005 m3/s (50% flowrate reduction)

L1 = 1e3; % [m] Location of Linked Cavity (center of the bed)
sigma = 1; % [m] Spatial scale of Linked Cavity (scale of the Gaussian distribution for the local rise in basal strength)

% Basal-drag, tau_bed formulation as per Coulomb-Slip on hard-bedrock
basal_tau_c =@(x,u) heaviside(sed_l - x).*(Cf*N_bedrock) ...
                 + heaviside(sed_r - x).*heaviside(x - sed_l).* ...
                 ((N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_l)/W_max))+ ...
                  ((N_lc-N_wf)*exp(-((x-L1).^2)/sigma^2)+N_wf)+ ...
                  (N_canal_side-N_infi)*(1-erf(gamma_side*abs(x-X_canal_sed_r)/W_max))) ...
                 + heaviside(x - sed_r).*(Cf*N_bedrock);
% original (without speed multiplied)

tau_c =@(x,y,u) (heaviside(sed_l - x).*(Cf*N_bedrock).*abs(u) ...
                 + heaviside(sed_r - x).*heaviside(x - sed_l).* ...
                 ((N_canal_side-N_wf)*(1-erf(gamma_side*abs(x-X_canal_sed_l)/W_max))+ ...
                 (N_lc-N_wf)*exp(-((x-L1).^2)/sigma^2)+ ...
                 (N_canal_side-N_wf)*(1-erf(gamma_side*abs(x-X_canal_sed_r)/W_max))+ ...
                 N_wf).*abs(u) ...
                 + heaviside(x - sed_r).*(Cf*N_bedrock).*abs(u) ...
                 ).*heaviside(905 - y);
% with speed multiplied


% Ice surface speed plot legend color
surfaceSpeedColor = surfacespeed(5,:);

% Basal strength plot legend color
basalStrengthColor = basalstrength(5,:);

%% save parameters in a file
filename = fullfile("..","InputParameterFiles","LinkedCavity_"+string(N_lc/1000)+"kPa.mat");   
save(filename)