using Lumberjack

export Wfst, Arc, add_arc!, add_initial_state!, add_final_state!

# The arc type that specify "arcs", "edges" or "transition rules".
type Arc
    from
    to
    input::String
    output::String
    weight::Float64
end

# The weighted FST type.
type Wfst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    # Arcs of the form: (from, to, input, output, weight)
    arcs::Set{Arc}
    # Maps from initial and final states to their weights.
    initial_weights::Dict
    final_weights::Dict
    semiring::Semiring
end

# Empty constructor
Wfst(semiring::Semiring) = Wfst(Set(), Set{String}(), Set{String}(), Set(),
        Set(), Set{Arc}(), Dict(), Dict(), semiring)

# Add a state to the initial states list with the given weight.
function add_initial_state!(wfst::Wfst, state, weight::Float64)
    @assert state in wfst.states
    wfst.initial_states = union(wfst.initial_states, Set([state]))
    wfst.initial_weights[state] = weight
end

# Add a state to the final states list with the given weight.
function add_final_state!(wfst::Wfst, state, weight::Float64)
    @assert state in wfst.states
    wfst.final_states = union(wfst.final_states, Set([state]))
    wfst.final_weights[state] = weight
end

function add_arc!(wfst::Wfst,
        from, to,
        input::String, output::String, weight::Float64)
    wfst.states = union(wfst.states, Set([[from], [to]]))
    if !ismatch(r"<.*>", input)
        wfst.input_alphabet = union(wfst.input_alphabet, Set([input]))
    end
    if !ismatch(r"<.*>", output)
        wfst.output_alphabet = union(wfst.output_alphabet, Set([output]))
    end
    wfst.arcs =
            union(wfst.arcs, Set([Arc(from, to, input, output, weight)]))
end
