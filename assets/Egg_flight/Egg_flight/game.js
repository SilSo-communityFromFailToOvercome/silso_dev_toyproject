var canDie = true
var world, game
var newTime = new Date().getTime()
var oldTime = new Date().getTime()

let scene, camera, renderer

//SCREEN & MOUSE VARIABLES
var MAX_WORLD_X=1000

// LIGHTS
var ambientLight

// 3D Models
let sea, sea2
let airplane
//UI
let ui

function createAirplaneMesh() {
	const mesh = new THREE.Object3D()

	// Cabin
	var matCabin = new THREE.MeshPhongMaterial({color: Colors.red, flatShading: true, side: THREE.DoubleSide})

	const frontUR = [ 40,  25, -25]
	const frontUL = [ 40,  25,  25]
	const frontLR = [ 40, -25, -25]
	const frontLL = [ 40, -25,  25]
	const backUR  = [-40,  15,  -5]
	const backUL  = [-40,  15,   5]
	const backLR  = [-40,   5,  -5]
	const backLL  = [-40,   5,   5]

	const vertices = new Float32Array(
		utils.makeTetrahedron(frontUL, frontUR, frontLL, frontLR).concat(   // front
		utils.makeTetrahedron(backUL, backUR, backLL, backLR)).concat(      // back
		utils.makeTetrahedron(backUR, backLR, frontUR, frontLR)).concat(    // side
		utils.makeTetrahedron(backUL, backLL, frontUL, frontLL)).concat(    // side
		utils.makeTetrahedron(frontUL, backUL, frontUR, backUR)).concat(    // top
		utils.makeTetrahedron(frontLL, backLL, frontLR, backLR))            // bottom
	)
	const geomCabin = new THREE.BufferGeometry()
	geomCabin.setAttribute('position', new THREE.BufferAttribute(vertices, 3))

	var cabin = new THREE.Mesh(geomCabin, matCabin)
	cabin.castShadow = true
	cabin.receiveShadow = true
	mesh.add(cabin)

	// Engine

	var geomEngine = new THREE.BoxGeometry(20,20,20,1,1,1);
	var matEngine = new THREE.MeshPhongMaterial({color:Colors.brownDark, flatShading:true,});
	var engine = new THREE.Mesh(geomEngine, matEngine);
	engine.position.x = 50;
	engine.castShadow = true;
	engine.receiveShadow = true;
	mesh.add(engine);

	// Tail Plane
	var geomTailPlane = new THREE.BoxGeometry(15,20,5,1,1,1);
	var matTailPlane = new THREE.MeshPhongMaterial({color:Colors.yellow, flatShading:true,});
	var tailPlane = new THREE.Mesh(geomTailPlane, matTailPlane);
	tailPlane.position.set(-40,20,0);
	tailPlane.castShadow = true;
	tailPlane.receiveShadow = true;
	mesh.add(tailPlane);

	// Wings

	var geomSideWing = new THREE.BoxGeometry(30,5,120,1,1,1);
	var matSideWing = new THREE.MeshPhongMaterial({color:Colors.yellow, flatShading:true,});
	var sideWing = new THREE.Mesh(geomSideWing, matSideWing);
	sideWing.position.set(0,15,0);
	sideWing.castShadow = true;
	sideWing.receiveShadow = true;
	mesh.add(sideWing);

	var geomWindshield = new THREE.BoxGeometry(3,15,20,1,1,1);
	var matWindshield = new THREE.MeshPhongMaterial({color:Colors.white,transparent:true, opacity:.3, flatShading:true,});;
	var windshield = new THREE.Mesh(geomWindshield, matWindshield);
	windshield.position.set(20,27,0);

	windshield.castShadow = true;
	windshield.receiveShadow = true;

	mesh.add(windshield);

	var geomPropeller = new THREE.BoxGeometry(20, 10, 10, 1, 1, 1);
	geomPropeller.attributes.position.array[4*3+1] -= 5
	geomPropeller.attributes.position.array[4*3+2] += 5
	geomPropeller.attributes.position.array[5*3+1] -= 5
	geomPropeller.attributes.position.array[5*3+2] -= 5
	geomPropeller.attributes.position.array[6*3+1] += 5
	geomPropeller.attributes.position.array[6*3+2] += 5
	geomPropeller.attributes.position.array[7*3+1] += 5
	geomPropeller.attributes.position.array[7*3+2] -= 5
	var matPropeller = new THREE.MeshPhongMaterial({color:Colors.brown, flatShading:true,});
	const propeller = new THREE.Mesh(geomPropeller, matPropeller);

	propeller.castShadow = true;
	propeller.receiveShadow = true;

	var geomBlade = new THREE.BoxGeometry(1,80,10,1,1,1);
	var matBlade = new THREE.MeshPhongMaterial({color:Colors.brownDark, flatShading:true,});
	var blade1 = new THREE.Mesh(geomBlade, matBlade);
	blade1.position.set(8,0,0);

	blade1.castShadow = true;
	blade1.receiveShadow = true;

	var blade2 = blade1.clone();
	blade2.rotation.x = Math.PI/2;

	blade2.castShadow = true;
	blade2.receiveShadow = true;

	propeller.add(blade1);
	propeller.add(blade2);
	propeller.position.set(60,0,0);
	mesh.add(propeller);

	var wheelProtecGeom = new THREE.BoxGeometry(30,15,10,1,1,1);
	var wheelProtecMat = new THREE.MeshPhongMaterial({color:Colors.red, flatShading:true,});
	var wheelProtecR = new THREE.Mesh(wheelProtecGeom,wheelProtecMat);
	wheelProtecR.position.set(25,-20,25);
	mesh.add(wheelProtecR);

	var wheelTireGeom = new THREE.BoxGeometry(24,24,4);
	var wheelTireMat = new THREE.MeshPhongMaterial({color:Colors.brownDark, flatShading:true,});
	var wheelTireR = new THREE.Mesh(wheelTireGeom,wheelTireMat);
	wheelTireR.position.set(25,-28,25);

	var wheelAxisGeom = new THREE.BoxGeometry(10,10,6);
	var wheelAxisMat = new THREE.MeshPhongMaterial({color:Colors.brown, flatShading:true,});
	var wheelAxis = new THREE.Mesh(wheelAxisGeom,wheelAxisMat);
	wheelTireR.add(wheelAxis);

	mesh.add(wheelTireR);

	var wheelProtecL = wheelProtecR.clone();
	wheelProtecL.position.z = -wheelProtecR.position.z ;
	mesh.add(wheelProtecL);

	var wheelTireL = wheelTireR.clone();
	wheelTireL.position.z = -wheelTireR.position.z;
	mesh.add(wheelTireL);

	var wheelTireB = wheelTireR.clone();
	wheelTireB.scale.set(.5,.5,.5);
	wheelTireB.position.set(-35,-5,0);
	mesh.add(wheelTireB);

	var suspensionGeom = new THREE.BoxGeometry(4,20,4);
	suspensionGeom.applyMatrix4(new THREE.Matrix4().makeTranslation(0,10,0))
	var suspensionMat = new THREE.MeshPhongMaterial({color:Colors.red, flatShading:true,});
	var suspension = new THREE.Mesh(suspensionGeom,suspensionMat);
	suspension.position.set(-35,-5,0);
	suspension.rotation.z = -.3;
	mesh.add(suspension)

	mesh.castShadow = true
	mesh.receiveShadow = true

	return [mesh, propeller]
}

