package spacelift

import future.keywords.in

stacks := ${STACKS}

tracked_stack {
	some input.static_run_environment.stack_slug in stacks
}

valid_jwt {
	token := input.run.user_provided_metadata[0]
	io.jwt.decode(token)
}

tracked_and_valid {
	tracked_stack
	valid_jwt
}

deny["No Token Sent"] {
	tracked_stack
	count(input.run.user_provided_metadata) == 0
}

deny["Not Valid JWT"] {
	tracked_stack
	not valid_jwt
}

deny["Invalid Token"] {
	tracked_and_valid

	token := input.run.user_provided_metadata[0]
	constraints := {"secret": "${SECRET}"}
	[valid, _, _] := io.jwt.decode_verify(token, constraints)
	not valid
}

deny["Stack Mismatch"] {
	tracked_and_valid

	token := input.run.user_provided_metadata[0]
	[_, payload, _] := io.jwt.decode(token)
	payload.spacelift_stack != input.static_run_environment.stack_slug
}

deny["Commit Mismatch"] {
	tracked_and_valid

	token := input.run.user_provided_metadata[0]
	[_, payload, _] := io.jwt.decode(token)
	payload.sub != input.run.commit.hash
}

sample = true
