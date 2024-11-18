package spacelift

import future.keywords.in

stacks := ${STACKS}

tracked_stack {
    some input.static_run_environment.stack_slug in stacks
}

deny["No Token Sent"] {
    tracked_stack
    count(input.run.user_provided_metadata) == 0
}

deny["Invalid Token"] {
    tracked_stack

    token := input.run.user_provided_metadata[0]
    constraints := {
        "secret": "${SECRET}"
    }
    [valid, _, payload] := io.jwt.decode_verify(token, constraints)
    not valid
}

deny["Stack Mismatch"] {
    tracked_stack

    token := input.run.user_provided_metadata[0]
    [_, payload, _] := io.jwt.decode(token)
    payload.spacelift_stack != input.static_run_environment.stack_slug
}

deny["Commit Mismatch"] {
    tracked_stack

    token := input.run.user_provided_metadata[0]
    [_, payload, _] := io.jwt.decode(token)
    payload.sub != input.run.commit.hash
}

sample { true }