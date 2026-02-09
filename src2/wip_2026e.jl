
import SNR
import Sequences


n_ch = 71
one71 = zeros(n_ch)
one71[37] = 1.0

a = Sequences.concatenate( Sequences.Single( one71 ) , Base.Iterators.repeated( zeros(n_ch) ) )  |> Processors.Take(5) |> CollectArrays

println("\n\n\n\n" )

N = 4*65536
fs = 48e3

agc1 = CARFAC_AGC( fs, n_ch )
agc2 = CARFAC_AGC( fs, n_ch )
agc2.spatial_FIR[ : , : ] .= [ 0.0, 1.0, 0.0 ]

b1 = Sequences.concatenate( Sequences.Single( one71 ) , Base.Iterators.repeated( zeros(n_ch) ) )  |> agc1 |> Processors.Take(N) |> CollectArrays
b2 = Sequences.concatenate( Sequences.Single( one71 ) , Base.Iterators.repeated( zeros(n_ch) ) )  |> agc2 |> Processors.Take(N) |> CollectArrays

fs = 48e3


function plot_response!( ys, fs )
        #ys = impulse |> CascadeScan( Constant_undamping.(undamping) .|> car .|> extract_y ) |> CollectArrays
        # complex_spectra = FFTW.fft( identity.(ys), 2 )
        complex_spectra = FFTW.fft( ys )
        db_spectra = 20 * log10.(abs.(complex_spectra) .+ 1e-50)
        #plot(db_spectra')

        faxis = range( 0 ; length = length( db_spectra ), step = fs / length(ys) )

        plot!( faxis, db_spectra )
        plot!(legend=false)
        plot!( xlim=(10.1, 1000.0), xaxis=:log )
        plot!( ylim=(-60,-20) )
end

plot()
plot_response!( b1.y[37,:], fs )
plot_response!( b2.y[37,:], fs )
plot!( xlim=(0.1, 10000.0), xaxis=:log )
plot!( ylim=(-60,-20) )



# tests similar to those in CARFAC_Test:
# these are spatially an impulse, but temporally a step response


# function test_AGC_steady_state_core(do_plots, CF)
function test_AGC_steady_state_core1( agc )

        n_ch = agc.n_ch
	agc_input = zeros(n_ch)
	test_channel = 40
	n_points = 16384
	num_stages = agc.n_AGC_stages # % 4
	decim = agc.decimation[1] # % 8
	agc_response = zeros(num_stages, div(n_points , decim), n_ch)
	num_outputs = 0

        # do first sample (initizalizes state)
        agc_input[test_channel] = 100 # % Leave other channels at 0 input.
        y,state = Processors.process( agc, agc_input )

        # do remaining steps:
	for i = 2:n_points
		agc_input[test_channel] = 100 # % Leave other channels at 0 input.
	#	agc_state, agc_updated = CARFAC_AGC_Step(agc_input, CF.ears[1].AGC_coeffs, CF_state_ears[1].AGC_state)

                y,state = Processors.process( agc, agc_input, state )

		if y.updated # % Every 8 samples.
			num_outputs = num_outputs + 1
			for stage = 1:num_stages
				agc_response[stage, num_outputs, :] = state.AGC_memory[:, stage]'
			end
		end
	end

	# % Test: Plot spatial response to match Figure 19.7
	# if do_plots
	#	figure
	#	hold on
	#	plot(squeeze(agc_response(:, end, :))')
	#	title('Steady state spatial responses of the stages')
	#	drawnow

	
                p = plot!( agc_response[:, end, : ]')
        #        push!( figures, p )
		plot!( title = "Steady state spatial responses of the stages" )

                return agc_response

end

# First test - defaults:
fs = 22050.0 # for comparison with CARFAC_Test
agc = CARFAC_AGC( fs, n_ch )

plot()
y1 = test_AGC_steady_state_core1( agc )


# Second test - simpler:

agc_params = AGC_params()
agc_params.decimation = [8, 1, 1, 1]; # % Override default, simpler.
agc = CARFAC_AGC( fs, n_ch, agc_params )
y2 = test_AGC_steady_state_core1( agc )


agc_params = AGC_params()
agc_params.decimation = [1, 1, 1, 1] # % Override default.
agc = CARFAC_AGC( fs, n_ch, agc_params )
y3 = test_AGC_steady_state_core1( agc )


plot()
plot!( y1[ 1, :, 40 ] )
plot!( y2[ 1, :, 40 ] )
plot!( y3[ 1, :, 40 ] )