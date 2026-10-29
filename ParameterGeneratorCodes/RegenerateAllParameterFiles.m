function RegenerateAllParameterFiles
% Regenerates every input-parameter .mat file in one run, without editing the
% generator scripts. For each case, the generator's text is read, its active
% assignment lines are replaced with the case values, its cbrewer colour index
% is set, 'clear all' is removed, and the result is run from a temporary file
% in the generators' folder (so their relative paths still work).
%
% Place this file in the same folder as the CreateParameterMATFiles_*.m scripts.
% The driver stops with an error if a variable name below is not found as an
% active (uncommented) assignment in that generator.
%
% Colour convention: baseline 5, 20% reduction 4, 50% reduction 3.

here = fileparts(mfilename('fullpath'));

%   generator file                          variable assignments (name, value)                    colour
cases = {
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','50e3';    'Q','''0.005'''},     5
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','100e3';   'Q','''0.00395'''},     4
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','150e3';   'Q','''0.0025'''},     3
    % matched-rate on-target canal cases for the off-target comparison (dQ = 0.5, 1 L/min)
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','50.44e3'; 'Q','''0.004992'''},    4
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','50.89e3'; 'Q','''0.004983'''},    3
    % wider central canal (gamma_center = 0.1), from the canal generator saved as CenterCanalWider_*; alpha locked (100.10 m/yr baseline)
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','50e3';    'Q','''0.005'''; 'gamma_center','0.1'; 'alpha','0.02439'; 'filename','fullfile("..","InputParameterFiles","CenterCanalWider_"+string(N_canal_center/1000)+"kPa.mat")'},   5
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','100e3';   'Q','''0.00395'''; 'gamma_center','0.1'; 'alpha','0.02439'; 'filename','fullfile("..","InputParameterFiles","CenterCanalWider_"+string(N_canal_center/1000)+"kPa.mat")'},   4
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','150e3';   'Q','''0.0025'''; 'gamma_center','0.1'; 'alpha','0.02439'; 'filename','fullfile("..","InputParameterFiles","CenterCanalWider_"+string(N_canal_center/1000)+"kPa.mat")'},   3
    % central canal only, no side canals (Fig. S5): side-canal strength set to the far field; alpha locked (100.25 m/yr baseline)
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','50e3';    'Q','''0.005'''; 'N_canal_side','N_infi'; 'alpha','0.02276'; 'filename','fullfile("..","InputParameterFiles","Only1CentralCanal_"+string(N_canal_center/1000)+"kPa.mat")'},   5
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','100e3';   'Q','''0.00395'''; 'N_canal_side','N_infi'; 'alpha','0.02276'; 'filename','fullfile("..","InputParameterFiles","Only1CentralCanal_"+string(N_canal_center/1000)+"kPa.mat")'},   4
    'CreateParameterMATFiles_Canal.m',             {'N_canal_center','150e3';   'Q','''0.0025'''; 'N_canal_side','N_infi'; 'alpha','0.02276'; 'filename','fullfile("..","InputParameterFiles","Only1CentralCanal_"+string(N_canal_center/1000)+"kPa.mat")'},   3
    % shared downstream slope (Fig. S9): every mode at the canal's alpha = 0.02383 (canal cases reuse Canal_*kPa)
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','N_wf';           'Q','''Q_0''';       'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_WaterFilm_"+string(floor(N_wfmod))+"Pa.mat")'},     5
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','5*N_wf/4';       'Q','''0.512 Q_0''';   'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_WaterFilm_"+string(floor(N_wfmod))+"Pa.mat")'},     3
    'CreateParameterMATFiles_LinkedCavity.m',      {'N_lc','250e3';             'Q','''0.010''';     'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_LinkedCavity_"+string(N_lc/1000)+"kPa.mat")'},     5
    'CreateParameterMATFiles_LinkedCavity.m',      {'N_lc','500e3';             'Q','''0.005''';     'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_LinkedCavity_"+string(N_lc/1000)+"kPa.mat")'},     3
    'CreateParameterMATFiles_RChannel.m',          {'N_ch','550e3';             'Q','''0.086''';     'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_RChannel_"+string(N_ch/1000)+"kPa.mat")'},         5
    'CreateParameterMATFiles_RChannel.m',          {'N_ch','520e3';             'Q','''0.043''';     'alpha','0.02383'; 'filename','fullfile("..","InputParameterFiles","SameSlope_RChannel_"+string(N_ch/1000)+"kPa.mat")'},         3
    'CreateParameterMATFiles_LinkedCavity.m',      {'N_lc','250e3';             'Q','''0.010'''},       5
    'CreateParameterMATFiles_LinkedCavity.m',      {'N_lc','500e3';             'Q','''0.005'''},       3
    'CreateParameterMATFiles_RChannel.m',          {'N_ch','550e3';             'Q','''0.086'''},       5
    'CreateParameterMATFiles_RChannel.m',          {'N_ch','520e3';             'Q','''0.043'''},       3
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','N_wf'; 'Q','''Q_0'''},                5
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','10*N_wf/9'; 'Q','''0.729 Q_0'''},          4
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','5*N_wf/4'; 'Q','''0.512 Q_0'''},          3
    'CreateParameterMATFiles_WaterFilm.m',         {'N_wfmod','2*N_wf'; 'Q','''0.125 Q_0'''},          2
};

tmpFile = fullfile(here, 'tmp_regen_param.m');
for k = 1:size(cases,1)
    gen = cases{k,1}; assigns = cases{k,2}; colour = cases{k,3};
    src = fileread(fullfile(here, gen));

    for j = 1:size(assigns,1)
        pat = ['^(\s*' assigns{j,1} '\s*=)[^;\n]*;'];
        if isempty(regexp(src, pat, 'once', 'lineanchors'))
            error('Case %d: no active assignment of %s in %s', k, assigns{j,1}, gen);
        end
        src = regexprep(src, pat, ['$1 ' strrep(assigns{j,2}, '$', '\$') ';'], 'once', 'lineanchors');
    end

    src = regexprep(src, 'surfacespeed\(\s*\d+\s*,\s*:\s*\)', sprintf('surfacespeed(%d,:)', colour));
    src = regexprep(src, 'basalstrength\(\s*\d+\s*,\s*:\s*\)', sprintf('basalstrength(%d,:)', colour));
    src = regexprep(src, 'clear\s+all\s*;?', '');

    fid = fopen(tmpFile, 'w'); fwrite(fid, src); fclose(fid);
    clear('tmp_regen_param');           % make MATLAB re-read the temporary file
    oldDir = cd(here);
    try
        runInOwnWorkspace(tmpFile);
    catch err
        cd(oldDir); delete(tmpFile); rethrow(err);
    end
    cd(oldDir);
    fprintf('Case %d done: %s | %s | colour %d\n', k, gen, ...
        strjoin(cellfun(@(n,v) [n ' = ' v], assigns(:,1), assigns(:,2), 'UniformOutput', false), ', '), colour);
end
delete(tmpFile);
end

function runInOwnWorkspace(f)
% Each generator runs in this function's workspace, discarded afterwards.
run(f);
end
