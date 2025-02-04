extends TextureRect

@onready var settings_screen = preload("res://scenes/Settings_Screen.tscn")
@onready var start_game_button: TextureButton = $StartGameButton
@onready var settings_button: TextureButton = $SettingsButton

func _ready() -> void:
    _connect_signals()

func _connect_signals() -> void:
    start_game_button.connect("pressed", _on_start_game_button_pressed)
    settings_button.connect("pressed", _on_settings_button_pressed)

func _on_start_game_button_pressed() -> void:
    start_game_button.disabled = true
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
    await tween.finished
    visible = false
    
func _on_settings_button_pressed() -> void:
    add_child(settings_screen.instantiate())