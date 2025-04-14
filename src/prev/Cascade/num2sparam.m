function s_params = num2sparam(num, freqs, sz)
    %% Helper function to generate s_param cells from variables
    ports = fpg(sz); ports = ports(2:end-1);
    nvars = 2*sum((ports.^2 + ports)/2)*length(freqs);
    s_params = cell(1, length(ports));
    realx = num(1:nvars/2);
    imagx = num(nvars/2+1:end);
    st = 1;
    for i = 1:length(ports)
        s_params{i} = zeros(ports(i), ports(i), length(freqs));
        nwav = (ports(i)^2 + ports(i))/2;
        for f = 0:length(freqs)-1
            rx = realx((st:st+nwav-1));
            ix = imagx((st:st+nwav-1));
            inter = s_params{i};
            start = 1;
            arr = zeros(ports(i));
            for k = 1:ports(i)
                totake = ports(i) - k + 1;
                arr = arr + diag(rx(start:start+totake-1)+1j*ix(start:start+totake-1), k-1);
                start = start + totake;
            end
            st = st+nwav;
            arr = arr + triu(arr, 1)';
            inter(:, :, f+1) = arr;
            s_params{i} = inter;
        end
    end
end