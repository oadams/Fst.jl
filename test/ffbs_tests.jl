using Fst

a = read_wfst(readall("fsts/ffbs/a.txt"), Probability_semiring)
b = read_wfst(readall("fsts/ffbs/b.txt"), Probability_semiring)

fa = forward_filtering(a)
fb = forward_filtering(b)

new_fa = new_forward_filtering(a)
new_fb = new_forward_filtering(b)

@assert fa == new_fa
@assert fb == new_fb

for i in 1:10
    println(sampleone(["a","b","c"], [0.9, 0.05, 0.05]))
end

for i in 1:10
    println(backward_sampling(a, forward_filtering(a)))
end
