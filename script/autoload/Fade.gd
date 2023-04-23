extends ColorRect

func _ready():
	white()

func white():
	color.a = 0
	visible = false

func black():
	color.a = 255
	visible = true

func fade_in():
	$anims.play("fade_in")

func fade_out():
	$anims.play("fade_out")
