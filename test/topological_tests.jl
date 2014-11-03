using Fst

a = read_wfst(readall("fsts/ffbs/a.txt"), Probability_semiring)
b = read_wfst(readall("fsts/ffbs/b.txt"), Probability_semiring)

orderings = topological_sort(a)
println(orderings[1])
println(orderings[2])
