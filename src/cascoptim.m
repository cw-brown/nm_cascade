function [s, result, fval, flag] = cascoptim(sz, startfreq, stopfreq, nfreq, errfunc, ispar)
    %% Optimize the nxm grid.
    freqs = linspace(startfreq, stopfreq, nfreq);
    ports = fpg(sz); ports = ports(2:end-1);
    nvars = 2*sum((ports.^2+ports)/2)*nfreq;
    
    if ispart == true
        pool = parpool();
    end
    obj = @(x)cascadeobj(x, freqs, sz, errfunc);
    constr = @(x)lprestr(x, freqs, sz);
    options = optimoptions("fmincon", "Display", "none", "MaxFunctionEvaluations", 1e5, "UseParallel", ispar);
    lb = -ones(1, nvars); ub = ones(1, nvars);
    [result, fval, flag, ~] = fmincon(obj, rand(1, nvars), [], [], [], [], lb, ub, constr, options);
    s = l2casc(num2sparam(result, freqs, sz), freqs, sz);
    if ispart == true
        delete(pool);
    end
end