const utils = {
	normalize: function (v, vmin, vmax, tmin, tmax) {
		var nv = Math.max(Math.min(v,vmax), vmin)
		var dv = vmax-vmin
		var pc = (nv-vmin)/dv
		var dt = tmax-tmin
		var tv = tmin + (pc*dt)
		return tv
	},

	collide: function (mesh1, mesh2, tolerance) {
		const diffPos = mesh1.position.clone().sub(mesh2.position.clone())
		const d = diffPos.length()
		return d < tolerance
	},

	makeTetrahedron: function (a, b, c, d) {
		return [
			a[0], a[1], a[2],
			b[0], b[1], b[2],
			c[0], c[1], c[2],
			b[0], b[1], b[2],
			c[0], c[1], c[2],
			d[0], d[1], d[2],
		]
	}
}

class SceneManager {
	constructor() {
		this.list = new Set()
	}

	add(obj) {
		scene.add(obj.mesh)
		this.list.add(obj)
	}

	remove(obj) {
		scene.remove(obj.mesh)
		this.list.delete(obj)
	}

	clear() {
		for (const entry of this.list) {
			this.remove(entry)
		}
	}

	tick(deltaTime) {
		for (const entry of this.list) {
			if (entry.tick) {
				entry.tick(deltaTime)
			}
		}
	}
}

