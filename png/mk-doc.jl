
function title( t )
        println( "# $(t)" )
end

function paragraph( p )
        println( p )
end

function heading( h )
        println( "## $(h)" )
end

function figure( p )
        println( "![$(p)]($p)" )
end

open("README.md", "w") do file
    redirect_stdout(file) do
        title( "CARFAC Tests" )
        paragraph( "These are test results derived from the google/carfac distribution when CARFAC_Test.m is run" )
        paragraph( "These also include corresponding results from the julia port - they should be identical, apart from cosmetic diffrences" )
        
        for f in 1:35
                heading( "Figure $(f)" )
                figure( "matlab/matlab_figure_$(f).png" )
                figure( "julia/julia-figure-$(f).svg"   )
        end
    end
end


