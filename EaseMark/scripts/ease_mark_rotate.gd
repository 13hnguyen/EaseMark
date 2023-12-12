extends EaseMarkControl

func behave(idx: int, sample: Vector2, object: Node2D) -> void:
    var val = (sample.y)*2*PI/200.0
    object.transform = object.transform.rotated(val) 
