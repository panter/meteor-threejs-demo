
deepSet = (obj, properties) ->
	for key, value of properties
		if _.isObject value
			deepSet obj[key], value
		else
			obj[key] = value

Meteor.isClient and Template.THREE_scene.onRendered ->
	# this object will hold references to all THREE.js-objects
	sceneObjects = {}

	# init renderer and scene
	renderer = new THREE.WebGLRenderer antialias: true
	
	renderer.setPixelRatio window.devicePixelRatio 
	renderer.setSize @$(".container").width(), @$(".container").height()
	@$(".container").append renderer.domElement
	scene = new THREE.Scene()
	
	# init camera
	camera = new THREE.PerspectiveCamera 75, 
		(@$(".container").width() / @$(".container").height()), 
		0.1, 1000
	camera.position.z = 5
	controls = new THREE.OrbitControls camera, renderer.domElement

	# add some lights
	scene.add new THREE.AmbientLight 0x505050
	light = new THREE.SpotLight 0xffffff, 1.5
	light.position.set 0, 500, 2000
	light.castShadow = true
	scene.add light
	
	# start render-loop
	render = =>
		unless @view.isDestroyed
			requestAnimationFrame render
			renderer.render scene, camera
	render()

	# start observe the objects-cursor
	observeHandle = @data.objects?.observeChanges 
		added: (id, fields) ->
			geometry = new THREE.BoxGeometry 1, 1, 1
			material = new THREE.MeshLambertMaterial
			cube = new THREE.Mesh geometry, material
			scene.add cube
			sceneObjects[id] = cube
			deepSet sceneObjects[id], fields
		changed: (id, fields) ->
			deepSet sceneObjects[id], fields
		removed: (id) ->
			thing = sceneObjects[id]
			scene.remove thing
			delete sceneObjects[id]

	# stop the observations, if the view/template is destroyed
	@view.onViewDestroyed ->
		console.log "stop"
		observeHandle?.stop()

		
	
