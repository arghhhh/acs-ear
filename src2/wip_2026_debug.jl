
# attempt to match new model with original model:

# based on 

#function test_whole_carfac(do_plots, version_string, non_decimating)


include( "env.jl" )

using Printf
using FFTW
using Plots, ColorSchemes
import Statistics


figures = Plots.Plot[]  


do_plots       = true
version_string = :one_cap
non_decimating = false



	# % Test: Make sure that the AGC adapts to a tone.
	# % Test with open-loop impulse response.

	status = false # 0;

	fs = 22050
	fp = 1000 # % Probe tone
	t = (0:(1/fs):(2 - 1/fs))  #  % Sample times for 2s of tone
#	t = 1/fs * (1:16)
#	t = 1/fs * (0:2)
	amplitude = 0.1
	sinusoid = reshape( amplitude * sin.(2 * pi * t * fp), :, 1 )

    #    sinusoid = vcat( zeros( length(sinusoid1) ), sinusoid1 ) 

     #   sinusoid = reshape( sinusoid, :, 1 )

    #    sinusoid = reshape( ones(1000), :, 1 )


	@show size(sinusoid)

	impulse_dur = 0.5; # % 0.25 is about enough; this is conservative.
	impulse = zeros(round(Int,impulse_dur*fs), 1); # % For short impulse wave.



	impulse[1] = 1e-4; # % Small amplitude impulse to keep it pretty linear

	if non_decimating
		CAR_params = CAR_params_default();
		AGC_params = AGC_params_default();
		AGC_params.decimation = [1, 1, 1, 1]; # % Override default.
	#	CF = CARFAC_Design(1, 22050, CAR_params, AGC_params, version_string);
		CF = CARFAC_Design_version( version_string, 1, 22050, CAR_params, AGC_params );
	else
	#	CF = CARFAC_Design(1, 22050, version_string); # % With default decimation.
	# use alternate version with the design string up front:
		CF = CARFAC_Design_version(version_string, 1, 22050 ); # % With default decimation.
	end
	# CF = CARFAC_Init(CF);
	CF_state_ears = CARFAC_Init(CF);

        ######
        #######  Removed the following lines, so CAR filters remain in zero state:
        ######

        if false
                CF.open_loop = true # 1; # % For measuring impulse response.
                CF.linear_car = true # 1; # % For measuring impulse response.
                (; CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, impulse);
                bm_initial = BM
        else
                bm_initial = copy(impulse)
        end

	CF.open_loop = false # 0; # % To let CF adapt to signal.
	CF.linear_car = false # 0; # % Normal mode.
#	(; naps, CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, sinusoid)
        (; naps, CF, CF_state_ears, BM, seg_ohc, seg_agc, firings_all ) = CARFAC_Run_Segment(CF, CF_state_ears, sinusoid)
	nap = naps
	bm_sine = BM

	# % Capture AGC state response at end, for analysis later.
	num_stages = CF.AGC_params.n_stages; # % 4
	agc_response = zeros(num_stages, CF.n_ch);
	for stage = 1:num_stages
		agc_response[stage, :] = CF_state_ears[1].AGC_state.AGC_memory[:, stage];
	end


if false  #######################################

	CF.open_loop = true # 1; # % For measuring impulse response.
	CF.linear_car = true # 1; # % For measuring impulse response.
	(; CF, CF_state_ears ) = CARFAC_Run_Segment(CF, CF_state_ears, 0*impulse); # % To let ringing die out.
	(; CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, impulse);
	bm_final = BM

	# % Now compare impulse responses bm_initial and bm_final.

	fft_len = 2048; # % Because 1024 is too sensitive to delay and such.
	num_bins = div(fft_len,2) + 1;
	freqs = (fs / fft_len) * (0:num_bins-1);

	# @show bm_initial

	# do FFT column wise - MATLAB style - needs extra ,1 arg
	initial_freq_response = 20*log10.(abs.(fft(bm_initial[1:fft_len, :],1)));
	final_freq_response   = 20*log10.(abs.(fft(bm_final[1:fft_len, :],1)));
	initial_freq_response = initial_freq_response[1:num_bins, :];
	final_freq_response   = final_freq_response[1:num_bins, :];

	if do_plots
	#	# % Match Figure 19.9(right) of Lyon's book
	#	figure; clf
	#	semilogx(freqs, initial_freq_response, ':')
	#	hold on
	#	semilogx(freqs, final_freq_response, '-')
	#	ylabel("dB")
	#	xlabel("Frequency")
	#	title("Initial (dotted) vs. Adapted at 1kHz (solid) Frequency Response")
	#	axis([0, max(freqs), -100, -15])
	#	%   savefig('/tmp/whole_carfac_response.png')
	#	drawnow

		p = plot()
                push!( figures, p )

		@show size(initial_freq_response)

		plot!( freqs, initial_freq_response , xlim=(freqs[2],freqs[end]), xaxis=:log, linestyle=:dot )
		plot!( freqs, final_freq_response  )
		plot!( ylabel="dB", xlabel="Frequency")
		plot!( title="Initial (dotted) vs. Adapted at 1kHz (solid) Frequency Response")
		plot!( legend=false )
		plot!( ylim=(-100,-15) )

