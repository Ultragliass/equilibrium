extends Control

var skip_deplay: float = 0.5
var splash_screens: Array[SplashScreen] = []

@export var move_to: PackedScene

@onready var splash_screen_continer: CenterContainer = $SplashContainer

func _ready():
	assert(move_to)
	
	set_process_input(false)
	
	for splash_screen in splash_screen_continer.get_children():
		splash_screen.hide()
		splash_screens.push_back(splash_screen)
		
	await get_tree().create_timer(skip_deplay).timeout
	
	start_splash_screen()
	
	set_process_input(true)
	
func start_splash_screen():
	if !splash_screens.size(): get_tree().change_scene_to_packed(move_to)
	else:
		var splash_screen: SplashScreen = splash_screens.pop_front()
		splash_screen.start()
		splash_screen.connect("finished", start_splash_screen)

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("splash_skip"): skip()

func skip():
	splash_screen_continer.get_child(0).queue_free()
	start_splash_screen()
