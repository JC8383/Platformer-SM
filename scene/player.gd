extends CharacterBody2D
class_name Player

## NOTE all controls are inside each state as required, movement direction is handled by each state
## specific data such as cooldown, velocities, etc is handled on each state as needed too

## Nodes
@onready var sprite: Sprite2D = $sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dust_particles: CPUParticles2D = $dust_particles
@onready var state_machine: StateMachine = $state_machine

@onready var default_shape : CollisionShape2D = $default_shape
@onready var slide_shape : CollisionShape2D = $slide_shape
@onready var state_label: Label = $state_label

## Const
const SPEED : float = 200.0

## Vars
var is_sliding: bool = false
var can_slide: bool = true

## NOTE look at the state machine component scene for info on whats going on!
func _ready() -> void:
	state_machine.initialize()

## Just print the current state above the players head
func _physics_process(_delta: float) -> void:
	if state_machine.state != null:
		state_label.text = str(state_machine.state.name).trim_prefix("player_")

## Gets which side the character is currently looking towards, regardless of control input
func get_direction() -> int:
	if sprite.flip_h == true:
		return -1
	else:
		return 1

## Flips the sprite given a direction
func flip_sprite(direction: float) -> void:
	if is_zero_approx(direction):
		return
	
	if direction > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
