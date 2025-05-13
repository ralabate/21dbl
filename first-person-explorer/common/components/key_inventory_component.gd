class_name KeyInventoryComponent extends Node


@export var key_chain: Array[String]


func add_key(key: String) -> void:
	key_chain.append(key)


func has_key(key: String) -> bool:
	return key_chain.has(key)
