extends SubViewport

@export var cel_sheet: CelSheet

func _on_cel_sheet_resized() -> void:
    size = cel_sheet.size
