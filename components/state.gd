class_name State
extends Node

## NOTE this is just the base class for all states, thus you can store vars shared across all states
## for example, movement direction may be used by all states to determine if the sprite flips, where to move, etc

static var movement_direction : float
