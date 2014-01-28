class Boid  {

	PVector position;
	PVector velocity;
	PVector steeringForce;

	float maxSpeed = 10;
	float maxForce = 0.05;

	Boid (PVector initial) {
		position = initial;
		steeringForce = new PVector(0,0,0);
	}

	// Updates the boid's position by updating it's velocity (based on steeringForce)
	// and adding it to the position
	void update(ArrayList<Boid> neighbors) {
		calculateSteeringForce(neighbors);
		// Update the velocity based on steering force
		velocity.add(steeringForce);
		velocity.limit(maxSpeed);	// limit it to the maxSpeed
		// Update boid's position
		position.add(velocity);
	}

	// Reset and calculate the boid's steering force based on the flocking behavior functions
	void calculateSteeringForce(ArrayList<Boid> neighbors) {
		steeringForce.mult(0); // Reset steering force to 0 before each update

		// Calculate the three forces that govern flock behavior
		PVector sep = separate(neighbors);
		PVector ali = align(neighbors);
		PVector coh = cohesion(neighbors);

		// Weight these according to the global weights
		sep.mult(sepWeight);
		ali.mult(aliWeight);
		coh.mult(cohWeight);

		// Add each of the force vectors to the steering force
		steeringForce.add(separation);
		steeringForce.add(alignment);
		steeringForce.add(cohesion);
	}

	// Returns a PVector indicating a force that steers the boid toward a target destination
	// steering force = desired velocity - current velocity
	PVector seek(PVector destination) {

	}

	PVector separate(ArrayList<Boid> neighbors) {

	}

	PVector align(ArrayList<Boid> neighbors) {

	}

	PVector cohesion(ArrayList<Boid> neighbors) {

	}

	void paint(){

	}

}