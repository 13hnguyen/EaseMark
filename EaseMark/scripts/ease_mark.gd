extends Resource

class_name EaseMark

signal ease_mark_changed

@export var curves: Array[Curve2D] = []
@export var curve_min: float = -100
@export var curve_max: float = 100

@export var default: Curve2D

var is_user_hovering: int = -1

func sample(idx: int, delta: float ) -> Vector2:
    if idx >= curves.size():
        return Vector2.ZERO
    
    return curves[idx].sample_baked(delta*curves[idx].get_baked_length())

func set_curve(curve: Curve2D, idx: int = -1 ) -> EaseMark:
    if idx == -1:
        curves.append(curve)
        ease_mark_changed.emit()
        return self
    
    if idx >= curves.size():
        return self
    
    curves[idx] = curve.duplicate()
    
    ease_mark_changed.emit()
    return self
    
func add_new_curve() -> EaseMark:
    curves.append(default.duplicate())
    ease_mark_changed.emit()
    return self
