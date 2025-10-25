class_name player_knockdown
extends State

## NOTE each state can have access to different nodes, for example, if a state requires for some reason
## access to the player's camera (to shake it, etc) you can add it here and on initialize(), grab it from
## the player!! to then use it accordingly in this state (or you can even access it player.camera)

var state_machine: StateMachine
var player : Player
var sprite: Sprite2D
var animation_player: AnimationPlayer

## Where this state can go TO
var to_signals : Array= ["idle"]

var knockdown_strength: float = 100.0
var landed: bool = false

## Signals which trigger other states
signal started_idle

## Node ready, turn its processing off
func initialize():
	state_machine = get_parent()
	player = state_machine.get_parent()
	sprite = player.sprite
	animation_player = player.animation_player
	
	animation_player.connect("animation_finished", _on_knockdown_anim_finished)

func _ready() -> void:
	set_physics_process(false)

## Entering!, play anim and turn its speciic physics process func ON
func _enter_state()->void:
	set_physics_process(true)
	## Knock upwards
	player.velocity.y = -knockdown_strength
	## Double strenght knockback backwards
	player.velocity.x = player.get_direction() * (knockdown_strength * 2) * -1
	animation_player.play("knockdown_start")

## Exiting! turn its speciic physics process func OFF, cleanup any needed things here!
func _exit_state()->void:
	landed = false
	set_physics_process(false)

## Fall code
func _physics_process(_delta: float) -> void:
	## Already landed!, let anim player exit the state!
	if landed:
		return
	
	## Touched Floor! Start impact anim and recovery!
	if player.is_on_floor():
		## Wait until start is at least done to land
		if animation_player.current_animation != "knockdown_start":
			animation_player.play("knockdown_land")
			## Stop momentum
			player.velocity = Vector2.ZERO
			landed = true
			return
	else:
		## Fall gravity
		player.velocity.y += player.get_gravity().y * _delta
		
		## If knocked downwards, start falling
		if player.velocity.y >= 0: 
			animation_player.play("knockdown_falling")
	player.move_and_slide()

func _on_knockdown_anim_finished(anim_name: String) -> void:
	## Getting up, once up, idle again
	if anim_name == "knockdown_land":
		started_idle.emit()
		return
