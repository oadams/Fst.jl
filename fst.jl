# The FST type that doesn't support weighted arcs.
type Fst
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    states::Set{String}
    initial_states::Set{String}
    final_states::Set{String}
    transitions::Set{(String, String, String, String)}
end

# Empty constructor
Fst() = Fst(Set{String}(), Set{String}(), Set{String}(), Set{String}(),
        Set{String}(), Set{(String, String, String, String)}())

function add_arc(fst::Fst,
        from::String, input::String,
        to::String, output::String)
    fst.states = union(fst.states, Set([from]))
    fst.input_alphabet = union(fst.input_alphabet, Set([input]))
    fst.states = union(fst.states, Set([to]))
    fst.output_alphabet = union(fst.output_alphabet, Set([output]))
    fst.transitions = union(fst.transitions, Set([(from, input, to, output)]))
end
