# Fst.jl

A weighted finite-state transducer Julia package inspired by OpenFst and the Pyfst python wrapper.

Ongoing discussion of design questions and decisions (tentative or strong) are
found in design-questions.txt.

Ideas and criticisms are welcome. Go ahead and open an issue!

**(Note that the code has not yet been subject to testing of a remotely rigorous standard. It "looks like it works".)**

## Usage

### Semirings

`Semiring` is the type for all created semirings. (Note the set of values the semiring deals with is not included, so at the moment the onus is on the user to make the Wfsts that use a given semiring makes sense. This may change.)

The following semirings are included:

  * `Probability_semiring`
  * `Tropical_semiring`
  * `Log_semiring`

### Constructing a WFST

`Wfst` is the type of all WFSTs. Its constructor takes an argument of type Semiring to specify the semiring that the WFST uses.

`Arc` is the type for all arcs (edges) in WFSTs. Arcs are not parameterized by Semirings - the meaning of their weights depends on the WFST they are being added to.

`add_arc!(wfst::Wfst, from, to, input::String, output::String, weight::Float64)` adds a new arc to the supplied Wfst from state `from` to state `to` with the specified `input`, `output` and `weight`. Specify epsilon transitions with the `input` or `output` string as "<eps>", as required.

`add_initial_state!(wfst::Wfst, state, weight::Float64)` makes the specified state an initial state of the given Wfst. The state must already be in the Wfst.

`add_final_state!(wfst::Wfst, state, weight::Float64)` makes the specified state a final state of the given Wfst. The state must already be in the Wfst.

### WFST operations

`compose_basic(a::Wfst, b::Wfst)` returns the composed Wfst of `a` and `b` assuming that there are no epsilon transitions.

`compose_epsilon(a::Wfst, b::Wfst)` returns the composed Wfst of `a` and `b` and handles cases of epsilon transitions (specified by "<eps>"). Currently inefficient and perhaps not even correct (although that holds for all the code right now).

`topological_sort(graph::Wfst)` returns a topologically sorted array of states in the Wfst, or an error if it's not a DAG.

`accessible(wfst::Wfst)` returns a Wfst with inaccessible states removed (states reachable from the initial state).

`coaccessible(wfst:Wfst)` returns a Wfst with states that are not coaccessible removed (states that cannot reach the final state).

`trim` returns an Wfst with all states that are not accessible or coaccessible removed.

### I/O

`wfst2dot(wfst::Wfst)` returns a string representation of the given Wfst in DOT language, for use by GraphViz (http://graphviz.org/)

`create_pdf(wfst::Wfst, filename::String)` creates a PDF representation of the given Wfst in the file specified by the filename.

`read_wfst(text::String, semiring::Semiring)` reads a string representation of a Wfst in a subset of AT&T FSM format (http://www2.research.att.com/~fsmtools/fsm/man4/fsm.5.html). The semiring used must be specified.





[![Build Status](https://travis-ci.org/oadams/Fst.jl.svg?branch=master)](https://travis-ci.org/oadams/Fst.jl)