const sceneManager = new SceneManager()

class LoadingProgressManager {
	constructor() {
		this.promises = []
	}

	add(promise) {
		this.promises.push(promise)
	}

	then(callback) {
		return Promise.all(this.promises).then(callback)
	}

	catch(callback) {
		return Promise.all(this.promises).catch(callback)
	}
}

const loadingProgressManager = new LoadingProgressManager()

class ModelManager {
	constructor(path) {
		this.path = path
		this.models = {}
	}

	load(modelName) {
		const promise = new Promise((resolve, reject) => {
			const loader = new THREE.OBJLoader()
			loader.load(this.path+'/'+modelName+'.obj', (obj) => {
				this.models[modelName] = obj
				resolve()
			}, function() {}, reject)
		})
		loadingProgressManager.add(promise)
	}

	get(modelName) {
		if (typeof this.models[modelName] === 'undefined') {
			throw new Error("Can't find model "+modelName)
		}
		return this.models[modelName]
	}
}

const modelManager = new ModelManager('/models')

var Colors = {
	red: 0xf25346,
	orange: 0xffa500,
	white: 0xd8d0d1,
	brown: 0x59332e,
	brownDark: 0x23190f,
	pink: 0xF5986E,
	yellow: 0xf4ce93,
	blue: 0x68c3c0,
}

//INIT THREE JS, SCREEN AND MOUSE EVENTS
function createScene() {
	scene = new THREE.Scene()
	camera = new THREE.PerspectiveCamera(50, ui.width/ui.height, 0.1, 10000)
	scene.fog = new THREE.Fog(0xf7d9aa, 100, 950)

	renderer = new THREE.WebGLRenderer({canvas: ui.canvas, alpha: true, antialias: true})
	renderer.setSize(ui.width, ui.height)
	renderer.setPixelRatio(window.devicePixelRatio? window.devicePixelRatio : 1)

	renderer.shadowMap.enabled = true


	function setupCamera() {
		renderer.setSize(ui.width, ui.height)
		camera.aspect = ui.width / ui.height
		camera.updateProjectionMatrix()
	}

	setupCamera()
	ui.onResize(setupCamera)
}

function createLights() {
	const hemisphereLight = new THREE.HemisphereLight(0xaaaaaa,0x000000, .9)
	ambientLight = new THREE.AmbientLight(0xdc8874, .5)
	const shadowLight = new THREE.DirectionalLight(0xffffff, .9)
	shadowLight.position.set(150, 350, 350)
	shadowLight.castShadow = true
	shadowLight.shadow.camera.left = -400
	shadowLight.shadow.camera.right = 400
	shadowLight.shadow.camera.top = 400
	shadowLight.shadow.camera.bottom = -400
	shadowLight.shadow.camera.near = 1
	shadowLight.shadow.camera.far = 1000
	shadowLight.shadow.mapSize.width = 4096
	shadowLight.shadow.mapSize.height = 4096

	scene.add(hemisphereLight)
	scene.add(shadowLight)
	scene.add(ambientLight)
}

class Airplane {
	constructor() {
		const [mesh, propeller] = createAirplaneMesh()
		this.mesh = mesh
		this.propeller = propeller
		this.lastShot = 0
	}

	tick(deltaTime) {
		this.propeller.rotation.x += 0.2 + game.planeSpeed * deltaTime*.005

		if (game.status === 'playing') {
			game.planeSpeed = utils.normalize(ui.mousePos.x, -0.5, 0.5, world.planeMinSpeed, world.planeMaxSpeed)
			let targetX = utils.normalize(ui.mousePos.x, -1, 1, -100, 100)
			let targetY = utils.normalize(ui.mousePos.y, -1, 1, world.planeDefaultHeight-world.planeAmpHeight -2, world.planeDefaultHeight+world.planeAmpHeight)

			game.planeCollisionDisplacementX += game.planeCollisionSpeedX
			targetX += game.planeCollisionDisplacementX

			game.planeCollisionDisplacementY += game.planeCollisionSpeedY
			targetY += game.planeCollisionDisplacementY

			this.mesh.position.z += (targetX - this.mesh.position.z) * deltaTime * world.planeMoveSensivity
			this.mesh.position.y += (targetY - this.mesh.position.y) * deltaTime * world.planeMoveSensivity

			this.mesh.rotation.z = (targetY - this.mesh.position.y) * deltaTime * world.planeRotZSensivity

			camera.fov = utils.normalize(ui.mousePos.x, -30, 1, 40, 80)
			camera.updateProjectionMatrix()
			camera.position.y = this.mesh.position.y + 30
			camera.position.z += (this.mesh.position.z - camera.position.z) * deltaTime * world.cameraSensivity
		}

		game.planeCollisionSpeedX += (0-game.planeCollisionSpeedX)*deltaTime * 0.03;
		game.planeCollisionDisplacementX += (0-game.planeCollisionDisplacementX)*deltaTime *0.01;
		game.planeCollisionSpeedY += (0-game.planeCollisionSpeedY)*deltaTime * 0.03;
		game.planeCollisionDisplacementY += (0-game.planeCollisionDisplacementY)*deltaTime *0.01;
	}


