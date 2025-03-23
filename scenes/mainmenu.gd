extends Control
var is_ready = false

func _ready() -> void:
	$AnimationPlayer.play("popin")

var texts = ["Fun fact : Ce jeu est open source :3","N'oubliez pas votre priere au seigneur pain","Indeniablement, la France est le meilleur pays :)","Chaque citoyen francais a une reduction de 99% sur BakeIndustry","Nous presentons BakeAI, notre nouvel outil revolutionnaire","Si vous le pouvez et le voulez, supportez moi sur github sponsors :)","J'ai visite Shangai grace a ce jeu","Les croissants >>> pains au chocolat","0x99987 C'est surement casse ...","J'espere que vous passez une bonne journee","Le multijoueur arrive bientot","Lopa a dit que ce jeu etait incroyable","Envoyez moi un email a alice@spectralo.me","Pourquoi ce jeu est aussi mal optimise :/","Lopa m'a menace pour que j'ajoute sa citation :(","Hackclub.com","wafels zijn beter dan chocolade croissants -> Mensonge"]

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "popin":
		spawn_text()
		$Timer.start()

func spawn_text():
	var text_scene = load("res://movinglabel.tscn")
	var text = text_scene.instantiate()
	text.text = texts[randi_range(0,texts.size()-1)]
	$Control/LabelCOntainer.add_child(text)

func _on_timer_timeout() -> void:
	spawn_text()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	Trans.fadeTransition(load("res://scenes/fakeloading.tscn"))
