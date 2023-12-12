extends Control

class_name EaseMarkFrame

signal move_up
signal move_down
signal delete
@onready var ttile: Label = %Ttile
@onready var ease_mark_edit: EaseMarkEdit = $EaseMarkEdit


func set_ease_mark(ease_mark: EaseMark) -> void:
    ease_mark_edit.ease_mark = ease_mark

func set_label_name(name: String) -> void:
    ttile.text = name

func _on_move_up_pressed() -> void:
    move_up.emit()


func _on_move_down_pressed() -> void:
    move_down.emit()


func _on_delete_pressed() -> void:
    delete.emit()
    
