
abstract type IHC <: Processors.SampleProcessor
end

struct IHC_hwr <: IHC
end

function Processors.process( f::IHC_hwr, bm, state = nothing )
        ihc_out = min(2, max(0, bm)) # % limit it for stability
        return ihc_out, nothing
end

mutable struct IHC_one_cap <: IHC
        lpf_coeff           :: Float64

	out_rate            :: Float64
	in_rate             :: Float64
	rest_cap            :: Float64
        output_gain         :: Float64
        rest_output         :: Float64

        IHC_one_cap() = new()

end

function mk_IHC_one_cap( fs = 48e3, tau_in = 0.010, tau_out = 0.0005, tau_lpf = 0.000080 )
        gmax = CARFAC_Detect1(10) # % output conductance at a high level
        rmin = 1 / gmax
        c = tau_out * gmax
        ri = tau_in / c
        # % to get approx steady-state average, double rmin for 50% duty cycle
        saturation_current = 1 / (2/gmax + ri)
        # % also consider the zero-signal equilibrium:
        g0 = CARFAC_Detect1(0)
        r0 = 1 / g0
        rest_current = 1 / (ri + r0)
        cap_voltage = 1 - rest_current * ri
        IHC_coeffs = IHC_one_cap()
#        IHC_coeffs.n_ch                = n_ch
#        IHC_coeffs.just_hwr            = false
        IHC_coeffs.lpf_coeff           = 1 - exp(-1/(tau_lpf * fs))
        IHC_coeffs.out_rate            = rmin / (tau_out * fs)
        IHC_coeffs.in_rate             = 1 / (tau_in * fs)
#        IHC_coeffs.one_cap             = IHC_params.one_cap
        IHC_coeffs.output_gain         = 1 / (saturation_current - rest_current)
        IHC_coeffs.rest_output         = rest_current / (saturation_current - rest_current)
        IHC_coeffs.rest_cap            = cap_voltage

        return IHC_coeffs
end

mutable struct IHC_two_cap <: IHC

        n_ch                :: Int64
        just_hwr            :: Bool
        lpf_coeff           :: Float64

	out_rate            :: Float64
	in_rate             :: Float64
	rest_cap            :: Float64

        out1_rate           :: Float64
        in1_rate            :: Float64
        out2_rate           :: Float64
        in2_rate            :: Float64
        one_cap             :: Bool
        output_gain         :: Float64
        rest_output         :: Float64
        rest_cap2           :: Float64
        rest_cap1           :: Float64

        IHC_two_cap() = new()
end

function mk_IHC_two_cap( fs = 48e3, tau1_in = 0.000200, tau1_out = 0.000500, tau2_in = 0.001, tau2_out = 0.010, tau_lpf = 0.000080, )

        g1max = CARFAC_Detect1(10)     # % receptor conductance at high level
        r1min = 1 / g1max
        c1 = tau1_out * g1max     # % capacitor for min depletion tau
        r1 = tau1_in / c1     # % resistance for recharge tau
        # % to get approx steady-state average, double r1min for 50% duty cycle
        saturation_current1 = 1 / (2*r1min + r1)     # % Approximately.
        # % also consider the zero-signal equilibrium:
        g10 = CARFAC_Detect1(0)
        r10 = 1/g10
        rest_current1 = 1 / (r1 + r10)
        cap1_voltage = 1 - rest_current1 * r1     # % quiescent/initial state

        # % Second cap similar, but using receptor voltage as detected signal.
        max_vrecep = r1 / (r1min + r1)     # % Voltage divider from 1.
        # % Identity from receptor potential to neurotransmitter conductance:
        g2max = max_vrecep     # % receptor resistance at very high level
        r2min = 1 / g2max
        c2 = tau2_out * g2max     # % capacitor for min depletion tau
        r2 = tau2_in / c2     # % resistance for recharge tau
        # % to get approx steady-state average, double r2min for 50% duty cycle
        saturation_current2 = 1 / (2 * r2min + r2)
        # % also consider the zero-signal equilibrium:
        rest_vrecep = r1 * rest_current1
        g20 = rest_vrecep
        r20 = 1 / g20
        rest_current2 = 1 / (r2 + r20)
        cap2_voltage = 1 - rest_current2 * r2     # % quiescent/initial state

        IHC_coeffs = IHC_two_cap()
#        IHC_coeffs.n_ch             = n_ch
#        IHC_coeffs.just_hwr         = false
        IHC_coeffs.lpf_coeff        = 1 - exp(-1/(tau_lpf * fs))
        IHC_coeffs.out1_rate        = r1min / (tau1_out * fs)
        IHC_coeffs.in1_rate         = 1 / (tau1_in * fs)
        IHC_coeffs.out2_rate        = r2min / (tau2_out * fs)
        IHC_coeffs.in2_rate         = 1 / (tau2_in * fs)
#        IHC_coeffs.one_cap          = IHC_params.one_cap
        IHC_coeffs.output_gain      = 1 / (saturation_current2 - rest_current2)
        IHC_coeffs.rest_output      = rest_current2 / (saturation_current2 - rest_current2)
        IHC_coeffs.rest_cap2        = cap2_voltage
        IHC_coeffs.rest_cap1        = cap1_voltage

        return IHC_coeffs
