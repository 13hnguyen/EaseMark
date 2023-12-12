extends EaseMarkControl

func behave(idx: int, sample: Vector2, object: Node2D) -> void:
    var tform := Transform2D(0.0, Vector2.ONE, sample.y * 0.009, Vector2.ZERO)
    object.transform = tform * object.transform
