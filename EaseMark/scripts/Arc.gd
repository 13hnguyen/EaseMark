extends Node

class_name Arc

@export var animation_time: float = 1.0
@export var object: Node2D
@export var cel_sheet: CelSheet
@export var ease_mark_container: EaseMarkContainer
@export var timeline: Timeline
@onready var speed_mark: SpeedMarkControl = $SpeedMarkControl


var is_playing: bool = false

var arcs: PackedVector2Array = []
var keys: Array[int] = []
var segments: Array[Vector2i] = []

var delta_time: float = 0

func _ready() -> void:
    ease_mark_container.set_speed_mark(speed_mark.ease_mark)
    cel_sheet.add_ease_mark(speed_mark.ease_mark)
    speed_mark.animation_time = animation_time

func _process(delta: float) -> void:
    if not is_playing:
        return
    
    var idx: int = 0
    var sample: float = 0.0
    
    var s:= speed_mark.get_sample(delta)
    
    idx = floor(s)
    if idx >= segments.size():
        return
    sample = s-idx
    if sample == 0.0:
        idx -= 1
        sample = 1.0
        
    object.transform = Transform2D()
    
    for child in get_children():
        if not child is EaseMarkControl:
            continue
        
        child.move(idx, sample, object)
    
    
    
    var seg := segments[idx]
    var range := keys[seg.y] - keys[seg.x]
    var mid_idx : int = floor(range * sample) + keys[seg.x]
    
    object.translate(arcs[mid_idx]) 
    
func update() -> void:
    pass
#    speed_mark.convert_speed_curve(segments.size())
#    for child in get_children():
#        if child is EaseMarkControl:
#            child.object = object
#            child.arc = self
#            for i in range(child.ease_mark.curves.size(), segments.size()):
#                child.ease_mark.set_curve(child.default_mark())


func _on_ease_mark_container_ease_mark_changed(ease_mark_option: EaseMarkOption, ease_mark_frame: EaseMarkFrame) -> void:
    
    var ease_mark := EaseMark.new()
    ease_mark.curve_min = ease_mark_option.curve_min
    ease_mark.curve_max = ease_mark_option.curve_max
    ease_mark.default = ease_mark_option.default.get_curve(0)
    
    ease_mark_frame.set_ease_mark(ease_mark)
    cel_sheet.add_ease_mark(ease_mark)
    
    for i in segments.size():
        ease_mark.add_new_curve()
        
    var new_node :EaseMarkControl= EaseMarkControl.new()
    new_node.set_script(ease_mark_option.control)
    
    new_node.arc = self
    new_node.ease_mark = ease_mark
    
    add_child(new_node)


func _on_timeline_timeline_changed() -> void:
    segments = timeline.segments
    
    var segment_num:= segments.size()
    
    if segment_num == 0:
        for child in get_children():
            child.ease_mark.curves.clear()
            child.ease_mark.ease_mark_changed.emit()
        return
    
    for i in range(speed_mark.ease_mark.curves.size(), segment_num):
        for child in get_children():
            child.ease_mark.add_new_curve()
    cel_sheet.segments = segments

func _on_cel_sheet_keys_changed() -> void:
    arcs = cel_sheet.arcs
    keys = cel_sheet.keys
    
