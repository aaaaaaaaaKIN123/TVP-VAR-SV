%%--------------------------------------------------------%%
%%                    TVP-VAR package                     %%
%%--------------------------------------------------------%%
%%
%%  [] = drawimp(vt, fldraw, opts)
%%
%%  "drawimp" draws time-varying impulse response
%%
%%  [input]
%%   (fldraw = 1)
%%     vt:   m*1 vector of horizons to draw impulse
%%   (fldraw = 0)
%%     vt:   m*1 vector of time points to draw impulse
%%   opts (optional struct)
%%     .save_full   : export full impulse figure (default 0)
%%     .save_panels : export each subplot panel (default 0)
%%     .outdir      : output root dir for exported images
%%

function [] = drawimp(vt, fldraw, opts)

global m_ns m_nk m_nl m_asvar;

ns = m_ns;
nk = m_nk;
nl = m_nl;
exportRes = 600;

if nargin < 3 || isempty(opts)
  opts = struct();
end
if ~isfield(opts, 'save_full')
  opts.save_full = 0;
end
if ~isfield(opts, 'save_panels')
  opts.save_panels = 0;
end
if ~isfield(opts, 'outdir') || isempty(opts.outdir)
  opts.outdir = fullfile('tvpvar_output', 'images');
end

fimp = 'tvpvar_imp.xlsx';
if exist(fimp, 'file') ~= 2
  fimp = fullfile('tvpvar_output', 'excel', 'tvpvar_imp.xlsx');
end
if exist(fimp, 'file') ~= 2
  error('drawimp:MissingImpulseFile', ...
        'Unable to find impulse file: %s', fimp);
end

mimpr = readtable(fimp);
mimpr = table2array(mimpr);
mimpm = mimpr(3:end, 3:end);

nimp = fix(size(mimpm, 1) / m_ns);
mline = [0 .5 0; 0 0 1; 1 0 0; 0 .7 .7];
vline = {':', '--', '-', '-.'};
nline = size(vt, 2);

figPos = get_maximized_position();
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', figPos);
ax = gobjects(nk * nk, 1);
for i = 1 : nk
  for j = 1 : nk
    id = (i-1)*nk + j;
    mimp = reshape(mimpm(:, id), nimp, ns)';
    ax(id) = subplot(nk, nk, id);

    if fldraw == 1

      for k = 1 : nline
        plot(mimp(:, vt(k)+1), char(vline(k)), ...
             'Color', mline(k, :), 'LineWidth', 1.2)
        hold on
      end
      vax = axis;
      axis([nl+1 ns+1 vax(3:4)])
      if vax(3) * vax(4) < 0
        line([nl+1, ns+1], [0, 0], 'Color', ones(1,3)*0.6)
      end
      if id == 1
        vlege = '-period ahead';
        for l = 2 : nline
          vlege = [vlege; '-period      ']; %#ok<AGROW>
        end
        legend([num2str(vt') vlege], 'Location', 'best')
      end

    else

      for k = 1 : nline
        plot(0:nimp-1, mimp(vt(k), :), char(vline(k)), ...
             'Color', mline(k, :), 'LineWidth', 1.2)
        hold on
      end
      vax = axis;
      axis([0 nimp-1 vax(3:4)])
      if vax(3) * vax(4) < 0
        line([0, nimp-1], [0, 0], 'Color', ones(1,3)*0.6)
      end
      if id == 1
        vlege = 't=';
        for l = 2 : nline
          vlege = [vlege; 't=']; %#ok<AGROW>
        end
        legend([vlege num2str(vt')], 'Location', 'best')
      end

    end

    hold off
    grid on
    title(['$\varepsilon_{', char(m_asvar(i)), ...
           '}\uparrow\ \rightarrow\ ', ...
           char(m_asvar(j)), '$'], 'interpreter', 'latex')

  end
end

if opts.save_full || opts.save_panels
  if ~exist(opts.outdir, 'dir')
    mkdir(opts.outdir);
  end
  fullDir = fullfile(opts.outdir, 'figure_full');
  panelDir = fullfile(opts.outdir, 'figure_panels');
  if opts.save_full && ~exist(fullDir, 'dir')
    mkdir(fullDir);
  end
  if opts.save_panels && ~exist(panelDir, 'dir')
    mkdir(panelDir);
  end

  vtstr = sprintf('_%g', vt);
  if fldraw == 1
    prefix = ['imp_fldraw1_h' strrep(vtstr(2:end), '_', '_h')];
  else
    prefix = ['imp_fldraw0_t' strrep(vtstr(2:end), '_', '_t')];
  end

  if opts.save_full
    exportgraphics(fig, fullfile(fullDir, [prefix '_full.png']), ...
                   'Resolution', exportRes);
  end

  if opts.save_panels
    for id = 1:(nk*nk)
      i = ceil(id / nk);
      j = mod(id-1, nk) + 1;
      panelPath = fullfile(panelDir, ...
        sprintf('%s_shock%d_resp%d.png', prefix, i, j));
      exportgraphics(ax(id), panelPath, 'Resolution', exportRes);
    end
  end
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
