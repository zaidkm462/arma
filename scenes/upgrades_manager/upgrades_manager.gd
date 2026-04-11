extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.UpgradesManager = self

func get_upgradable_weapons() -> Array[Dictionary]:
	var wlist:Array[Dictionary]=[]
	
	var pur_wepeans:Dictionary[String, SingleWeapon] = GameManager.WeaponsManager.purchased_weapons
	var gm_wepeans:Dictionary[String, Area2D] = GameManager.WeaponsManager.game_weapons
	
	# add weapons.
	for w in pur_wepeans:	
		if w in gm_wepeans: continue
			
		var w_data := pur_wepeans[w]
		wlist.append({
			"type": "weapon",
			"action": "add",
			"id": w_data.id,
			"name": w_data.name,
			"desc": w_data.desc,
			"icon": w_data.icon,
			"level": "new"	
		})
		
	
	# up weapons.
	for w in gm_wepeans:
		var w_inst := gm_wepeans[w]
		var w_data := pur_wepeans[w]
		if w_inst.level == len(w_data.levels): continue		
		wlist.append({
			"type": "weapon",
			"action": "upgrade",
			"id": w_data.id,
			"name": w_data.name,
			"desc": w_data.levels[w_inst.level-1].desc,
			"icon": w_data.icon,
			"level": "level:"+str(w_inst.level+1)			
		})
		
	return wlist

func get_upgradable_items() -> Array[Dictionary]:
	var ilist:Array[Dictionary]=[]
	
	var pur_items:Dictionary[String, PassiveItem] = GameManager.PassivesManager.purchased_items
	var gm_items:Dictionary[String, PassiveItem] = GameManager.PassivesManager.game_items
	
	# add items.
	for i in pur_items:	
		if i in gm_items: continue
			
		var i_data := pur_items[i]
		ilist.append({
			"type": "item",
			"action": "add",
			"id": i_data.id,
			"name": i_data.name,
			"desc": i_data.description,
			"icon": i_data.icon,
			"level": "new"	
		})
		
	
	# up items.
	for i in gm_items:
		var i_inst := gm_items[i]
		
		if i_inst.level == i_inst.max_level: continue		
		ilist.append({
			"type": "item",
			"action": "upgrade",
			"id": i_inst.id,
			"name": i_inst.name,
			"desc": i_inst.description,
			"icon": i_inst.icon,
			"level": "level:"+str(i_inst.level+1)			
		})
		
	return ilist

func get_level_up_cards() -> Array[Dictionary]:
	var w := get_upgradable_weapons()
	var i := get_upgradable_items()
	var all := w + i
	all.shuffle()
	var ran = all.slice(0, 3)
	for j in all: print(j)
	print("---------------")
	for j in ran: print(j['id'])
	return ran
	
