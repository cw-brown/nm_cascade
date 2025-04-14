function ax = customplotrf(s, normFreq, figName)
%% Plot s-parameters in a custom plot, easier to control.
    arguments
        s sparameters
        normFreq (1,1) logical
        figName (1,:) string = ''
    end
    if nargin == 2; figure("Name",figName,"NumberTitle","off"); else; figure; end
    n = s.NumPorts;
    if normFreq; freqs=s.Frequencies/max(s.Frequencies); else; freqs=s.Frequencies; end
    h = s.Parameters;
    labels = cell(1, n^2);
    for ii = 1:n^2
        [i,j] = ind2sub([n,n], ii);
        plot(freqs, db(squeeze(h(i,j,:))), LineWidth=1.5);
        hold on; grid on; 
        labels{ii} = ['S_' num2str(i) '_' num2str(j)];
    end
    if normFreq; xlabel('Normalized Frequency (Hz)'); else; xlabel('Frequency (Hz)'); end
    ylabel('Magnitude (dB)'); legend(labels,'Location','best');
    xlim([min(freqs), max(freqs)]); ylim([-100, 5]);
    drawnow;
    ax = gca;
end