<a name="top"></a>
# CARFAC Tests
These are test results derived from the google/carfac distribution when CARFAC_Test.m is run


These also include corresponding results from the julia port - they should be identical, apart from cosmetic diffrences


[Figure 1 - CAR Filters Linear Frequency Response](#Sect1)



[Figure 2 - "One Cap" (v1) IHC Response for tone blips at 300Hz](#Sect2)



[Figure 3 - "One Cap" (v1) IHC Response for tone blips at 3000Hz](#Sect3)



[Figure 4 - "Two Cap" (v2) IHC Response for tone blips at 300Hz](#Sect4)



[Figure 5 - "Two Cap" (v2) IHC Response for tone blips at 3000Hz](#Sect5)



[Figure 6 - "do_syn" (v3) IHC Response for tone blips at 300Hz](#Sect6)



[Figure 7 - "do_syn" (v3) IHC Response "class_firings" for tone blips at 300Hz](#Sect7)



[Figure 8 - "do_syn" (v3) IHC Response for tone blips at 3000Hz](#Sect8)



[Figure 9 - "do_syn" (v3) IHC "class_firings" Response for tone blips at 3000Hz](#Sect9)



[Figure 10 - Steady state spatial responses of the stages, default [8, 2, 2, 2] decimation](#Sect10)



[Figure 11 - Steady state spatial responses of the stages, simpler [8, 1, 1, 1] decimation](#Sect11)



[Figure 12 - Steady state spatial responses of the stages, no decimation](#Sect12)



[Figure 13 - test stage g calculation](#Sect13)



[Figure 14 - Whole CARFAC "one cap" (v1), decimating](#Sect14)



[Figure 15 - Whole CARFAC "one cap" (v1), decimating](#Sect15)



[Figure 16 - Whole CARFAC "one cap" (v1), decimating](#Sect16)



[Figure 17 - Whole CARFAC "two cap" (v2), decimating](#Sect17)



[Figure 18 - Whole CARFAC "two cap" (v2), decimating](#Sect18)



[Figure 19 - Whole CARFAC "two cap" (v2), decimating](#Sect19)



[Figure 20 - Whole CARFAC "do_syn"  (v3), decimating](#Sect20)



[Figure 21 - Whole CARFAC "do_syn"  (v3), decimating](#Sect21)



[Figure 22 - Whole CARFAC "do_syn"  (v3), decimating](#Sect22)



[Figure 23 - Whole CARFAC "one cap" (v1), non-decimating](#Sect23)



[Figure 24 - Whole CARFAC "one cap" (v1), non-decimating](#Sect24)



[Figure 25 - Whole CARFAC "one cap" (v1), non-decimating](#Sect25)



[Figure 26 - Whole CARFAC "two cap" (v2), non-decimating](#Sect26)



[Figure 27 - Whole CARFAC "two cap" (v2), non-decimating](#Sect27)



[Figure 28 - Whole CARFAC "two cap" (v2), non-decimating](#Sect28)



[Figure 29 - Whole CARFAC "do_syn"  (v3), non-decimating](#Sect29)



[Figure 30 - Whole CARFAC "do_syn"  (v3), non-decimating](#Sect30)



[Figure 31 - Whole CARFAC "do_syn"  (v3), non-decimating](#Sect31)



[Figure 32 - unhealthy hf OHC noise transfer function ratio](#Sect32)



[Figure 33 - Spike Rates - Instantaneous](#Sect33)



[Figure 34 - Spike Rates - Means](#Sect34)



[Figure 35 - Spike Rates - agc](#Sect35)



---
<a name="Sect1"></a>
[^](#top)
## Figure 1 - CAR Filters Linear Frequency Response
This is showing 71 frequency responses - as intensities along 71 vertical stripes.
The x-axis is the channel number, starting at the high frequency end of the basilar membrane.  
The y-axis is frequency bin number - not very useful - the sample rate is 22050Hz, and the 
simulation was performed for 2^14 (16384) samples, and zero padded to 2^15.

Extra plots show all 71 curves and one out of 5 curves.



![matlab/matlab_figure_1.png](matlab/matlab_figure_1.png)
![julia/julia-figure-1.svg](julia/julia-figure-1.svg)
---
<a name="Sect2"></a>
[^](#top)
## Figure 2 - "One Cap" (v1) IHC Response for tone blips at 300Hz




![matlab/matlab_figure_2.png](matlab/matlab_figure_2.png)
![julia/julia-figure-2.svg](julia/julia-figure-2.svg)
---
<a name="Sect3"></a>
[^](#top)
## Figure 3 - "One Cap" (v1) IHC Response for tone blips at 3000Hz
Same as previous, except for 3kHz instead of 300Hz.



![matlab/matlab_figure_3.png](matlab/matlab_figure_3.png)
![julia/julia-figure-3.svg](julia/julia-figure-3.svg)
---
<a name="Sect4"></a>
[^](#top)
## Figure 4 - "Two Cap" (v2) IHC Response for tone blips at 300Hz




![matlab/matlab_figure_4.png](matlab/matlab_figure_4.png)
![julia/julia-figure-4.svg](julia/julia-figure-4.svg)
---
<a name="Sect5"></a>
[^](#top)
## Figure 5 - "Two Cap" (v2) IHC Response for tone blips at 3000Hz
Same as previous, except for 3kHz instead of 300Hz.



![matlab/matlab_figure_5.png](matlab/matlab_figure_5.png)
![julia/julia-figure-5.svg](julia/julia-figure-5.svg)
---
<a name="Sect6"></a>
[^](#top)
## Figure 6 - "do_syn" (v3) IHC Response for tone blips at 300Hz
"Two-cap version with receptor potential; slightly different blips."



![matlab/matlab_figure_6.png](matlab/matlab_figure_6.png)
![julia/julia-figure-6.svg](julia/julia-figure-6.svg)
---
<a name="Sect7"></a>
[^](#top)
## Figure 7 - "do_syn" (v3) IHC Response "class_firings" for tone blips at 300Hz
Plot of "class_firings" - low, medium, high spontaneous firing rate neurons(?)



![matlab/matlab_figure_7.png](matlab/matlab_figure_7.png)
![julia/julia-figure-7.svg](julia/julia-figure-7.svg)
---
<a name="Sect8"></a>
[^](#top)
## Figure 8 - "do_syn" (v3) IHC Response for tone blips at 3000Hz
Same as previous, except for 3kHz instead of 300Hz.



![matlab/matlab_figure_8.png](matlab/matlab_figure_8.png)
![julia/julia-figure-8.svg](julia/julia-figure-8.svg)
---
<a name="Sect9"></a>
[^](#top)
## Figure 9 - "do_syn" (v3) IHC "class_firings" Response for tone blips at 3000Hz
Plot of "class_firings" - low, medium, high spontaneous firing rate neurons(?)



![matlab/matlab_figure_9.png](matlab/matlab_figure_9.png)
![julia/julia-figure-9.svg](julia/julia-figure-9.svg)
---
<a name="Sect10"></a>
[^](#top)
## Figure 10 - Steady state spatial responses of the stages, default [8, 2, 2, 2] decimation
Steady state spatial responses of the stages
With default [8, 2, 2, 2] decimation
Test: Make sure that the AGC adapts to an appropriate steady state, like [Lyon book] figure 19.7



![matlab/matlab_figure_10.png](matlab/matlab_figure_10.png)
![julia/julia-figure-10.svg](julia/julia-figure-10.svg)
---
<a name="Sect11"></a>
[^](#top)
## Figure 11 - Steady state spatial responses of the stages, simpler [8, 1, 1, 1] decimation
Steady state spatial responses of the stages
With [8, 1, 1, 1] simpler decimation
Test: Make sure that the AGC adapts to an appropriate steady state, like [Lyon book] figure 19.7



![matlab/matlab_figure_11.png](matlab/matlab_figure_11.png)
![julia/julia-figure-11.svg](julia/julia-figure-11.svg)
---
<a name="Sect12"></a>
[^](#top)
## Figure 12 - Steady state spatial responses of the stages, no decimation
Steady state spatial responses of the stages
With no decimation
Make sure 2025 non-decimating changes is "close enough" to same



![matlab/matlab_figure_12.png](matlab/matlab_figure_12.png)
![julia/julia-figure-12.svg](julia/julia-figure-12.svg)
---
<a name="Sect13"></a>
[^](#top)
## Figure 13 - test stage g calculation
Make sure the quadratic stage_g calculation agrees with the ratio of polynomials from the book



![matlab/matlab_figure_13.png](matlab/matlab_figure_13.png)
![julia/julia-figure-13.svg](julia/julia-figure-13.svg)
---
<a name="Sect14"></a>
[^](#top)
## Figure 14 - Whole CARFAC "one cap" (v1), decimating
Whole CARFAC v1, decimating



![matlab/matlab_figure_14.png](matlab/matlab_figure_14.png)
![julia/julia-figure-14.svg](julia/julia-figure-14.svg)
---
<a name="Sect15"></a>
[^](#top)
## Figure 15 - Whole CARFAC "one cap" (v1), decimating
Whole CARFAC v1, decimating



![matlab/matlab_figure_15.png](matlab/matlab_figure_15.png)
![julia/julia-figure-15.svg](julia/julia-figure-15.svg)
---
<a name="Sect16"></a>
[^](#top)
## Figure 16 - Whole CARFAC "one cap" (v1), decimating
Whole CARFAC v1, decimating



![matlab/matlab_figure_16.png](matlab/matlab_figure_16.png)
![julia/julia-figure-16.svg](julia/julia-figure-16.svg)
---
<a name="Sect17"></a>
[^](#top)
## Figure 17 - Whole CARFAC "two cap" (v2), decimating
Whole CARFAC v2, decimating



![matlab/matlab_figure_17.png](matlab/matlab_figure_17.png)
![julia/julia-figure-17.svg](julia/julia-figure-17.svg)
---
<a name="Sect18"></a>
[^](#top)
## Figure 18 - Whole CARFAC "two cap" (v2), decimating
Whole CARFAC v2, decimating



![matlab/matlab_figure_18.png](matlab/matlab_figure_18.png)
![julia/julia-figure-18.svg](julia/julia-figure-18.svg)
---
<a name="Sect19"></a>
[^](#top)
## Figure 19 - Whole CARFAC "two cap" (v2), decimating
Whole CARFAC v2, decimating



![matlab/matlab_figure_19.png](matlab/matlab_figure_19.png)
![julia/julia-figure-19.svg](julia/julia-figure-19.svg)
---
<a name="Sect20"></a>
[^](#top)
## Figure 20 - Whole CARFAC "do_syn"  (v3), decimating
Whole CARFAC v3, do_syn, decimating



![matlab/matlab_figure_20.png](matlab/matlab_figure_20.png)
![julia/julia-figure-20.svg](julia/julia-figure-20.svg)
---
<a name="Sect21"></a>
[^](#top)
## Figure 21 - Whole CARFAC "do_syn"  (v3), decimating
Whole CARFAC v3, do_syn, decimating



![matlab/matlab_figure_21.png](matlab/matlab_figure_21.png)
![julia/julia-figure-21.svg](julia/julia-figure-21.svg)
---
<a name="Sect22"></a>
[^](#top)
## Figure 22 - Whole CARFAC "do_syn"  (v3), decimating
Whole CARFAC v3, do_syn, decimating



![matlab/matlab_figure_22.png](matlab/matlab_figure_22.png)
![julia/julia-figure-22.svg](julia/julia-figure-22.svg)
---
<a name="Sect23"></a>
[^](#top)
## Figure 23 - Whole CARFAC "one cap" (v1), non-decimating
Whole CARFAC v1, non-decimating



![matlab/matlab_figure_23.png](matlab/matlab_figure_23.png)
![julia/julia-figure-23.svg](julia/julia-figure-23.svg)
---
<a name="Sect24"></a>
[^](#top)
## Figure 24 - Whole CARFAC "one cap" (v1), non-decimating
Whole CARFAC v1, non-decimating



![matlab/matlab_figure_24.png](matlab/matlab_figure_24.png)
![julia/julia-figure-24.svg](julia/julia-figure-24.svg)
---
<a name="Sect25"></a>
[^](#top)
## Figure 25 - Whole CARFAC "one cap" (v1), non-decimating
Whole CARFAC v1, non-decimating



![matlab/matlab_figure_25.png](matlab/matlab_figure_25.png)
![julia/julia-figure-25.svg](julia/julia-figure-25.svg)
---
<a name="Sect26"></a>
[^](#top)
## Figure 26 - Whole CARFAC "two cap" (v2), non-decimating
Whole CARFAC v2, non-decimating



![matlab/matlab_figure_26.png](matlab/matlab_figure_26.png)
![julia/julia-figure-26.svg](julia/julia-figure-26.svg)
---
<a name="Sect27"></a>
[^](#top)
## Figure 27 - Whole CARFAC "two cap" (v2), non-decimating
Whole CARFAC v2, non-decimating



![matlab/matlab_figure_27.png](matlab/matlab_figure_27.png)
![julia/julia-figure-27.svg](julia/julia-figure-27.svg)
---
<a name="Sect28"></a>
[^](#top)
## Figure 28 - Whole CARFAC "two cap" (v2), non-decimating
Whole CARFAC v2, non-decimating



![matlab/matlab_figure_28.png](matlab/matlab_figure_28.png)
![julia/julia-figure-28.svg](julia/julia-figure-28.svg)
---
<a name="Sect29"></a>
[^](#top)
## Figure 29 - Whole CARFAC "do_syn"  (v3), non-decimating
Whole CARFAC v3, do_syn, non-decimating



![matlab/matlab_figure_29.png](matlab/matlab_figure_29.png)
![julia/julia-figure-29.svg](julia/julia-figure-29.svg)
---
<a name="Sect30"></a>
[^](#top)
## Figure 30 - Whole CARFAC "do_syn"  (v3), non-decimating
Whole CARFAC v3, do_syn, non-decimating



![matlab/matlab_figure_30.png](matlab/matlab_figure_30.png)
![julia/julia-figure-30.svg](julia/julia-figure-30.svg)
---
<a name="Sect31"></a>
[^](#top)
## Figure 31 - Whole CARFAC "do_syn"  (v3), non-decimating
Whole CARFAC v3, do_syn, non-decimating



![matlab/matlab_figure_31.png](matlab/matlab_figure_31.png)
![julia/julia-figure-31.svg](julia/julia-figure-31.svg)
---
<a name="Sect32"></a>
[^](#top)
## Figure 32 - unhealthy hf OHC noise transfer function ratio
Verify frequency dependent reduced gain with reduced health
This test has a random component, which explains the differences between the MATLAB and Julia versions.



![matlab/matlab_figure_32.png](matlab/matlab_figure_32.png)
![julia/julia-figure-32.svg](julia/julia-figure-32.svg)
---
<a name="Sect33"></a>
[^](#top)
## Figure 33 - Spike Rates - Instantaneous
Instantaneous rates of 3 fiber-group classes



![matlab/matlab_figure_33.png](matlab/matlab_figure_33.png)
![julia/julia-figure-33.svg](julia/julia-figure-33.svg)
---
<a name="Sect34"></a>
[^](#top)
## Figure 34 - Spike Rates - Means
Mean rates of 3 fiber classes



![matlab/matlab_figure_34.png](matlab/matlab_figure_34.png)
![julia/julia-figure-34.svg](julia/julia-figure-34.svg)
---
<a name="Sect35"></a>
[^](#top)
## Figure 35 - Spike Rates - agc
agc



![matlab/matlab_figure_35.png](matlab/matlab_figure_35.png)
![julia/julia-figure-35.svg](julia/julia-figure-35.svg)
---
