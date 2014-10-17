using Fst
using Base.Test

a = Wfst()
add_arc(a, "0", "1", "a", "b", 0.1)
add_arc(a, "1", "0", "a", "b", 0.2)
add_arc(a, "1", "2", "b", "b", 0.3)
add_arc(a, "1", "3", "b", "b", 0.4)
add_arc(a, "2", "3", "a", "b", 0.5)
add_arc(a, "3", "3", "a", "a", 0.6)
add_initial_state(a, "0")
add_final_state(a, "3")
a.final_weights["3"] = 0.7
create_pdf(a, "a.pdf")

b = Wfst()
add_arc(b, "0", "1", "b", "b", 0.1)
#add_arc(b, "1", "1", "b", "a", 0.2)
add_arc(b, "1", "2", "a", "b", 0.3)
add_arc(b, "1", "3", "a", "b", 0.4)
add_arc(b, "2", "3", "b", "a", 0.5)
add_initial_state(b, "0")
add_final_state(b, "3")
b.final_weights["3"] = 0.6
create_pdf(b, "b.pdf")

c = compose(a, b)
create_pdf(c, "c.pdf")

println(states_with_no_in_edges(a))
println(states_with_no_in_edges(b))
println(states_with_no_in_edges(c))

#println(topological_sort(a))
println(topological_sort(b))
println(topological_sort(c))
