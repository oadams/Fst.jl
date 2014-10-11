type Fst
    input_alphabet::Dict{String,Int}
    output_alphabet::Dict{String,Int}
    states::Dict{String,Int}
    initial_states::Vector{String}
    final_states::Vector{String}
    transitions::Array{Int,4}
end

# Constructors
Fst() = Fst(Dict(), Dict(), Dict(), String[], String[],
        falses(100,100,100,100)) # Temporary - should be variable

Fst(input_alphabet, output_alphabet, states, initial_states, final_states) =
    Fst(input_alphabet, output_alphabet, states, initial_states, final_states,
            falses(Int, length(states), length(input_alphabet), length(states),
            length(output_alphabet)))

function add_arc(fst::Fst, from, to, input, output)
    # Extend the arrays to cope with the possibly new symbols
    if !(from in keys(fst.states))
        fst.states[from] = length(keys(fst.states)) + 1
    end
    if !(to in keys(fst.states))
        fst.states[to] = length(keys(fst.states)) + 1
    end
    if !(input in keys(fst.input_alphabet))
        fst.input_alphabet[input] = length(keys(fst.input_alphabet)) + 1
    end
    if !(output in keys(fst.output_alphabet))
        fst.output_alphabet[output] = length(keys(fst.output_alphabet)) + 1
    end
    return

    fst.transitions[fst.states[from], fst.input_alphabet[input],
            fst.states[to], fst.output_alphabet[output]] = true

end

# Since we want to be able to add arcs and symbols after construction, we don't
# want to have to specify the transitions matrix size from the get go.
