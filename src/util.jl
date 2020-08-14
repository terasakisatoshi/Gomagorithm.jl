# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.5.2
#   kernelspec:
#     display_name: Julia 1.5.0-rc2
#     language: julia
#     name: julia-1.5
# ---

# For convenience
TupleN{T,N} = NTuple{N,T}

@inline convert_ntuple(::Type{T}, d::T) where {T} = T # For zero-dimensional arrays
@inline convert_ntuple(::Type{T}, d::NTuple{N,T}) where {N,T} = d
@generated function convert_ntuple(::Type{T}, d::NTuple{N,Any}) where {N,T}
    exprs = ntuple(i->:(convert(T, d[$i])), Val(N))
    return quote
        @_inline_meta
        $(Expr(:tuple, exprs...))
    end
end

# Base gives up on tuples for promote_eltype... (TODO can we improve Base?)
@generated function promote_tuple_eltype(::Union{T,Type{T}}) where T <: Tuple
    t = Union{}
    for i = 1:length(T.parameters)
        tmp = T.parameters[i]
        if tmp <: Vararg
            tmp = tmp.parameters[1]
        end
        t = :(promote_type($t, $tmp))
    end
    return quote
        @_inline_meta
        $t
    end
end

# The ::Tuple variants exist to make sure anything that calls with a tuple 
# instead of a Tuple gets through to the constructor, so the user gets a nice error message
Base.@pure tuple_length(T::Type{<:Tuple}) = length(T.parameters)
Base.@pure tuple_length(T::Tuple) = length(T)
Base.@pure tuple_prod(T::Type{<:Tuple}) = length(T.parameters) == 0 ? 1 : *(T.parameters...)
Base.@pure tuple_prod(T::Tuple) = prod(T)
Base.@pure tuple_minimum(T::Type{<:Tuple}) = length(T.parameters) == 0 ? 0 : minimum(tuple(T.parameters...))
Base.@pure tuple_minimum(T::Tuple) = minimum(T)


