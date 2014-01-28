import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
Final Project

Flock Flow Fields

Autonomous Agents 

Jeremy Ho
1/27/2014
**/

PVector separation;
PVector alignment;
PVector cohesion;

float sepWeight = 10;
float aliWeight = .1f;
float cohWeight = .1f;

ArrayList<Boid> flock = new ArrayList<Boid>();

public void setup() {
	size(800, 800, P3D);	
}

public void draw() {
	translate(width/2, height/2, 0);	
	rotateY(20);
	rectMode(CENTER);

	rect(0, 0, 100, 100);
}

class Boid  {

	PVector position;
	PVector velocity;
	PVector steeringForce;

	float maxSpeed = 10;

	Boid (PVector initial) {
		position = initial;
		steeringForce = new PVector(0,0,0);
	}

	// Updates the boid's position by updating it's velocity (based on steeringForce)
	// and adding it to the position
	public void update(ArrayList<Boid> neighbors) {
		calculateSteeringForce(neighbors);
		// Update the velocity based on steering force
		velocity.add(steeringForce);
		velocity.limit(maxSpeed);	// limit it to the maxSpeed
		// Update boid's position
		position.add(velocity);
	}

	// Reset and calculate the boid's steering force based on the flocking behavior functions
	public void calculateSteeringForce(ArrayList<Boid> neighbors) {
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

	public PVector separate(ArrayList<Boid> neighbors) {

	}

	public void paint(){

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
