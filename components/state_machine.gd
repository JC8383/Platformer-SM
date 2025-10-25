class_name StateMachine
extends Node

## This script handles all requests for states transitioning to other states
## Used in all entities which use states as animations

@export var state : State

func initialize() -> void:
	## When initializing the state machine it grabs each state and connects it, so each state can trigger 
	## the enter or exit signals of the others, using their to_signals array on each state, thats where you 
	## decide to which state you can go to when the current one ends!
	for new_state in get_children():
		if new_state is State:
			connect_state(new_state)

func _ready():
	## The player has to be ready and all its nodes, since Godot readies children first (this state machine for example)
	## The states wont have access to the required nodes yet, so once player is done, start the machine
	await get_parent().ready
	## Start all states
	for p_state in get_children():
		p_state.initialize()
	## Start in this state (idle)
	change_state(state)

func change_state(new_state: State):
	## Exists the current state, calling its _exit state func, then enters the next one
	if state is State:
		state._exit_state()
	new_state._enter_state()
	state = new_state

func connect_state(new_state: State):
	### Connects each state in the to_signals array onto the corresponding signal on the state
	### for example, from idle, the target state is player_run , grabs that state, then
	### connects the [idle.started_run] to [player_run] enter and exit signals
	for to_signal in new_state.to_signals:
		var target_state : State = get_node_or_null("player_"+to_signal)
		if target_state != null:
			new_state.get("started_"+to_signal).connect(change_state.bind(target_state))
		else:
			push_error("The state ", to_signal, " is not present as part of the state machine children!")
