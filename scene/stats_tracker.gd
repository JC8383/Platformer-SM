extends VBoxContainer
@export var player: Player

@onready var velocity_label: Label = $velocity_label
@onready var sliding_label: Label = $sliding_label
@onready var sliding_available_label: Label = $sliding_available_label

func _physics_process(_delta: float) -> void:
	if player:
		velocity_label.text = "speed (x) = "+str(abs(player.velocity.x))
		sliding_label.text = "can_slide = "+str(player.can_slide)
		sliding_available_label.text = "is_sliding = "+str(player.is_sliding)
