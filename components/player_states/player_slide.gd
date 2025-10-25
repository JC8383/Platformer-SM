class_name player_slide
extends State

## Nodes
var state_machine: StateMachine
var player : Player
var animation_player: AnimationPlayer
var slide_cd_timer: Timer

## Where this state can go TO
var to_signals : Array= ["idle","run"]
## If you slide, fall from a cliff and touch floor again whilst still sliding, a loop slide anim will play
## instead of instantly switching to fall once reaching cliffs!
var sliding_from_fall: bool = false

## Slide parameters
@export var slide_initial_speed: float = 500.0
@export var slide_deceleration: float = 600.0
@export var slide_stop_threshold: float = 100.0
@export var slide_cooldown: float = 1.5

## Signals which trigger other states
signal started_idle
signal started_run

## Node ready, turn its processing off
func initialize():
	state_machine = get_parent()
	player = state_machine.get_parent()
	animation_player = player.animation_player
	
	## Can create custom timers, nodes, etc whatever you need here, in this case the cooldown for the
	## slide can be made here
	slide_cd_timer = Timer.new()
	slide_cd_timer.autostart = false
	slide_cd_timer.one_shot = true
	slide_cd_timer.wait_time = slide_cooldown
	slide_cd_timer.connect("timeout", _on_slide_cd_timer_timeout)
	add_child(slide_cd_timer)

func _ready() -> void:
	set_physics_process(false)

## Entering!, play anim and turn its speciic physics process func ON
func _enter_state()->void:
	set_physics_process(true)
	## Entering a slide, you can handle collisions here!
	player.is_sliding = true
	player.can_slide = false
	player.default_shape.disabled = true
	player.slide_shape.disabled = false
	
	## Velocity change
	player.velocity.x = slide_initial_speed * player.get_direction()
	player.dust_particles.direction.x = player.get_direction() * -1
	
	animation_player.play("slide")

## Exiting! turn its speciic physics process func OFF, cleanup any needed things here!
func _exit_state()->void:
	## Exiting a slide, you can handle collisions here!
	player.is_sliding = false
	player.default_shape.disabled = false
	player.slide_shape.disabled = true
	
	## Start slide CD when exiting the slide state
	slide_cd_timer.start()
	set_physics_process(false)

## Slide code
func _physics_process(_delta: float) -> void:
	if player.is_on_floor():
		## Deaccelerate slide
		player.velocity.x -= slide_deceleration * _delta * sign(player.velocity.x)
		## Slide stop, should i go idle or run?
		if abs(player.velocity.x) <= slide_stop_threshold:
			## If was pressing nothing, idle, otherwise run
			if is_zero_approx(movement_direction):
				started_idle.emit()
				return
			else:
				started_run.emit()
				return
		
		## Fell but still sliding!
		if sliding_from_fall:
			player.animation_player.play("slide_loop")
	else:
		## Still technically inside the slide state, but you can apply gravity too to keep the state going
		## as if it was a fall
		player.velocity.y += player.get_gravity().y * _delta
		if player.velocity.y >= 0:
			player.animation_player.play("falling")
			## Maybe sliding and falling causes a faster deacceleration too!
			## so your character doesnt fly off edges with full slide force
			player.velocity.x -= slide_deceleration * _delta * sign(player.velocity.x)
			
			sliding_from_fall = true
	
	player.move_and_slide()

func _on_slide_cd_timer_timeout() -> void:
	player.can_slide = true
