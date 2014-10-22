using Fst
using Base.Test

include("compose_tests.jl")
include("trim_tests.jl")

#=
println(Fst.states_with_no_in_arcs(a))
println(Fst.states_with_no_in_arcs(b))
println(Fst.states_with_no_in_arcs(c))

#println(topological_sort(a))
println(topological_sort(b))
println(topological_sort(c))
=#
