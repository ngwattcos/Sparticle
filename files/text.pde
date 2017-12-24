
/*
 * background stars
 * stars, planets of difference colors
 * pre-generated stars
 * all physics objects inherit from abstract class PhysObj
 * all PhysObjs inherit from graphObj (which has .inFrustum(), .draw())
 * 2d space
 * gravity, momentum and collisions
	* use moduli of elasticity to deal with final velocities
		* composite modulus = obj1.mod * obj2.mod
	* 2d vector collisions
 * include electromagnetic forces?
 * mouse click() methods

 */








int screenX = 900, screenY = 600, frameRt = 30;

PFont monaco;
PFont courierNew;

/*class Picture {
	
	Dimensions size;
	PImage image;
	
	public Picture(PImage image, int x, int y) {
		
		this.image = image;
		size = new Dimensions(x, y);
	}
}*/

/*
PImage[] PImages = new PImage[30];
Picture[] pictures = new Picture[1];

void loadImages() {
	for (int i = 0; i < pictures.length; i++) {
		PImage thisImg = loadImage("data_small/" + Integer.toString(i) + ".png");
		pictures[i] = new Picture(thisImg, thisImg.width, thisImg.height);
	}
}
*/

///////////////////////////////////////////////////////// Keys

class Key {
	int code;
	
	boolean pressed = false;
	boolean released = false;
	boolean clicked = false;
	int pressedTimer = 0;
	int releasedTimer = 0;
	
	public Key(int code) {
		this.code = code;
	}
	
	void update() {
		pressedTimer += 1;
		clicked = false;
		
		releasedTimer += 1;
		released = false;
	}
}

int MAX_KEYS = 200;

Key[] keys = new Key[MAX_KEYS];

// ArrayList<Key> pressedKeys = new ArrayList<Key>();
ArrayList<Integer> pressedKeys = new ArrayList<Integer>();


void keyPressed() {
	boolean inArr = false;
	
	if (keyCode < MAX_KEYS) {
		
		keys[keyCode].pressed = true;
		keys[keyCode].released = false;
		keys[keyCode].clicked = true;
		
		for (int i = 0; i < pressedKeys.size(); i++) {
			if (pressedKeys.get(i).intValue() == keyCode) {
				inArr = true;
			}
		}
		
		if (!inArr) {
			pressedKeys.add(new Integer(keyCode));
		}
	}
}

void keyReleased() {
	if (keyCode < MAX_KEYS) {
		
		keys[keyCode].pressed = false;
		keys[keyCode].released = true;
		keys[keyCode].clicked = false;
		keys[keyCode].releasedTimer = 0;
		
		int i = 0;
		boolean found = false;
		
		while (!found && i < pressedKeys.size()) {
			if (pressedKeys.get(i).intValue() == keyCode) {
				found = true;
				pressedKeys.remove(i);
				
				i -= 1;
			}
			
			i += 1;
		}
	}
}

void updateKey(int i) {
	if (keys[i].pressed) {
			keys[i].pressedTimer += 1;
		} else {
			keys[i].pressedTimer = 0;
		}
	
		if (keys[i].pressedTimer == 1) {
			keys[i].clicked = true;
		} else {
			keys[i].clicked = false;
		}
	
	
		if (!keys[i].pressed) {
			keys[i].releasedTimer += 1;
		}
	
		if (keys[i].releasedTimer == 1) {
			keys[i].released = true;
		} else {
			keys[i].released = false;
		}
}

void updateKeys() {
	for (int i = 16; i < 100; i++) {
		updateKey(i);
	}
	
	
	//// update the = key
	updateKey(187);
}



class Coords {
	int x; int y;
	
	public Coords(int x, int y) {
		this.x = x;
		this.y = y;
	}
}

int gSizeX = 3000;
int gSizeY = 3000;

float posX = gSizeX/2;
float posY = gSizeY/2 - 300;


//////////// mouse

public class Mouse {
	int prevX = mouseX;
	int prevY = mouseY;
	int x = mouseX;
	int y = mouseY;
	
	boolean isPressed = false;
	boolean isReleased = false;
	boolean isDragged = false;
	int pressedTimer = 0;
	int releasedTimer = 0;
	boolean clicked = false;
	boolean released = false;
	
	int dx = 0;
	int dy = 0;
	
	// selecting when mouse.selecting && mouse.clickNum == 0
	
	boolean selecting = false;
	boolean select = false;
	int clickNum = 0;
	Coords click1 = new Coords(x, y);
	Coords click2 = new Coords(x, y);
	
	
	
	public Mouse() {
		
	}
	
	void addPressed() {
		pressedTimer += 1;
	}
	
	void addReleased() {
		releasedTimer += 1;
	}
	
	void update() {
		
		if (pressedTimer == 1) {
			clicked = true;
		} else {
			clicked = false;
		}
		
		if (releasedTimer == 1) {
			released = true;
		} else {
			released = false;
		}
	}
	
