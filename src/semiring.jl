export Semiring

# A semiring type that you can create. Currently the onus is on the user to
# make sure the semiring makes sense.
immutable Semiring
	addition::Function
	multiplication::Function
	ring_zero::Float64
	ring_one::Float64
end

probability_semiring = Semiring(+, *, 0, 1)
