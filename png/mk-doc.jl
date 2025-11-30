
function title( t )
        println( "# $(t)" )
end

function paragraph( p="" )
        println( p, "\n\n" )
end

function heading( h )
        println( "## $(h)" )
end

function figure( p )
        println( "![$(p)]($p)" )
end

function sectionline()
        println("---")
end

function setanchor(n)
        println("<a name=\"$(n)\"></a>")
end
function refanchor(n, txt=n )
        println("[$txt](#$(n))")
end



titles = Array{String}(undef,35)
descriptions = Array{String}(undef,35)

titles[1] = "CAR Filters Linear Frequency Response"
descriptions[1] = """
This is showing 71 frequency responses - as intensities along 71 vertical stripes.
The x-axis is the channel number, starting at the high frequency end of the basilar membrane.  
The y-axis is frequency bin number - not very useful - the sample rate is 22050Hz, and the 
simulation was performed for 2^14 (16384) samples, and zero padded to 2^15.

Extra plots show all 71 curves and one out of 5 curves.
"""

titles[2] = "\"One Cap\" (v1) IHC Response for tone blips at 300Hz"
descriptions[2] = """

"""

titles[3] = "\"One Cap\" (v1) IHC Response for tone blips at 3000Hz"
descriptions[3] = """
Same as previous, except for 3kHz instead of 300Hz.
"""

titles[4] = "\"Two Cap\" (v2) IHC Response for tone blips at 300Hz"
descriptions[4] = """

"""

titles[5] = "\"Two Cap\" (v2) IHC Response for tone blips at 3000Hz"
descriptions[5] = """
Same as previous, except for 3kHz instead of 300Hz.
"""

titles[6] = "\"do_syn\" (v3) IHC Response for tone blips at 300Hz"
descriptions[6] = """
"Two-cap version with receptor potential; slightly different blips."
"""

titles[7] = "\"do_syn\" (v3) IHC Response \"class_firings\" for tone blips at 300Hz"
descriptions[7] = """
Plot of "class_firings" - low, medium, high spontaneous firing rate neurons(?)
"""

titles[8] = "\"do_syn\" (v3) IHC Response for tone blips at 3000Hz"
descriptions[8] = """
Same as previous, except for 3kHz instead of 300Hz.
"""

titles[9] = "\"do_syn\" (v3) IHC \"class_firings\" Response for tone blips at 3000Hz"
descriptions[9] = """
Plot of "class_firings" - low, medium, high spontaneous firing rate neurons(?)
"""

titles[10] = "Steady state spatial responses of the stages, default [8, 2, 2, 2] decimation"
descriptions[10] = """
Steady state spatial responses of the stages
With default [8, 2, 2, 2] decimation
Test: Make sure that the AGC adapts to an appropriate steady state, like [Lyon book] figure 19.7
"""

titles[11] = "Steady state spatial responses of the stages, simpler [8, 1, 1, 1] decimation"
descriptions[11] = """
Steady state spatial responses of the stages
With [8, 1, 1, 1] simpler decimation
Test: Make sure that the AGC adapts to an appropriate steady state, like [Lyon book] figure 19.7
"""

titles[12] = "Steady state spatial responses of the stages, no decimation"
descriptions[12] = """
Steady state spatial responses of the stages
With no decimation
Make sure 2025 non-decimating changes is "close enough" to same
"""

titles[13] = "test stage g calculation"
descriptions[13] = """
Make sure the quadratic stage_g calculation agrees with the ratio of polynomials from the book
"""

titles[14] = "Whole CARFAC \"one cap\" (v1), decimating"
titles[15] = "Whole CARFAC \"one cap\" (v1), decimating"
titles[16] = "Whole CARFAC \"one cap\" (v1), decimating"
descriptions[14] = """
Whole CARFAC v1, decimating
"""
descriptions[15] = """
Whole CARFAC v1, decimating
"""
descriptions[16] = """
Whole CARFAC v1, decimating
"""

