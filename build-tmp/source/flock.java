import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import peasy.*; 
import toxi.geom.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class flock extends PApplet {

/**
Generative Art - Final Project

A 3D Particle System with Sinusoidal and Flocking Behavior in a Moving 3D Noise Field

In this project my initial goal was to create a 3D particle system with agents (boids) that exhibited flocking behavior. I started by understanding Craig Reynold's flocking algorithm, in which "boids" follow three rules of flocking: separation, alignment, and cohesion. These were basically just rules for forces that act on each boid's velocity. Once I got a nice 3D particle system up and running, I started to experiment with my own rules for forces.
Because I was really interested in the concept of noise, I had a force be applied to boid's based off their 3D position in a noise field, with an offset that is constantly moving. Because of the nature of noise, nearby points have a similar noise value, so this implemented a type of pseudo-flocking behavior.
The only real flocking rule that I ended up using was cohesion, which basically means each boid looks at its neighbors (neighbor distance being a variable i control), and a force is applied to the boid to tend toward the avg position of the neighbors.
Viscocity was a force that just slows the boid's down by applying a factor of the inverse of velocity.
I also applied a force that I called centering which causes boid's to tend toward the global avg of all boids' positions. As the camera is pointed at this global average, the point the camera points to is always the center of the flock. 
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





boolean paused = false;

Flock flock;
int n = 10000; // number of boids

float cohWeight = 0.5f; // weight of cohesion force

float centWeight; // weight of the centering force
float center_cosine = 0;	// this is basically theta on the cosine curve
float sinusoid_step = PI/35;	// how big of a step to take on the cosine curve each time (i.e how fast to oscillate)
float pauseCent = 15;	//how long to pause the sinusoidal action
int pauseCentCounter; // assisting vairable counter to "pause"

float noiWeight = 0.23f; // weight of the noise force

float maxSpeed = 100;
float maxForce = 0.45f;

float doF = 80; // depth of field

float viscocity = 0.002f; //

float step = 0.000001f; // step to take in noise after each iteration
float noiseScale =1000;	// varies the scale in the 3d perlin noise 

float neighbor_distance = 100; //maximum distance to be considered a neighboro

PVector noiseOffset = new PVector(0, 1.f/3, 2.0f/3); // vector for noise offset on the noise force

PeasyCam cam;
PVector cameraFocusPoint = new PVector();
Plane cameraPlane;
PVector avg_pvec;

public void setup() {
	size(700, 400, P3D);
	cam = new PeasyCam(this, 500); // initialize camera 1000px away from origin
	// noLoop();
	// frameRate(5);
	flock = new Flock(n);
}

public void draw() {
	// Pause the sinusoidal center weight force for a bit when its at PI. At PI, cosine curve is at a minimum (minimum centering force)
	if (!paused) {
		if (Math.abs(center_cosine % TWO_PI - PI) < 0.01f  && pauseCentCounter != pauseCent) {
			pauseCentCounter++;	// if we're at the designated cosine, wait for pauseCentCounter frames
			// println("paused "+pauseCentCounter);
		} else {
			// Calculate centering force weight based on a sinusoid
			centWeight = cos(center_cosine)/4+1.f/3;
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
	public void iterate() {
		for (Boid b : flock) {
			b.run(neighborsHash.get(b), globalAvg); // pass the boid's neighbors and global average to run
		}
	}

	// Calculate the global average vector of the positions of all boids in the flock
	public void findGlobalAvg() {
		PVector sum = new PVector(0,0,0);
		for (Boid b : flock) {
			sum.add(b.position);
		}
		sum.div(numBoids);
		globalAvg = sum;
	}

	// Set the arraylist of neighbors for all nodes. Neighbors being defined by neighbor_distance
	// This proved to be too computationally expensive
	public void setNeighborsHash() {
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
	public void addBoid(Boid b) {
		flock.add(b);
	}

}



public void keyPressed() {
  if(key == 'p')
    paused = !paused;

	if (key == 'r') {
		for (Boid b : flock.flock) {
			// b.position = flock.globalAvg.add(b.origin_x, b.origin_y, 0);
			b.position = flock.globalAvg;
		}
	}
	
}
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
	public void run(ArrayList<Boid> neighbors, PVector global_avg) {
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
	public void update() {
		// Update the velocity based on steering force
		velocity.add(steeringForce);
		velocity.limit(maxSpeed);	// limit it to the maxSpeed
		// Update boid's position
		position.add(velocity);
		steeringForce = new PVector(0,0,0); // Reset steering force to 0 after each update
	}


	// Returns a PVector indicating a force that steers the boid toward a target destination
	// steering force = desired velocity - current velocity
	public PVector seek(PVector destination) {
		PVector desired = PVector.sub(destination, position);	//desired  = target - position
		// Set the magnitude of the desired velocity to be maxSpeed
		desired.normalize();
		desired.mult(maxSpeed);
		PVector sf = PVector.sub(desired, velocity);
		sf.limit(maxForce);
		return sf; // return the steering force toward the target destination
	}

	/** FORCE BEHAVIOR FUNCTIONS **/

	public void applyViscosityForce() {
	  PVector visc = new PVector(0,0,0);
	  visc = velocity.get();
	  visc.mult(-viscocity);
	  steeringForce.add(visc);
	}

	// Cohesion - apply a force that pushes boids toward the average of their neighbors
	public void applyCohesion(ArrayList<Boid> neighbors) {
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
	public void applyCentering(PVector avg) {
		cent = seek(avg);
		cent.mult(centWeight);	// scale by the defined weight
		steeringForce.add(cent);	// add to steering force
	}

	// Use Perlin noise based on particle location and the offset to apply a force
	public void applyNoise() {
		noi = new PVector(
		noise(position.x / noiseScale +noiseOffset.x, position.y / noiseScale, position.z / noiseScale) - .5f,
		noise(position.x / noiseScale, position.y / noiseScale + noiseOffset.y, position.z / noiseScale) - .5f,
		noise(position.x / noiseScale, position.y / noiseScale, position.z / noiseScale + noiseOffset.z) - .5f);
		noi.mult(noiWeight);	// scale by the defined weight
		steeringForce.add(noi);	// add to steering force
	}

	// Set the position of the the Boid
	public void setPosition(PVector p) {
		position = p;
	}

	// Draw point with depth of field effect relative to the point's position to the camera plane
	public void paint(){
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "flock" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
