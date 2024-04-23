extends Resource
class_name ItemResource

export var name: String
export var stackable: bool=false
export var max_stack: int = 99

enum ItemType {GENERIC, CONSUMABLE}
export(ItemType) var type
export var texture: Texture
export var mesh: Mesh
