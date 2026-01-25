


function pole_freqs( f_min, f_max, ERB_per_step = 0.5 )

# extracted from CARFAC_Design.jl :

        # % First count how many filter stages (PZFC/CARFAC channels):
        pole_Hz = f_max # CF_CAR_params.first_pole_theta * fs / (2*pi)
        n_ch = 0
        while pole_Hz > f_min
                n_ch = n_ch + 1
                pole_Hz = pole_Hz - ERB_per_step * ERB_Hz(pole_Hz);
        end
        # % Now we have n_ch, the number of channels, so can make the array
        # % and compute all the frequencies again to put into it:
        pole_freqs = zeros(n_ch)
        pole_Hz = f_max # first_pole_theta * fs / (2*pi)
        for ch = 1:n_ch
                pole_freqs[ch] = pole_Hz
                pole_Hz = pole_Hz - ERB_per_step * ERB_Hz(pole_Hz)
        end

        return pole_freqs

end

