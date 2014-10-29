export Semiring, Probability_semiring, Tropical_semiring

# A semiring type that you can create. Currently the onus is on the user to
# make sure the semiring makes sense.
immutable Semiring
	addition::Function
	multiplication::Function
	ring_zero::Float64
	ring_one::Float64
end

Probability_semiring = Semiring(+, *, 0, 1)
Tropical_semiring = Semiring(min, +, Inf, 0)
