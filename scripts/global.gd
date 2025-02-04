extends Node

enum TWEENS {
	SCALE,
	ROTATE,
	SCATTER
}

enum ITEM_TYPES {
	IRON,
	STONE,
	EARTH,
	WATER
}

enum SFXs {
	IRON_PLACE,
	IRON_DROP,
	WATER_PLACE,
	WATER_FLOAT,
	STONE_PLACE,
	EARTH_PLACE,
}

enum ANIMATIONS {
	DEATH,
	IDLE,
	NEW_STAGE,
	NORMAL_WALK,
	SAD_WALK,
	START_NORMAL_WALK,
	STOP_NORMAL_WALK
}

enum DIFFICULTIES {
	EASY,
	MEDIUM,
	HARD
}

const SFX: Dictionary = {
	SFXs.IRON_PLACE: preload("res://assets/sounds/sfx/iron_place.ogg"),
	SFXs.IRON_DROP: preload("res://assets/sounds/sfx/iron_drop.ogg"),
	SFXs.WATER_PLACE: preload("res://assets/sounds/sfx/water_place.ogg"),
	SFXs.WATER_FLOAT: preload("res://assets/sounds/sfx/water_float.ogg"),
	SFXs.STONE_PLACE: preload("res://assets/sounds/sfx/stone_place.ogg"),
	SFXs.EARTH_PLACE: preload("res://assets/sounds/sfx/earth_place.ogg"),
}

const ANIMATION: Dictionary = {
	ANIMATIONS.DEATH: "death",
	ANIMATIONS.IDLE: "idle",
	ANIMATIONS.NEW_STAGE: "new_stage",
	ANIMATIONS.NORMAL_WALK: "normal_walk",
	ANIMATIONS.SAD_WALK: "sad_walk",
	ANIMATIONS.START_NORMAL_WALK: "start_normal_walk",
	ANIMATIONS.STOP_NORMAL_WALK: "stop_normal_walk",
}

