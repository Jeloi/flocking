/**
Final Project

Flock Flow Fields

Autonomous Agents 

Jeremy Ho
1/27/2014
**/




Flock flock;



void setup() {
	size(800, 800, P3D);
	noLoop();
	background(0);
	flock = new Flock(10);
}

void draw() {
	// translate(width/2, height/2, 0);	
	// rotateY(20);
	// rectMode(CENTER);

	// rect(0, 0, 100, 100);
	flock.setGlobalAvg();
	flock.iterate();
}




class Flock  {

	ArrayList<Boid> flock;
	int numBoids;

	PVector globalAvg = new PVector();

	float neighborDistance;	// Maximum distance from another particle for it to be a "neighbor"
	boolean allNeighbors = false;

	HashMap<Boid, ArrayList<Boid>> neighborsHash = new HashMap<Boid, ArrayList<Boid>>();



	// PVector separation;
	// PVector alignment;
	// PVector cohesion;



	Flock(int n) {
		flock = new ArrayList<Boid>();
		// neighborsHash = new HashMap<Boid, ArrayList<Boid>>();
		numBoids = n;
		// Add initial n number of boids to the flock, initialize the neighborsHash
		for (int i = 0; i < numBoids; ++i) {
			// ArrayList<Boid> neighbors = new ArrayList<Boid>();
			Boid b = new Boid();
			addBoid(b);
			// neighborsHash.put(b, neighbors);
			
		}
	}

	void iterate() {
		setGlobalAvg();
		for (Boid b : flock) {
			b.run(flock, globalAvg);
		}
		println("globalAvg: "+globalAvg);
	}

	void setGlobalAvg() {
		PVector sum = new PVector(0,0,0);
		for (Boid b : flock) {
			sum.add(b.position);
		}
		// globalAvg = sum;
		sum.div(numBoids);
		globalAvg = sum;
	}

	// Add a boid to the flock
	void addBoid(Boid b) {
		flock.add(b);
	}

}