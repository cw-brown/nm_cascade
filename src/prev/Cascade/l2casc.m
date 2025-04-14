function s = l2casc(s_params, freqs, sz)
    %% Cascade a grid of s_parameter black boxes at multiple frequencies
    s = zeros(2, 2, length(freqs));
    nnets = sz(1)*sz(2)+2;
    ports = fpg(sz);
    nwaves = sum(ports);

    % Calculate topology matrix and constants
    gamma = topology(sz);
    c1 = zeros(nwaves, 1); c1(1) = 1;
    c2 = zeros(nwaves, 1); c2(end) = 1;

    for ff = 1:length(freqs)
        v = zeros(1, sum(ports.^2)-2); i = v; j = v;
        offset = 1;
        % Build the S diagonal matrix
        for ii = 2:nnets-1
            [p, q] = meshgrid(1:ports(ii), 1:ports(ii));
            startpos = sum(ports(1:ii-1)) + 1;
            s_cell = s_params{ii-1};
            v(offset:offset+ports(ii)^2-1) = s_cell(:,:,ff)';
            i(offset:offset+ports(ii)^2-1) = startpos + p(:) - 1;
            j(offset:offset+ports(ii)^2-1) = startpos + q(:) - 1;
            offset = sum(ports(1:ii).^2);
        end
        s_block = sparse(i, j, v, nwaves, nwaves);
        W = gamma-s_block;
        a_1 = W\c1;
        a_2 = W\c2;
        b_1 = gamma*a_1;
        b_2 = gamma*a_2;
        s(:, :, ff) = [a_1(1)/b_1(1) a_2(1)/b_2(end); a_1(end)/b_1(1) a_2(end)/b_2(end)];
    end
end