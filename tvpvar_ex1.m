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

img_dir = fullfile('tvpvar_output', 'image');

imp_opts = struct('save_full', 1, 'save_panels', 1, 'outdir', img_dir);

drawimp([4 8 12], 1, imp_opts); % draw impulse response(1)
                             % : 4-,8-,12-period ahead (legend shown on all panels)

imp_opts.vt_labels = [1 2 3];
drawimp([30 60 90], 0, imp_opts); % draw impulse response(2)
                                  % : response at t=30,60,90 (legend label: 1,2,3 on all panels)

export_results_images(fullfile(img_dir, 'summary'));
fprintf('\n[tvpvar_ex1] output_dir: %s\n', fullfile('tvpvar_output'));
