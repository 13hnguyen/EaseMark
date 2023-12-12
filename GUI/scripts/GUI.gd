extends Control

@onready var arcs: Node = $SubViewport/Arcs
@onready var cel_sheet: Control = $HSplitContainer/VSplitContainer/CelSheet
@onready var onion_skinning: Node2D = $SubViewport/OnionSkinning


var hide_arc:bool = false

func _input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    if event.keycode == KEY_S and event.pressed==true and event.echo == false:
        if hide_arc:
            hide_arc = false
            cel_sheet.show_arc = true
            onion_skinning.show()
        else:
            hide_arc = true
            cel_sheet.show_arc = false
            onion_skinning.hide()

func _process(_delta: float) -> void:
    
    if Input.is_action_just_pressed("play"):
        for arc in arcs.get_children():
            arc.is_playing = true
    if Input.is_action_just_released("play"):
        for arc in arcs.get_children():
            arc.is_playing = false
