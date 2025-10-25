class_name player_jump
extends State

## Nodes
var state_machine: StateMachine
var player : Player
var animation_player: AnimationPlayer

## Where this state can go TO
var to_signals : Array= ["fall"]

@export var jump_velocity : float = -400.0

## Signals which trigger other states
signal started_fall

## Node ready, turn its processing off
func initialize():
	state_machine = get_parent()
	player = state_machine.get_parent()
	animation_player = player.animation_player

func _ready() -> void:
	set_physics_process(false)

## Entering!, play anim and turn its speciic physics process func ON
func _enter_state()->void:
	set_physics_process(true)
	## Only apply the jump velocity when entering the state once!
	player.velocity.y = jump_velocity
	animation_player.play("jump")

## Exiting! turn its speciic physics process func OFF, cleanup any needed things here!
func _exit_state()->void:
	set_physics_process(false)

## Jump code
func _physics_process(_delta: float) -> void:
	## Fall gravity
	player.velocity.y += player.get_gravity().y * _delta
	
	## Movement axis
	movement_direction = Input.get_axis("left","right")
	## Flip sprite when running!
	player.flip_sprite(movement_direction)
	
	## Started falling downwards now
	if player.velocity.y >= 0: 
		started_fall.emit()
		return
	else:
		## Movement while in the air
		player.velocity.x = movement_direction * player.SPEED
		
		player.move_and_slide()
