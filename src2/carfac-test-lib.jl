
# these are functions pulled out of CARFAC_Test
# that may be useful beyond CARFAC_Test
# 


# % Formula from:
# % https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html
function  quadratic_peak_interpolation( alpha, beta, gamma)
        location = 1 / 2 * (alpha - gamma) / (alpha - 2 * beta + gamma);
        amplitude = beta - 1.0 / 4 * (alpha - gamma) * location;

        return location, amplitude
end


function find_peak_response(freqs, db_gains, bw_level)

global g_freqs    = freqs   
global g_db_gains = db_gains
global g_bw_level = bw_level


# freqs    = g_freqs   
# db_gains = g_db_gains
# bw_level = g_bw_level

        # db_gains is twice as long as freqs
        # make sure we use the first half:
        db_gains = db_gains[1:length(freqs)]

        # % Returns center frequency, amplitude at this point, and the 3dB width."""
        peak_bin = argmax(db_gains);
        peak_frac, amplitude = quadratic_peak_interpolation( db_gains[peak_bin - 1], db_gains[peak_bin], db_gains[peak_bin + 1]);
        peak_loc = peak_bin + peak_frac;
        if peak_frac < 0
                cf = (1 + peak_frac)*freqs[peak_bin] - peak_frac*freqs[peak_bin - 1];
        else
                cf = (1 - peak_frac)*freqs[peak_bin] + peak_frac*freqs[peak_bin + 1];
        end
        # % cf = linear_interp(freqs, peak_bin + peak_frac)
        freqs_3db = find_zero_crossings(freqs, db_gains .- amplitude .+ bw_level);
        if length(freqs_3db) >= 2
                bw = freqs_3db[2] - freqs_3db[1];
        else
                bw = 0;
        end
        cf_amp_bw = cf, amplitude, bw;
        return cf_amp_bw
end


function find_zero_crossings(x, y)
       # locs = find(y(2:end) .* y(1:end-1) < 0, 2);
       # a = y(locs);
       # b = y(locs+1);
       # frac = -a ./ (b - a);
       # zclist = x(locs) .* (1 - frac) + x(locs + 1) .* frac;
        
#@show x y
#global global_x = x
#global global_y = y

        locs = findall( (xy)-> xy < 0, y[2:end] .* y[1:end-1] )
        locs = locs[1:min(2,length(locs))]
        a = y[locs]
        b = y[locs.+1]
        frac = -a ./ (b .- a)
        zclist = x[locs] .* (1 .- frac) + x[locs .+ 1] .* frac
        return zclist
end