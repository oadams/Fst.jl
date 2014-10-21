#=
a = Wfst()
add_arc!(a, "0", "1", "a", "b", 0.1)
add_arc!(a, "1", "0", "a", "b", 0.2)
add_arc!(a, "1", "2", "b", "b", 0.3)
add_arc!(a, "1", "3", "b", "b", 0.4)
add_arc!(a, "2", "3", "a", "b", 0.5)
add_arc!(a, "3", "3", "a", "a", 0.6)
add_initial_state!(a, "0")
add_final_state!(a, "3")
a.final_weights["3"] = 0.7
println(wfst2dot(a))
create_pdf(a, "a.pdf")

b = Wfst()
add_arc!(b, "0", "1", "b", "b", 0.1)
add_arc!(b, "1", "1", "b", "a", 0.2)
add_arc!(b, "1", "2", "a", "b", 0.3)
add_arc!(b, "1", "3", "a", "b", 0.4)
add_arc!(b, "2", "3", "b", "a", 0.5)
add_initial_state!(b, "0")
add_final_state!(b, "3")
b.final_weights["3"] = 0.6
create_pdf(b, "b.pdf")

c = compose(a, b)
create_pdf(c, "c.pdf")
=#

# Tests for composition involving <epsilon> transitions
t1 = Wfst()
add_arc!(t1, 0, 1, "a", "a", 1.0)
add_arc!(t1, 1, 2, "b", "<eps>", 1.0)
add_arc!(t1, 2, 3, "c", "<eps>", 1.0)
add_arc!(t1, 3, 4, "d", "d", 1.0)
add_initial_state!(t1, 0, 1.0)
add_final_state!(t1, 4, 1.0)
create_pdf(t1, "t1.pdf")

t2 = Wfst()
add_arc!(t2, 0, 1, "a", "d", 1.0)
add_arc!(t2, 1, 2, "<eps>", "e", 1.0)
add_arc!(t2, 2, 3, "d", "a", 1.0)
add_initial_state!(t2, 0, 1.0)
add_final_state!(t2, 3, 1.0)
create_pdf(t2, "t2.pdf")

c = compose(t1, t2)
create_pdf(c, "c.pdf")

c_eps = compose_epsilon(t1,t2)
create_pdf(c_eps, "c_eps.pdf")
