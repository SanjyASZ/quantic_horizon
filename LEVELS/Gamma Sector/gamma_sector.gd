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
@export var satellite_start_time: float = 10.0  # 15h00 = 3PM
@export var satellite_duration: float = 0.5   # 20 minutes = 20/60 heures
@export var satellite_color: Color = Color.BLACK
@export var satellite_size: float = 0.8  # Taille du point noir
@export var satellite_fade_duration: float = 0.03  # ✅ NOUVEAU : 2 minutes = 2/60 heures
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

# ✅ AJOUT : Stocker le tween actuel
var current_tween: Tween = null
var satellite_tween: Tween = null  # ✅ Tween séparé pour le satellite
var satellite_fade_tween: Tween = null  # ✅ NOUVEAU : Tween pour le fade

func _ready() -> void:
	_change_duration()
	_set_sun()
	_set_current_state()
	_refresh_day_state()
	_day_change_animation()
	_create_satellite()

func _create_satellite():
	# ✅ Créer un Sprite3D pour un point noir simple
	satellite = Sprite3D.new()
	
	# Créer une texture : petit cercle noir
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Dessiner un cercle noir
	for x in range(64):
		for y in range(64):
			var dx = x - 32
			var dy = y - 32
			var distance = sqrt(dx*dx + dy*dy)
			if distance < 28:  # Rayon du cercle
				image.set_pixel(x, y, satellite_color)
	
	satellite.texture = ImageTexture.create_from_image(image)
	
	# Configuration du sprite
	satellite.billboard = BaseMaterial3D.BILLBOARD_ENABLED  # Face toujours la caméra
	satellite.shaded = false  # Pas affecté par la lumière
	satellite.pixel_size = 0.0000001 * 0.4  # ✅ NOUVEAU : Commence minuscule
	satellite.modulate = satellite_color
	
	# ✅ Ajouter comme enfant de Sun pour suivre sa rotation
	$Sun.add_child(satellite)
	
	# ✅ Position TRÈS LOIN dans la direction opposée à la lumière
	# (là où le soleil visuel du sky shader apparaît)
	satellite.position = Vector3(0, 0, -500)
	
	# Cacher au départ
	satellite.visible = false
	
	print("🛰️ Satellite créé (Sprite3D)")

func _update_satellite_visibility():
	if not satellite:
		return
		
	var current_time = animation_player.current_animation_position
	var end_time = satellite_start_time + satellite_duration
	
	# Afficher uniquement pendant la fenêtre de temps
	if current_time >= satellite_start_time and current_time < end_time:
		if not satellite.visible:
			print("✅ Satellite VISIBLE à ", current_time, "h")
			satellite.visible = true
			_animate_satellite()  # Démarrer l'animation
			_fade_in_satellite()  # ✅ NOUVEAU : Fade in par taille
	else:
		if satellite.visible:
			print("❌ Satellite CACHÉ")
			_fade_out_satellite()  # ✅ NOUVEAU : Fade out par taille

# ✅ NOUVELLE FONCTION : Apparition progressive (taille 0.0000001 → 0.8)
func _fade_in_satellite():
	if satellite_fade_tween and satellite_fade_tween.is_valid():
		satellite_fade_tween.kill()
	
	satellite_fade_tween = create_tween()
	var fade_duration = satellite_fade_duration * durationMultiplier
	
	satellite.pixel_size = 0.0000001 * 0.4
	satellite_fade_tween.tween_property(satellite, "pixel_size", satellite_size * 0.4, fade_duration)

# ✅ NOUVELLE FONCTION : Disparition progressive (taille 0.8 → 0.0000001)
func _fade_out_satellite():
	if satellite_fade_tween and satellite_fade_tween.is_valid():
		satellite_fade_tween.kill()
	
	satellite_fade_tween = create_tween()
	var fade_duration = satellite_fade_duration * durationMultiplier
	
	satellite_fade_tween.tween_property(satellite, "pixel_size", 0.0000001 * 0.4, fade_duration)
	satellite_fade_tween.tween_callback(func(): satellite.visible = false)

func _animate_satellite():
	# ✅ Tuer le tween précédent du satellite
	if satellite_tween and satellite_tween.is_valid():
		satellite_tween.kill()
	
	satellite_tween = create_tween()
	var duration = satellite_duration * durationMultiplier
	
	# ✅ Trajectoire qui traverse le soleil (coordonnées relatives au Sun)
	# X : gauche à droite
	# Y : peut ajouter une composante verticale
	# Z : reste à -500 (loin, devant le soleil du sky)
	var start_pos = Vector3(500, 5000, 300)   # Haut gauche
	var end_pos = Vector3(-500, 4000, -300)     # Bas droite
	
	satellite.position = start_pos
	satellite_tween.tween_property(satellite, "position", end_pos, duration)
	
	print("🎬 Animation satellite : ", duration, " secondes réelles")

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
	
	for i in dayColorList.size():
		var sameState = i == currentDayState
		if not sameState and animation_player.current_animation_position > dayColorList[i].startTime:
			currentDayState = i
			newState = true
			
	if newState: 
		_day_change_animation()

func _day_change_animation():
	# ✅ FIX : TUER le tween précédent avant d'en créer un nouveau
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
	time_updated.emit(animation_player.current_animation_position)

# ✅ BONUS : Nettoyer à la destruction
func _exit_tree() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	if satellite_tween and satellite_tween.is_valid():
		satellite_tween.kill()
	if satellite_fade_tween and satellite_fade_tween.is_valid():  # ✅ NOUVEAU
		satellite_fade_tween.kill()
