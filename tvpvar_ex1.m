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

out_root = 'tvpvar_output';
run_img_dir = fullfile(out_root, 'image');
src_excel_dir = fullfile(out_root, 'excel');

imp_opts = struct('save_full', 1, 'save_panels', 1, 'outdir', run_img_dir, ...
                  'axes_font_size', 11, 'legend_font_size', 11, ...
                  'title_font_size', 14);

drawimp([4 8 12], 1, imp_opts); % draw impulse response(1)
                             % : 4-,8-,12-period ahead (legend shown on all panels)

imp_opts.vt_labels = [1 2 3];
drawimp([30 60 90], 0, imp_opts); % draw impulse response(2)
                                  % : response at t=30,60,90 (legend label: 1,2,3 on all panels)

export_results_images(fullfile(run_img_dir, 'summary'), src_excel_dir);
fprintf('\n[tvpvar_ex1] output dirs: %s | %s\n', src_excel_dir, run_img_dir);