	gethit(position) {
		const diffPos = this.mesh.position.clone().sub(position)
		const d = diffPos.length()
		game.planeCollisionSpeedX = 10 * diffPos.x / d
		game.planeCollisionSpeedY = 10 * diffPos.y / d
		ambientLight.intensity = 2
	}
}

function rotateAroundSea(object, deltaTime, speed) {
	object.angle += deltaTime * game.speed * world.enemiesSpeed
	if (object.angle > Math.PI*2) {
		object.angle -= Math.PI*2
	}
	object.mesh.position.x = Math.cos(object.angle) * object.distance
	object.mesh.position.y = -world.seaRadius + Math.sin(object.angle) * object.distance
}

class Sea {
	constructor() {
		var geom = new THREE.CylinderGeometry(world.seaRadius, world.seaRadius, world.seaLength, 40, 10)
		geom.applyMatrix4(new THREE.Matrix4().makeRotationX(-Math.PI/2))
		this.waves = [];
		const arr = geom.attributes.position.array
		for (let i=0; i<arr.length/3; i++) {
			this.waves.push({
				x: arr[i*3+0],
				y: arr[i*3+1],
				z: arr[i*3+2],
				ang: Math.random()*Math.PI*2,
				amp: world.wavesMinAmp + Math.random()*(world.wavesMaxAmp-world.wavesMinAmp),
				speed: world.wavesMinSpeed + Math.random()*(world.wavesMaxSpeed - world.wavesMinSpeed)
			})
		}
		var mat = new THREE.MeshPhongMaterial({
			color: Colors.brown,
			transparent: true,
			opacity: 0.8,
			flatShading: true,
		})
		this.mesh = new THREE.Mesh(geom, mat)
		this.mesh.receiveShadow = true
	}

	tick(deltaTime) {
		var arr = this.mesh.geometry.attributes.position.array
		for (let i=0; i<arr.length/3; i++) {
			var wave = this.waves[i]
			arr[i*3+0] = wave.x + Math.cos(wave.ang) * wave.amp
			arr[i*3+1] = wave.y + Math.sin(wave.ang) * wave.amp
			wave.ang += wave.speed * deltaTime
		}
		this.mesh.geometry.attributes.position.needsUpdate = true
	}
}

class Enemy {
	constructor() {
		var geom = new THREE.TetrahedronGeometry(8, 2)
		var mat = new THREE.MeshPhongMaterial({
			color: Math.random() * 0xffffff,
			shininess: 3,
			specular: 0xffffff,
			flatShading: true,
		})
		this.mesh = new THREE.Mesh(geom, mat)
		this.mesh.castShadow = true
		this.angle = 0
		this.distance = 0
		sceneManager.add(this)
	}


	tick(deltaTime) {
		rotateAroundSea(this, deltaTime, world.enemiesSpeed)
		this.mesh.rotation.y += Math.random() * 0.1
		this.mesh.rotation.z += Math.random() * 0.1

		// collision?
		if (utils.collide(airplane.mesh, this.mesh, world.enemyDistanceTolerance) && game.status!=='finished') {
			this.explode()
			airplane.gethit(this.mesh.position)
			game.status = "gameover"
		}
		// passed-by?
		else if (this.angle > Math.PI) {
			sceneManager.remove(this)
		}
	}


	explode() {
		sceneManager.remove(this)
		game.statistics.enemiesKilled += 1
	}
}

