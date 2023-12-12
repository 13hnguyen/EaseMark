extends VBoxContainer

class_name EaseMarkContainer


signal ease_mark_update()
signal ease_mark_changed(ease_mark_option: EaseMarkOption, ease_mark_frame: EaseMarkFrame)

@export var arc: Arc 
@onready var ease_mark_edit: ColorRect = $EaseMarksContainer/SpeedMarkFrame/EaseMarkEdit

@export var ease_mark_list: Array[EaseMarkOption]

@onready var menu_button: MenuButton = $MenuButton
@onready var ease_marks_container: VBoxContainer = $EaseMarksContainer

@onready var speed_mark_edit: EaseMarkEdit = $EaseMarksContainer/SpeedMarkFrame/EaseMarkEdit

var num_segments:int
    
var frames: Array[EaseMarkFrame] = []

func _ready() -> void:
    for ease_mark in ease_mark_list:
        menu_button.get_popup().add_item(ease_mark.name)
        
#    for child in ease_marks_container.get_children():
#        child.set_num_segments(num_segments)
#
    menu_button.get_popup().index_pressed.connect(add_ease_mark)   
    
#    arc.speed_mark = ease_mark_edit.ease_mark
#    arc.update()
    
func add_ease_mark(id: int)->void:
    var ease_mark_option := ease_mark_list[id].duplicate()
    ease_mark_list.remove_at(id)
    menu_button.get_popup().remove_item(id)
    var packed_frame : EaseMarkFrame = ease_mark_option.get_packed_frame()

    ease_marks_container.add_child(packed_frame)

    packed_frame.set_label_name(ease_mark_option.name)
    
    ease_mark_changed.emit(ease_mark_option, packed_frame)

func set_speed_mark(speed_mark: EaseMark) -> void:
    speed_mark_edit.ease_mark = speed_mark
    
    
