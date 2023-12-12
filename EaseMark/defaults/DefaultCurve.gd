extends Resource

class_name DefaultCurve

@export var array_curve: Array[Curve2D]



func get_curve(idx: int) -> Curve2D:
    if idx >= array_curve.size():
        return array_curve[0]
    return array_curve[idx].duplicate()