const ITEMS: Dictionary = {
	ITEM_TYPES.IRON: [
		{"shape": [[1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 2, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron1x1-H.png"),
			"v": preload("res://assets/objects/iron1x1-V.png")
		}},
		{"shape": [[1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 4, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron1x2-H.png"),
			"v": preload("res://assets/objects/iron1x2-V.png")
		}},
		{"shape": [[1, 1], [1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.MEDIUM, "score": {"penalty": 4, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron2x2-H.png"),
			"v": preload("res://assets/objects/iron2x2-V.png")
		}},
		{"shape": [[1, 1], [1, 1], [1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.HARD, "score": {"penalty": 6, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron2x3-H.png"),
			"v": preload("res://assets/objects/iron2x3-V.png")
		}},
		{"shape": [[1, 1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.MEDIUM, "score": {"penalty": 6, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron1x3-H.png"),
			"v": preload("res://assets/objects/iron1x3-V.png")
		}},
		{"shape": [[1, 1, 1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.HARD, "score": {"penalty": 8, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron1x4-H.png"),
			"v": preload("res://assets/objects/iron1x4-V.png")
		}},
		{"shape": [[1, 1, 1, 1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.HARD, "score": {"penalty": 10, "bonus": 0}, "images": {
			"h": preload("res://assets/objects/iron1x5-H.png"),
			"v": preload("res://assets/objects/iron1x5-V.png")
		}},
	],
	ITEM_TYPES.STONE: [
		{"shape": [[0, 1, 0], [1, 1, 1]], "shape_type": "צורת T", "difficulty": DIFFICULTIES.MEDIUM, "score": {"penalty": 6, "bonus": 3}, "images": {
			"h": preload("res://assets/objects/stone_T-H.png"),
			"v": preload("res://assets/objects/stone_T-V.png")
		}},
		{"shape": [[1, 0], [1, 1], [0, 1]], "shape_type": "זיגזג", "difficulty": DIFFICULTIES.MEDIUM, "score": {"penalty": 6, "bonus": 3}, "images": {
			"h": preload("res://assets/objects/stone_Z-H.png"),
			"v": preload("res://assets/objects/stone_Z-V.png")
		}},
		{"shape": [[1, 1], [1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 4, "bonus": 2}, "images": {
			"h": preload("res://assets/objects/stone2x2-H.png"),
			"v": preload("res://assets/objects/stone2x2-V.png")
		}},
		{"shape": [[1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 2, "bonus": 1}, "images": {
			"h": preload("res://assets/objects/stone1x1-H.png"),
			"v": preload("res://assets/objects/stone1x1-V.png")
		}},
		{"shape": [[1], [1], [1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 6, "bonus": 3}, "images": {
			"h": preload("res://assets/objects/stone1x3-H.png"),
			"v": preload("res://assets/objects/stone1x3-V.png")
		}},
		{"shape": [[0, 1], [1, 1]], "shape_type": "צורת L", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 4, "bonus": 2}, "images": {
			"h": preload("res://assets/objects/stone_L-H.png"),
			"v": preload("res://assets/objects/stone_L-V.png")
		}},
	],
	ITEM_TYPES.EARTH: [
		{"shape": [[1, 1], [1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 4}, "images": {
			"h": preload("res://assets/objects/earth2x2-H.png"),
			"v": preload("res://assets/objects/earth2x2-V.png")
		}},
		{"shape": [[1, 0], [1, 1]], "shape_type": "צורת L", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 4}, "images": {
			"h": preload("res://assets/objects/earth_L-H.png"),
			"v": preload("res://assets/objects/earth_L-V.png")
		}},
		{"shape": [[1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 4}, "images": {
			"h": preload("res://assets/objects/earth1x2-V.png"),
			"v": preload("res://assets/objects/earth1x2-H.png")

		}},
		{"shape": [[1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 2}, "images": {
			"h": preload("res://assets/objects/earth1x1-H.png"),
			"v": preload("res://assets/objects/earth1x1-V.png")
		}},
	],
	ITEM_TYPES.WATER: [
		{"shape": [[1, 1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 1}, "images": {
			"h": preload("res://assets/objects/water1x2-H.png"),
			"v": preload("res://assets/objects/water1x2-V.png")
		}},
		{"shape": [[1]], "shape_type": "", "difficulty": DIFFICULTIES.EASY, "score": {"penalty": 0, "bonus": 2}, "images": {
			"h": preload("res://assets/objects/water1x1-H.png"),
			"v": preload("res://assets/objects/water1x1-V.png")
		}},
	]
}

const WEEKDAY_GRID_SLOTS: Dictionary = {"rows": 5, "columns": 4}
const WEEKEND_GRID_SLOTS: Dictionary = {"rows": 5, "columns": 3}

var INITIAL_HEALTH: int = 30

var tasks_1 = {
	1: {
		"type": ITEM_TYPES.STONE,
		"difficulty": DIFFICULTIES.EASY,
		"description": "קלאסית 1/6 - למצוא רפרנס והשראות",
		"completed": false
	},
	2: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "קלאסית 2/6 -הכנת פרזנטציה וסטוריבורד",
		"completed": false
	},
	3: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "קלאסית 3/6 - גיבוש ותזמון אנימטיק",
		"completed": false
	},
	4: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "קלאסית 4/6 - חידוד ואינמוצ 6 שניות",
		"completed": false
	},
	5: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "קלאסית 5/6 - סאונד ועריכה",
		"completed": false
	},
	6: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "קלאסית 6/6 - הגשה סופית באנימציה קלאסית",
		"completed": false
	},
}

var tasks_2 = {
	1: {
		"type": ITEM_TYPES.STONE,
		"difficulty": DIFFICULTIES.EASY,
		"description": "סטופ 1/6 - טסטים",
		"completed": false
	},
	2: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.EASY,
		"description": "סטופ 2/6 - הכנת פיצ’ וגיבוש רעיון סופי",
		"completed": false
	},
	3: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "סטופ 3/6 - צילומים",
		"completed": false
	},
	4: {
		"type": ITEM_TYPES.STONE,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "סטופ 4/6 - פגישות אישיות",
		"completed": false
	},
	5: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "סטופ 5/6 - עריכה",
		"completed": false
	},
	6: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "סטופ 6/6 - הגשה סופית בסטופ מושן",
		"completed": false
	},
}

var tasks_3 = {
	1: {
		"type": ITEM_TYPES.STONE,
		"difficulty": DIFFICULTIES.EASY,
		"description": "תלת 1/7 - גיבוש רפרנסים",
		"completed": false
	},
	2: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "תלת 2/7 - גיבוש ומידול הסביבה",
		"completed": false
	},
	3: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.EASY,
		"description": "תלת 3/7 - לייאאוט ראשוני של הדמות",
		"completed": false
	},
	4: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.MEDIUM,
		"description": "תלת 4/7 - פוזות וברייקדאונים",
		"completed": false
	},
	5: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "תלת 5/7 - טיקסטור הסביבה והוספת תאורה",
		"completed": false
	},
	6: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "תלת 6/7 - העברת התרגיל לאוטו וחידוד סופי של האנימציה",
		"completed": false
	},
	7: {
		"type": ITEM_TYPES.IRON,
		"difficulty": DIFFICULTIES.HARD,
		"description": "תלת 7/7 - הגשה סופית בתחלת מימד",
		"completed": false
	},
}

const WATER_TASK_DESCRIPTIONS = [
"לישון",
"לאכול",
"לכבס את הבגדים",
"להתקשר להורים",
"לבלות עם החברים",
"לצפות בסדרה",
'לקרוא בתנ"ך',
"להתעסק בתחביב",
"לצייר",
"לשחק במשחק מחשב"
]

const EARTH_TASK_DESCRIPTIONS = [
"חדר כושר",
"פגישה עם פסיכולוג",
"לטייל בטבע"
]


const EASY_AND_MEDIUM_METAL_AND_STONE = [
"כתיבת תרגיל בתסריט",
"גיבוש רעיון ותחילת מחקר לפרוס",
"משמרת בעבודה",
"רישומים לקורס רישום",
"לטייל עם הכלב",
"להתקשר לבנק",
"לטפל בבירוקרטיה",
"לעשות קניות לבית",
"נקיון בבית"
]

var week: int = 0
var low_health: bool = false
var godmode: bool = false
var is_dragging = false
var drag_preview: Node
var cell_size = {
	"width": 0,
	"height": 0
}

var background_music_player: AudioStreamPlayer
var player_animations: AnimatedSprite2D
var screen_animations: AnimatedSprite2D

func init(_background_music_player: AudioStreamPlayer, _player_animations_: AnimatedSprite2D, _screen_animations: AnimatedSprite2D) -> void:
	background_music_player = _background_music_player
	player_animations = _player_animations_
	screen_animations = _screen_animations
	_initialize_cell_size()
	background_music_player.play()

# Helper function to initialize the cell sizes
func _initialize_cell_size() -> void:
	var weekday_grid_manager: Control = get_node("/root/Main/WeekdayGridManager")
	var weekend_grid_manager: Control = get_node("/root/Main/WeekendGridManager")
	cell_size.width = weekday_grid_manager.size.x / WEEKDAY_GRID_SLOTS.columns
	cell_size.height = weekday_grid_manager.size.y / WEEKDAY_GRID_SLOTS.rows

	prints("Cell size based on weekday grid:", cell_size)
	print("Cell size based on weekend grid: ", {"width": weekend_grid_manager.size.x / WEEKEND_GRID_SLOTS.columns, "height": weekend_grid_manager.size.y / WEEKEND_GRID_SLOTS.rows})

	if (cell_size.width != weekend_grid_manager.size.x / WEEKEND_GRID_SLOTS.columns or cell_size.height != weekend_grid_manager.size.y / WEEKEND_GRID_SLOTS.rows):
		print("WARNING: Cell sizes are not equal between weekday and weekend grids!")

# Helper function to create empty shape array
func _create_empty_shape(rows: int, cols: int) -> Array:
	var new_shape = []
	for i in range(rows):
		new_shape.append([])
		for _j in range(cols):
			new_shape[i].append(0)
	return new_shape

# Helper function to play SFX
func _play_sfx(type: SFXs) -> void:
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = SFX[type]
	player.connect("finished", func(): player.queue_free())

	add_child(player)

	player.play()

func _play_animations(animations: Array[ANIMATIONS], reverse: bool = false) -> void:
	for animation in animations:
		if reverse:
			player_animations.play_backwards(ANIMATION[animation])
			screen_animations.play_backwards(ANIMATION[animation])
		else:
			player_animations.play(ANIMATION[animation])
			screen_animations.play(ANIMATION[animation])
		await player_animations.animation_finished

func reset() -> void:
	week = 0
	is_dragging = false
	drag_preview = null
	
	for task in tasks_1.values():
		task.completed = false
	for task in tasks_2.values():
		task.completed = false
	for task in tasks_3.values():
		task.completed = false

	_play_animations([ANIMATIONS.IDLE])