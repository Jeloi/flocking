/**
Generative Art - Final Project

A 3D Particle System with Sinusoidal and Flocking Behavior in a Moving 3D Noise Field

In this project my initial goal was to create a 3D particle system with agents (boids) that exhibited flocking behavior. I started by understanding Craig Reynold's flocking algorithm, in which "boids" follow three rules of flocking: separation, alignment, and cohesion. These were basically just rules for forces that act on each boid's velocity. Once I got a nice 3D particle system up and running, I started to experiment with my own rules for forces.
Because I was really interested in the concept of noise, I had a force be applied to boid's based off their 3D position in a noise field, with an offset that is constantly moving. Because of the nature of noise, nearby points have a similar noise value, so this implemented a type of pseudo-flocking behavior.
The only real flocking rule that I ended up using was cohesion, which basically means each boid looks at its neighbors (neighbor distance being a variable i control), and a force is applied to the boid to tend toward the avg position of the neighbors.
Viscocity was a force that just slows the boid's down by applying a factor of the inverse of velocity.
I also applied a force that I called centering which causes boid's to tend toward the global avg of all boids' positions. As the camera is poitned at this global average, the point the camera points to is always the center of the flock. 
One challenge I had was that I felt the artwork would devolve too quickly into a a messy blur of points heavily concentrated around the center, with the noise movements being less defined and interesting. I attempted to address this problem with the piece not having much "perpetual action" by making the weight of the centering force be a function of a sinusoidal function. After tweaking with the variables a ton, I was able to achieve a nice oscilatting effect that makes the piece much more perpetual.

This was a fun project, and there are a bajillion combinations of variables that can be tweaked to produce cool visual images.

Controls:
Mouse click and drag - rotate
Mouse scroll - zoom
p - pause

Misc: 
This project uses the external libraries PeasyCam and Toxi.geom. I included them in a libraries folder. They need to be put in ~/Documents/Processing/libraries.

Jeremy Ho
1/27/2014
**/

import peasy.*;
import toxi.geom.*;
import java.util.*;

boolean paused = false;

Flock flock;
int n = 10000; // number of boids

float cohWeight = 0.5; // weight of cohesion force

float centWeight; // weight of the centering force
float center_cosine = 0;	// this is basically theta on the cosine curve
float sinusoid_step = PI/35;	// how big of a step to take on the cosine curve each time (i.e how fast to oscillate)
float pauseCent = 15;	//how long to pause the sinusoidal action
int pauseCentCounter; // assisting vairable counter to "pause"

float noiWeight = 0.23; // weight of the noise force

float maxSpeed = 100;
float maxForce = 0.45;

float doF = 80; // depth of field

float viscocity = 0.002; //

float step = 0.000001; // step to take in noise after each iteration
float noiseScale =1000;	// varies the scale in the 3d perlin noise 

float neighbor_distance = 100; //maximum distance to be considered a neighboro

PVector noiseOffset = new PVector(0, 1./3, 2.0/3); // vector for noise offset on the noise force

PeasyCam cam;
PVector cameraFocusPoint = new PVector();
Plane cameraPlane;
PVector avg_pvec;

void setup() {
	size(700, 400, P3D);
	cam = new PeasyCam(this, 500); // initialize camera 1000px away from origin
	// noLoop();
	// frameRate(5);
	flock = new Flock(n);
}

void draw() {
	// Pause the sinusoidal center weight force for a bit when its at PI. At PI, cosine curve is at a minimum (minimum centering force)
	if (!paused) {
		if (Math.abs(center_cosine % TWO_PI - PI) < 0.01  && pauseCentCounter != pauseCent) {
			pauseCentCounter++;	// if we're at the designated cosine, wait for pauseCentCounter frames
			// println("paused "+pauseCentCounter);
		} else {
			// Calculate centering force weight based on a sinusoid
			centWeight = cos(center_cosine)/4+1./3;
			center_cosine += sinusoid_step; // increment where on cosine centWeight curve we are
			pauseCentCounter = 0;
		}
	}

	flock.findGlobalAvg(); // find the average of all the boids
	// flock.setNeighborsHash(); // set the neighbors for each boid

	//extract the flock's avg to a Vec3D variable from a PVector
	avg_pvec = flock.globalAvg;
	Vec3D avg = new Vec3D(avg_pvec.x, avg_pvec.y, avg_pvec.z);	

	// Make the camera's focus point the avg point of flock, and translate accordinly
	cameraFocusPoint.set(avg_pvec);
	// Translate the "world" with the inverse of camera's focus point (give the appearance of moving the camera with the flock, so flock looks stationary)
	translate(-cameraFocusPoint.x, -cameraFocusPoint.y, -cameraFocusPoint.z);

	// Find the camera plane based off the camera's position and the avg
	float[] camPosition = cam.getPosition();
	cameraPlane = new Plane(avg, new Vec3D(camPosition[0], camPosition[1], camPosition[2]));
	  // println("cameraPosition: "+camPosition[0]+", "+camPosition[1]+", "+camPosition[2]);

	background(0);
	flock.iterate();
	
	noiseOffset.add(step, step, step); // move the noiseOffset vector by step
}




class Flock  {

	ArrayList<Boid> flock;
	int numBoids;

	public PVector globalAvg = new PVector();

	float neighborDistance;	// Maximum distance from another particle for it to be a "neighbor"
	boolean allNeighbors = false;

	HashMap<Boid, ArrayList<Boid>> neighborsHash = new HashMap<Boid, ArrayList<Boid>>();

	Flock(int n) {
		flock = new ArrayList<Boid>();
		// neighborsHash = new HashMap<Boid, ArrayList<Boid>>();
		numBoids = n;
		// Add initial n number of boids to the flock, initialize the neighborsHash
		for (int i = 0; i < numBoids; ++i) {
			ArrayList<Boid> neighbors = new ArrayList<Boid>();
			Boid b = new Boid();
			addBoid(b);
			neighborsHash.put(b, neighbors);
			
		}
	}

	// Call the run function of each boid
	void iterate() {
		for (Boid b : flock) {
			b.run(neighborsHash.get(b), globalAvg); // pass the boid's neighbors and global average to run
		}
	}

	// Calculate the global average vector of the positions of all boids in the flock
	void findGlobalAvg() {
		PVector sum = new PVector(0,0,0);
		for (Boid b : flock) {
			sum.add(b.position);
		}
		sum.div(numBoids);
		globalAvg = sum;
	}

	// Set the arraylist of neighbors for all nodes. Neighbors being defined by neighbor_distance
	// This proved to be too computationally expensive
	void setNeighborsHash() {
		for (int i = 0; i < flock.size(); ++i) {
			for (int j = i+1; j < flock.size(); ++j) {
				Boid a = flock.get(i);
				Boid b = flock.get(j);
				if (PVector.dist(a.position, b.position) < neighbor_distance) {
					neighborsHash.get(a).add(b);
					neighborsHash.get(b).add(a);
				}
			}
		}
	}

	// Add a boid to the flock
	void addBoid(Boid b) {
		flock.add(b);
	}

}



void keyPressed() {
  if(key == 'p')
    paused = !paused;

	if (key == 'r') {
		for (Boid b : flock.flock) {
			// b.position = flock.globalAvg.add(b.origin_x, b.origin_y, 0);
			b.position = flock.globalAvg;
		}
	}
	
}