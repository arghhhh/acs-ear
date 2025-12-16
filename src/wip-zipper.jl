

include( "env.jl" )
include( "include.jl" )
include( "carfac-test-lib.jl" )
using Plots
using FFTW

using SNR
using Windows
using Sequences

include("dmh_collect.jl" )

using PortAudio, SampledSignals



fs = 48e3

f = 1000

ampdB = 0:-1:-6 |> collect
ampdB = -6:1:0 |> collect

# should ramp up and down the ends of the tone

sig_ampdB0 = ampdB |> Processors.Upsamplehold( 6000 ) |> collect

sig_ampdB = vcat( first(sig_ampdB0) * ones(round(Int64, 3*fs/f/4 )), sig_ampdB0 )

gain = 10.0 .^ (sig_ampdB/20)

sig =  0.1 * gain * Sequences.Sinusoid( f, fs )  |> collect

PortAudioStream(0, 2; samplerate=fs) do stream
    write(stream, sig)
end
#plot( ampdB, ydB )



CF = CARFACjl.CARFAC_Design_version( :do_syn, 1, fs )

a = sig |> CARFACjl.CF_Runner( CF ) |> CollectNamedTuples

ydB = 20.0 * log10.( abs.( a.BM[53,1,:] ) )

bm = a.BM[:,1,:]
bm2 = bm .* bm
nr,nc = size(bm2)

iT = round(Int, 4*fs/f )  # period in terms of samples rounded to nearest int
chan = 1
i_step = div(iT,4)
i_starts = 1:i_step:nc-iT

t_axis = (i_starts .- 1) ./ fs
t_axis1 = (0:length(sig)-1) ./ fs

filtered_power = [ 10.0*log10( sum( bm2[chan,i:i+iT-1] )/iT ) for chan in 1:nr, i in i_starts ]

plot( t_axis, filtered_power', linewidth=2, legend=nothing, ylim=(-75,25) )
plot!( xlabel="Time [s]", ylabel="channel excitation (arbitrary scaling) [dB]" )
savefig( "zipper-1.png" )


plot( t_axis, filtered_power[1:57,:]', linewidth=2, legend=nothing, ylim=(-75,25) )
plot!( xlabel="Time [s]", ylabel="channel excitation (arbitrary scaling) [dB]" )
savefig( "zipper-2.png" )

plot( t_axis, filtered_power[57:end,:]', linewidth=2, legend=nothing, ylim=(-75,25) )
plot!( xlabel="Time [s]", ylabel="channel excitation (arbitrary scaling) [dB]" )
savefig( "zipper-3.png" )

#plot( [ gain sig ] )
plot( t_axis1, gain, size = (600,200), linewidth=2, legend = nothing )
#plot!( xlabel="Time [s]", ylabel="Gain [unitless ratio]" )
savefig( "zipper-4.png" )

plot( t_axis1, sig, size = (600,200), linewidth=2, legend = nothing )
#plot!( xlabel="Time [s]", ylabel="Signal [arbitrary units]" )
savefig( "zipper-5.png" )


plot( sig, linewidth=2, legend = nothing )
plot!( xlim=(29900,30200) )
plot!( xlabel="Time [sample index @ 48kHz]", ylabel="Signal [arbitrary units]" )
savefig( "zipper-6.png" )

plot( sig, linewidth=2, legend = nothing )
scatter!( sig )
plot!( xlim=(30025,30050) )
plot!( ylim=(-0.1, 0 ) )
plot!( xlabel="Time [sample index @ 48kHz]", ylabel="Signal [arbitrary units]" )
savefig( "zipper-7.png" )

## 
## bm = a.BM[53,1,:]
## nr,nc = size(bm)iT
## 
## mi,ma = extrema(bm)
#=

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

plot( ampdB1, ydB )
plot!( ampdB1, ampdB1 )

# bm_power = 10.0 * log10.( sum( x->x^2, a.BM[:,1,:]; dims=1 ) )

# a.BM[:,1,:] |> eachcol |> v->20.0*log10(SNR.estimate_dc_ac(v)[2])


t = a.BM[:,1,:][:,i:i+1023]
mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,i:i+1023] ; dims=2 )


# need version of start_indices from ACS503
CollectArrays( mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,:][:,i:i+1023] ; dims=2 ) for i = [1,2] )[:,1,:]


=#

