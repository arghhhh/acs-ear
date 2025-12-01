


# this is derived from test_whole_carfac

function wip_test_whole_carfac(; fp = 1000, fs = 22050, amplitude = 0.1, version_string = :one_cap, non_decimating = false )
	# % Test: Make sure that the AGC adapts to a tone.
	# % Test with open-loop impulse response.

	# version_string = :one_cap ; non_decimating = false

        figures = Plots.Plot[] 

#	fs = 22050
#	fp = 1000 # % Probe tone
	t = (0:(1/fs):(2 - 1/fs))  #  % Sample times for 2s of tone
#	amplitude = 0.1
	sinusoid = reshape( amplitude * sin.(2 * pi * t * fp), :, 1 )

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
		CF = CARFAC_Design_version(version_string, 1, 22050 ); # % With default decimation.
	end
	# CF = CARFAC_Init(CF);
#	CF_state_ears = CARFAC_Init(CF);

	CF.open_loop = true # 1; # % For measuring impulse response.
	CF.linear_car = true # 1; # % For measuring impulse response.
#	(; CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, impulse);
#	bm_initial = BM

	cf = Processors.Stateful( CF_Runner( CF ) )
	r = impulse |> cf |> CollectNamedTuples
	bm_initial_1 = permutedims( r.BM, (3,1,2) )
	cf.p.CF.open_loop = false
	cf.p.CF.linear_car = false
	r = sinusoid |> cf |> CollectNamedTuples

	bm_sine_1 = permutedims( r.BM, (3,1,2) )
	nap_1 = permutedims( r.naps, (3,1,2) )


#	CF.open_loop = false # 0; # % To let CF adapt to signal.
#	CF.linear_car = false # 0; # % Normal mode.
#	(; naps, CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, sinusoid);
#	nap = naps
#	bm_sine = BM

#	@show extrema( bm_initial - bm_initial_1 )
#	@show extrema( nap        - nap_1        )
#	@show extrema( bm_sine    - bm_sine_1    )


#	# % Capture AGC state response at end, for analysis later.
#	num_stages = CF.AGC_params.n_stages; # % 4
#	agc_response = zeros(num_stages, CF.n_ch);
#	for stage = 1:num_stages
#		@assert cf.state[1].AGC_state.AGC_memory == CF_state_ears[1].AGC_state.AGC_memory
#		agc_response[stage, :] = CF_state_ears[1].AGC_state.AGC_memory[:, stage];
#	end

#	CF.open_loop = true # 1; # % For measuring impulse response.
#	CF.linear_car = true # 1; # % For measuring impulse response.

	cf.p.CF.open_loop = true
	cf.p.CF.linear_car = true


#	(; CF, CF_state_ears ) = CARFAC_Run_Segment(CF, CF_state_ears, 0*impulse); # % To let ringing die out.
#	(; CF, CF_state_ears, BM ) = CARFAC_Run_Segment(CF, CF_state_ears, impulse);
#	bm_final = BM

	r = 0*impulse |> cf |> CollectNamedTuples
	r =   impulse |> cf |> CollectNamedTuples
	bm_final_1 = permutedims( r.BM, (3,1,2) )

#	@assert bm_final_1 == bm_final

	# after this point in this function - it is just analysis - no more simulation.

	# % Now compare impulse responses bm_initial and bm_final.

	fft_len = 2048; # % Because 1024 is too sensitive to delay and such.
	num_bins = div(fft_len,2) + 1;
	freqs = (fs / fft_len) * (0:num_bins-1);

	# @show bm_initial

	# do FFT column wise - MATLAB style - needs extra ,1 arg
	initial_freq_response = 20*log10.(abs.(fft(bm_initial_1[1:fft_len, :],1)));
	final_freq_response   = 20*log10.(abs.(fft(bm_final_1[1:fft_len, :],1)));
	initial_freq_response = initial_freq_response[1:num_bins, :];
	final_freq_response   = final_freq_response[1:num_bins, :];

	#if do_plots
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

	#end

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


	#if do_plots
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

	#end


	# #if do_plots # % Plot final AGC state
	# #	figure
	# #	plot(agc_response')
	# #	title("Steady state spatial responses of the stages")
	# #	axis([0, CF.n_ch + 1, 0, 1])
	# #	drawnow
	# 	p = plot()
        #         push!( figures, p )
	# 	plot!( agc_response' )
	# 	plot!( title="Steady state spatial responses of the stages" )
	# 	plot!( ylim=(0,1) )
# 
	# #end
	return figures
end


r1 = wip_test_whole_carfac(; fp = 1000, fs = 22050, amplitude = 0.1 )
r2 = wip_test_whole_carfac(; fp = 2000, fs = 22050, amplitude = 0.1 )

anim = @animate for i ∈ [r1,r2]
    plot( i[1] )
end
gif(anim, "wip.gif", fps = 2 )

