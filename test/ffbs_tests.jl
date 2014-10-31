using Fst

a = read_wfst(readall("fsts/ffbs/a.txt"), Probability_semiring)

println(forward_filtering(a))
