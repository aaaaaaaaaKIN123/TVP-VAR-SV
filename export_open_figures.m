%%--------------------------------------------------------%%
%%                    TVP-VAR package                     %%
%%--------------------------------------------------------%%
%%
%%  files = export_open_figures(outdir, prefix)
%%
%%  Export all currently open MATLAB figures to PNG files.
%%
%%  [input]
%%    outdir: output directory (optional, default: 'tvpvar_images')
%%    prefix: filename prefix (optional, default: 'figure')
%%
%%  [output]
%%    files: cell array of exported file paths
%%

function files = export_open_figures(outdir, prefix)

if nargin < 1 || isempty(outdir)
    outdir = 'tvpvar_images';
end
if nargin < 2 || isempty(prefix)
    prefix = 'figure';
end

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

hfig = findall(0, 'Type', 'figure');
if isempty(hfig)
    files = {};
    fprintf('[export_open_figures] no open figures found.\n');
    return;
end

% Sort by figure number for deterministic naming/order
figNums = arrayfun(@(h) h.Number, hfig);
[~, idx] = sort(figNums, 'ascend');
hfig = hfig(idx);

files = cell(length(hfig), 1);
for i = 1:length(hfig)
    outpath = fullfile(outdir, sprintf('%s_%02d.png', prefix, i));
    exportgraphics(hfig(i), outpath, 'Resolution', 180);
    files{i} = outpath;
    fprintf('[ok] figure #%d -> %s\n', hfig(i).Number, outpath);
end

fprintf('[export_open_figures] exported %d figure(s).\n', length(files));
end
