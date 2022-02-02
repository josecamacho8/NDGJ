extends RigidBody2D


export var DialogueResource: Resource
export var StartingLine: String
export var AnimationStr: String

func _ready():
	$CharacterSprite.animation = AnimationStr
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
