# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.5.2
#   kernelspec:
#     display_name: Julia 1.5.0
#     language: julia
#     name: julia-1.5
# ---

using LinearAlgebra

include("SOneTo.jl")

"""
    abstract type StaticArrays{S,T,N} <: AbstractArray{T, N} end
    StaticScalar{T} = StaticArray{Tuple{}, T, 0}
    StaticVector{N,T} = StaticArray{Tuple{N}, T, 1}
    StaticMatrix{N, T} = StaticArray{Tuple{N, M}, T, 2}
`StaticArray`s are Julia arrays with fixed, known size.
"""

abstract type StaticArray{S <: Tuple, T, N} <: AbstractArray{T, N} end
const StaticScalar{T} = StaticArray{Tuple{}, T, 0}
const StaticVector{N, T} = StaticArray{Tuple{N}, T, 1}
const StaticMatrix{N, M, T} = StaticArray{Tuple{N, M}, T, 2}
const StaticVecOrMat{T} = Union{StaticVector{<:Any, T}, StaticMatrix{<:Any, <:Any, T}}

# +
# Being a member of StaticMatrixLike, StaticVecOrMatLike, or StaticArrayLike implies that Size(A)
# returns a static Size instance (none of the dimensions are Dynamic). The converse may not be true.
# These are akin to aliases like StridedArray and in similarly bad taste, but the current approach
# in Base necessitates their existence.
const StaticMatrixLike{T} = Union{
    StaticMatrix{<:Any, <:Any, T},
    Transpose{T, <:StaticVecOrMat{T}},
    Adjoint{T, <:StaticVecOrMat{T}},
    Symmetric{T, <:StaticMatrix{<:Any, <:Any, T}},
    Hermitian{T, <:StaticMatrix{<:Any, <:Any, T}},
    Diagonal{T, <:StaticVector{<:Any, T}},
    # We specifically list *Triangular here rather than using
    # AbstractTriangular to avoid ambiguities in size() etc.
    UpperTriangular{T, <:StaticMatrix{<:Any, <:Any, T}},
    LowerTriangular{T, <:StaticMatrix{<:Any, <:Any, T}},
    UnitUpperTriangular{T, <:StaticMatrix{<:Any, <:Any, T}},
    UnitLowerTriangular{T, <:StaticMatrix{<:Any, <:Any, T}}
}
const StaticVecOrMatLike{T} = Union{StaticVector{<:Any, T}, StaticMatrixLike{T}}
const StaticArrayLike{T} = Union{StaticVecOrMatLike{T}, StaticArray{<:Tuple, T}}

const AbstractScalar{T} = AbstractArray{T, 0} # not exported, but useful none-the-less
const StaticArrayNoEltype{S, N, T} = StaticArray{S, T, N}

# +
# utils.jl
# -

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

"""
    size_to_tuple(::Type{S}) where S<:Tuple
Convert a size given by `Tuple{N,M,...}` into a tuple `(N, M, ...)`
"""
Base.@pure function size_to_tuple(::Type{S}) where S<:Tuple
    return tuple(S.parameters...)
end

# +
# Something doesn't match up type wise
function check_array_parameters(Size, T, N, L)
    (!isa(Size, DataType) || (Size.name !== Tuple.name)) && throw(ArgumentError("Static Array parameter Size must be a Tuple type, got $Size"))
    !isa(T, Type) && throw(ArgumentError("Static Array parameter T must be a type, got $T"))
    !isa(N.parameters[1], Int) && throw(ArgumenError("Static Array parameter N must be an integer, got $(N.parameters[1])"))
    !isa(L.parameters[1], Int) && throw(ArgumentError("Static Array parameter L must be an integer, got $(L.parameters[1])"))
    # shouldn't reach here. Anything else should have made it to the function below
    error("Internal error. Please file a bug")
end

@generated function check_array_parameters(::Type{Size}, ::Type{T}, ::Type{Val{N}}, ::Type{Val{L}}) where {Size,T,N,L}
    if !all(x->isa(x, Int), Size.parameters)
        return :(throw(ArgumentError("Static Array parameter Size must be a tuple of Ints (e.g. `SArray{Tuple{3,3}}` or `SMatrix{3,3}`).")))
    end

    if L != tuple_prod(Size) || L < 0 || tuple_minimum(Size) < 0 || tuple_length(Size) != N
        return :(throw(ArgumentError("Size mismatch in Static Array parameters. Got size $Size, dimension $N and length $L.")))
    end

    return nothing
end


# +
"""
   TrivialView
Use to drop static dimensions to override dispatch
"""
struct TrivialView{A, T, N} <: AbstractArray{T, N}
    a::A
end

size(a::TrivialView) = size(a.a)
getindex(a::TrivialView) = getindex(a.a, inds...)
setindex!(a::TrivialView) = setindex!(a.a, inds...)
Base.IndexStyle(::Type{<:TrivialView{A}}) where {A} = IndexStyle{A}

# +
@inline drop_sdims(a::StaticArrayLike) = TrivialView(a)
@inline drop_sdims(a) = a

Base.@propagate_inbounds function invperm(p::StaticVector)
    # in difference to base, this does not check if p is a permutation (every value unique)
     ip = similar(p)
     ip[p] = 1:length(p)
     similar_type(p)(ip)
end
