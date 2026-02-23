

include( "include.jl" )
using Plots
using FFTW

using SNR
using Windows
using Sequences

function plot_response!( car, undamping )

        ys = impulse |> CascadeScan( Constant_undamping.(undamping) .|> car .|> extract_y ) |> CollectArrays
        # complex_spectra = FFTW.fft( identity.(ys), 2 )
        complex_spectra = FFTW.fft( ys, 2 )
        db_spectra = 20 * log10.(abs.(complex_spectra) .+ 1e-50)
        #plot(db_spectra')

        n = div( length(cfs) , 10 )
        plot!(db_spectra[1:n:length(cfs),:]')
        plot!(legend=false)
        plot!( xlim=(1,8192), xaxis=:log )
        plot!( ylim=(-25,75) )
end


function do_plots_car( car )
        p = plot()
        plot_response!( car, 1.0 )
        plot_response!( car, 0.5 )
        plot_response!( car, 0.0 )
        return p
end

# error("stop")

function do_pole_zero_plots( car )

        linear_resonators = [ LinearResonator( r, 1.0 ) for r in car ]
        p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
        z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )


        indxs = 1:findfirst( f->(f<1000), cfs )


        unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
        plt = plot( size=(600,600), aspect_ratio=:equal )
        plot!( unit_circle )

        scatter!( z[indxs], markershape=:circle, markercolor=:white )
        scatter!( p[indxs], markershape=:xcross  )


        linear_resonators = [ LinearResonator( r, 0.0 ) for r in car ]
        p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
        z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )

        scatter!( z[indxs], markershape=:circle, markercolor=:white )
        scatter!( p[indxs], markershape=:xcross )


        return plt
end


# plot!( xlim=(-1,0) )


function plot_impulse_responses( car, chan = 40, fs = 48e3 )

        impulse = zeros(16384); impulse[1] = 1





        car_dohc = CAR_DOHC.( car )

        ys = impulse |> CascadeScanAdapt( Constant_undamping.(1.0) .|> car , x->x.y, identity ) 

        car2 = CascadeScanAdapt( Constant_undamping.(1.0) .|> car , x->x.y, identity )

        adapt(x) = x.y
#        keep(x) = [ x.y, x.y ]
        keep(x) = x.y

        impulse |> CascadeScanAdapt( Constant_undamping.(1.0) .|> car , adapt, keep ) |> CollectArrays


        ys = impulse |> CascadeScanAdapt( Constant_undamping.(0.5) .|> car_dohc , x->x.y, x->x.y ) |> CollectArrays
        ys1 = ys'[:,1:10:end]
        ys2 = ys1 .+ [ 20 40 60 80 100 120 140 160 ]
        plot( ys2 )
        plot!( xlim=(0,2000) , legend = false )



        # impulse = [1.0, 0.0 ]

        ys1 = impulse |> CascadeScanAdapt( Constant_undamping.(0.0) .|> car_dohc , x->x.y, x->x.y ) |> CollectArrays
        ys2 = impulse |> CascadeScanAdapt( Constant_undamping.(0.5) .|> car_dohc , x->x.y, x->x.y ) |> CollectArrays
        ys3 = impulse |> CascadeScanAdapt( Constant_undamping.(1.0) .|> car_dohc , x->x.y, x->x.y ) |> CollectArrays

        chan = 48

        p = plot(  ys1[chan,:] )
        plot!( ys2[chan,:] )
        plot!( ys3[chan,:] )
        plot!( xlim=(0,2000) , legend = false )

        return p
end




#=


cfs = pole_freqs( 30, f_high, ERB_per_step )
zeta = 0.1

@show Q = 1/(2*zeta)

xaxis = range( 1.0, fs/2 ; length = 1000 )

r = exp.( -zeta * 2 * pi * xaxis / fs )

plot( xaxis, r )

=#


import SNR
import Sequences


to_dB(x) = 20.0 * log10(x)
from_dB(x) = 10.0^(x/20) 











