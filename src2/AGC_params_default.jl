
mutable struct AGC_params
        n_stages        ::Int64 
        time_constants  ::Vector{Float64} # % 2, 8, 32, 128 ms
        AGC_stage_gain  ::Float64         # % gain from each stage to next slower stage
        decimation      ::Vector{Int64}   # % how often to update the AGC states
        AGC1_scales     ::Vector{Float64} # % in units of channels
        AGC2_scales     ::Vector{Float64} # % spread more toward base
        AGC_mix_coeff   ::Float64

        function AGC_params()
                r = new()
                r.n_stages         = 4
                r.time_constants   = 0.002 * 4.0 .^ (0:3)  # % 2, 8, 32, 128 ms
                r.AGC_stage_gain   = 2.0                   # % gain from each stage to next slower stage
                r.decimation       = [8, 2, 2, 2]          # % how often to update the AGC states
                r.AGC1_scales      = 1.0 * sqrt(2).^(0:3)  # % in units of channels
                r.AGC2_scales      = 1.65 * sqrt(2).^(0:3) # % spread more toward base
                r.AGC_mix_coeff    = 0.5                
                return r
        end
end

AGC_params_default() = AGC_params()
