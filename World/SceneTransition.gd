extends Node2D

export var SceneToTransitionTo: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func transition():
	GlobalAudioSounds.stream.resource_path = "res://Resources/Sounds/qubodup-DoorOpen01.ogg"
	GlobalAudioSounds.play()
	get_tree().change_scene(SceneToTransitionTo)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
