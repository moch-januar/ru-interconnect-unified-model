function fitPick = pick_fit(ablFits, fieldName, fallback)
    fitPick = fallback;
    if ~isempty(ablFits) && isstruct(ablFits) && isfield(ablFits, fieldName)
        fitPick = ablFits.(fieldName);
    end
end