
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

open("README.md", "w") do file
    redirect_stdout(file) do
        setanchor("top")
        title( "CARFAC Tests" )
        paragraph( "These are test results derived from the google/carfac distribution when CARFAC_Test.m is run" )
        paragraph( "These also include corresponding results from the julia port - they should be identical, apart from cosmetic diffrences" )

        for i in 1:35
                refanchor( "Sect$(i)", "Figure $(i)" )
                paragraph()
        end


        sectionline()
        for f in 1:35
                setanchor( "Sect$(f)" )
                refanchor( "top", "^" )
                heading( "Figure $(f)" )
                figure( "matlab/matlab_figure_$(f).png" )
                figure( "julia/julia-figure-$(f).svg"   )
                sectionline()
        end
    end
end


