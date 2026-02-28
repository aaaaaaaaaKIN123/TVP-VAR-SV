%%--------------------------------------------------------%%
%%                    TVP-VAR package                     %%
%%--------------------------------------------------------%%
%%
%%  files = drawimp3d(pair_list, opts)
%%
%%  "drawimp3d" draws 3D time-varying impulse responses from
%%  tvpvar_imp.xlsx using the same source format as drawimp.m.
%%
%%  [input]
%%    pair_list : m*2 matrix [shock_i, response_j]
%%                default: all nk^2 pairs
%%    opts (optional struct)
%%      .save_full      : export full figure (default 1)
%%      .save_panels    : export each panel (default 1)
%%      .outdir         : output root dir (default tvpvar_output/image/figure_3d)
%%      .layout_mode    : 'auto' | 'h_fast' | 't_fast' (default 'auto')
%%      .time_labels    : labels for y-axis (length = ns, optional)
%%      .view_az        : azimuth angle (default -125)
%%      .view_el        : elevation angle (default 24)
%%      .line_width     : mesh line width (default 0.45)
%%      .axes_font_size : axis font size (default 10)
%%      .tick_font_size : axis tick font size (default = axes_font_size)
%%      .label_font_size: x/y/z label font size (default = axes_font_size)
%%      .title_font_size: panel title font size (default 11)
%%      .colormap_name  : colormap name (default 'turbo')
%%
%%  [output]
%%    files.full   : full figure path
%%    files.panels : cell array of panel figure paths
%%

function files = drawimp3d(pair_list, opts)

global m_ns m_nk m_asvar;

ns = m_ns;
nk = m_nk;
exportRes = 600;

if nargin < 1 || isempty(pair_list)
  pair_list = all_pairs(nk);
end
if nargin < 2 || isempty(opts)
  opts = struct();
end
opts = apply_default_opts(opts);

if size(pair_list, 2) ~= 2
  error('drawimp3d:InvalidPairs', 'pair_list must be m*2 [shock, response].');
end
if any(pair_list(:) < 1) || any(pair_list(:) > nk)
  error('drawimp3d:PairOutOfRange', 'pair_list indices must be between 1 and nk.');
end
if ~isempty(opts.time_labels) && numel(opts.time_labels) ~= ns
  error('drawimp3d:InvalidTimeLabels', ...
        'opts.time_labels must have the same length as ns (%d).', ns);
end

fimp = 'tvpvar_imp.xlsx';
if exist(fimp, 'file') ~= 2
  fimp = fullfile('tvpvar_output', 'excel', 'tvpvar_imp.xlsx');
end
if exist(fimp, 'file') ~= 2
  error('drawimp3d:MissingImpulseFile', 'Unable to find impulse file: %s', fimp);
end

mimpr = readtable(fimp);
mimpr = table2array(mimpr);
mimpm = mimpr(3:end, 3:end);
outCols = mimpr(3:end, 1:2);

if mod(size(mimpm, 1), ns) ~= 0
  error('drawimp3d:InvalidMatrixSize', ...
        'IRF row count (%d) is not divisible by ns (%d).', size(mimpm, 1), ns);
end

hcol = outCols(:, 2);
vh = unique(hcol(~isnan(hcol)))';
vh = sort(vh);
nimp = numel(vh);
if nimp == 0
  nimp = size(mimpm, 1) / ns;
  vh = 0:nimp-1;
end

layoutMode = resolve_layout_mode(opts.layout_mode, hcol, ns, nimp);

if ~exist(opts.outdir, 'dir')
  mkdir(opts.outdir);
end
fullDir = fullfile(opts.outdir, 'full');
panelDir = fullfile(opts.outdir, 'panels');
if opts.save_full && ~exist(fullDir, 'dir')
  mkdir(fullDir);
end
if opts.save_panels && ~exist(panelDir, 'dir')
  mkdir(panelDir);
end

np = size(pair_list, 1);
nr = ceil(sqrt(np));
nc = ceil(np / nr);
figPos = get_maximized_position();
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', figPos);
ax = gobjects(np, 1);
panelPaths = cell(np, 1);

for p = 1:np
  shock = pair_list(p, 1);
  resp = pair_list(p, 2);
  id = (shock-1) * nk + resp;

  z = reshape_irf_series(mimpm(:, id), ns, nimp, layoutMode);
  if ~isempty(vh) && size(z, 2) == numel(vh)
    [xg, yg] = meshgrid(vh, 1:ns);
  else
    [xg, yg] = meshgrid(0:size(z, 2)-1, 1:ns);
  end

  ax(p) = subplot(nr, nc, p);
  mesh(xg, yg, z, 'LineWidth', opts.line_width);
  view(opts.view_az, opts.view_el);
  colormap(ax(p), get_cmap(opts.colormap_name));
  grid on
  box on
  set(ax(p), 'FontSize', opts.axes_font_size);

  ax(p).XAxis.FontSize = opts.tick_font_size;
  ax(p).YAxis.FontSize = opts.tick_font_size;
  ax(p).ZAxis.FontSize = opts.tick_font_size;

  xlabel('horizon', 'FontSize', opts.label_font_size);
  ylabel('time', 'FontSize', opts.label_font_size);
  zlabel('IRF', 'FontSize', opts.label_font_size);
  if ~isempty(opts.time_labels)
    apply_time_labels(ax(p), opts.time_labels);
  end

  title(sprintf('$\\varepsilon_{%s}\\uparrow\\rightarrow %s$', ...
        char(m_asvar(shock)), char(m_asvar(resp))), ...
        'Interpreter', 'latex', 'FontSize', opts.title_font_size);
