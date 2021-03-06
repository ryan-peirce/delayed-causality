
class @World
	constructor: ->
		@objects = []
		@gravity = 0.4
		@player_1_controller = new KeyboardController(false)
		@player_2_controller = new CoupledController(
			new KeyboardController(true)
			new GamepadController()
		)
		# TODO: remove this, and use localStorage for settings
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ({bg})->
		window.debug_mode = location.hash.match /debug/
		
		include_ai = location.hash.match /ai|npc/
		
		@objects = []
		@players = []
		
		@objects.push(ground = new Ground({y: 0, h: 1000}))
		# @objects.push(ceiling = new Ground({y: -1000, h: 50}))
		block = (cx, cy, w, h)=>
			@objects.push(new Ground({x: cx - w/2, y: cy - h/2, w, h}))
			@objects.push(new Ground({x: -cx - w/2, y: cy - h/2, w, h})) unless cx is 0
		block(0, -100, 50, 100)
		block(200, -250, 50, 150)
		block(400, -250, 250, 50)
		block(500, -250, 50, 150)
		block(800, -125, 50, 150)
		level_width = 2400
		level_height = 1000
		block(level_width/2, -500, 50, level_height) # walls
		block(0, -level_height, level_width+50, 50) # ceiling
		
		unless bg
			player_1 = new Player({x: -150, y: ground.y, face: +1, name: "Player 1", color: "#DD4B39", controller: @player_1_controller})
			player_2 = new Player({x: +150, y: ground.y, face: -1, name: "Player 2", color: "#3C81F8", controller: @player_2_controller})
			@objects.push(player_1); @players.push(player_1)
			@objects.push(player_2); @players.push(player_2)
			
			if include_ai
				ai_player = new Player({x: 0, y: ground.y-250, face: -1, name: "Dumb AI", color: "#FED14C", controller: ai_controller = new AIController})
				@objects.push(ai_player); @players.push(ai_player)
				ai_controller.player = ai_player
				ai_controller.world = world
	
	collision_point: (x, y, {type, filter}={})->
		for object in world.objects
			if type? and object not instanceof type
				continue # as in don't continue with this one
			if filter? and not filter(object)
				continue # as in don't continue with this one
			if (
				x < object.x + object.w and
				y < object.y + object.h and
				x > object.x and
				y > object.y
			)
				return object
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
		for object in @objects
			object.draw_fx?(ctx, view)