function spawnEnemies(count) {
	for (let i=0; i<count; i++) {
		const enemy = new Enemy()
		enemy.angle = - (i*0.1)
		enemy.distance = world.seaRadius + world.planeDefaultHeight + (-1 + Math.random() * 2) * (world.planeAmpHeight-20)
		enemy.mesh.position.x = Math.cos(enemy.angle) * enemy.distance*0.2
		enemy.mesh.position.y = -world.seaRadius + Math.sin(enemy.angle)*enemy.distance
		enemy.mesh.position.z = (Math.random() - 0.5) * 300;
		enemy.mesh.scale.set(5, 5, 5);
	}
	game.statistics.enemiesSpawned += count
}

function createPlane() {
	airplane = new Airplane()
	airplane.mesh.scale.set(.25,.25,.25)
	airplane.mesh.position.y = world.planeDefaultHeight
	scene.add(airplane.mesh)
}

function createSea() {
	// We create a second sea that is not animated because the animation of our our normal sea leaves holes at certain points and I don't know how to get rid of them. These holes did not occur in the original script that used three js version 75 and mergeVertices. However, I tried to reproduce that behaviour in the animation function but without succes - thus this workaround here.
	sea = new Sea()
	sea.mesh.position.y = -world.seaRadius
	scene.add(sea.mesh)
}	

function loop() {
	newTime = new Date().getTime()
	const deltaTime = newTime - oldTime
	oldTime = newTime

	if (game.status == 'playing') {
		if (!game.paused) {
			if (Math.floor(game.distance)%world.distanceForSpeedUpdate == 0 && Math.floor(game.distance) > game.speedLastUpdate) {
				game.speedLastUpdate = Math.floor(game.distance);
				game.targetBaseSpeed += world.incrementSpeedByTime * deltaTime;
			}
			if (Math.floor(game.distance)%world.distanceForEnemiesSpawn == 0 && Math.floor(game.distance) > game.enemyLastSpawn) {
				game.enemyLastSpawn = Math.floor(game.distance)
				spawnEnemies(5)
			}

			airplane.tick(deltaTime)
			game.distance += game.speed * deltaTime * world.ratioSpeedDistance
			game.baseSpeed += (game.targetBaseSpeed - game.baseSpeed) * deltaTime * 0.02
			game.speed = game.baseSpeed * game.planeSpeed
			ui.updateDistanceDisplay()

			if (game.lifes<=0 && canDie) {
				game.status = "gameover"
			}
			if (airplane.mesh.position.y < 0) {
				game.status = "gameover"
			}
		}
	}
	else if (game.status == "gameover") {
		game.speed *= .99
		airplane.mesh.rotation.z += (-Math.PI/2 - airplane.mesh.rotation.z) * 0.0002 * deltaTime
		airplane.mesh.rotation.x += 0.0003 * deltaTime
		game.planeFallSpeed *= 1.05
		airplane.mesh.position.y -= game.planeFallSpeed * deltaTime

		if (airplane.mesh.position.y < -200) {
			ui.showReplay()
			game.status = "waitingReplay"
		}
	}
	else if (game.status == "waitingReplay"){
		// nothing to do
	}

	if (!game.paused) {
		airplane.tick(deltaTime)

		sea.mesh.rotation.z += game.speed*deltaTime
		if (sea.mesh.rotation.z > 2*Math.PI) {
			sea.mesh.rotation.z -= 2*Math.PI
		}
		ambientLight.intensity += (.5 - ambientLight.intensity) * deltaTime * 0.005

		sceneManager.tick(deltaTime)
		sea.tick(deltaTime)
	}

	renderer.render(scene, camera)
	requestAnimationFrame(loop)
}


function setFollowView() {
	game.fpv = true
	camera.position.set(-70, airplane.mesh.position.y+70, airplane.mesh.position.z)
	camera.setRotationFromEuler(new THREE.Euler(-1.490248, -1.4124514, -1.48923231))
	camera.updateProjectionMatrix ()
}

class UI {
	constructor(onStart) {
		this._elemDistanceCounter = document.getElementById("distValue")
		this._elemReplayMessage = document.getElementById("replayMessage")

		document.querySelector('#intro-screen button').onclick = () => {
			document.getElementById('intro-screen').classList.remove('visible')
			onStart()
		}

		document.addEventListener('mousemove', this.handleMouseMove.bind(this), false)

		document.oncontextmenu = document.body.oncontextmenu = function() {return false;}

		window.addEventListener('resize', this.handleWindowResize.bind(this), false)

		this.width = window.innerWidth
		this.height = window.innerHeight
		this.mousePos = {x: 0, y: 0}
		this.canvas = document.getElementById('threejs-canvas')

		this.mouseButtons = [false, false, false]
		this.keysDown = {}

		this._resizeListeners = []
	}


