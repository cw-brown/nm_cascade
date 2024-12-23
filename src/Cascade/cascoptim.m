function [s, result, fval, flag] = cascoptim(sz, startfreq, stopfreq, nfreq, errfunc, maxeval, ispar)
    %% Optimize the nxm grid.
    freqs = logspace(startfreq, stopfreq, nfreq);
    ports = fpg(sz); ports = ports(2:end-1);
    nvars = 2*sum((ports.^2+ports)/2)*nfreq;
    
    if ispar == true
        try
            pool = parpool();
        catch
            pool = gcp();
        end
    end
    obj = @(x)cascadeobj(x, freqs, sz, errfunc);
    constr = @(x)lprestr(x, freqs, sz);
    options = optimoptions("fmincon", "Display", "none", "MaxFunctionEvaluations", maxeval, "UseParallel", ispar);
    lb = -ones(1, nvars); ub = ones(1, nvars);
    [result, fval, flag, ~] = fmincon(obj, rand(1, nvars), [], [], [], [], lb, ub, constr, options);
    s_params = l2casc(num2sparam(result, freqs, sz), freqs, sz);
    s = sparameters(s_params, freqs);
end