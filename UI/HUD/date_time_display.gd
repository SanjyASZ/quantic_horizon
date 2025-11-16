extends Control

@onready var location: Label = %Location
@onready var time_zone: Label = %TimeZone
@onready var time_label: Label = %Time_label

var currentDate = Time.get_datetime_dict_from_datetime_string("2025-04-01T06:00:00", false)
var lastHour = 0

func _ready() -> void:
	_refresh_display()

func _refresh_display():
	time_label.text = _get_time_label()

func _add_zero(number):
	if number < 10: 
		return "0" + str(number)
	else:
		return str(number)

func _get_time_label():
	var hour: int
	var meridiem: String
	
	if currentDate.hour - 12 < 0:
		hour = currentDate.hour
		meridiem = "am"
	else:
		hour = currentDate.hour - 12
		meridiem = "pm"
		
	return _add_zero(hour) + ":" + _add_zero(currentDate.minute) + " " + meridiem
	


func _on_tidehaven_time_updated(animationTime: Variant) -> void:
	var total_minutes := int(animationTime * 60)

	var new_hour := total_minutes / 60
	var new_minute := total_minutes % 60

	if new_hour != currentDate.hour or new_minute != currentDate.minute:
		currentDate.hour = new_hour
		currentDate.minute = new_minute

		_refresh_display()
 
#0c1a3c