function do_single_resonator_DOHC_amplitude_sweep( car, chan, f_sig )

        #  Single Resonator & DOHC - amplitude sweep

        fs = 48e3
   #     f_sig = 997.123456
        ampdBs = range(-100, 100.0; length = 101 )

        n_drop = 100
        N      = 1000



        car_dohc = CAR_DOHC.( car )

        sys = CascadeScanAdapt( Constant_undamping.(0.0) .|> car_dohc , x->x.y, x->x.y ) |> Processors.MapT{Float64}( x->x[chan] )
        dB = 0.0

        res = nothing
        for dB in ampdBs
                x = from_dB(dB) * Sequences.Sinusoid( f_sig, fs ) 

                y1 = x |> sys |> Processors.Take(N+n_drop) |> Processors.Drop(n_drop) |> collect

                mag, residual1, bhat = SNR.determine_snr( y1, f_sig/fs * (1:5)  )

                keep = (; mag = to_dB.(mag), bhat)

                if res == nothing
                        res = new_arrays_first_row( keep )
                else
                        arrays_push!( res, keep )
                end

        end

        # finalize shape:
        res = NamedTuple{ keys(res) }( map( vector_reshape, values(res) ) )

        # plot( ampdBs, res.mag[1,:] )
        p = plot( ampdBs, res.mag' )
        plot!( ampdBs, ampdBs )

        return p
end






# response.( CAR_filter.( pole_freqs( 30, 0.85*0.5*22050 ), 22050) ) |> CollectArrays
# impulse |> CascadeScan( CAR_filter.( pole_freqs( 30, 0.85*0.5*22050 ), 22050) ) |> collect
impulse = zeros(16384); impulse[1] = 1
fs = 22050.0
fs = 48000.0
#fs = 96000
ERB_per_step = 0.5
#ERB_per_step = 0.25
#ERB_per_step = 0.125
#ERB_per_step = 0.0625
#ERB_per_step = 0.0375
#ERB_per_step = 0.01875
f_high = 0.85*0.5*22050
f_high = 15000.0
# ys = impulse |> CascadeScan( CAR_filter.( pole_freqs( 30, f_high, ERB_per_step ), fs, 2.0 ^ ERB_per_step ) ) |> CollectArrays
cfs = pole_freqs( 30, f_high, ERB_per_step )
car = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )
car = CAR_filter2.( cfs, fs, ERB_per_step  )
extract_y = fill(  Processors.Mapb{x->x.y, Float64}(), length(cfs) )




        fs = 48e3

        freqs = range(100.0, 10000.0; length = 501 )

        n_drop = 2000
        N      = 2000



        # pass the "y" output to next stage, and keep everything:
        sys = CascadeScanAdapt( Constant_undamping.(1.0) .|> car , x->x.y, identity )
        dB = 0.0

        res_y_ac    = Float64[]
        res_ymag_dc = Float64[]
        res_ymag_ac = Float64[]
        res_z1_ac   = Float64[]
        res_z2_ac   = Float64[]

        for f_sig in freqs
   # f_sig = 1000.0
                x = from_dB(dB) * sqrt(2) * Sequences.Sinusoid( f_sig, fs ) |> Processors.Take(N+n_drop) |> collect

                y1 = x |> sys |> Processors.Take(N+n_drop) |> CollectArrays

                n_ch = 40
                y2 = y1[n_ch,:]
  

                y    = [ y.y   for y in y2[ n_drop+1:end ] ]
                ymag = [ y.mag for y in y2[ n_drop+1:end ] ]
                y_z1 = [ y.z1  for y in y2[ n_drop+1:end ] ]
                y_z2 = [ y.z2  for y in y2[ n_drop+1:end ] ]

                y_dc, y_ac = SNR.estimate_dc_ac( y    )
                ymag_dc, ymag_ac = SNR.estimate_dc_ac( ymag )
                _, z1_ac = SNR.estimate_dc_ac( y_z1 )
                _, z2_ac = SNR.estimate_dc_ac( y_z2 )
 
                push!( res_y_ac   , y_ac    )
                push!( res_ymag_dc, ymag_dc )
                push!( res_ymag_ac, ymag_ac )
                push!( res_z1_ac  , z1_ac   )
                push!( res_z2_ac  , z2_ac   )

        end


        p = plot( freqs, to_dB.([ res_y_ac res_ymag_dc res_ymag_ac res_z1_ac res_z2_ac ]), xaxis=:log  )

