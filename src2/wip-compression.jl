

# original work in wip-3.jl



# include( "env.jl" )
include( "include.jl" )
# include( "carfac-test-lib.jl" )
using Plots
using FFTW

using SNR
using Windows
using Sequences

# include("dmh_collect.jl" )



function compression_data( carfac, ampdB, f_sig, fs, n_ch )


        sig = 10.0 .^ (ampdB/20) * Sequences.Sinusoid( f_sig, fs ) |> collect


        a = sig |> carfac |> CollectNamedTuples

        ydB = 20.0 * log10.( abs.( a.bm[n_ch,:] ) )

        #plot( ampdB, ydB )

        #bm = a.bm[n_ch,:]
        #nr,nc = size(bm)

#        mi,ma = extrema(bm)

        ydB = collect(
                a.bm[n_ch,:] 
                |> Processors.SlidingWindow(1024) 
                |> Processors.Downsample(100) 
                |> Processors.Map( v->20.0*log10(SNR.estimate_dc_ac(v)[2]) ) 
                )

        fast_undamping = collect(
                a.fast_undamping[n_ch,:]
                |> Processors.SlidingWindow(1024) 
                |> Processors.Downsample(100)
                |> Processors.Map( v->SNR.estimate_dc_ac(v)[1] )
                )

        agc_undamping = collect(
                a.agc_undamping[n_ch,:]
                |> Processors.SlidingWindow(1024) 
                |> Processors.Downsample(100)
                |> Processors.Map( v->SNR.estimate_dc_ac(v)[1] )
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
        fast_undamping = fast_undamping[3:end]
        agc_undamping  = agc_undamping[3:end]

        # convert from CARFAC scaling to dB SPL:
        ampdB1 = ampdB1 .+ 101


        return a, ampdB1, ydB, agc_undamping, fast_undamping
end




function plot_compression!( ampdB1, ydB )

        #plot()
        plot!( xticks=0:20:100 )
        # plot!( tickfontsize=16 )
        # plot!( labelfontsize=14 )

        # plot!( ampdB1, ydB , linewidth=2, size=(900,600), framestyle=:box )
        plot!( ampdB1, ydB , linewidth=2, framestyle=:box )
        # plot just the ends of ampdB1 - so straight line can be dashed:
        plot!( [ first(ampdB1), last(ampdB1) ], [ first(ampdB1), last(ampdB1) ] .+ (last(ydB)-last(ampdB1) ), linestyle=:dash )
        plot!( [ first(ampdB1), last(ampdB1) ], [ first(ampdB1), last(ampdB1) ] .+ (first(ydB)-first(ampdB1) ), linestyle=:dash )
        plot!( xlim=(0,110), ylim=( -80, 20 ) )
        plot!( xticks=0:20:100 )
        plot!( xlabel = "Sound Pressure Level [dB SPL]" )
        plot!( ylabel = "Auditory Filter Output Level [dB re arbitrary]" )
        plot!( legend = nothing )
end


fs = 48e3

sig = [ [1.0], [1.0], [1.0] ]







# CF = CARFACjl.CARFAC_Design_version( :do_syn, 1, fs )

# a = sig |> CARFACjl.CF_Runner( CF ) |> CollectNamedTuples

cfs = pole_freqs( 30.0, 0.85 * fs/2 )



# _sig = 4000.0
# _ch = 30
# 
# _sig = 250.0
# _ch = 71

car = CAR_filter.( cfs, fs )
carfac = CARFAC_Loop( fs, car )


N = 7*48000

ampdB = range( -100, 40 ; length = N )



# bm_power = 10.0 * log10.( sum( x->x^2, a.BM[:,1,:]; dims=1 ) )

# a.BM[:,1,:] |> eachcol |> v->20.0*log10(SNR.estimate_dc_ac(v)[2])

## 
## t = a.BM[:,1,:][:,i:i+1023]
## mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,i:i+1023] ; dims=2 )
## 
## 
## # need version of start_indices from ACS503
## CollectArrays( mapslices( v->20.0*log10(SNR.estimate_dc_ac(v)[2]), a.BM[:,1,:][:,i:i+1023] ; dims=2 ) for i = [1,2] )[:,1,:]
## 

if true
        f_sig = 1000.0
        n_ch = 53

        a1, ampdB1, ydB1, agc_undamping, fast_undamping = compression_data( carfac, ampdB, f_sig, fs, n_ch )


        p1 = plot()
        plot_compression!( ampdB1, ydB1 )
        # savefig( "compression.png" )

        @show (last(ydB1)-last(ampdB1) ) - (first(ydB1)-first(ampdB1) )

        p2 = plot( ampdB1, [agc_undamping fast_undamping agc_undamping.*fast_undamping ] )
end

if true

        f_sig = 4000.0
        n_ch = 30

        a2, ampdB1, ydB2, agc_undamping, fast_undamping = compression_data( carfac, ampdB, f_sig, fs, n_ch )

        p3 = plot()
        plot_compression!( ampdB1, ydB2 )
        # savefig( "compression.png" )

        @show (last(ydB2)-last(ampdB1) ) - (first(ydB2)-first(ampdB1) )

        p4 = plot( ampdB1, [agc_undamping fast_undamping agc_undamping.*fast_undamping ] )
end


if true

        f_sig = 250.0
        n_ch = 71

        a3, ampdB1, ydB3, agc_undamping, fast_undamping = compression_data( carfac, ampdB, f_sig, fs, n_ch )

        p5 = plot()
        plot_compression!( ampdB1, ydB3 )
        # savefig( "compression.png" )

        @show (last(ydB3)-last(ampdB1) ) - (first(ydB3)-first(ampdB1) )

        p6 = plot( ampdB1, [agc_undamping fast_undamping agc_undamping.*fast_undamping ] )

end

p7 = plot()
plot_compression!( ampdB1, [ ydB1 ydB2 ydB3 ] )