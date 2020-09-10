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

using StaticArrays

"""
AbstractGeometry in R{Dim} with Number type T <: Number
"""
abstract type AbstractGeometry{Dim, T <: Number} end
abstract type GeometryPrimitive{Dim, T} <: AbstractGeometry{Dim, T} end
Base.ndims(x::AbstractGeometry{Dim}) where Dim = Dim

"""
Geometry made of N connected points. Connected as one flat geometry, it makes a Ngon/Polygon.
Connected as volume it will be a Simplex/Tri/Cube.
Note That `Polytope{N} where N == 3` denotes a Triangle both as a Simplex or Ngon.
"""
abstract type Polytope{Dim, T} <: AbstractGeometry{Dim, T} end
abstract type AbstractPolygon{Dim, T} <: Polytope{Dim, T} end

"""
Point and Face as a subtype of StaticVector
"""
abstract type AbstractPoint{Dim ,T} <: StaticVector{Dim, T} end
abstract type AbstractFace{N, T} <: StaticVector{N, T} end
abstract type AbstractSimplex{Dim, N, T} <: StaticVector{Dim, T} end
abstract type AbstractSimplexFace{N, T} <: AbstractFace{N, T} end
abstract type AbstractNgonFace{N, T} <: AbstractFace{N, T} end

"""
Face index, connecting points to form a simplex
"""

@fixed_vector Simplex AbstractSimplexFace
const TetrahedronFace{T} = SimplexFace{4, T}
Face(::Type{<: SimplexFace{N}}, ::Type{T}) where {N, T} = SimplexFace{N, T}

@fixed_vector NgonFace AbstractNgonFace
const LineFace{T} = NgonFace{2, T}
const TriangleFace{T} = NgonFace{3, T}
const QuadFace{T} = NgonFace{4,T}


