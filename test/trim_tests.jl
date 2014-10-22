using Fst

a = Wfst()
add_arc!(a, 0, 1, "x", "x", 1.0)
add_arc!(a, 1, 2, "x", "x", 1.0)
add_arc!(a, 3, 1, "x", "x", 1.0)
add_arc!(a, 3, 4, "x", "x", 1.0)
add_arc!(a, 4, 3, "x", "x", 1.0)
add_arc!(a, 1, 5, "x", "x", 1.0)
add_arc!(a, 5, 1, "x", "x", 1.0)
add_initial_state!(a, 0, 1.0)
add_final_state!(a, 2, 1.0)
create_pdf(a, "a.pdf")
create_pdf(accessible(a), "A(a).pdf")
