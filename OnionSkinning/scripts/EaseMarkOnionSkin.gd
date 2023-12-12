extends Node2D

@export var control: EaseMarkControl

@export var num_sheets: int = 5

func update_skin() -> void:
    var delta:float = 1.0/num_sheets
    for child in get_children():
        
