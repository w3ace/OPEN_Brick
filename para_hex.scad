inch = 25.4;

base_d = (5+1/4) * inch;
base_h = 0.4 * inch;
base_q = 5;

post_d = (1+1/2) * inch;
post_h = 12 * inch;
post_q = 3;

module base() 
{
    linear_extrude(height = base_h, twist = 10, scale = 0.9) 
    polygon([
        for (i = [0 : 359])
        [
            sin(i) * (base_d / 2 + base_q * sin(7 * i)),
            cos(i) * (base_d / 2 + base_q * sin(8 * i))
        ]
    ]);
}

module post()
{
  translate([0, 0, base_h]) 
    linear_extrude(height = post_h, twist = 180, scale = 1) 
    polygon([
        for (i = [0 : 359])
        [
            sin(i) * (post_d / 2 + post_q * sin(5 * i)),
            cos(i) * (post_d / 2 + post_q * sin(7 * i))
        ]
    ]);
}

module cap() {
  r = 1.2*post_d;
  translate([0, 0, post_h])
  difference()
  {
    cube([r, r, r/2], center=true);
    translate([0,0,-r/4])
    sphere(r/2);
  }
}

base();
difference() {
  post();
  cap();
}