function ax = customplotrfvs(s1, s2, s1name, s2name, normFreq, figName)
%% Custom plot two s-parameters against each other in a grid
    arguments
        s1 sparameters
        s2 sparameters
        s1name (1,:) string
        s2name (1,:) string
        normFreq logical
        figName (1,:) string = ''
    end
    % Validate that the two networks are the same size and same frequency
    if s1.NumPorts ~= s2.NumPorts
        error('Networks must be the same size');
    elseif ~all(s1.Frequencies == s2.Frequencies)
        error('Frequencies must be the same for both networks');
    end
    if nargin == 5; figure("Name",figName,"NumberTitle","off"); else; figure; end
    n = s1.NumPorts;
    if normFreq; freqs=s1.Frequencies/max(s1.Frequencies); else; freqs=s1.Frequencies; end
    h1 = s1.Parameters;
    h2 = s2.Parameters;
    for ii = 1:n^2
        [i,j] = ind2sub([n,n],ii);
        subplot(n,n,ii);
        plot(freqs, db(squeeze(h1(i,j,:))),LineWidth=1.5);
        hold on; grid on;
        plot(freqs, db(squeeze(h2(i,j,:))),LineWidth=1.5,Color='r',LineStyle='--');
        title(['S_' num2str(i) '_' num2str(j)]);
        if normFreq; xlabel('Normalized Frequency (Hz)'); else; xlabel('Frequency (Hz)'); end
        ylabel('Magnitude (dB)');
        xlim([min(freqs), max(freqs)]); ylim([-100, 5]);
    end
    % Put a legend on the final graph
    legend(s1name, s2name, 'Location', 'best');
    drawnow;
    ax = gca;
end