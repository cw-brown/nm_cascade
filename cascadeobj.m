function f = cascadeobj(x, freqs, sz, errorfunc)
    %% Build the variables into something parsable and then find the error
    s_params = num2sparam(x, freqs, sz);
    s = l2casc(s_params, freqs, sz);
    s12 = db(s(1, 2, :));
    f = sqrt(mean((s12(:)' - errorfunc).^2));
end