

include( "include.jl" )
using Plots
using FFTW

using SNR
using Windows
using Sequences

function plot_response!( car, undamping, color=:blue, indxs = (1:5:length(car)), fs=48e3 )

        extract_y = fill(  Processors.Mapb{x->x.y, Float64}(), length(car) )

        ys = impulse |> CascadeScan( Constant_undamping.(undamping) .|> car .|> extract_y ) |> CollectArrays
        # complex_spectra = FFTW.fft( identity.(ys), 2 )
        complex_spectra = FFTW.fft( ys, 2 )
        db_spectra = 20 * log10.(abs.(complex_spectra) .+ 1e-50)
        #plot(db_spectra')

       # @show size(ys)
        f_axis = ( 0:size(ys)[2]-1 ) * fs / size(ys)[2]

     #   n = div( length(cfs) , 10 )
        plot!(f_axis, db_spectra[indxs,:]', color = color )
        plot!(legend=false)
        plot!( xlim=(10,20e3), xaxis=:log )
        plot!( ylim=(-25,75) )
        plot!( xticks=[10,100,1000,10000] )
        plot!( xlabel = "Frequency (Hz)" )
        plot!( ylabel = "CARFAC Channel Response (dB)" )
end


function do_plots_car( car, indxs= (1:5:length(car)), fs = 48e3 )
        p = plot()
        plot_response!( car, 1.0, :blue   , indxs, fs)
        plot_response!( car, 0.5, :gray   , indxs, fs)
        plot_response!( car, 0.0, :green  , indxs, fs)
        plot!( dpi=600 )
        plot!( framestyle=:box )

        return p
end

# error("stop")

function plot_unit_circle()
        unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
        plt = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
        plot!( unit_circle )

        return plt
end


function do_pole_zero_plots( car )

        linear_resonators = [ LinearResonator( r, 1.0 ) for r in car ]
        p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
        z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )


        indxs = 1:findfirst( f->(f<1000), cfs )


        unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
        plt = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
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

function do_pole_zero_plots!( car, f_lim, undamping, color = :blue )

        @show length(car)


                linear_resonators = [ LinearResonator( r, undamping ) for r in car ]
                p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
                z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )


          #      indxs = 1:findfirst( f->(f<f_lim), cfs )

          #      indxs = 

           #     scatter!( z[indxs], markershape=:circle, markercolor=:white )
           #     scatter!( p[indxs], markershape=:xcross  )

                scatter!( z, markerstrokecolor = color, markershape=:circle, markercolor=:white )
                scatter!( z[end-1:end], markerstrokewidth = 3, markerstrokecolor = color, markershape=:circle, markercolor=:white )
                scatter!( p, color = color, markershape=:xcross  )
                scatter!( p[end-1:end], markerstrokewidth = 3, color = color, markershape=:xcross  )

        
        #        linear_resonators = [ LinearResonator( r, 0.0 ) for r in car ]
        #        p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
        #        z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )
#
        #        scatter!( z[indxs], markershape=:circle, markercolor=:white )
        #        scatter!( p[indxs], markershape=:xcross )

        


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











function do_single_resonator_DOHC_amplitude_sweep( car, chan, f_sig, undamping )

        #  Single Resonator & DOHC - amplitude sweep

        fs = 48e3
   #     f_sig = 997.123456
        ampdBs = range(-100, 100.0; length = 101 )

        n_drop = 100
        N      = 1000



        car_dohc = CAR_DOHC.( car )

        sys = CascadeScanAdapt( Constant_undamping.(undamping) .|> car_dohc , x->x.y, x->x.y ) |> Processors.MapT{Float64}( x->x[chan] )
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


function report_plot_poles_zeros( fs, fplotmin, f_high = 0.85*0.5*fs )
        ERB_per_step = 0.5
  #      f_high = 0.85*0.5*fs
        cfs = pole_freqs( fplotmin, f_high, ERB_per_step )
        car = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )

        unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
        p = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
        plot!( unit_circle, color=:gray )
        do_pole_zero_plots!( car, fplotmin, 1.0, :blue )
        do_pole_zero_plots!( car, fplotmin, 0.0, :green )

        return p
end

