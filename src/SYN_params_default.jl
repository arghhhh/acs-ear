
mutable struct SYN_params_default

        do_syn     #  % This may just turn it off completely.
        n_classes
        healthy_n_fibers
        spont_rates
        sat_rates
        sat_reservoir
        v_width
        tau_lpf
        reservoir_tau
        agc_weights

        function SYN_params_default( do_syn )

                n_classes = 3;
                IHCs_per_channel = 10;
                # % Parameters could generally have columns if class-dependent.

                r = new()

                r.do_syn           = do_syn # % This may just turn it off completely.
                r.n_classes        = n_classes
                r.healthy_n_fibers = [50, 35, 25] * IHCs_per_channel
                r.spont_rates      = [50, 6, 1] # % Tweak last to 50, 5, 0.5 maybe?
                r.sat_rates        = 200
                r.sat_reservoir    = 0.2
                r.v_width          = 0.02         # % Mayb 0.025 tweak is better?
                r.tau_lpf          = 0.000080
                r.reservoir_tau    = 0.020
                r.agc_weights      = [1.2, 1.2, 1.2] / (22050*IHCs_per_channel) # % Tweaked.

                # % The weights 1.2 were picked before correctly account for sample rate
                # % and number of fibers.  This way works for more different numbers.

                return r
        end
end


