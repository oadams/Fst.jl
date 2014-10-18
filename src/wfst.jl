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
end

# Empty constructor
Wfst() = Wfst(Set(), Set{String}(), Set{String}(), Set(), Set(),
        Set{Arc}(), Dict(), Dict())

# Add a state to the initial states list
function add_initial_state!(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.initial_states = union(wfst.initial_states, Set([state]))
end

# Add a state to the final states list
function add_final_state!(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.final_states = union(wfst.final_states, Set([state]))
end

function add_arc!(wfst::Wfst,
        from::String, to::String,
        input::String, output::String, weight::Float64)
    wfst.states = union(wfst.states, Set([[from], [to]]))
    wfst.input_alphabet = union(wfst.input_alphabet, Set([input]))
    wfst.output_alphabet = union(wfst.output_alphabet, Set([output]))
    wfst.arcs =
            union(wfst.arcs, Set([Arc(from, to, input, output, weight)]))
end
