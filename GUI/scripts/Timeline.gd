extends Control

class_name Timeline

@export var cel_sheet: CelSheet

signal timeline_changed
@onready var keys_container: HBoxContainer = $Keys
@onready var segments_container: HBoxContainer = $Segments

var timeline_key_packed : PackedScene = preload("res://GUI/TimelineKey.tscn")
var timeline_segment_packed : PackedScene = preload("res://GUI/TimelineSegment.tscn")

var keys: Array[int] = []
var segments: Array[Vector2i] = []

var key_pressed:= false

var current_segment: Vector2i

func reset() -> void:
    segments = []
    for n in segments_container.get_children():
        segments_container.remove_child(n)    
        n.queue_free()
    
    timeline_changed.emit()



func on_key_clicked(idx: int) -> void:

    key_pressed = true
    current_segment.x = idx

func on_key_released(idx: int) -> void:

    if not key_pressed:
        return
    key_pressed = false
    current_segment.y = idx
    segments.append(current_segment)
    var segment_panel := timeline_segment_packed.instantiate()
    
    segments_container.add_child(segment_panel)
    segment_panel.set_first(current_segment.x)
    segment_panel.set_second(current_segment.y)
    
    timeline_changed.emit()
    
func mouse_pressed(event: InputEventMouseButton):
    var pos = keys_container.get_local_mouse_position()
    var idx = -1
    for i in keys_container.get_child_count():
        var button := keys_container.get_child(i) as Button
        if button.get_rect().has_point(pos):
            idx = i
            break
    
    if idx == -1:
        key_pressed = false
        return
    
    if event.pressed == true:
        on_key_clicked(idx)
    else:
        on_key_released(idx) 
    
    
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_C and event.pressed == false and event.echo == false:
        reset()
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        mouse_pressed(event)

func _on_cel_sheet_keys_changed() -> void:
    if not keys_container:
        return
    for n in keys_container.get_children():
        keys_container.remove_child(n)    
        n.queue_free()
    
    keys = cel_sheet.keys
    for i in keys.size():
        var key_button:= timeline_key_packed.instantiate() as Button
        key_button.text = str(i)
        keys_container.add_child(key_button)         
    
    reset()
    
