function tests = test_drawimp_vt_shapes
% Regression tests for drawimp accepting row and column vt vectors.
tests = functiontests(localfunctions);
end

function testRowAndColumnVectorsInBothDrawModes(testCase)
repoRoot = fileparts(fileparts(mfilename('fullpath')));
wasOnPath = any(strcmp(strsplit(path, pathsep), repoRoot));
addpath(repoRoot);

originalDir = pwd;
testDir = tempname;
mkdir(testDir);
oldFigureVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
cleanup = onCleanup(@() restoreTestEnvironment( ...
  originalDir, testDir, oldFigureVisibility, repoRoot, wasOnPath)); %#ok<NASGU>
cd(testDir);

global m_ns m_nk m_nl m_asvar;
m_ns = 3;
m_nk = 1;
m_nl = 0;
m_asvar = {'y'};

% drawimp reads rows 3:end and columns 3:end from this workbook.
fixture = array2table(reshape(1:33, 11, 3), ...
  'VariableNames', {'meta1', 'meta2', 'ir'});
writetable(fixture, 'tvpvar_imp.xlsx');

for fldraw = 0:1
  for isColumn = 0:1
    if fldraw == 1
      vtRow = [0, 2]; % zero-based horizons, indexed as vt + 1
    else
      vtRow = [1, 3]; % one-based time points
    end
    if isColumn
      vt = vtRow.';
    else
      vt = vtRow;
    end

    opts = struct();
    opts.vt_labels = {'early', 'late'};
    drawimp(vt, fldraw, opts);

    fig = gcf;
    closeFigure = onCleanup(@() close(fig)); %#ok<NASGU>
    legends = findall(fig, 'Type', 'legend');
    verifyNumElements(testCase, legends, 1);
    labels = strtrim(cellstr(legends(1).String));
    if fldraw == 1
      verifyTrue(testCase, contains(labels{1}, 'early'));
      verifyTrue(testCase, contains(labels{1}, '-period ahead'));
      verifyTrue(testCase, contains(labels{2}, 'late'));
      verifyTrue(testCase, contains(labels{2}, '-period'));
    else
      verifyEqual(testCase, labels, {'t=early', 't=late'});
    end
    clear closeFigure
  end
end
end

function restoreTestEnvironment(originalDir, testDir, oldFigureVisibility, repoRoot, wasOnPath)
close all;
set(groot, 'defaultFigureVisible', oldFigureVisibility);
cd(originalDir);
if ~wasOnPath
  rmpath(repoRoot);
end
if exist(testDir, 'dir') == 7
  rmdir(testDir, 's');
end
global m_ns m_nk m_nl m_asvar;
m_ns = [];
m_nk = [];
m_nl = [];
m_asvar = [];
end