global dbg1 = freqs
global dbg2 = initial_freq_response

	end

	# initial_resps = []; # % To collect peak [cf, amplitude, bw] per channel.
	# final_resps = [];
	initial_resps1 = Float64[] # % To collect peak [cf, amplitude, bw] per channel.
	final_resps1   = Float64[] # % To collect peak [cf, amplitude, bw] per channel.
	for ch = 1:CF.n_ch
	#	initial_resps = [initial_resps; find_peak_response(freqs, initial_freq_response[:, ch], 3)];
		push!( initial_resps1 , find_peak_response(freqs, initial_freq_response[:, ch], 3)... ) ;
	#	final_resps = [final_resps; find_peak_response(freqs, final_freq_response[:, ch], 3)];
		push!( final_resps1, find_peak_response(freqs, final_freq_response[:, ch], 3)... );
	end
	initial_resps = reshape( initial_resps1, 3, : )'
	final_resps   = reshape( final_resps1  , 3, : )'


	if do_plots
	#	figure; clf('reset')
	#	plot(1:CF.n_ch, initial_resps(:,2), ':')
	#	hold on
	#	plot(1:CF.n_ch, final_resps(:,2))
	#	xlabel("Ear Channel #")
	#	ylabel("dB")
	#	title("NP: Initial (dotted) vs. Adapted (solid) Peak Gain")
	#	# %.   savefig('/tmp/whole_carfac_peak_gain.png')
	#	drawnow
		p = plot()
                push!( figures, p )
		plot!(1:CF.n_ch, initial_resps[:,2], linestyle=:dot)
		plot!(1:CF.n_ch, final_resps[:,2])
		plot!( xlabel="Ear Channel #", ylabel="dB") 
		plot!( title="NP: Initial (dotted) vs. Adapted (solid) Peak Gain")

	end

	# % Test for change in peak gain after adaptation.
	# % Golden data table of frequency, channel, peak frequency, delta:
	if version_string == :one_cap
		# % Before moving ac coupling into CAR, peaks gains a little different:
		# %   125, 65,   118.944255,     0.186261
		# %   250, 59,   239.771898,     0.910003
		# %   500, 50,   514.606412,     7.243568
		# %   1000, 39,  1099.433179,    31.608529
		# %   2000, 29,  2038.873929,    27.242882
		# %   4000, 17,  4058.881505,    13.865787
		# %   8000,  3,  8289.882476,     3.574972
		results = [
		   125   65        119.007          0.264
		;  250   59        239.791          0.986
		;  500   50        514.613          7.309
		; 1000   39       1099.436         31.644
		; 2000   29       2038.875         27.214
		; 4000   17       4058.882         13.823
		; 8000    3       8289.883          3.565
		];
	elseif version_string == :two_cap
		results = [
		   125   65        119.007          0.258
		;  250   59        239.791          0.963
		;  500   50        514.613          7.224
		; 1000   39       1099.436         31.373
		; 2000   29       2038.875         26.244
		; 4000   17       4058.882         12.726
		; 8000    3       8289.883          3.212
		];
	elseif version_string == :do_syn
		results = [
		   125   65        119.007          0.238
		;  250   59        239.791          0.942
		;  500   50        514.613          7.249
		; 1000   40       1030.546         30.843
		; 2000   29       2038.875         22.514
		; 4000   17       4058.882          7.691
		; 8000    4       7925.624          1.935
		];
	end

	# % Print data blocks that can be used to update golden test data.
	test_cfs = 125 * 2.0 .^ (0:6)
	# % Print the golden data table for the above test center frequencies.
	@printf "Golden data for Matlab:\n"
	for j = 1:length(test_cfs)
		cf = test_cfs[j];
		c = find_closest_channel(final_resps[:,1], cf);
		dB_change = initial_resps[c, 2] - final_resps[c, 2];
		@printf "  %d, %2d, %12.3f, %12.3f\n" cf c initial_resps[c, 1] dB_change
	end
	# % Print the golden data table for the Python test, 0-based channel index.
	@printf "Golden data for Python:\n"
	for j = 1:length(test_cfs)
		result = results[j, :];
		cf = test_cfs[j];
		c = find_closest_channel(final_resps[:,1], cf);
		dB_change = initial_resps[c, 2] - final_resps[c, 2];
		@printf "        %d: [%d, %.3f, %.3f],\n" cf c-1 initial_resps[c, 1] dB_change
	end

	for j = 1:size(results, 1)
		result = results[j, :];
		cf = result[1];
		expected_c = Int( result[2] ); # % Which will be one more than in the Python.
		expected_cf = result[3];
		expected_change = result[4];
		c = find_closest_channel(final_resps[:,1], cf);

		@show c expected_c size(initial_resps)

		dB_change = initial_resps[expected_c, 2] - final_resps[expected_c, 2];
		@printf "Channel %d has CF of %6f and an adaptation change of %f dB\n" expected_c initial_resps[expected_c, 1] dB_change

		if c != expected_c
			status = true # 1;
			@printf "c = %d should equal expected_c %d\n" c expected_c
		end

		if non_decimating
			tolerance = expected_cf / 1000;
		else
			tolerance = expected_cf / 10000;
		end
		if abs(initial_resps[expected_c, 1] - expected_cf) > tolerance
			status = true # 1;
			@printf "initial_resps(c, 0) = %8.3f not close to expected_cf %8.3f\n" initial_resps[c, 1] expected_cf
		end
		if non_decimating
			tolerance = 0.02 + expected_change/30;
		else
			tolerance = 0.01; # % dB
		end
		if abs(dB_change - expected_change) > tolerance
			status = true # 1;
			@printf "dB_change = %6.3f not close to expected_change %6.3f\n" dB_change expected_change
		end
	end

	if do_plots # % Plot final AGC state
	#	figure
	#	plot(agc_response')
	#	title("Steady state spatial responses of the stages")
	#	axis([0, CF.n_ch + 1, 0, 1])
	#	drawnow
		p = plot()
                push!( figures, p )
		plot!( agc_response' )
		plot!( title="Steady state spatial responses of the stages" )
		plot!( ylim=(0,1) )

	end

end ##################

#error("stop")



fs = 22050.0
cfs = pole_freqs( 30.0, 0.85 * 22050/2 )

@assert maximum( abs.( CF.pole_freqs - cfs ) ) < 1e-9

car = CAR_filter.( cfs, fs )

# compare:

@assert CF.ears[1].CAR_coeffs.r1_coeffs == [ each_car.r1 for each_car in car ]
@assert CF.ears[1].CAR_coeffs.a0_coeffs == [ each_car.a0 for each_car in car ]
@assert CF.ears[1].CAR_coeffs.c0_coeffs == [ each_car.c0 for each_car in car ]
@assert CF.ears[1].CAR_coeffs.zr_coeffs == [ each_car.zr for each_car in car ]
@assert CF.ears[1].CAR_coeffs.h_coeffs  == [ each_car.h  for each_car in car ]

carfac = CARFAC_Loop( fs, car )


if false

       # xs = vcat( length(sinusoid), sinusoid )

        xs = sinusoid[:,1]

     #   ys = sinusoid |> carfac
        ys = xs |> carfac

        global state
        y,state = iterate( ys )
   #     for x in sinusoid[2:end]
        for i in 2:length(ys)
                global state
                y,state = iterate( ys, state )
        end

        # compare end AGC states:
        @show maximum( abs.( state[2][5].AGC_memory' - agc_response ))

        # compare the feedback AGC value (interpolated)
        display( CF_state_ears[1].CAR_state.zB_memory ./ CF.ears[1].CAR_coeffs.zr_coeffs )
        display( [ x.zB_memory for x in state[2][6] ] )
        diffs = CF_state_ears[1].CAR_state.zB_memory ./ CF.ears[1].CAR_coeffs.zr_coeffs - [ x.zB_memory for x in state[2][6] ] 


        #compare BM
        orig_bm = bm_sine[end,:,1]
        new_bm  = y.bm
        display( orig_bm - new_bm )

plot( agc_response[1,:] )
plot!( state[2][5].AGC_memory[:,1] )
        error("stopped")

end


a = sinusoid |> carfac  |> CollectArrays

# look at all agc outputs (71 channels at each time sample):
diffs = a.agc_out' - seg_agc
 display(diffs)

# look at BM at each time sample:
diffs = bm_sine - a.bm'
display(diffs)




to_dB(x) = 20.0 * log10(x)
from_dB(x) = 10.0^(x/20) 


plot( to_dB.( a.mag'[end,:] ) )

plot( agc_response[1,:] )
plot!( a.agc_state[:,:,end] )

@show maximum( abs.( agc_response[1,:]-a.agc_state[:,1,end] ) )

# plot the AGC signal vs time:
plot( a.agc_undamping[1,:] )