	onResize(callback) {
		this._resizeListeners.push(callback)
	}


	handleWindowResize(event) {
		this.width = window.innerWidth
		this.height = window.innerHeight

		for (const listener of this._resizeListeners) {
			listener()
		}
	}


	handleMouseMove(event) {
		var tx = -1 + (event.clientX / this.width)*2
		var ty = 1 - (event.clientY / this.height)*2
		this.mousePos = {x:tx, y:ty}
		//setFollowView()
	}

	handleTouchMove(event) {
		event.preventDefault()
		var tx = -1 + (event.touches[0].pageX / this.width)*2
		var ty = 1 - (event.touches[0].pageY / this.height)*2
		this.mousePos = {x: tx, y: ty}
	}

	// handleMouseDown(event) {
	// 	this.mouseButtons[event.button] = true

	// 	if (event.button===1 && game.status==='playing') {
	// 		airplane.shoot()
	// 	}
	// }

	handleMouseUp(event) {
		this.mouseButtons[event.button] = false
		event.preventDefault()

		if (game && game.status == "waitingReplay") {
			resetMap()
			game.paused = false

			ui.hideReplay()
		}
	}

	// handleKeyDown(event) {
	// 	this.keysDown[event.code] = true
	// 	if (event.code === 'KeyP') {
	// 		game.paused = !game.paused
	// 	}
	// 	// if (event.code === 'Enter') {
	// 	// 	if (game.fpv) {
	// 	// 		setSideView()
	// 	// 	} else {
	// 	// 		setFollowView()
	// 	// 	}
	// 	// }
	// }

	showReplay() {
		this._elemReplayMessage.style.display = 'block'
	}

	hideReplay() {
		this._elemReplayMessage.style.display = 'none'
	}

	updateDistanceDisplay() {
		this._elemDistanceCounter.innerText = Math.floor(game.distance)
	}
}


function createWorld() {
	world = {
		initSpeed: 0.00035,
		incrementSpeedByTime: 0.0000025,
		distanceForSpeedUpdate: 100,
		ratioSpeedDistance: 50,

		maxLifes: 1,
		pauseLifeSpawn: 400,

		planeDefaultHeight: 100,
		planeAmpHeight: 150,
		planeAmpWidth: 75,
		planeMoveSensivity: 0.002,
		planeRotXSensivity: 0.008,
		planeRotZSensivity: 0.002,
		planeMinSpeed: 1.2,
		planeMaxSpeed: 1.6,

		seaRadius: 600,
		seaLength: 800,
		wavesMinAmp: 5,
		wavesMaxAmp: 20,
		wavesMinSpeed: 0.001,
		wavesMaxSpeed: 0.003,

		cameraSensivity: 0.002,

		enemyDistanceTolerance: 40,
		enemiesSpeed: 0.6,
		distanceForEnemiesSpawn: 50,
	}

	// create the world
	createScene()
	createSea()
	createLights()
	createPlane()
	resetMap()
}

function resetMap() {
	game = {
		status: 'playing',

		speed: 0,
		paused: false,
		baseSpeed: 0.00035,
		targetBaseSpeed: 0.00035,
		speedLastUpdate: 0,

		distance: 0,

		fpv: false,

		lastLifeSpawn: 0,
		lifes: world.maxLifes,

		planeFallSpeed: 0.001,
		planeSpeed: 0,
		planeCollisionDisplacementX: 0,
		planeCollisionSpeedX: 0,
		planeCollisionDisplacementY: 0,
		planeCollisionSpeedY: 0,

		enemyLastSpawn: 0,

		statistics: {
			enemiesKilled: 0,
			enemiesSpawned: 0,
			shotsFired: 0,
			lifesLost: 0,
		}
	}

	// update ui
	ui.updateDistanceDisplay()
	sceneManager.clear()
	setFollowView()
}

function startMap() {
	createWorld()
	loop()
	game.paused = false
}

function onWebsiteLoaded(event) {
	ui = new UI(startMap)
}

window.addEventListener('load', onWebsiteLoaded, false)
