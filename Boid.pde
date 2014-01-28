class Boid  {

	PVector position;
	PVector velocity = new PVector(0,0,0);
	PVector steeringForce = new PVector(0,0,0);

	PVector sep; // separation
	PVector ali; // alignment
	PVector coh; // cohesion
	PVector noi; // noise

	float sepWeight = 10;
	float aliWeight = .1;
	float cohWeight = .1;
	float noiWeight = 1;

	float maxSpeed = 10;
	float maxForce = 0.05;

	float neighborhood = 700;


	// ArrayList<Boid> neighbors;

	Boid() {
		position = new PVector(width/2 + random(0, 10);, height/2, 0);
	}

	Boid (PVector initial) {
		position = initial;
	}

	void run(ArrayList<Boid> neighbors, PVector global_avg) {
		// applyForces();
		applyNoise();
		applyCohesion(global_avg);
		calculateSteeringForce(neighbors);
		update();
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

		steeringForce.mult(0); // Reset steering force to 0 after each update
	}

	void applyForces() {
		// Calculate the three forces that govern flock behavior
		// separate(neighbors);
		// align(neighbors);
		// cohesion();
	}

	// Calculate boid's steering force by adding the weighted vectors on the flocking behavior functions (rules)
	void calculateSteeringForce(ArrayList<Boid> neighbors) {

		// Weight these according to the global weights
		// sep.mult(sepWeight);
		// ali.mult(aliWeight);

		// Add each of the force vectors to the steering force
		// steeringForce.add(sep);
		// steeringForce.add(ali);
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

	void applySeparation(ArrayList<Boid> neighbors) {
		// return null;
	}

	// Alignment
	void applyAlignment(ArrayList<Boid> neighbors) {
		// return null;

	}

	// Cohesion/Centering Force
	// 
	void applyCohesion(PVector avg) {
		coh = seek(avg);
		float distanceToCenter = coh.mag();
		// coh.normalize();

		coh.mult(cohWeight);	// scale by the defined weight
		steeringForce.add(coh);	// add to steering force
	}

	// Instead of calculating the average velocity of the neighbors, use Perlin noise based on particle location to calculate alignment force
	void applyNoise() {
		noi = noise(
        position.x / neighborhood,
        position.y / neighborhood,
        position.z / neighborhood)
        - .5,
      noise(
        position.x / neighborhood,
        position.y / neighborhood,
        position.z / neighborhood)
        - .5,
      noise(
        position.x / neighborhood,
        position.y / neighborhood,
        position.z / neighborhood)
        - .5);

		noi.mult(noiWeight);	// scale by the defined weight
		steeringForce.add(noi);	// add to steering force
	}

	// Set the position of the the Boid
	void setPosition(PVector p) {
		position = p;
	}

	void paint(){
		fill(255);
		point(position.x, position.y, 0);
		println(position);
	}

}