	void check() {
		prevX = x;
		prevY = y;
		
		x = mouseX;
		y = mouseY;
		
		dx = mouseX - prevX;
		dy = mouseY - prevY;
		
		if (isPressed) {
			pressedTimer += 1;
		} else {
			pressedTimer = 0;
		}
		
		if (pressedTimer == 1) {
			clicked = true;
		} else {
			clicked = false;
		}
		
		if (isReleased) {
			releasedTimer += 1;
		} else {
			releasedTimer = 0;
		}
		
		if (releasedTimer == 1) {
			released = true;
		} else {
			released = false;
		}
		
		
		if (clickNum == 0) {
			selecting = false;
		}
		
		// selecting - hold shift
		if (keys[16].pressed) {
			if (released) {
				clickNum += 1;
				
				if (clickNum == 1) {
					selecting = true;
					click1.x = x + (int) round(posX);
					click1.y = y + (int) round(posY);
				}
		
				if (clickNum == 2) {
					selecting = true;
					click2.x = x + (int) round(posX);
					click2.y = y + (int) round(posY);
				}
				
			}	// if released
		} else {
			// shift is not held
			if (clicked) {
				clickNum = 0;
				selecting = false;
			}
		}
		
		// 0 - nothing selected; 1 - 1st point selected; 2 - 2nd point selected --> immediately back to 0
		if (clickNum > 1) {
			clickNum = 0;
		}
		
		select = selecting && clickNum == 0;
		
	}
	
	
	void draw() {
		stroke(0, 255, 0);
		line(x - 20, y - 20, x + 20, y + 20);
		line(x + 20, y - 20, x - 20, y + 20);
		
		if (clickNum == 1) {
			pushMatrix();
				translate(-posX, -posY);
				fill(255, 255, 255, 100);
				stroke(255, 255, 255);
				rect(click1.x, click1.y, (x + posX) - click1.x, (y + posY) - click1.y);
				noStroke();
			popMatrix();
		}
	}
}

Mouse mouse = new Mouse();

void mousePressed() {
	mouse.isPressed = true;
	mouse.isReleased = false;
}

void mouseDragged() {
	mouse.isDragged = true;
}

void mouseReleased() {
	mouse.isPressed = false;
	mouse.isDragged = false;
	mouse.isReleased = true;
}




///////////////////////////////////////////////// names of celestial bodies

String[] starNames;
String[] planetNames;

int starName;
int planetName;

void loadStars() {
	String stars = "src/stars.txt";
	
	starNames = new String[] {"Supergiant",
"ACAMAR",
"Death Star",
"Life Star",
"Thug Life Star",
"ACHERNAR",
"Achird",
"PotatoStar",
"ACRUX",
"Acubens",
"Starkiller",
"ADARA",
"Adhafera",
"Sparta",
"Adhil",
"AGENA",
"Ain al Rami",
"Ain",
"Al Anz",
"Al Kalb al Rai",
"Al Minliar al Asad",
"Al Minliar al Shuja",
"Aladfar",
"Alathfar",
"Albaldah",
"Albali",
"ALBIREO",
"Alchiba",
"Flatlands",
"ALCOR",
"ALCYONE",
"ALDEBARAN",
"ALDERAMIN",
"Aldhibah",
"Alfecca Meridiana",
"Alfirk",
"ALGENIB",
"ALGIEBA",
"ALGOL",
"Algorab",
"ALHENA",
"ALIOTH",
"ALKAID",
"Alkalurops",
"Alkes",
"Alkurhah",
"ALMAAK",
"ALNAIR",
"ALNATH",
"ALNILAM",
"ALNITAK",
"Alniyat",
"Alniyat",
"ALPHARD",
"ALPHEKKA",
"ALPHERATZ",
"Alrai",
"Alrisha",
"Alsafi",
"Alsciaukat",
"ALSHAIN",
"Alshat",
"Alsuhail",
"ALTAIR",
"Altarf",
"Alterf",
"Aludra",
"Alula Australis",
"Alula Borealis",
"Alya",
"Alzirr",
"Ancha",
"Angetenar",
"Portal II",
"ANKAA",
"Anser",
"ANTARES",
"ARCTURUS",
"Arkab Posterior",
"Arkab Prior",
"ARNEB",
"Arrakis",
"Ascella",
"Asellus Australis",
"Asellus Borealis",
"Asellus Primus",
"Asellus Secondus",
"Asellus Tertius",
"Asterope",
"Atik",
"Atlas",
"Auva",
"Avior",
"Azelfafage",
"Azha",
"Azmidiske",
"Baham",
"Baten Kaitos",
"Becrux",
"Beid",
"BELLATRIX",
"BETELGEUSE",
"Botein",
"Brachium",
"CANOPUS",
"CAPELLA",
"Caph",
"CASTOR",
"Cebalrai",
"Celaeno",
"Chara",
"Chort",
"COR CAROLI",
"Cursa",
"Dabih",
"Deneb Algedi",
"Deneb Dulfim",
"Deneb el Okab",
"Deneb el Okab",
"Deneb Kaitos Shemali",
"DENEB",
"DENEBOLA",
"Dheneb",
"Diadem",
"DIPHDA",
"Double Double (7051)",
"Double Double (7052)",
"Double Double (7053)",
"Double Double (7054)",
"Dschubba",
"Dsiban",
"DUBHE",
"Ed Asich",
"Electra",
"ELNATH",
"ENIF",
"ETAMIN",
"FOMALHAUT",
"Fornacis",
"Fum al Samakah",
"Furud",
"Gacrux",
"Gianfar",
"Gienah Cygni",
"Gienah Ghurab",
"Gomeisa",
"Gorgonea Quarta",
"Gorgonea Secunda",
"Gorgonea Tertia",
"Graffias",
"Grafias",
"Grumium",
"HADAR",
"Haedi",
"HAMAL",
"Hassaleh",
"Head of Hydrus",
"Herschel's 'Garnet Star'",
"Heze",
"Hoedus II",
"Homam",
"Hyadum I",
"Hyadum II",
"IZAR",
"Jabbah",
"Kaffaljidhma",
"Kajam",
"KAUS AUSTRALIS",
"Kaus Borealis",
"Kaus Meridionalis",
"Keid",
"Kitalpha",
"KOCAB",
"Kornephoros",
"Kraz",
"Kuma",
"Lesath",
"Maasym",
"Maia",
"Marfak",
"Marfak",
"Marfic",
"Marfik",
"MARKAB",
"Matar",
"Mebsuta",
"MEGREZ",
"Meissa",
"Mekbuda",
"Menkalinan",
"MENKAR",
"Menkar",
"Menkent",
"Menkib",
"MERAK",
"Merga",
"Merope",
"Mesarthim",
"Metallah",
"Miaplacidus",
"Minkar",
"MINTAKA",
"MIRA",
"MIRACH",
"Miram",
"MIRPHAK",
"MIZAR",
"Mufrid",
"Muliphen",
"Murzim",
"Muscida",
"Muscida",
"Muscida",
"Nair al Saif",
"Naos",
"Nash",
"Nashira",
"Nekkar",
"NIHAL",
"Nodus Secundus",
"NUNKI",
"Nusakan",
"Peacock",
"PHAD",
"Phaet",
"Pherkad Minor",
"Pherkad",
"Pleione",
"Polaris Australis",
"POLARIS",
"POLLUX",
"Porrima",
"Praecipua",
"Prima Giedi",
"PROCYON",
"Propus",
"Propus",
"Propus",
"Rana",
"Ras Elased Australis",
"Ras Elased Borealis",
"RASALGETHI",
"RASALHAGUE",
"Rastaban",
"REGULUS",
"Rigel Kentaurus",
"RIGEL",
"Rijl al Awwa",
"Rotanev",
"Ruchba",
"Ruchbah",
"Rukbat",
"Sabik",
"Sadalachbia",
"SADALMELIK",
"Sadalsuud",
"Sadr",
"SAIPH",
"Salm",
"Sargas",
"Sarin",
"Sceptrum",
"SCHEAT",
"Secunda Giedi",
"Segin",
"Seginus",
"Sham",
"Sharatan",
"SHAULA",
"SHEDIR",
"Sheliak",
"SIRIUS",
"Situla",
"Skat",
"SPICA",
"Sterope II",
"Sualocin",
"Subra",
"Suhail al Muhlif",
"Sulafat",
"Syrma",
"Tabit (1543)",
"Tabit (1544)",
"Tabit (1552)",
"Tabit (1570)",
"Talitha",
"Tania Australis",
"Tania Borealis",
"TARAZED",
"Taygeta",
"Tegmen",
"Tejat Posterior",
"Terebellum I",
"Terebellum II",
"Terebellum III",
"Terebellum IIII",
"Thabit",
"Theemim",
"THUBAN",
"Torcularis Septentrionalis",
"Turais",
"Tyl",
"UNUKALHAI",
"VEGA",
"VINDEMIATRIX",
"Wasat",
"Wezen",
"Wezn",
"Yed Posterior",
"Yed Prior",
"Yildun",
"Zaniah",
"Zaurak",
"Zavijah",
"Zibal",
"Zosma",
"Zuben Elakrab",
"Zuben Elakribi",
"Zuben Elgenubi II",
"Zuben Elschemali"};
}

