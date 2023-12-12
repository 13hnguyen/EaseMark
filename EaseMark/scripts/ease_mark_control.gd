extends Node

class_name EaseMarkControl

@export var ease_mark: EaseMark
@export var arc: Arc

func move(idx: int, delta: float, object: Node2D) -> Vector2:
    var sample := ease_mark.sample(idx, delta)
    behave(idx, sample, object)
    return sample

func behave(idx: int, sample: Vector2, object: Node2D) -> void:
    pass