titles[17] = "Whole CARFAC \"two cap\" (v2), decimating"
titles[18] = "Whole CARFAC \"two cap\" (v2), decimating"
titles[19] = "Whole CARFAC \"two cap\" (v2), decimating"
descriptions[17] = """
Whole CARFAC v2, decimating
"""
descriptions[18] = """
Whole CARFAC v2, decimating
"""
descriptions[19] = """
Whole CARFAC v2, decimating
"""
titles[20] = "Whole CARFAC \"do_syn\"  (v3), decimating"
titles[21] = "Whole CARFAC \"do_syn\"  (v3), decimating"
titles[22] = "Whole CARFAC \"do_syn\"  (v3), decimating"
descriptions[20] = """
Whole CARFAC v3, do_syn, decimating
"""
descriptions[21] = """
Whole CARFAC v3, do_syn, decimating
"""
descriptions[22] = """
Whole CARFAC v3, do_syn, decimating
"""


titles[23] = "Whole CARFAC \"one cap\" (v1), non-decimating"
titles[24] = "Whole CARFAC \"one cap\" (v1), non-decimating"
titles[25] = "Whole CARFAC \"one cap\" (v1), non-decimating"
descriptions[23] = """
Whole CARFAC v1, non-decimating
"""
descriptions[24] = """
Whole CARFAC v1, non-decimating
"""
descriptions[25] = """
Whole CARFAC v1, non-decimating
"""

titles[26] = "Whole CARFAC \"two cap\" (v2), non-decimating"
titles[27] = "Whole CARFAC \"two cap\" (v2), non-decimating"
titles[28] = "Whole CARFAC \"two cap\" (v2), non-decimating"
descriptions[26] = """
Whole CARFAC v2, non-decimating
"""
descriptions[27] = """
Whole CARFAC v2, non-decimating
"""
descriptions[28] = """
Whole CARFAC v2, non-decimating
"""
titles[29] = "Whole CARFAC \"do_syn\"  (v3), non-decimating"
titles[30] = "Whole CARFAC \"do_syn\"  (v3), non-decimating"
titles[31] = "Whole CARFAC \"do_syn\"  (v3), non-decimating"
descriptions[29] = """
Whole CARFAC v3, do_syn, non-decimating
"""
descriptions[30] = """
Whole CARFAC v3, do_syn, non-decimating
"""
descriptions[31] = """
Whole CARFAC v3, do_syn, non-decimating
"""

titles[32] = "unhealthy hf OHC noise transfer function ratio"
descriptions[32] = """
Verify frequency dependent reduced gain with reduced health
This test has a random component, which explains the differences between the MATLAB and Julia versions.
"""

titles[33] = "Spike Rates - Instantaneous"
descriptions[33] = """
Instantaneous rates of 3 fiber-group classes
"""

titles[34] = "Spike Rates - Means"
descriptions[34] = """
Mean rates of 3 fiber classes
"""

titles[35] = "Spike Rates - agc"
descriptions[35] = """
agc
"""

open("README.md", "w") do file
    redirect_stdout(file) do
        setanchor("top")
        title( "CARFAC Tests" )
        paragraph( "These are test results derived from the google/carfac distribution when CARFAC_Test.m is run" )
        paragraph( "These also include corresponding results from the julia port - they should be identical, apart from cosmetic diffrences" )

        for i in 1:35
                refanchor( "Sect$(i)", "Figure $(i) - $(titles[i])" )
                paragraph()
        end

        sectionline()
        for f in 1:35
                setanchor( "Sect$(f)" )
                refanchor( "top", "^" )
                heading( "Figure $(f) - $(titles[f])" )
                paragraph( descriptions[f] )
                figure( "matlab/matlab_figure_$(f).png" )
                figure( "julia/julia-figure-$(f).svg"   )
                sectionline()
        end
    end
end


