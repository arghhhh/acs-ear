
mutable struct CAR_params
        velocity_scale   #  % for the velocity nonlinearity
        v_offset         # % offset gives a quadratic part
        min_zeta         # % minimum damping factor in mid-freq channels
        max_zeta         # % maximum damping factor in mid-freq channels
        first_pole_theta 
        zero_ratio       # % how far zero is above pole
        high_f_damping_compression # % 0 to 1 to compress zeta
        ERB_per_step     # % assume G&M's ERB formula
        min_pole_Hz      #
        ERB_break_freq   #  % 165.3 is Greenwood map's break freq.
        ERB_Q            # % Glasberg and Moore's high-cf ratio
        ac_corner_Hz     # % AC couple at 20 Hz corner
        use_delay_buffer # % Default to true starting in v3.
  
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
                r.use_delay_buffer  = 0       # % Default to true starting in v3.
                return r
        end
end

CAR_params_default() = CAR_params()
