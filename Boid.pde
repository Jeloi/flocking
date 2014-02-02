class Boid  {

	PVector position;
	PVector velocity = new PVector(0,0,0);
	PVector steeringForce = new PVector(0,0,0); // Force that acts on velocity (i.e acceleration)

	// Forces that contribute to steeringForce
	PVector cent; // centering
	PVector coh; // cohesion
	PVector noi; // noise

	// Origin points were saved in case I wanted to use them again
	float origin_x = random(0, 300);
	float origin_y = random(0, 300);

	Boid() {
		position = new PVector(origin_x, origin_y);
	}

	Boid (PVector initial) {
		position = initial;
	}


	// Main run function. Applies the forces, and updates the boid's position. Paints the boid.
	void run(ArrayList<Boid> neighbors, PVector global_avg) {
		if (!paused) {
			applyNoise();
			applyViscosityForce();
			applyCohesion(neighbors);
			applyCentering(global_avg);
			update();
		}
		paint();
	}

	// Updates the boid's position by updating it's velocity (based on steeringForce)
	// and adding it to the position
	void update() {
		// Update the velocity based on steering force
		velocity.add(steeringForce);
		velocity.limit(maxSpeed);	// limit it to the maxSpeed
		// Update boid's position
		position.add(velocity);
		steeringForce = new PVector(0,0,0); // Reset steering force to 0 after each update
	}


	// Returns a PVector indicating a force that steers the boid toward a target destination
	// steering force = desired velocity - current velocity
	PVector seek(PVector destination) {
		PVector desired = PVector.sub(destination, position);	//desired  = target - position
		// Set the magnitude of the desired velocity to be maxSpeed
		desired.normalize();
		desired.mult(maxSpeed);
		PVector sf = PVector.sub(desired, velocity);
		sf.limit(maxForce);
		return sf; // return the steering force toward the target destination
	}

	/** FORCE BEHAVIOR FUNCTIONS **/

	void applyViscosityForce() {
	  PVector visc = new PVector(0,0,0);
	  visc = velocity.get();
	  visc.mult(-viscocity);
	  steeringForce.add(visc);
	}

	// Cohesion - apply a force that pushes boids toward the average of their neighbors
	void applyCohesion(ArrayList<Boid> neighbors) {
		PVector sum = new PVector(0,0,0);
		int count = 0;
		for (Boid b : neighbors) {
			float dist = PVector.dist(position, b.position);
			if ((dist > 0) && (dist < neighbor_distance)) {
				sum.add(b.position);
				count++;
			}
		}
		if (count > 0) { //has at least one neighbor
			sum.div(count);
			coh = seek(sum);
			coh.mult(cohWeight);
			steeringForce.add(coh);
		}
	}

	// Centering Force - tend to move toward the global (flock) average
	void applyCentering(PVector avg) {
		cent = seek(avg);
		cent.mult(centWeight);	// scale by the defined weight
		steeringForce.add(cent);	// add to steering force
	}

	// Use Perlin noise based on particle location and the offset to apply a force
	void applyNoise() {
		noi = new PVector(
		noise(position.x / noiseScale +noiseOffset.x, position.y / noiseScale, position.z / noiseScale) - .5,
		noise(position.x / noiseScale, position.y / noiseScale + noiseOffset.y, position.z / noiseScale) - .5,
		noise(position.x / noiseScale, position.y / noiseScale, position.z / noiseScale + noiseOffset.z) - .5);
		noi.mult(noiWeight);	// scale by the defined weight
		steeringForce.add(noi);	// add to steering force
	}

	// Set the position of the the Boid
	void setPosition(PVector p) {
		position = p;
	}

	// Draw point with depth of field effect relative to the point's position to the camera plane
	void paint(){
		Vec3D p = new Vec3D(position.x, position.y, position.z);
		float distanceToCamera = cameraPlane.getDistanceToPoint(p);
		// println("distanceToCamera: "+distanceToCamera);
		// println("distanceToCamera/dof: "+distanceToCamera/doF);
		distanceToCamera = distanceToCamera/doF;
		distanceToCamera = constrain(distanceToCamera, 1, 15);
		strokeWeight(distanceToCamera);
		// rgb(110, 213, 247)
		stroke(223, 248,220, constrain(255 / (distanceToCamera * distanceToCamera), 0, 255));
		point(position.x, position.y, position.z);
		// println(position);
	}

}