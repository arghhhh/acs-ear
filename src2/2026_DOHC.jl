

nlf( scale = 0.1, offset = 0.04 ) = v -> 1.0 / ( 1+ (v * scale + offset )^2 )

f_ref_DOHC_nlf = 48000.0

struct DOHC <: Processors.SampleProcessor
        r1      # pole radius at max damping (smallest r)
        d_rz    # extra "r" to add for min damping (largest total r)
        fs      # sample rate to denormalize nlf
        nlf     # non-linear function
end

DOHC( r1, d_rz, fs = f_ref_DOHC_nlf ) = DOHC( r1, d_rz, fs, nlf() )

# if its not a tuple, then use the default:
tuple_default( x::NamedTuple, n::Symbol, default ) = haskey( x, n ) ? x[n] : default
tuple_default( x , n::Symbol, default ) = default

# if its not a tuple, then use the value itself:
single_default( x::NamedTuple, n::Symbol, default ) = haskey( x, n ) ? x[n] : default
single_default( x , n::Symbol, default ) = x


function Processors.process( f::DOHC, in, state=0.0 )
        x = single_default( in, :x, 0.0 )
        b = tuple_default( in, :b, 0.0 )

    #    println("DOHC x = $(x), b = $(b) ")

        global f_ref_DOHC_nlf  # reference frequency for which nlf was 
        velocity = ( x - state ) * f.fs/ f_ref_DOHC_nlf
        nlf_out = f.nlf( velocity )
        relative_undamping = nlf_out * (1-b)
        delta_r = relative_undamping * f.d_rz
        r = f.r1 + delta_r

    #    println( "DOHC relative_undamping = $(relative_undamping)" )

        y = (; velocity, nlf_out, relative_undamping, delta_r, r, state=x )

    #    println( "DOHC: y = $(y)" )

        next_state = x
        return y, next_state
end

# extract a single field:
struct ExtractField <: Processors.SampleProcessor
        n::Symbol
end
Processors.process( f::ExtractField, in, state=nothing ) = in[f.n], nothing

# extract several fields, as a vector - can then be collected using CollectArrays
struct ExtractFields{N} <: Processors.SampleProcessor
        ns::NTuple{N,Symbol}
        ExtractFields( v... ) = new{ length(v) }( v )
end
Processors.process( f::ExtractFields, in, state=nothing ) = [ in[n] for n in f.ns ], nothing




import Plots
# time domain plot helper - supply the time axis starting from 0, automatically, assuming given sample rate
tplot(  fs, v, args... ) = Plots.plot(  1/fs * (0:length(v)-1), v, args... )
tplot!( fs, v, args... ) = Plots.plot!( 1/fs * (0:length(v)-1), v, args... )

y = 100.0 * Sequences.Sinusoid( 997.123, 48e3 ) |> DOHC( 0.6, 0.3, 48e3 ) |> ExtractField(:r) |> Processors.Take(100) |> collect
tplot(  48e3, y )
y = 100.0 * Sequences.Sinusoid( 997.123, 96e3 ) |> DOHC( 0.6, 0.3, 96e3 ) |> ExtractField(:r) |> Processors.Take(200) |> collect
tplot!( 96e3, y )



struct CAR_DOHC <: Processors.SampleProcessor
        resonator::CAR_filter
        dohc::DOHC
        default_undamping
end
CAR_DOHC( res::CAR_filter, default_undamping = 0.0 ) = CAR_DOHC( res, DOHC( res.r1, res.zr, res.fs ), default_undamping )


function Processors.process( f::CAR_DOHC, in )
        x = single_default( in, :x, 0.0 )
        b = tuple_default( in, :undamping, f.default_undamping )

    #    @show in
    #    @show x b

        dohc_out,next_dohc_state = Processors.process( f.dohc, ( x=0.0, b=b ) )  # initial input to DOHC is zer0
        resonator_out, next_resonator_state = Processors.process( f.resonator, (;x=x,undamping = dohc_out.relative_undamping) )

        return (;y=resonator_out.y,dohc_out, resonator_out), (next_dohc_state, next_resonator_state)
end

function Processors.process( f::CAR_DOHC, in, state )
        x = single_default( in, :x, 0.0 )
        b = tuple_default( in, :undamping, f.default_undamping )

    #    println( CAR_DOHC )
    #    @show in x b

        (dohc_state, resonator_state) = state;

   #     @show resonator_state.z2_memory
        dohc_out,next_dohc_state = Processors.process( f.dohc, (; x=resonator_state.z2_memory, b ), dohc_state )
    #    @show dohc_out.relative_undamping
        resonator_out, next_resonator_state = Processors.process( f.resonator, (;x=x,undamping = dohc_out.relative_undamping), resonator_state )

        return (;y=resonator_out.y,dohc_out, resonator_out), (next_dohc_state, next_resonator_state)
end




struct CARFAC_Loop <: Processors.SampleProcessor
        resonators::Vector{CAR_filter}
        dohc::Vector{DOHC}
        ihc::Vector
        loop::Vector{AGC_Loop}
        agc::AGC_coeffs_struct  # this is the version from the carfac repo, directly translated to Julia, and wrapped as a Processors.SampleProcessor
