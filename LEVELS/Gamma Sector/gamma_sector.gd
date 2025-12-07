extends Node3D

signal time_updated(animationTime)

@export var startTime = 20
@export var dayLengthInSeconds:float = 24

@export var morningColorTop: Color = Color("5897fa")
@export var morningColorHorizon: Color = Color("d3916b")

@export var dayColorTop: Color = Color("1f6ddf")
@export var dayColorHorizon: Color = Color("56a9f5")

@export var afternoonColorTop: Color = Color("3d6fcd")
@export var afternoonColorHorizon: Color = Color("e98174")

@export var nightColorTop: Color = Color("000000")
@export var nightColorHorizon: Color = Color("000000")

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Satellite 
@export var satellite_start_time: float = 10.0
@export var satellite_duration: float = 0.5   # 30 minutes = 0.5 heures
@export var satellite_color: Color = Color.BLACK
@export var satellite_size: float = 0.8
@export var satellite_fade_duration: float = 0.03
@onready var satellite: Sprite3D = null

var dayDuration = 24
var dayColorList = [
	{"top": morningColorTop, "horizon": morningColorHorizon, "startTime": 6},
	{"top": dayColorTop, "horizon": dayColorHorizon, "startTime": 8},
	{"top": afternoonColorTop, "horizon": afternoonColorHorizon, "startTime": 18},
	{"top": nightColorTop, "horizon": nightColorHorizon, "startTime": 20}
]
var currentDayState = 0
var durationMultiplier = 1.0

var current_tween: Tween = null
var satellite_tween: Tween = null
var satellite_fade_tween: Tween = null

func _ready() -> void:
	_change_duration()
	_set_sun()
	_set_current_state()
	_refresh_day_state()
	_day_change_animation()
	_create_satellite()
	
	# ✅ Configurer l'animation pour boucler
	var animation = animation_player.get_animation("day_and_night")
	if animation:
		animation.loop_mode = Animation.LOOP_LINEAR

func _create_satellite():
	satellite = Sprite3D.new()
	
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	for x in range(64):
		for y in range(64):
			var dx = x - 32
			var dy = y - 32
			var distance = sqrt(dx*dx + dy*dy)
			if distance < 28:
				image.set_pixel(x, y, satellite_color)
	
	satellite.texture = ImageTexture.create_from_image(image)
	
	satellite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	satellite.shaded = false
	satellite.pixel_size = 0.0000001 * 0.4
	satellite.modulate = satellite_color
	
	$Sun.add_child(satellite)
	
	satellite.position = Vector3(0, 0, -500)
	
	satellite.visible = false
	Global.satellite_visible = false

func _update_satellite_visibility():
	if not satellite:
		return
	
	# ✅ Normaliser le temps entre 0-24
	var current_time = fmod(animation_player.current_animation_position, 24.0)
	if current_time < 0:
		current_time += 24.0
	
	var end_time = satellite_start_time + satellite_duration
	
	# ✅ FIX PRINCIPAL : Mettre à jour Global.satellite_visible selon la fenêtre de temps
	var should_be_visible = (current_time >= satellite_start_time and current_time < end_time)
	
	# ✅ Mettre à jour immédiatement le Global
	Global.satellite_visible = should_be_visible
	
	# Gérer l'affichage visuel
	if should_be_visible:
		if not satellite.visible:
			satellite.visible = true
			_animate_satellite()
			_fade_in_satellite()
	else:
		if satellite.visible:
			_fade_out_satellite()

func _fade_in_satellite():
	if satellite_fade_tween and satellite_fade_tween.is_valid():
		satellite_fade_tween.kill()
	
	satellite_fade_tween = create_tween()
	var fade_duration = satellite_fade_duration * durationMultiplier
	
	satellite.pixel_size = 0.0000001 * 0.4
	satellite_fade_tween.tween_property(satellite, "pixel_size", satellite_size * 0.4, fade_duration)

func _fade_out_satellite():
	if satellite_fade_tween and satellite_fade_tween.is_valid():
		satellite_fade_tween.kill()
	
	satellite_fade_tween = create_tween()
	var fade_duration = satellite_fade_duration * durationMultiplier
	
	satellite_fade_tween.tween_property(satellite, "pixel_size", 0.0000001 * 0.4, fade_duration)
	satellite_fade_tween.tween_callback(func(): satellite.visible = false)

func _animate_satellite():
	if satellite_tween and satellite_tween.is_valid():
		satellite_tween.kill()
	
	satellite_tween = create_tween()
	var duration = satellite_duration * durationMultiplier
	
	var start_pos = Vector3(500, 5000, 300)
	var end_pos = Vector3(-500, 4000, -300)
	
	satellite.position = start_pos
	satellite_tween.tween_property(satellite, "position", end_pos, duration)

func _change_duration():
	durationMultiplier = dayLengthInSeconds/24
	animation_player.speed_scale = 1.0 / durationMultiplier

func _set_sun():
	animation_player.play("day_and_night")
	animation_player.seek(startTime)

func _set_current_state():
	for i in dayColorList.size():
		if startTime < dayColorList[i].startTime:
			currentDayState = i -1
			return

func _refresh_day_state():
	var newState = false
	
	var current_time = fmod(animation_player.current_animation_position, 24.0)
	if current_time < 0:
		current_time += 24.0
	
	for i in dayColorList.size():
		var sameState = i == currentDayState
		if not sameState and current_time > dayColorList[i].startTime:
			currentDayState = i
			newState = true
			
	if newState: 
		_day_change_animation()

func _day_change_animation():
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	current_tween = create_tween()
	
	var topColor = dayColorList[currentDayState]["top"]
	var hoirzonColor = dayColorList[currentDayState]["horizon"]
	
	var duration = durationMultiplier
	
	current_tween.tween_property(world_environment, "environment:sky:sky_material:sky_top_color", topColor, duration)
	current_tween.parallel()
	current_tween.tween_property(world_environment, "environment:sky:sky_material:sky_horizon_color", hoirzonColor, duration)
	current_tween.parallel()
	current_tween.tween_property(world_environment, "environment:sky:sky_material:ground_bottom_color", topColor, duration)
	current_tween.parallel()
	current_tween.tween_property(world_environment, "environment:sky:sky_material:ground_horizon_color", hoirzonColor, duration)

func _process(_delta: float) -> void:
	_refresh_day_state()
	_update_satellite_visibility()
	var normalized_time = fmod(animation_player.current_animation_position, 24.0)
	if normalized_time < 0:
		normalized_time += 24.0
	time_updated.emit(normalized_time)

func _exit_tree() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	if satellite_tween and satellite_tween.is_valid():
		satellite_tween.kill()
	if satellite_fade_tween and satellite_fade_tween.is_valid():
		satellite_fade_tween.kill()