void loadPlanets() {
	String planets = "src/planets.txt";
	
	planetNames = new String[] {"Tiny Tim",
"Kepler-452b",
"Kepler-186f",
"Kepler-62f",
"Wolf 1061c",
"Kepler-1229b",
"/usr/bin/src",
"Kepler-442b",
"Gliese 667 Cc",
"Yosmainope",
"Letreipra",
"Eflides",
"Quscuna",
"大便",
"狗屎",
"厕所",
"马桶",
"裤子",
"死",
"活",
"小男孩",
"小姑娘",
"小女娘",
"Tawhuturn",
"Yuchutov",
"Vuchiri",
"Fefrion",
"////....",
"Buytera",
"Ueter",
"Thaamia",
"Crodorus",
"Shore IC",
"Cheon 7G",
"Vusceunia",
"Gabloyter",
"Vowhion",
"Fudrarth",
"Jueclite",
"Weacarro",
"Stucenus",
"Gruzephus",
"Clov XIB",
"Swomia T0F",
"Udroilia",
"Ofraonov",
"Eshapus",
"Leglade",
"Wiaclite",
"Uoclite",
"Projonia",
"Brajocury",
"Scilia 634",
"Cleon WQ0P",
"Gutera",
"⁄€‹›ﬁﬂ‡°",
"Zuycarro",
"Scuxuter",
"Craheclite",
"Flarth LG",
"Bradus QB0",
"{...} {..}",
"Hobrayvis",
"Kechoenerth",
"Dasnorix",
"Zosnorth",
"Daithea",
"Moyter",
"Snoehiri III",
"Sloastea",
"Glilles N2T",
"Strone 4",
"Zasmeyzuno",
"Hothiawei",
"Mescov",
"Kegryke",
"Ioybos",
"Uenia",
"Glutecury",
"˙∆©˚¥¨∂®",
"Wheenus",
"Pradus 449",
"Store OU9",
".--..--.-.-.-"};
}

void loadNames() {
	
	loadStars();
	
	loadPlanets();
}


////////////////////////////////////////////////////////// Setup
void setup() {
	size(900, 600, OPENGL);
	frameRate(33);
	
	// loadImages();
	
	loadNames();
	
	monaco = createFont("monaco", 20);
	courierNew = createFont("monaco", 10);
	
	for (int i = 0; i < keys.length; i++) {
		keys[i] = new Key(i);
	}
}




///////////////////////////////////////////////////////////////////////