end
function CARFAC_Loop( fs::Float64, resonators::Vector, agc_params = AGC_params(), OHC_health = ones( length( resonators ) ) ) 

        n_ch = length(resonators)

        dohc = [ DOHC( r.r1 , r.zr, r.fs ) for r in resonators ]

        OHC_health = 1.0
        zr_coeffs = [ r.zr for r in resonators ]

        agc = CARFAC_DesignAGC(agc_params, fs, n_ch)
        decim1 = agc.decimation[1]

        loop = AGC_Loop.(  decim1, OHC_health, zr_coeffs )

        IHC_version = :one_cap

        ihc = [ IHC1( IHC_version, fs ) for i in 1:n_ch ]
        
        return CARFAC_Loop( resonators, dohc, ihc, loop, agc )
end


function parallel_process( f, in )
        r = Processors.process.( f, in )
        # r is vector of tuples of the outputs and states
        # separate these out:
        ys     = [ e[1] for e in r ]
        next_states = [ e[2] for e in r ] 

        return ( ys, next_states )
end

function parallel_process( f, in, states )
        r = Processors.process.( f, in, states )
        # r is vector of tuples of the outputs and states
        # separate these out:
        ys     = [ e[1] for e in r ]
        next_states = [ e[2] for e in r ] 

        return ( ys, next_states )
end


function Processors.process( f::CARFAC_Loop, inp::Float64 )
 
        n_ch = length(f.resonators)
        
        initial_DOHC_input = [ (; x = 0.0, b = 0.0 ) for i in 1:n_ch ] # TODO: initial state of "b"?

    #    process_dohc_output = [ Processors.processor( each_ohc, (; x=each_input.x, b =each_input.b) ) for (each_ohc,each_input) in zip( f.ohc, initial_DOHC_input ) ]
        dohc_output, next_dohc_state = parallel_process( f.dohc, initial_DOHC_input )

        x = inp
        next_resonator_state = []
        res_ys = []
        for (r,b) in zip( f.resonators, dohc_output )
         #       @show inp x ( x=x, undamping=b.relative_undamping )
                each_resonator_out, each_resonator_state = Processors.process( r, ( x=x, undamping=b.relative_undamping ) )
                push!( next_resonator_state, each_resonator_state )
                push!( res_ys   , each_resonator_out   )
                x = each_resonator_out.y
        end

        ihc_in = [ r_y.y for r_y in res_ys ]

        ihc_out, next_ihc_state = parallel_process( f.ihc, ihc_in )

        agc_in = [ each_ihc_out.ihc_out for each_ihc_out in ihc_out ]

        agc_out, next_agc_state = Processors.process( f.agc, agc_in  )

     #   @show agc_out
        initial_loop_input = [ (; x = each_agc_out_y, updated = agc_out.updated ) for each_agc_out_y in agc_out.y ]
    #    initial_loop_input = (; x=agc_out.y, updated = agc_out.updated )

    #    @show initial_loop_input
        loop_out, next_loop_state = parallel_process( f.loop, initial_loop_input )

        next_state = ( next_dohc_state, next_resonator_state, next_ihc_state, next_agc_state, next_loop_state )

        return (;y=res_ys, dohc_output ), next_state
end

function Processors.process( f::CARFAC_Loop, inp::Float64, state )

        ( dohc_state, resonator_state, ihc_state, agc_state, loop_state ) = state
 
        n_ch = length(f.resonators)
        
        initial_DOHC_input = [ (; x = 0.0, b = 0.0 ) for i in 1:n_ch ] # TODO: initial state of "b"?

    #    process_dohc_output = [ Processors.processor( each_ohc, (; x=each_input.x, b =each_input.b) ) for (each_ohc,each_input) in zip( f.ohc, initial_DOHC_input ) ]
        dohc_output, next_dohc_state = parallel_process( f.dohc, initial_DOHC_input, dohc_state )

        x = inp
        next_resonator_state = []
        res_ys = []
        for (r,b,s) in zip( f.resonators, dohc_output, resonator_state )
              #  @show inp x ( x=x, undamping=b.relative_undamping )
              #  @show resonator_state
                each_resonator_out, each_resonator_state = Processors.process( r, ( x=x, undamping=b.relative_undamping ), s )
                push!( next_resonator_state, each_resonator_state )
                push!( res_ys   , each_resonator_out   )
                x = each_resonator_out.y
        end

        ihc_in = [ r_y.y for r_y in res_ys ]

        ihc_out, next_ihc_state = parallel_process( f.ihc, ihc_in, ihc_state )

        agc_in = [ each_ihc_out.ihc_out for each_ihc_out in ihc_out ]

        agc_out, next_agc_state = Processors.process( f.agc, agc_in, agc_state  )

    #    @show agc_out
        initial_loop_input = [ (; x = each_agc_out_y, updated = agc_out.updated ) for each_agc_out_y in agc_out.y ]
    #    initial_loop_input = (; x=agc_out.y, updated = agc_out.updated )

    #    @show initial_loop_input
        loop_out, next_loop_state = parallel_process( f.loop, initial_loop_input, loop_state )

        next_state = ( next_dohc_state, next_resonator_state, next_ihc_state, next_agc_state, next_loop_state )

        return (;y=res_ys, dohc_output ), next_state
end

