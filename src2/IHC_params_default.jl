

mutable struct IHC_params
        just_hwr  # % not just a simple HWR
        one_cap   # % bool; 0 for new two-cap hack
        do_syn    # % bool; 1 for v3 synapse feature
        tau_lpf   # % 80 microseconds smoothing twice
        tau_out   # % depletion tau is pretty fast
        tau_in    # % recovery tau is slower
        tau1_out  # % depletion tau is fast 500 us
        tau1_in   # % recovery tau is very fast 200 us
        tau2_out  # % depletion tau is pretty fast 1 ms
        tau2_in   # % recovery tau is slower 10 ms

        function IHC_params( CF_version_keyword = :two_cap )
                one_cap  = false # % bool; 1 for Allen model, 0 for new default two-cap
                just_hwr = false # % bool; 0 for normal/fancy IHC; 1 for HWR
                do_syn   = false #

                if     CF_version_keyword == :just_hwr
                        just_hwr = true # % bool; 0 for normal/fancy IHC; 1 for HWR
                elseif CF_version_keyword == :one_cap
                        one_cap = true  #     % bool; 1 for Allen model, as text states we use
                elseif CF_version_keyword == :do_syn
                        do_syn = true
                elseif CF_version_keyword == :two_cap
                        # % nothing to do; accept the v2 default, two-cap IHC, no SYN.
                else
                        error("unknown IHC_keyword $(CF_version_keyword) in CARFAC_Design")
                end

                r = new()
                r.just_hwr = just_hwr # % not just a simple HWR
                r.one_cap  = one_cap  # % bool; 0 for new two-cap hack
                r.do_syn   = do_syn   # % bool; 1 for v3 synapse feature
                r.tau_lpf  = 0.000080 # % 80 microseconds smoothing twice
                r.tau_out  = 0.0005   # % depletion tau is pretty fast
                r.tau_in   = 0.010    # % recovery tau is slower
                r.tau1_out = 0.000500 # % depletion tau is fast 500 us
                r.tau1_in  = 0.000200 # % recovery tau is very fast 200 us
                r.tau2_out = 0.001    # % depletion tau is pretty fast 1 ms
                r.tau2_in  = 0.010    # % recovery tau is slower 10 ms
                return r
        end

end

IHC_params_default( CF_version_keyword = :two_cap ) = IHC_params( CF_version_keyword )
