extends Control

class_name Pen


signal stroke_changed
signal pen_lifted
signal pen_reset
signal right_click(idx: int)


@export var is_active: bool = true

var strokes: Array[PackedVector2Array] = []
var current_stroke: PackedVector2Array = []

var is_mouse_pressed: bool = false

var last_point: Dictionary = {"position": Vector2.ZERO}

func on_reset() -> void:
    on_released()
    
    strokes = []
    current_stroke = []
    pen_reset.emit()
    queue_redraw()
    
func on_pressed() -> void:
    is_mouse_pressed = true
    strokes.append(current_stroke)
    
    add_new_point()
    queue_redraw()

func on_released() -> void:
    is_mouse_pressed = false
    current_stroke = []
    if get_rect().has_point(get_local_mouse_position()): 
        pen_lifted.emit()

func on_moved() -> void:
    add_new_point()

func on_right_click() -> void:
    right_click.emit(-1)

func on_key_pressed(event: InputEventKey) -> void:
    pass

func add_new_point() -> void:
    var lsi := strokes.size() - 1 #last stroke index
    
    strokes[lsi].append(last_point["position"])

func _read_point(point_position: Vector2) -> void:
    last_point["position"] = point_position
    queue_redraw()

func _process(_delta: float) -> void:
    if not is_active:
        return
        
    if is_mouse_pressed:
        stroke_changed.emit()
        queue_redraw()

func _input(event: InputEvent) -> void:
    if not is_active:
        return
    
    Input.use_accumulated_input = false
    
    if event is InputEventKey:
        on_key_pressed(event)
        return
    
    if event is InputEventMouseMotion:
        var point := get_local_mouse_position()
        if get_rect().has_point(point): 
            _read_point(point)
        else:
            on_released()
    
    if event is InputEventMouseButton  and event.pressed == false and event.button_index == MOUSE_BUTTON_RIGHT:
        on_right_click()
        return
    
    
    if not is_mouse_pressed and event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT :
        on_pressed()
        return
    
    if is_mouse_pressed and event is InputEventMouseButton  and event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
        on_moved()
        on_released()
        return
    
    
    if is_mouse_pressed and event is InputEventMouseMotion:
        on_moved()
        return
    
func _draw() -> void:
    draw_circle(last_point["position"], 3.0, Color.WHITE)
