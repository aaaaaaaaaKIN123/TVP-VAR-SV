%%--------------------------------------------------------%%
%%                     tvpvar_ex1.m                       %%
%%--------------------------------------------------------%%

%%
%%  MCMC estimation for Time-Varying Parameter VAR model
%%  with stochastic volatility
%%
%%  tvpvar_ex*.m illustrates MCMC estimation
%%  using TVP-VAR Package
%%  (Data: "tvpvar_ex.xlsx")
%%

warning('off');
clear;
close all;
clc;

my = readtable('tvpvar_ex.xlsx');  % load data
my = table2array(my);

asvar = {'p'; 'x'; 'i'};    % variable names
nlag = 4;                   % # of lags

setvar('data', my, asvar, nlag); % set data

setvar('fastimp', 1);       % fast computing of response

mcmc(1000);                % MCMC

run_tag = datestr(now, 'yyyymmdd_HHMMSS');
run_dir = fullfile('tvpvar_output', ['run_' run_tag]);
run_img_dir = fullfile(run_dir, 'images');
run_excel_dir = fullfile(run_dir, 'excel');
if ~exist(run_excel_dir, 'dir')
    mkdir(run_excel_dir);
end

% snapshot mcmc excel outputs for this run
src_excel_dir = fullfile('tvpvar_output', 'excel');
excel_files = {'tvpvar_vol.xlsx', 'tvpvar_a.xlsx', 'tvpvar_ai.xlsx', ...
               'tvpvar_int.xlsx', 'tvpvar_imp.xlsx'};
for i = 1:numel(excel_files)
    src = fullfile(src_excel_dir, excel_files{i});
    if exist(src, 'file') == 2
        copyfile(src, fullfile(run_excel_dir, excel_files{i}));
    end
end

imp_opts = struct('save_full', 1, 'save_panels', 1, 'outdir', run_img_dir);

drawimp([4 8 12], 1, imp_opts); % draw impulse response(1)
                             % : 4-,8-,12-period ahead (legend shown on all panels)

imp_opts.vt_labels = [1 2 3];
drawimp([30 60 90], 0, imp_opts); % draw impulse response(2)
                                  % : response at t=30,60,90 (legend label: 1,2,3 on all panels)

export_results_images(fullfile(run_img_dir, 'summary'), run_excel_dir);
fprintf('\n[tvpvar_ex1] run_dir: %s\n', run_dir);
