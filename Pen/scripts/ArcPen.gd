extends Pen

var MIN_DIST:= 1000.0

var arcs: PackedVector2Array = []
var keys: PackedInt32Array = []

func on_reset() -> void:
    super()
    arcs.clear()
    keys.clear()
    
func on_key_pressed(event: InputEventKey) -> void:
    if not get_rect().has_point(get_local_mouse_position()): 
        return
    if event.keycode == KEY_R and event.pressed == false and event.echo == false:
        on_reset()
        
func on_right_click() -> void:
    if not last_point.has("closest"):
        return
    right_click.emit(last_point["closest"])
    
func _read_point(point_position: Vector2) -> void:
    super(point_position)
    
    last_point["closest"] = -1
    var min_distance = MIN_DIST
    
    var idx = 0
    
    for i in arcs.size():
        var dist = arcs[i].distance_squared_to(point_position)
        if  dist < min_distance:
            last_point["closest"] = idx
            min_distance = dist
        idx += 1
        
    min_distance = MIN_DIST*2.0
    for i in keys.size():
        var dist = arcs[keys[i]].distance_squared_to(point_position)
        if  dist < min_distance:
            last_point["closest"] = -1
            min_distance = dist
        idx += 1
        
func _draw() -> void:
    if not last_point.has("closest"):
        return
    if last_point["closest"] == -1:
        return
    if arcs.is_empty():
        return
    draw_dashed_line(arcs[last_point["closest"]], last_point["position"], Color.BLACK, 3.0)
    draw_circle(arcs[last_point["closest"]], 7.0, Color.RED)
