

# ideas for collecting an iterator that returns named tuple elements
#
# want to be able to collect into a namedtuple of arrays
#
# ie do the array of structs to struct of arrays conversions - but with named tuples


# could extend this for ordinary tuples



# TODO: related - collect_with_state
# allow an initial state to be specified, return state
# this would allow MATLAB style operation

import Sequences


struct ResizeArray{T,N}
        elsize::NTuple{N,Int64}
        v::Vector{T}
end


# take any value, and start a collection to which further values can be efficiently appended:
# general case:
function vector_length1( x )
        @assert x isa Number
        [ x ] 
end
# any kind of vector, matrix, multidimensional array:
## function vector_length1( x::AbstractArray{T,N} ) where {T,N}
##         r = copy(x)
##         # will add further elements of same type as x, at end:
##         reshape( r, size(r)..., 1 )
## end


#### function vector_length1( x::AbstractArray{T,N} ) where {T,N}
####         v = T[]
####         append!( v, reshape( x, : ) )
####         return ResizeArray{T,N}( size(x), v )
#### end
function vector_length1( x::AbstractArray ) 
        x1 = identity.(x)  # broadcast identity will tighten up array of element type Any, also copies
        v = Vector{ eltype(x1) }()
        append!( v, reshape( x1, : ) )  # TODO: I think this can be simplified / improved, but not now.
        return ResizeArray( size(x), v )
end

# for any collection started by vector_length1, add another element:
function vector_push( a::AbstractArray{T,N}, v ) where {T,N}
        push!( a, v )
end
function vector_push( a::ResizeArray{T,N}, v::AbstractArray ) where {T,N}
        append!( a.v, reshape(v,:) )
end


# at the end, want to put shape back in:
vector_reshape( v ) = v
vector_reshape( t::NamedTuple ) = NamedTuple{ keys(t) }( vector_reshape.( values(t) ) )
vector_reshape( v::ResizeArray{T,N} ) where {T,N} = begin
        if length(v.v) == 0
                return reshape( v.v, v.elsize..., 0 )
        end
        return reshape( v.v, v.elsize..., : )
end


function new_arrays_first_row( row::NamedTuple )
        r = NamedTuple{ keys(row) }( vector_length1.( values(row) ) )
end

function new_arrays_first_row( row::AbstractArray )
        r = vector_length1( row ) 
end


function arrays_push!( arrays::NamedTuple, row::NamedTuple )
#        for (k,v) in pairs(row)
#                push!( arrays[k], v )
#        end
        for (i,v) in enumerate(row)
#                push!( arrays[i], v )
                vector_push( arrays[i], v )
        end
        return arrays
end

function arrays_push!( arrays::ResizeArray{T,N}, row::AbstractArray ) where {T,N}
        vector_push( arrays, row )
end


# 1:100 |> Processors.Vectorize(4) |> Collect(Vector)
Collect( T ) = ( seq ) -> collect(T,seq)


function CollectNamedTuples( iter )
        r = iterate( iter )
        if r === nothing
                return nothing
        end
        v,state = r
        a = new_arrays_first_row( v )

        next = iterate(iter, state)
        while next !== nothing
                (i, state) = next
                # body
                arrays_push!( a, i )
                next = iterate(iter, state)
        end


     #   return a

     #   @show a keys(a) values(a)

        return NamedTuple{ keys(a) }( map( vector_reshape, values(a) ) )
end

function CollectArrays( iter )
        r = iterate( iter )
        if r === nothing
                return nothing
        end
        v,state = r
        a = new_arrays_first_row( v )

 #       @show a
        next = iterate(iter, state)
        while next !== nothing
                (i, state) = next
                # body
  #              @show typeof(i)
                arrays_push!( a, i )
  #              @show typeof(a) a
                next = iterate(iter, state)
        end


     #   return a

     #   @show a keys(a) values(a)

        return vector_reshape( a )
end


#=
function Collect1( ::Val{true}, seq )
        println("here1 ")
end

function Collect1( ::Val{false}, seq )
        collect(seq)
end
function Collect( seq )
#        if eltype(seq) <: NamedTuple
#                @show seq
#        else
#                return collect( seq )
#        end

        Collect1( Val{eltype(seq) <: NamedTuple} , seq )
end

=#

#=
 @show el = [ 1 2 ; 3 4 ]

  @show a = vector_length1(el)
  vector_push( a, el )
@show a
  @show vector_push( a, el )
@show a
  @show vector_push( a, el )
@show a
=#