end

files = struct('full', '', 'panels', {panelPaths});

if opts.save_full
  files.full = fullfile(fullDir, 'impulse_3d_full.png');
  exportgraphics(fig, files.full, 'Resolution', exportRes);
end

if opts.save_panels
  for p = 1:np
    shock = pair_list(p, 1);
    resp = pair_list(p, 2);
    panelPaths{p} = fullfile(panelDir, sprintf('impulse_3d_shock%d_resp%d.png', shock, resp));
    exportgraphics(ax(p), panelPaths{p}, 'Resolution', exportRes);
  end
end
files.panels = panelPaths;
end

function z = reshape_irf_series(vec, ns, nimp, layoutMode)
vec = vec(:);
if strcmp(layoutMode, 't_fast')
  z = reshape(vec, ns, nimp);
else
  z = reshape(vec, nimp, ns)';
end
end

function mode = resolve_layout_mode(layoutMode, hcol, ns, nimp)
if ~any(strcmp(layoutMode, {'auto', 'h_fast', 't_fast'}))
  error('drawimp3d:InvalidLayoutMode', ...
        'opts.layout_mode must be auto, h_fast, or t_fast.');
end
if ~strcmp(layoutMode, 'auto')
  mode = layoutMode;
  return;
end

h = hcol(~isnan(hcol));
if numel(h) >= nimp
  v = sort(unique(h))';
  if isequal(h(1:nimp)', v)
    mode = 'h_fast';
    return;
  end
end
if numel(h) >= ns && numel(unique(h(1:ns))) == 1
  mode = 't_fast';
  return;
end
mode = 'h_fast';
end

function cmap = get_cmap(name)
try
  cmap = feval(name, 256);
catch
  cmap = parula(256);
end
end

function apply_time_labels(ax, labels)
step = max(1, floor(numel(labels) / 10));
yt = 1:step:numel(labels);
set(ax, 'YTick', yt);
if isnumeric(labels)
  ylab = arrayfun(@(x) sprintf('%g', x), labels(yt), 'UniformOutput', false);
else
  ylab = cellstr(string(labels(yt)));
end
set(ax, 'YTickLabel', ylab);
end

function pairs = all_pairs(nk)
pairs = zeros(nk*nk, 2);
id = 1;
for i = 1:nk
  for j = 1:nk
    pairs(id, :) = [i, j];
    id = id + 1;
  end
end
end

function opts = apply_default_opts(opts)
if ~isfield(opts, 'save_full')
  opts.save_full = 1;
end
if ~isfield(opts, 'save_panels')
  opts.save_panels = 1;
end
if ~isfield(opts, 'outdir') || isempty(opts.outdir)
  opts.outdir = fullfile('tvpvar_output', 'image', 'figure_3d');
end
if ~isfield(opts, 'layout_mode') || isempty(opts.layout_mode)
  opts.layout_mode = 'auto';
end
if ~isfield(opts, 'time_labels')
  opts.time_labels = [];
end
if ~isfield(opts, 'view_az') || isempty(opts.view_az)
  opts.view_az = -125;
end
if ~isfield(opts, 'view_el') || isempty(opts.view_el)
  opts.view_el = 24;
end
if ~isfield(opts, 'line_width') || isempty(opts.line_width)
  opts.line_width = 0.45;
end
if ~isfield(opts, 'axes_font_size') || isempty(opts.axes_font_size)
  opts.axes_font_size = 10;
end
if ~isfield(opts, 'tick_font_size') || isempty(opts.tick_font_size)
  opts.tick_font_size = opts.axes_font_size;
end
if ~isfield(opts, 'label_font_size') || isempty(opts.label_font_size)
  opts.label_font_size = opts.axes_font_size;
end
if ~isfield(opts, 'title_font_size') || isempty(opts.title_font_size)
  opts.title_font_size = opts.axes_font_size + 1;
end
if ~isfield(opts, 'colormap_name') || isempty(opts.colormap_name)
  opts.colormap_name = 'turbo';
end
end

function figPos = get_maximized_position()
figPos = [1 1 1920 1080];
try
  scr = get(groot, 'ScreenSize');
  if numel(scr) == 4 && all(isfinite(scr)) && scr(3) > 200 && scr(4) > 200
    figPos = [1 1 floor(scr(3)) floor(scr(4))];
  end
catch
  % keep fallback
end
end
