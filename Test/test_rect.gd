extends Node2D

@export var rect: Rect2

@export var curve_min: float = -100
@export var curve_max: float = 100

@export var curves: Array[Curve2D]

@export var index: int = 0:
    set(i):
        index = i
        change_curve(curves[i], curve_min, curve_max, 100.0)
        
var closest:Vector2 = Vector2.ZERO
var current_curve: Curve2D

func change_curve(curve: Curve2D, curve_min: float = 0.0, curve_max: float = 100.0, x_range: float = 100.0) -> void:
    
    var curve_range = curve_max - curve_min
    
    for i in curve.point_count:
        curve.get_point_in(i)
        curve.get_point_position(i)
        curve.get_point_out(i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    change_curve(curves[index], curve_min, curve_max, 100.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    #closest = GeometryHelper.get_closest_rect_point(get_global_mouse_position(), rect)
    
    
func _draw() -> void:
    draw_rect(rect, Color.BEIGE, true)
    #draw_circle(closest, 10.0, Color.RED)
