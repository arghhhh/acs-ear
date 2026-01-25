

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
end
CAR_DOHC( res::CAR_filter ) = CAR_DOHC( res, DOHC( res.r1, res.zr, res.fs ) )


function Processors.process( f::CAR_DOHC, in )
        x = single_default( in, :x, 0.0 )
        b = tuple_default( in, :b, 0.0 )

   #     @show x b

        dohc_out,next_dohc_state = Processors.process( f.dohc, ( x=0.0, b=b ) )  # initial input to DOHC is zer0
        resonator_out, next_resonator_state = Processors.process( f.resonator, (;in=x,undamping = dohc_out.relative_undamping) )

        return (;y=resonator_out.y,dohc_out, resonator_out), (next_dohc_state, next_resonator_state)
end

function Processors.process( f::CAR_DOHC, in, state )
        x = single_default( in, :x, 0.0 )
        b = tuple_default( in, :b, 0.0 )

    #    @show x b

        (dohc_state, resonator_state) = state;

   #     @show resonator_state.z2_memory
        dohc_out,next_dohc_state = Processors.process( f.dohc, (; x=resonator_state.z2_memory, b ), dohc_state )
    #    @show dohc_out.relative_undamping
        resonator_out, next_resonator_state = Processors.process( f.resonator, (;in=x,undamping = dohc_out.relative_undamping), resonator_state )

        return (;y=resonator_out.y,dohc_out, resonator_out), (next_dohc_state, next_resonator_state)
end