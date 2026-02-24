# Example Test Attempt Log

Date: 2026-02-24

## Goal
Run the repository examples (`tvpvar_ex1.m`, `tvpvar_ex2.m`) and capture output.

## Commands attempted

1. Check for GNU Octave:

```bash
octave --version | head -n 1
```

Result: `bash: command not found: octave`

2. Check for MATLAB:

```bash
matlab -batch "disp('ok')"
```

Result: `bash: command not found: matlab`

## Conclusion
This environment does not have MATLAB or GNU Octave installed, so the `.m` examples cannot be executed here.

## How to run locally
From the repository root in MATLAB:

```matlab
tvpvar_ex1
tvpvar_ex2
```
