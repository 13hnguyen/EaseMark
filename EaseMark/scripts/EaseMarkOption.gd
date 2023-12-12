extends Resource

class_name EaseMarkOption

@export var control: Script

@export var name: String
@export var curve_min: float = -100
@export var curve_max: float = 100
@export var default: Resource


var packed_frame: PackedScene = preload("res://EaseMark/EaseMarkFrame.tscn")

func get_packed_frame() -> EaseMarkFrame:
    var p = packed_frame.instantiate()

    return p
