

include( "env.jl" )
include( "include.jl" )
include( "carfac-test-lib.jl" )
using Plots
using FFTW

using SNR
using Windows
using Sequences

include("dmh_collect.jl" )


fs = 48e3

sig = [ [1.0], [1.0], [1.0] ]

N = 5*48000

ampdB = range( -100, 20 ; length = N )

sig = 10.0 .^ (ampdB/20) * Sequences.Sinusoid( 1000, fs ) |> collect


CF = CARFACjl.CARFAC_Design_version( :do_syn, 1, fs )

a = sig |> CARFACjl.CF_Runner( CF ) |> CollectNamedTuples

ydB = 20.0 * log10.( abs.( a.BM[53,1,:] ) )

#plot( ampdB, ydB )

bm = a.BM[53,1,:]
#nr,nc = size(bm)

mi,ma = extrema(bm)

ydB = collect(
        bm 
        |> Processors.SlidingWindow(1024) 
        |> Processors.Downsample(100) 
        |> Processors.Map( v->20.0*log10(SNR.estimate_dc_ac(v)[2]) ) 
        )
ampdB1 = collect(
        ampdB 
        |> Processors.SlidingWindow(1024) 
        |> Processors.Downsample(100) 
        |> Processors.Map( v->v[512]) 
        ) 

# cut the first points:
ydB = ydB[3:end]
ampdB1 = ampdB1[3:end]

# convert from CARFAC scaling to dB SPL:
ampdB1 = ampdB1 .+ 101

plot()
plot!( xticks=0:20:100 )
plot!( tickfontsize=16 )
plot!( labelfontsize=14 )

plot!( ampdB1, ydB , linewidth=2, size=(900,600), framestyle=:box )
# plot just the ends of ampdB1 - so straight line can be dashed:
plot!( [ first(ampdB1), last(ampdB1) ], [ first(ampdB1), last(ampdB1) ] .+ (last(ydB)-last(ampdB1) ), linestyle=:dash )
plot!( [ first(ampdB1), last(ampdB1) ], [ first(ampdB1), last(ampdB1) ] .+ (first(ydB)-first(ampdB1) ), linestyle=:dash )
plot!( xlim=(0,110), ylim=( -80, 20 ) )
plot!( xticks=0:20:100 )
plot!( xlabel = "Sound Pressure Level [dB SPL]" )
plot!( ylabel = "Auditory Filter Channel Output Level [dB re arbitrary]" )
plot!( legend = nothing )
savefig( "compression.png" )

@show (last(ydB)-last(ampdB1) ) - (first(ydB)-first(ampdB1) )

# bm_power = 10.0 * log10.( sum( x->x^2, a.BM[:,1,:]; dims=1 ) )

# a.BM[:,1,:] |> eachcol |> v->20.0*log10(SNR.estimate_dc_ac(v)[2])


t = a.BM[:,1,:][:,i:i+1023]
mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,i:i+1023] ; dims=2 )


# need version of start_indices from ACS503
CollectArrays( mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,:][:,i:i+1023] ; dims=2 ) for i = [1,2] )[:,1,:]


