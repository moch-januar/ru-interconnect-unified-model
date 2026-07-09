function ensure_dir(dirpath)
%ENSURE_DIR Create directory if it does not exist.
%   ensure_dir(dirpath) creates the directory specified by dirpath,
%   including parent directories as needed. No error if it already exists.

if ~exist(dirpath, 'dir')
    mkdir(dirpath);
end
end
