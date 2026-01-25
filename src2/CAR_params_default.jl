
mutable struct CAR_params
        velocity_scale   ::Float64   # % for the velocity nonlinearity  DMH: used in CARFAC_OHC_NLF
        v_offset         ::Float64   # % offset gives a quadratic part  DMH: used in CARFAC_OHC_NLF
        min_zeta         ::Float64   # % minimum damping factor in mid-freq channels
        max_zeta         ::Float64   # % maximum damping factor in mid-freq channels
        first_pole_theta ::Float64 
        zero_ratio       ::Float64   # % how far zero is above pole
        high_f_damping_compression ::Float64 # % 0 to 1 to compress zeta
        ERB_per_step     ::Float64   # % assume G&M's ERB formula
        min_pole_Hz      ::Float64   #
        ERB_break_freq   ::Float64   # % 165.3 is Greenwood map's break freq.
        ERB_Q            ::Float64   # % Glasberg and Moore's high-cf ratio
        ac_corner_Hz     ::Float64   # % AC couple at 20 Hz corner
        use_delay_buffer ::Bool      # % Default to true starting in v3.
  
        function CAR_params()
                r = new()
                r.velocity_scale    = 0.1     # % for the velocity nonlinearity
                r.v_offset          = 0.04    # % offset gives a quadratic part
                r.min_zeta          = 0.10    # % minimum damping factor in mid-freq channels
                r.max_zeta          = 0.35    # % maximum damping factor in mid-freq channels
                r.first_pole_theta  = 0.85*pi #
                r.zero_ratio        = sqrt(2) # % how far zero is above pole
                r.high_f_damping_compression  = 0.5  #  % 0 to 1 to compress zeta
                r.ERB_per_step      = 0.5     # % assume G&M's ERB formula
                r.min_pole_Hz       = 30.0    #
                r.ERB_break_freq    = 165.3   # % 165.3 is Greenwood map's break freq.
                r.ERB_Q             = 1000/(24.7*4.37)  # % Glasberg and Moore's high-cf ratio
                r.ac_corner_Hz      = 20.0    # % AC couple at 20 Hz corner
                r.use_delay_buffer  = false   # % Default to true starting in v3.
                return r
        end
end

CAR_params_default() = CAR_params()
