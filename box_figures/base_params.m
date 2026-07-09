

function prm = base_params(fitResult, ps)
    prm               = struct;
    prm.rho300_uohmcm = fitResult.global.rho300_uohmcm;
    prm.alpha_TCR     = fitResult.alpha_TCR;
    prm.T_K           = fitResult.T_K;
    prm.lambda_nm     = fitResult.global.lambda_nm;
    prm.p             = ps.p;
    prm.R             = ps.R;
    prm.D_nm          = ps.D_nm;
    prm.tdead_nm      = ps.tdead_nm;
    prm.tq_nm         = fitResult.global.tq_nm;
    prm.Aq            = fitResult.global.Aq;
    prm.qexp          = 3;
end