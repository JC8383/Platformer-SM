class_name player_fall
extends State

## Nodes
var state_machine: StateMachine
var player : Player
var sprite: Sprite2D
var animation_player: AnimationPlayer

## Where this state can go TO
var to_signals : Array= ["idle"]

## Signals which trigger other states
signal started_idle

## Node ready, turn its processing off
func initialize():
	state_machine = get_parent()
	player = state_machine.get_parent()
	sprite = player.sprite
	animation_player = player.animation_player

func _ready() -> void:
	set_physics_process(false)

## Entering!, play anim and turn its speciic physics process func ON
func _enter_state()->void:
	set_physics_process(true)
	animation_player.play("falling")

## Exiting! turn its speciic physics process func OFF, cleanup any needed things here!
func _exit_state()->void:
	set_physics_process(false)

## Fall code
func _physics_process(_delta: float) -> void:
	## Touched Floor! Start idling
	if player.is_on_floor():
		started_idle.emit()
		return
	else:
		## Movement axis
		movement_direction = Input.get_axis("left","right")
		## Flip sprite when running!
		player.flip_sprite(movement_direction)
		
		## Fall gravity
		player.velocity.y += player.get_gravity().y * _delta
		## Movement while in the air only when is not sliding!
		if not player.is_sliding:
			player.velocity.x = movement_direction * player.SPEED
		
		player.move_and_slide()