float distSq(Vector p1, Vector p2) {
	return (pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
}

float distSq(float x, float y) {
	return (pow(x, 2) + pow(y, 2));
}



int boundsX = 3500;
int boundsY = 3500;


class Vector {
	
	// static Vector ZERO = new Vector(0.0, 0.0);
	
	float x;
	float y;
	float angle;
	float mag;
	
	// default zero vector
	public Vector() {
		this(0.0, 0.0);
	}
	
	// create a Vector with components
	public Vector(float _x, float _y) {
		x = _x;
		y = _y;
		
		syncProperties();
	}
	
	// create a Vector based on angle and magnitude
	public Vector(float _angle, float _mag, String s) {
		angle = _angle;
		mag = _mag;
		
		syncComponents();
	}
	
	void reset() {
		x = 0;
		y = 0;
		syncProperties();
	}
	
	void setX(float _x) {
		
		x = _x;
		
		// change angle, mag
		syncProperties();
	}
	
	void setY(float _y) {
		
		y = _y;
		
		// change angle, mag
		syncProperties();
	}
	
	void setAngle(float _angle) {
		
		angle = _angle;
		
		// change x, y
		syncComponents();
	}
	
	void setMag(float _mag) {
		
		mag = _mag;
		
		// change mag
		syncComponents();
	}
	
	void syncComponents() {
		x = cos(angle) * mag;
		y = sin(angle) * mag;
	}
	
	void syncProperties() {
		angle = atan2(y, x);
		mag = sqrt(pow(x, 2) + pow(y, 2));
	}
	
	float angleBetween(Vector v2) {
		return atan2(y - v2.y, x - v2.x) + PI;
	}
	
	Vector copy() {
		Vector c = new Vector(x, y);
		
		return c;
	}
	
	Vector add(Vector v2) {
		
		float _x = x + v2.x;
		float _y = y + v2.y;
		
		return new Vector(_x, _y);
	}
	
	Vector subtract(Vector v2) {
		
		float _x = x - v2.x;
		float _y = y - v2.y;
		
		return new Vector(_x, _y);
	}
	
	/*Vector cross(Vector v2) {
		
		float theta = angle = v2.angle;
		
		
		return new Vector();
	}*/
		
	float cross(Vector v2) {
		// float theta = angle - v2.angle;
	
		float theta = angleBetween(v2);
	
		theta = theta - PI;
	
		return mag * v2.mag * sin(theta);
	}
	
	Vector mult(float a) {
		return new Vector(angle, mag * a, "");
	}
	
	Vector divide(float a) {
		return new Vector(angle, mag / a, "");
	}
	
	Vector dot(Vector v2) {
		return new Vector();
	}
	
	void draw(Vector p) {
		pushMatrix();
		translate(p.x, p.y);
			stroke(0, 255, 0);
			line(0, 0, mag * cos(angle), mag * sin(angle));
		popMatrix();
	}
	
}



// class

float G = 0.001;

abstract class PhysicsObj {
	
	int mass;
	int moment;
	Vector center;		// it is assumed center is the center of mass
	Vector velocity;
	Vector acceleration;
	Vector position;
	
	boolean inFrustum = true;
	
	Vector forces;
	float torques;		// is used to represent torque
	
	float angle;
	float omega;
	float alpha;
	
	String typeObj;
	
	public PhysicsObj(Vector _position, Vector _velocity, int _mass, int _moment) {
		position = _position;
		velocity = _velocity.copy();
		forces = new Vector(0, 0);
		acceleration = forces.divide(mass);
		
		mass = _mass;
		moment = _moment;
				
	}
	
	
	void applyForce(Vector force, Vector pos) {
		// can also apply a torque
		
		forces = forces.add(force);
		
		
		// torque = r x F
		if (abs(force.cross(pos)) > 0.0001) {
			
			// torques
			
			// direction to point of application
			float theta;
			float r;
			float t1;
			
			theta = position.angleBetween(pos);
			r = sqrt(distSq(position, pos));
			// T = r * F * sin(ø)
			
			// + is counterclockwise, - is clockwise
			t1 = r * force.mag * sin(theta)/10.0;
			
			// torques += t1;
		}
	}
	
	void applyGravity(PhysicsObj o) {
		
		// angle from the object
		float theta = position.angleBetween(o.position);
		
		// magnitude of the force
		float fg = G * mass * o.mass / distSq(position, o.position);
		
		// combine into a vector
		Vector force_gravity = new Vector(theta, fg, "");
		
		// add this to the net force
		applyForce(force_gravity, new Vector(0, 0));
		
		println(fg);
	}
	
	void interact() {
		
	}
	
	void clearForces() {
		forces.reset();
		
		torques = 0;
	}
	
	void update() {
		
		interact();
		
		acceleration = forces.divide(mass);
		
		velocity = velocity.add(acceleration);
		
		position = position.add(velocity);
		
		alpha = torques/moment;
		
		omega += alpha;
		
		angle += omega;
		
		// if position is too far left, move to right edge
		if (position.x < -boundsX) {
			position.x = boundsX;
		}

		// and vice versa
		if (position.x > boundsX) {
			position.x = -boundsX;
		}
		
		// is position is too far up, move to bottome edge
		if (position.y < -boundsY) {
			position.y = boundsY;
		}

		// and vice versa
		if (position.y > boundsY) {
			position.y = -boundsY;
		}
	}
	
	void drawForces() {
		// forces.draw(position);
	}
	
	void drawObj() {
		
	}
	
	void draw() {

		if (inFrustum) {
			drawObj();
		}
		
		// drawForces();
		
		clearForces();
	}
}


class CelestialBody extends PhysicsObj {
	boolean hasAtmosphere;
	float atmosphere;
	float diameter;
	float radius;
	
	String name;
	
	Color col;
	
	
	// I = mr^2
	// d = m^0.33
	// I = m * m^0.66
	// I = m^1.66
	
	
	public CelestialBody(Vector _position, Vector _velocity, int _mass) {
		super(_position, _velocity, _mass, round(pow(_mass, 0.666)));
		
		diameter = pow(mass, 0.333) * 2;
		radius = diameter/2;
		
		typeObj = "potato";
		
	}
	
	public String getT() {
		return typeObj;
	}
	
	void drawBody() {
		
		noStroke();
		fill(col.r, col.g, col.b);
		ellipse(position.x, position.y, diameter, diameter);
		
	}
	
	void interact() {
		inFrustum = distSq(position.x - rocket.position.x, position.y - rocket.position.y) < 360000;
	}
	
	void displayName() {
		if (distSq(position.x - rocket.position.x, position.y - rocket.position.y) < 90000) {
			fill(150, 150, 150);
			textAlign(CENTER);
			text(name, position.x, position.y + radius + 20);
			textAlign(LEFT);
		}
	}
	
	void drawObj() {
		
		drawBody();
		
		displayName();
		
		/*if (distSq(mouse.x - this.position.x + rocket.position.x, mouse.y - this.position.y + rocket.position.y) < 400) {
			fill(255, 255, 255, 50);
			rect(position.x, position.y, 100, 40);
			fill(255, 255, 0);
			text("v_x: " + velocity.x + "\nv_y: " + velocity.y, position.x + 30, position.y + 10);
		}*/
	}
}

class Star extends CelestialBody {
	
	
	
	public Star(Vector _position, Vector _velocity, int _mass, int it) {
		super(_position, _velocity, _mass);
		
		col = colors[it];
		
		name = starNames[starName % starNames.length];
		
		typeObj = "star";
		
		for (int i = 0; i < starName/starNames.length; i++) {
			if (i == 0) {
				name += " ";
			}
			
			name += "X";
		}
		
		starName += 1;
	}
	
	
}

class Planet extends CelestialBody {
	
	
	
	public Planet(Vector _position, Vector _velocity, int _mass, int it) {
		super(_position, _velocity, _mass);
		
		col = colors2[it];
		
		name = planetNames[planetName % planetNames.length];
		
		typeObj = "planet";
		
		for (int i = 0; i < planetName/planetNames.length; i++) {
			if (i == 0) {
				name += " ";
			}
			
			name += "X";
		}
		
		planetName += 1;
		
	}
	
	/*void drawBody() {
		
		noStroke();
		fill(col.r, col.g, col.b);
		ellipse(position.x, position.y, diameter, diameter);
		
	}*/
	
}

class Color {
	int r;
	int g;
	int b;
	
	public Color(int _r, int _g, int _b) {
		r = _r;
		g = _g;
		b = _b;
	}
}

//// star colors
Color[] colors = {
	new Color(166, 255, 255),	// deep red
	new Color(166, 255, 255),
	new Color(255, 200, 0),		// orange
	new Color(255, 200, 0),
	new Color(255, 255, 0),		// yellow
	new Color(255, 255, 166),
	new Color(255, 255, 166),
	new Color(255, 255, 166),
	new Color(0, 166, 255),		// deep blue
	new Color(166, 255, 255),	// bright blue
	new Color(220, 266, 266)	// very bright blue
};


class Particle {
	// has momentum
	
	public Particle() {
		
	}
}

////// planet colors
Color[] colors2 = {
	new Color(166, 255, 255),
	new Color(0, 0, 255),
	new Color(150, 150, 150),
	new Color(244, 195, 212)
};


void orb(float x, float y, float size, int n, float factor, float offset, int[] col) {
	for (int i = 0; i < n; i++) {
		// fill(255 - i * (255 - col[0])/n, 255 - i * (255 - col[1])/n, 255 - i * (255 - col[2])/n, 75);
		
		fill(col[0] + i * (255 - col[0])/n, col[1] + i * (255 - col[1])/n, col[2] + i * (255 - col[2])/n, 75);
		ellipse(x, y + offset * i, size * pow(factor, i) * random(0.8, 1), size * pow(factor, i) * random(0.8, 1.2));
	}
}

void orb2(float x, float y, float size, int n, float factor, float offset, int[] col) {
	for (int i = n; i >= 0; i--) {
		fill(255 - i * (255 - col[0])/n, 255 - i * (255 - col[1])/n, 255 - i * (255 - col[2])/n, 75);
		
		// fill(col[0] + i * (255 - col[0])/n, col[1] + i * (255 - col[1])/n, col[2] + i * (255 - col[2])/n, 75);
		ellipse(x, y + offset * i, size * pow(factor, i) * random(0.8, 1), size * pow(factor, i) * random(0.8, 1.2));
	}
}


class Rocket extends PhysicsObj {
	int width = 8;
	int length = 50;
	
	boolean mainThruster = false;
	boolean left = false;
	boolean right = false;
	
	// float angle;
	
	// public PhysicsObj(Vector _position, Vector _velocity, int _mass, int _moment) {
	public Rocket() {
		super(
			new Vector(0, 0),
			new Vector(0, 0),
			10, 5);
		
		angle = -PI/2;
		
	}
	
	void fireRocket() {
		mainThruster = true;
		applyForce(new Vector(angle, 1.5, ""), new Vector(angle + PI, length/2, ""));
	}
	
	void fireLeft() {
		left = true;
		
		torques -= 0.02;
		
		// applyForce(new Vector(angle + PI/2, 0.01, ""), new Vector(angle, length/2, ""));
	}
	
	void fireRight() {
		right = true;
		
		torques += 0.02;
		
		// applyForce(new Vector(angle - PI/2, 0.01, ""), new Vector(angle, length/2, ""));
	}

	// is called by the update() method
	void interact() {
		
		if (keys[38].pressed) {
			fireRocket();
		}
		

		if (keys[40].pressed) {
			// Vector force, Vector pos
			// applyForce(new Vector(angle + PI, 1, ""), new Vector(angle, length/2, ""));
			
		}
		
		if (keys[37].pressed) {
			// angle -= 0.1;
			fireLeft();
		}
		
		if (keys[39].pressed) {
			// angle += 0.1;
			fireRight();
		}
		
	}
	
	void drawForces() {

		/*pushMatrix();
		translate(position.x, position.y);
			stroke(0, 255, 0);
			line(0, 0, forces.mag * cos(forces.angle) * 100, forces.mag * sin(forces.angle) * 100);
		popMatrix();*/
				
		// draw angle
		// pushMatrix();
		// translate(position.x, position.y);
		// 	stroke(0, 0, 255);
		// 	line(0, 0, cos(angle) * 100, sin(angle) * 100);
		// popMatrix();
	}
	
	void drawObj() {
		pushMatrix();
		translate(position.x, position.y);
		rotate(angle + PI/2);
			noStroke();
			fill(220, 0, 0);
			triangle(0, 0 - length/2 - 20,
				0 - width/2, 0 - length/2,
				0 + width/2, 0 - length/2
			);

			fill(150, 150, 150);
			rect(0 - width/2, 0 - length/2, width, length);
			
			if (mainThruster) {

				orb2(0, length/2 + 15, 10, 10, 0.85, 5, new int[] {255, 210, 0});
				orb(0, length/2 + 10, 15, 10, 0.8, -1, new int[] {255, 210, 0});
			}
			
			if (left) {
				pushMatrix();
				rotate(PI/2);
				orb(length/3, 10, 10, 10, 0.8, -1, new int[] {255, 255, 255});
				popMatrix();
				

				pushMatrix();
				rotate(-PI/2);
				orb(length/3, 10, 10, 10, 0.8, -1, new int[] {255, 255, 255});
				popMatrix();
			}
			
			if (right) {
				pushMatrix();
				rotate(PI/2);
				orb(-length/3, 10, 10, 10, 0.8, -1, new int[] {255, 255, 255});
				popMatrix();
				

				pushMatrix();
				rotate(-PI/2);
				orb(-length/3, 10, 10, 10, 0.8, -1, new int[] {255, 255, 255});
				popMatrix();
			}
			
		popMatrix();
		
		
		mainThruster = false;
		left = false;
		right = false;
	}
	
}


ArrayList<CelestialBody> objs = new ArrayList<CelestialBody>();

// use rocket.applyForce later

Rocket rocket = new Rocket();

void addingStars() {
	
	// public Star(Vector _position, Vector _velocity, int _mass, int _moment) {
	if (keys[32].clicked && keys[16].pressed) {

		int i = round(random(0, colors.length - 1));
		
		objs.add(new Star(
			new Vector(mouse.x + rocket.position.x - screenX/2, mouse.y + rocket.position.y  - screenY/2),
				new Vector(mouse.dx/1, mouse.dy/1),
				round(random(5000, 10000)),
				i
			)
		);
	}
	
	if (keys[32].clicked && !keys[16].pressed) {
		int i = round(random(0, colors2.length - 1));
		objs.add(new Planet(
			new Vector(mouse.x + rocket.position.x - screenX/2, mouse.y + rocket.position.y  - screenY/2),
				new Vector(mouse.dx/1, mouse.dy/1),
				round(random(50, 100)),
				i
			)
		);
	}
	
	if (keys[16].clicked && !keys[32].pressed) {
		addSystem(mouse.x + rocket.position.x - screenX/2, mouse.y + rocket.position.y  - screenY/2);
	}
	
	if (mouse.clicked) {
		addBinary(mouse.x + rocket.position.x - screenX/2, mouse.y + rocket.position.y  - screenY/2);
	}
}

void addStar(float x, float y) {
	int i = round(random(0, colors.length - 1));
	
	objs.add(new Star(
		new Vector(x, y),
		new Vector(0, 0),
		round(random(5000, 10000)),
		i
	));
}

void addPlanet(float x, float y) {
	int i = round(random(0, colors2.length - 1));
	
	objs.add(new Planet(
		new Vector(x, y),
		new Vector(0, 0),
		round(random(50, 100)),
		i
	));
}

void addSystem(float x, float y) {
	
	int ms = round(random(50000, 500000));
	int mp = round(random(5, 65));
	
	int minR = round(pow(ms, 0.333) * 1.2);
	int maxR = round(minR * 2.5);
	
	int factor = round(random(0, 1)) * 2 - 1;
	
	int r = round(random(minR, maxR));
	
	objs.add(new Star(
		new Vector(x, y),
		new Vector(0, 0),
		ms,
		round(random(0, colors.length - 1))
	));
	
	objs.add(new Planet(
		new Vector(x - (r * factor), y),
		new Vector(0, (sqrt(G * ms/r) * factor)),
		mp,
		round(random(0, colors2.length - 1))
	));
	
}

void addBinary(float x, float y) {
	int r = round(random(10, 25));
	int m = round(random(1000, 5000));
	
	int rand = round(random(0, 1)) * 2 - 1;
	
	objs.add(new Star(
		new Vector(x - r, y),
		new Vector(0, rand * sqrt(G * m/(4 * r))),
		m,
		round(random(0, colors.length - 1))
	));
	
	objs.add(new Star(
		new Vector(x + r, y),
		new Vector(0, rand * -sqrt(G * m/(4 * r))),
		m,
		round(random(0, colors.length - 1))
	));
}

void addBinary2(float x, float y) {
	int r = round(random(2, 6));
	int m = round(random(5, 50));
	
	int rand = round(random(0, 1)) * 2 - 1;
	
	objs.add(new Planet(
		new Vector(x - r, y),
		new Vector(0, rand * sqrt(G * m/(4 * r))),
		m,
		round(random(0, colors2.length - 1))
	));
	
	objs.add(new Planet(
		new Vector(x + r, y),
		new Vector(0, rand * -sqrt(G * m/(4 * r))),
		m,
		round(random(0, colors2.length - 1))
	));
}


boolean showG = false;
boolean showM = true;

void updateSimulation() {
	
	if (keys[82].clicked) {
		loadBodies();
	}
	
	if (keys[71].clicked) {
		showG = !showG;
	}
	
	if (keys[77].clicked) {
		showM = !showM;
	}
	
	
	//// draw the grid
	
    firstX = (int) ceil(rocket.position.x/tileSize) - 5;
    firstY = (int) ceil(rocket.position.y/tileSize) - 3;
    
    lastX = (int) floor((rocket.position.x + screenX)/tileSize) - 2;
    lastY = (int) floor((rocket.position.y + screenY)/tileSize) - 1;
	
	if (showG) {
		pushMatrix();
		translate(-rocket.position.x + screenX/2, -rocket.position.y + screenY/2);
		for (int i = firstX; i < lastX; i++) {
			for (int j = firstY; j < lastY; j++) {
				stroke(150, 150, 150);
				line((i - 1) * tileSize, (j - 1) * tileSize, i * tileSize, (j - 1) * tileSize);
				line((i - 1) * tileSize, (j - 1) * tileSize, (i - 1) * tileSize, j * tileSize);
				noStroke();
			}
		}
		popMatrix();
	}
	
	
	// apply gravity to all objects first
	for (int i = 0; i < objs.size(); i++) {
		
		// rocket applies a force onto the object
		// this is negligible
		// objs.get(i).applyGravity(rocket);
		
		// object applies a force on the rocket, if rocket distance is less than 500
		if (distSq(rocket.position.x - objs.get(i).position.x, rocket.position.y - objs.get(i).position.y) < 250000) {
			rocket.applyGravity(objs.get(i));
			
			if (showG) {
				stroke(0, 255, 0);
				line(objs.get(i).position.x - rocket.position.x + screenX/2, objs.get(i).position.y - rocket.position.y + screenY/2, rocket.position.x - rocket.position.x + screenX/2, rocket.position.y - rocket.position.y + screenY/2);
				noStroke();
			}
		}
		

		// apply a force on every other object before
		for (int o = 0; o < i; o++) {
			
			// if < 250 pixels
			if (distSq(objs.get(i).position.x - objs.get(o).position.x, objs.get(i).position.y - objs.get(o).position.y) < 62500) {
				objs.get(o).applyGravity(objs.get(i));
				if (showG) {
					stroke(0, 255, 0);
					line(objs.get(i).position.x - rocket.position.x + screenX/2, objs.get(i).position.y - rocket.position.y + screenY/2, objs.get(o).position.x - rocket.position.x + screenX/2, objs.get(o).position.y - rocket.position.y + screenY/2);
					noStroke();
				}
			}
			
		}
		
		// apply a force on every other object after
		for (int o = i + 1; o < objs.size(); o++) {
			
			// if < 250 pixels
			if (distSq(objs.get(i).position.x - objs.get(o).position.x, objs.get(i).position.y - objs.get(o).position.y) < 62500) {
				objs.get(o).applyGravity(objs.get(i));
				
				if (showG) {
					stroke(0, 255, 0);
					line(objs.get(i).position.x - rocket.position.x + screenX/2, objs.get(i).position.y - rocket.position.y + screenY/2, objs.get(o).position.x - rocket.position.x + screenX/2, objs.get(o).position.y - rocket.position.y + screenY/2);
					noStroke();
				}
				
			}
		}
	}
	
	
	// then update yourself
	for (int i = 0; i < objs.size(); i++) {
		objs.get(i).update();
	}
	
	
}

void loadBodies() {
	
	starName = 0;
	
	planetName = 0;
	
	objs.clear();
	
	rocket.velocity = new Vector(0, 0);
	
	int systems = 50;
	
	int nums = 14;
	
	int spacing = 2 * boundsX/nums;
	
	for (int i = 0; i < nums; i++) {
		for (int j = 0; j < nums; j++) {
			int rand = round(random(0, 13));
			
			if (rand == 0 || rand == 4) {
				// add a cluster of planets
				addBinary2(-boundsX + (i * spacing) + (spacing/2) + random(-100, 100), -boundsY + (j * spacing) + (spacing/2) + random(-100, 100));
			}
			
			if (rand == 1) {
				addSystem(-boundsX + (i * spacing) + (spacing/2) + random(-100, 100), -boundsY + (j * spacing) + (spacing/2) + random(-100, 100));
			}
			
			if (rand == 2) {
				addBinary(-boundsX + (i * spacing) + (spacing/2) + random(-100, 100), -boundsY + (j * spacing) + (spacing/2) + random(-100, 100));
			}
			
			if (rand == 3) {
				addStar(-boundsX + (i * spacing) + (spacing/2) + random(-100, 100), -boundsY + (j * spacing) + (spacing/2) + random(-100, 100));
			}
		}
	}
}




int tileSize = 100;

int firstX = 0;
int firstY = 0;
int lastX = 0;
int lastY = 0;


void drawSimulation() {

	
	////////// draw the bondaries
	
	stroke(255, 255, 255);
	line(-boundsX, -boundsY, boundsX, -boundsY);
	line(-boundsX, boundsY, boundsX, boundsY);
	line(-boundsX, -boundsY, -boundsX, boundsY);
	line(boundsX, -boundsY, boundsX, boundsY);
	noStroke();
	fill(255, 255, 255);
	
	//// left side
	pushMatrix();
		translate(-boundsX, -boundsY);
		rotate(PI/2);
		text("The Universe is flat.", 100, 100);
	popMatrix();
	
	
	pushMatrix();
		translate(-boundsX, boundsY);
		rotate(PI/2);
		text("The Universe is flat.", -100, 100);
	popMatrix();
	
	////// right side
	pushMatrix();
		translate(boundsX, boundsY);
		rotate(-PI/2);
		text("The Universe is flat.", 100, 100);
	popMatrix();
	

	pushMatrix();
		translate(boundsX, -boundsY);
		rotate(-PI/2);
		text("The Universe is flat.", -100, 100);
	popMatrix();
	
	//// top
	pushMatrix();
		translate(-boundsX, -boundsY);
		rotate(0);
		text("The Universe is flat.", 100, -100);
	popMatrix();
	
	pushMatrix();
		translate(boundsX, -boundsY);
		rotate(0);
		text("The Universe is flat.", -100, -100);
	popMatrix();
	
	
	
	//// bottom
	pushMatrix();
		translate(-boundsX, boundsY);
		rotate(0);
		text("The Universe is flat.", 100, 100);
	popMatrix();
	
	pushMatrix();
		translate(boundsX, boundsY);
		rotate(0);
		text("The Universe is flat.", -100, 100);
	popMatrix();
	
	for (int i = 0; i < objs.size(); i++) {
		objs.get(i).draw();
	}
	
	rocket.draw();
}

class Panel {
	
}

int mapX = 750;
int mapY = 450;

int mapSizeX = 100;
int mapSizeY = 100;

void debug() {
	noStroke();
	fill(50, 50, 50, 150);
	rect(30, 30, 100, 150);
	fill(0, 255, 0);
	text("\nframerate: " + round(frameRate) + "\nbodies: " + objs.size() + "\nv_x: " + round(rocket.velocity.x * 100)/100.0 + "\nv_y: " + round(rocket.velocity.y * 100)/100.0, 40, 30);
	/*
	for (int i = 0; i < objs.size(); i++) {
		fill(255, 255, 255, 50);
		rect((i * 120) + 20, 200, 100, 80);
		fill(255, 255, 0);
		text("(" + round(objs.get(i).position.x) + ", " + round(objs.get(i).position.y) + ")" + "\nv_x: " + round(objs.get(i).velocity.x * 100)/100.0 + "\nv_y: " + round(objs.get(i).velocity.y * 100)/100.0 + "\nmass: " + objs.get(i).mass, i * (120) + 30, 220);
	}
	
	fill(255, 255, 255, 50);
	rect(30, 280, 80, 150);
	fill(0, 255, 0);
	text("x: " + (round(rocket.position.x)/1) + "\ny: " + (round(rocket.position.y * 1)/1)
		+ "\nv_x: " + round(rocket.velocity.x * 100)/100 + "\nv_y: " + round(rocket.velocity.y * 100)/100 + "\nalpha: " + rocket.alpha, 40, 310);*/
	
	fill(0, 255, 0);
	noStroke();
	text("r = reload simulation\nm = show/hide map\ng = show/hide gravity interactions\nshift = add solar system\nclick = add binary star system\nshift + space + flick mouse = shooting star\nspace + flick mouse = flying planet", 40, 480);
	
	fill(255, 0, 0);
	if (abs(abs(rocket.position.x) - abs(boundsX)) < 500 || abs(abs(rocket.position.y) - abs(boundsY)) < 500) {
		fill(255, 0, 0);
		textAlign(CENTER);
		text("YOU ARE LEAVING THE BOUNDARY OF THE KNOWN UNIVERSE.", 450, 450);
		fill(255, 255, 255);
		text("\n\nThe Universe is flat.", 450, 450);
		textAlign(LEFT);
	}
	
	if (showM) {
		fill(150, 150, 150, 80);
		rect(mapX, mapY, mapSizeX, mapSizeY);
		for (int i = 0; i < objs.size(); i++) {
			if (objs.get(i).typeObj.equals("star")) {
				stroke(objs.get(i).col.r, objs.get(i).col.g, objs.get(i).col.b);
				strokeWeight(2);
				point(mapX + objs.get(i).position.x/(boundsX * 2) * mapSizeX + mapSizeX/2, mapY + objs.get(i).position.y/(boundsY * 2) * mapSizeY + mapSizeY/2);
				
				
				// text("d" + objs.get(i).typeObj, mapX + objs.get(i).position.x/(boundsX * 2) * mapSizeX + mapSizeX/2, mapY + objs.get(i).position.y/(boundsY * 2) * mapSizeY + mapSizeY/2);
				noStroke();
			} else {
				stroke(objs.get(i).col.r, objs.get(i).col.g, objs.get(i).col.b);
				strokeWeight(1);
				point(mapX + objs.get(i).position.x/(boundsX * 2) * mapSizeX + mapSizeX/2, mapY + objs.get(i).position.y/(boundsY * 2) * mapSizeY + mapSizeY/2);
				
				fill(255, 0, 0);
				noStroke();
			}
			strokeWeight(1);
			noStroke();
		}
		
		fill(255, 0, 0);
		ellipse(mapX + rocket.position.x/(boundsX * 2) * mapSizeX + mapSizeX/2, mapY + rocket.position.y/(boundsY * 2) * mapSizeY + mapSizeY/2, 2, 2);
	}
	
	textAlign(RIGHT);
	fill(0, 255, 0);
	text("by Scott Wang", 850, 570);
	textAlign(LEFT);
	
}


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

void draw() {
	background(0, 0, 0);
	noStroke();
	
	
	textFont(createFont("monaco", 10));
	
	updateKeys();
	
	mouse.check();
	
	addingStars();
	
	updateSimulation();
	
	rocket.update();
	
	
	pushMatrix();
		translate(-rocket.position.x + screenX/2, -rocket.position.y + screenY/2);
		drawSimulation();
	popMatrix();
	
	
	
	debug();
	
	mouse.draw();
}