end



function IHC1( CF_version_keyword, fs )
        if CF_version_keyword == :just_hwr
                return IHC_hwr()
        elseif CF_version_keyword == :one_cap
                return mk_IHC_one_cap(fs)
        else
                return mk_IHC_two_cap(fs)
        end
end

mutable struct IHC1_state

        # should probably different state structs for each of just_hwr, one_cap, else cases
        ihc_accum::Float64 

        cap_voltage::Float64 
        lpf1_state::Float64 
        lpf2_state::Float64 

        cap1_voltage::Float64 
        cap2_voltage::Float64 



        IHC1_state() = new(0.0,0.0,0.0,0.0,0.0)
end               

function IHC_Init_State(coeffs::IHC_hwr)::IHC1_state
        n_ch = coeffs.n_ch;

        state = IHC1_state()

        state.ihc_accum = 0.0;

        return state
end

function IHC_Init_State(coeffs::IHC_one_cap)::IHC1_state
        state = IHC1_state()

        state.ihc_accum     = 0.0
        state.cap_voltage   = coeffs.rest_cap
        state.lpf1_state    = coeffs.rest_output
        state.lpf2_state    = coeffs.rest_output
        
        return state
end

function IHC_Init_State(coeffs::IHC_two_cap)::IHC1_state
        state = IHC1_state()

        state.ihc_accum     = 0.0
        state.cap1_voltage  = coeffs.rest_cap1
        state.cap2_voltage  = coeffs.rest_cap2
        state.lpf1_state    = coeffs.rest_output

        return state
end




function Processors.process( coeffs::IHC_one_cap, bm_out, state = IHC_Init_State(coeffs) )

        conductance = CARFAC_Detect(bm_out) # % rectifying nonlinearity

        # % Output comes from receptor current like in Hall and Allen's models.
        ihc_out = conductance .* state.cap_voltage
        state.cap_voltage = state.cap_voltage .- ihc_out .* coeffs.out_rate .+ (1 .- state.cap_voltage) .* coeffs.in_rate
        ihc_out = ihc_out * coeffs.output_gain
        # % Smooth it twice with LPF:
        state.lpf1_state = state.lpf1_state + coeffs.lpf_coeff * (ihc_out - state.lpf1_state)
        state.lpf2_state = state.lpf2_state + coeffs.lpf_coeff * (state.lpf1_state - state.lpf2_state)
        ihc_out = state.lpf2_state .- coeffs.rest_output

        v_recep = 0.0  # only used for two_cap version

        return  (;ihc_out, v_recep, state.cap_voltage ), state
end

function Processors.process( coeffs::IHC_two_cap, bm_out, state = IHC_Init_State(coeffs) )

        conductance = CARFAC_Detect(bm_out) # % rectifying nonlinearity

        # % Change to 2-cap version mediated by receptor potential at cap1:
        # % Geisler book fig 8.4 suggests 40 to 800 Hz corner.
        receptor_current = conductance * state.cap1_voltage
        # % "out" means charge depletion; "in" means restoration toward 1.
        state.cap1_voltage = state.cap1_voltage - receptor_current * coeffs.out1_rate + (1 - state.cap1_voltage) * coeffs.in1_rate
        # % Amount of depletion below 1 is receptor potential.
        receptor_potential = 1 - state.cap1_voltage # % Already smooth.
        # % Identity map from receptor potential to neurotransmitter conductance.
        ihc_out = receptor_potential * state.cap2_voltage # % Now a current.
        # % cap2 represents transmitter store; another adaptive gain.
        # % Deplete the transmitter store like in Meddis models:
        state.cap2_voltage = state.cap2_voltage - ihc_out * coeffs.out2_rate + (1 - state.cap2_voltage) * coeffs.in2_rate
        # % Awkwardly, gain needs to be here for the init states to be right.
        ihc_out = ihc_out * coeffs.output_gain
        # % smooth once more with LPF (receptor potential was already smooth):
        state.lpf1_state = state.lpf1_state + coeffs.lpf_coeff * (ihc_out - state.lpf1_state)
        ihc_out = state.lpf1_state - coeffs.rest_output
        # % Return a modified receptor potential that's zero at rest, for SYN.
        v_recep = coeffs.rest_cap1 - state.cap1_voltage
                
        return  (;ihc_out, v_recep, state.cap_voltage), state
end

#=
function CARFAC_DesignIHC(IHC_params::IHC_params, fs, n_ch)

        if IHC_params.just_hwr
                IHC_coeffs = Parallel( [ IHC_hwr() for i in 1:n_ch ] )
        elseif IHC_params.one_cap
                IHC_coeffs = Parallel( [ mk_IHC_one_cap( fs ) for i in 1:n_ch ] )
        else
                IHC_coeffs = Parallel( [ mk_IHC_two_cap( fs ) for i in 1:n_ch ] )
        end

        return IHC_coeffs
end


IHC_Init_State(coeffs::Parallel) = [ IHC_Init_State( coeffs.v[i] ) for i in 1:length(coeffs.v) ]

=#

