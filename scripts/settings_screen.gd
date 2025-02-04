extends Panel

var sfx_bus_index: int = AudioServer.get_bus_index("SFX")
var music_bus_index: int = AudioServer.get_bus_index("Music")

@onready var settings_button: Button = $SettingsBackground/SettingsButton
@onready var sfx_volume_slider: HSlider = $SettingsBackground/SFXVolumeBox/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $SettingsBackground/MusicVolumeBox/MusicVolumeSlider
@onready var godmode_check: CheckButton = $SettingsBackground/GodmodeCheck
@onready var low_health_check: CheckButton = $SettingsBackground/LowHealthCheck

func _ready() -> void:
    _initialize_data()
    _connect_signals()
    z_index = 10

func _initialize_data() -> void:
    sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
    music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
    if Global.godmode:
        godmode_check.button_pressed = true
        low_health_check.disabled = true
    
    if Global.low_health:
        low_health_check.button_pressed = true
        godmode_check.disabled = true

func _connect_signals() -> void:
    settings_button.connect("pressed", _close)
    sfx_volume_slider.connect("value_changed", _on_sfx_volume_changed)
    music_volume_slider.connect("value_changed", _on_music_volume_changed)
    godmode_check.connect("toggled", _on_god_mode_check_toggled)
    low_health_check.connect("toggled", _on_low_health_check_toggled)

func _close() -> void:
    queue_free()

func _on_sfx_volume_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))

func _on_music_volume_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))

func _on_god_mode_check_toggled(toggled_on: bool) -> void:
    Global.godmode = toggled_on

    if toggled_on:
        low_health_check.disabled = true
    else:
        low_health_check.disabled = false

func _on_low_health_check_toggled(toggled_on: bool) -> void:
    Global.low_health = toggled_on

    if toggled_on:
        godmode_check.disabled = true
    else:
        godmode_check.disabled = false