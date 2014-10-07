type Fst
    input_alphabet::Vector{String}
    output_alphabet::Vector{String}
    states::Vector{String}
    initial_states::Vector{String}
    final_states::Vector{String}
    transitions::Array{Bool,4}
end

Fst() = Fst(String[], String[], String[], String[], String[])
Fst(input_alphabet, output_alphabet, states, initial_states, final_states) =
    Fst(input_alphabet, output_alphabet, states, initial_states, final_states,
            falses(Int, length(states), length(input_alphabet), length(states),
            length(output_alphabet)))

function add_arc(fst::Fst, from, to, input, output)
    # Extend the arrays to cope with the possibly new symbols
    if !(from in fst.states)
        fst.states = [fst.states; from]
        #fst.transitions = cat(1, fst.transitions, true)
    end
    if !(to in fst.states)
        fst.states = [fst.states; to]
        #fst.transitions = cat(3, fst.transitions, true)
    end
    if !(input in fst.input_alphabet)
        fst.input_alphabet = [fst.input_alphabet; input]
    end
    if !(output in fst.output_alphabet)
        fst.output_alphabet = [fst.output_alphabet; output]
    end
    return
    # Doing the inefficient but simple thing of just creating a new transitions
    # array
    fst.transitions = reshape(fst.transitions, length(fst.states),
            length(fst.input_alphabet), length(fst.states),
            length(fst.output_alphabet))
end

# Since we want to be able to add arcs and symbols after construction, we don't
# want to have to specify the transitions matrix size from the get go.
