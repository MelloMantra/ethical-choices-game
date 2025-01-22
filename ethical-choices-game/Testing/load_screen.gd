extends Control
var scene_to_load : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	
	scene_to_load = BasicClassFunctions.scene_to_load
	ResourceLoader.load_threaded_request(scene_to_load)

func _process(delta):
	if scene_to_load != "":
		var progressAmount : Array = []
		var loadStatus : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_to_load, progressAmount)
		if loadStatus == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_to_load))
		
		$Label/ProgressBar.value = progressAmount[0]