report_plot_poles_zeros( 48000.0, 5000.0, 15e3 )
plot!( dpi=600 );savefig( "pz_48k_5k.png" )
report_plot_poles_zeros( 48000.0,  500.0, 15e3 )
plot!( dpi=600 );savefig( "pz_48k_500.png" )
report_plot_poles_zeros( 22050.0,    0.0 )
plot!( dpi=600 );savefig( "pz_22k_0.png" )



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
#f_high = 0.85*0.5*fs
f_high = 15000.0
# ys = impulse |> CascadeScan( CAR_filter.( pole_freqs( 30, f_high, ERB_per_step ), fs, 2.0 ^ ERB_per_step ) ) |> CollectArrays
cfs = pole_freqs( 30, f_high, ERB_per_step )
car = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )
# car = CAR_filter2.( cfs, fs, ERB_per_step  )
# extract_y = fill(  Processors.Mapb{x->x.y, Float64}(), length(cfs) )


figures = []

indxs = vcat( 1:5:79, 79 )
p = do_plots_car( car, indxs, 48e3 )
savefig( "car_responses.png" )
push!( figures, p )

p = do_pole_zero_plots( car )
push!( figures, p )

p = plot_impulse_responses( car, 48e3 )
push!( figures, p )

chan = 40
f_sig = cfs[chan]

undamping = 0.0
p = do_single_resonator_DOHC_amplitude_sweep( car, chan, f_sig, undamping )
push!( figures, p )

error("stop")


unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
p = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
plot!( unit_circle )
do_pole_zero_plots!( car, 500.0, 1.0 )
do_pole_zero_plots!( car, 500.0, 0.0 )
push!( figures, p )

unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
p = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
plot!( unit_circle )
do_pole_zero_plots!( car, 10000.0, 1.0 )
do_pole_zero_plots!( car, 10000.0, 0.0 )
push!( figures, p )


ERB_per_step = 0.25
cfs = pole_freqs( 30, f_high, ERB_per_step )
car2 = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )
p = plot( size=(600,600), aspect_ratio=:equal )
p = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
plot!( unit_circle )

do_pole_zero_plots!( car2, 1000.0, 1.0 )
do_pole_zero_plots!( car2, 1000.0, 0.0 )
push!( figures, p )

do_plots_car( car2 )

ERB_per_step = 0.25
cfs = pole_freqs( 30, f_high, ERB_per_step )
car3 = CAR_filter2.( cfs, fs, ERB_per_step  )
#p = plot( size=(600,600), aspect_ratio=:equal )
p = plot( size=(600,600), aspect_ratio=:equal, framestyle=:box, legend = false, xlabel = "Re(z)", ylabel="Im(z)" )
plot!( unit_circle )

do_pole_zero_plots!( car3, 1000.0, 1.0 )
do_pole_zero_plots!( car3, 1000.0, 0.0 )
push!( figures, p )


plot( figures[end-1], figures[end], size=(700,1200), layout = (2,1) )
push!( figures, p )


error("stop")

carfac = CARFAC_Loop( fs, car )

# a = impulse[1:100] |> carfac |> CollectArrays

amp_dB = 40.0

ch = 47
f_sig = cfs[ch]

xs = from_dB( amp_dB ) * Sequences.Sinusoid( f_sig, fs ) 
N = 100000

a = xs |> carfac |> Processors.Take(N) |> CollectArrays
plot( a.zB[ch,:] )
plot( a.nlf_out[ch,:] )


plot( to_dB.( a.mag'[end,:] ) )
plot( to_dB.( a.mag'[:,1:5:end] ) )

ERB_per_step = 0.5
cfs = pole_freqs( 30, f_high, ERB_per_step )
car = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )


undamping = [ 0.0 for i in 1:length(cfs) ]
tf = tfn( car, undamping )
freqs = logrange( 20.0, 20e3 ; length = 1000 )
z_invs = PolyTransform.f_to_zinv.( freqs, fs )
nums = tf.numerator
dens = tf.denominator
mags = zeros( length( freqs ) )
cumulative_gain = zeros( length(nums), length(freqs) )
for (i,(n,d)) in enumerate( zip( nums, dens  ) )
        stg_gain = to_dB.( abs.( n.(z_invs) ./ d.(z_invs) ) )
        mags += stg_gain 
        cumulative_gain[i,:] .= mags
end

plot( freqs, cumulative_gain[ 1:5:end, : ]', xaxis=:log, ylim=(-50,150), legend=false )


zetas = get_zeta_from_s_poly.( s_from_z_poly.( dens, fs ) )
plot( cfs, zetas, xaxis =:log )

