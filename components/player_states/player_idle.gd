class_name player_idle
extends State

## NOTE each state can have access to different nodes, for example, if a state requires for some reason
## access to the player's camera (to shake it, etc) you can add it here and on initialize(), grab it from
## the player!! to then use it accordingly in this state (or you can even access it player.camera)

var state_machine: StateMachine
var player : Player
var animation_player: AnimationPlayer

## Where this state can go TO
var to_signals : Array= ["run","slide","jump","fall", "knockdown"]

## Signals which trigger other states
signal started_run
signal started_slide
signal started_jump
signal started_fall
signal started_knockdown

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
	## Idling causes to stop
	player.velocity = Vector2.ZERO
	animation_player.play("idle")

## Exiting! turn its speciic physics process func OFF, cleanup any needed things here!
func _exit_state()->void:
	set_physics_process(false)

## Idle code, can jump, fall, slide and jump
func _physics_process(_delta: float) -> void:
	## Idle is always on floor!
	if player.is_on_floor():
		
		## Debug knockdown player!
		if Input.is_action_just_pressed("debug_knockdown"):
			started_knockdown.emit()
			return
		
		## Movement axis
		movement_direction = Input.get_axis("left","right")
		
		## Started running!
		if not is_zero_approx(movement_direction):
			started_run.emit()
			return
		## Jump OR slide
		if Input.is_action_just_pressed("jump"):
			started_jump.emit()
			return
		elif Input.is_action_pressed("down") and player.can_slide:
			if Input.is_action_just_pressed("ability"):
				started_slide.emit()
				return
		
		player.move_and_slide()
	else:
		## Started falling from idle (maybe a platform dissapeared)
		started_fall.emit()
		return
