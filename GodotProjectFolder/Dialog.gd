extends Control
class_name Dialog


@export var typing_rate = 0.15


# TEMPORARY
var text = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890
	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"

var speaker : Node3D
var split_text = []
var queue_typing = false
var is_typing = false
var can_continue = false
var pause_array = []
var visible_chars = 0
var skipping = false
var page_index = 0
var closing = false

signal finished

@onready var textbox = $Panel as Panel
@onready var textlabel = $Panel/RichTextLabel as RichTextLabel
@onready var arrow = $Panel/ArrowPivot/ArrowIcon as TextureRect
@onready var arrow_anim = $Panel/ArrowPivot/ArrowIcon/AnimationPlayer as AnimationPlayer


func _ready():
	
	#text = "ABCDEFG_HIJKLMNOP_QRSTUV_WX_Y_Z[color=#ffff00][wavy amp=2.0 freq=10.0 rate=10.0]abcdefg__hijklmnop__qrstuv__wxyz[/wavy][/color]!!!__Lorem ipsum,_ the quick brown fox jumps over the lazy dog."
	
	textbox.size.y = 0
	textbox.position.y = 0
	
	text_to_pages(text)
	init_text(split_text[page_index])
	
	is_typing = false
	queue_typing = true
	
	Input.action_release("interact")


func _process(delta):
	
	var border_width = (textbox.size.y - textlabel.size.y)
	var text_height = textlabel.get_line_count() * 12
	if closing:
		border_width = 0.0
		text_height = 0.0
	
	textbox.size.y = move_toward(textbox.size.y, text_height + border_width + 2, 2)
	textbox.position.y = move_toward(textbox.position.y, -text_height - border_width - 2, 2)
	
	if textbox.size.y == text_height + border_width + 2:
		if closing:
			queue_free()
		elif queue_typing:
			is_typing = true
	
	var speaker_unprojected = get_viewport().get_camera_3d().unproject_position(speaker.global_position)
	position = speaker_unprojected
	position.y -= 30
	
	var res = get_viewport_rect().size
	var marg = 8
	var final_marg = Vector2(marg + textbox.size.x/2, marg + textbox.size.y)
	position = position.clamp(final_marg, Vector2(res.x, res.y) - Vector2(final_marg.x, marg))
	
	var tail_target = Vector2(speaker_unprojected.x - position.x - $Tail.size.x / 2,
		speaker_unprojected.y - position.y - $Tail.size.y / 2 - 16).round()
	$Tail.position.x = tail_target.x
	$Tail.position.y = tail_target.y
	$Tail.position = $Tail.position.clamp($Panel.position, $Panel.position + $Panel.size - Vector2($Tail.size.x,7))
	if $Tail.position.x != tail_target.x:
		$Tail.visible = false
	else:
		$Tail.visible = true
	
	
	if is_typing:
		queue_typing = false
		can_continue = false
		
		# Turn on skipping
		if Input.is_action_just_pressed("interact"):
			skipping = true
			print("skipped")
		
		if skipping:
			visible_chars += 4
		else:
			if !pause_array.has(int(visible_chars)):
				visible_chars += typing_rate
			else:
				var pause_amount = 6
				visible_chars += typing_rate / (pause_amount * pause_array.count(int(visible_chars)))
			
		if visible_chars >= textlabel.get_total_character_count():
			visible_chars = textlabel.get_total_character_count()
			is_typing = false
			skipping = false
			can_continue = true
		
	
	if can_continue:
		arrow.visible = true
		arrow_anim.play("Move")
		if Input.is_action_just_pressed("interact"):
			arrow.visible = false
			arrow_anim.stop()
			can_continue = false
			visible_chars = 0
			
			#anim.play("Close")
			page_index += 1
			if page_index < split_text.size():
				init_text(split_text[page_index])
				queue_typing = true
			else:
				closing = true
				emit_signal("finished")
				
	else:
		arrow.visible = false
		arrow_anim.stop()
	
	textlabel.visible_characters = int(visible_chars)


func text_to_pages(t):
	text = text.replace("\t", "")
	split_text = text.split("\n")
	#for i in split_text:
		#i = i.replace("\t", "")
		#print(i)
	print(split_text)


# Initializes strings before they can be displayed in the textbox
func init_text(t):
	
	# Clear the pause array
	pause_array.clear()
	
	# Declare the pause character
	var pause_char = "_"
	
	# Set the raw text to the label
	textlabel.text = t
	
	# Loop through the parsed text with BBCode mark-up removed
	for i in textlabel.get_parsed_text().length():
		
		# If the current char is a pause, store its index in the pause array
		var c = textlabel.get_parsed_text()[i]
		if c == pause_char:
			pause_array.append(i - pause_array.size())
	
	# Remove all pause characters from the label
	textlabel.text = t.replace(pause_char, "")
	
	# Reset visible characters
	visible_chars = 0
	textlabel.visible_characters = 0

