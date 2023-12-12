extends EaseMarkControl

func behave(idx: int, sample: Vector2, object: Node2D) -> void:
    var val = (sample.y*0.01)
    object.transform = object.transform.scaled(Vector2(1.0+val, 1.0+val))
