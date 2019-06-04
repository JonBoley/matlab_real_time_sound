

function pointspl = calcspl(p_Pa)
p_ref = 20*1e-6; % reference pressure in air is typically 20 uPa
p_rms = sqrt(mean(p_Pa.*p_Pa));
pointspl = 20*log10(p_rms/p_ref);
end