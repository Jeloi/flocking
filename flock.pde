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
float aliWeight = .1;
float cohWeight = .1;

ArrayList<Boid> flock = new ArrayList<Boid>();

void setup() {
	size(800, 800, P3D);	
}

void draw() {
	translate(width/2, height/2, 0);	
	rotateY(20);
	rectMode(CENTER);

	rect(0, 0, 100, 100);
}

