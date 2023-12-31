thickness = 1.6;
panel_height = 128.5;
width_1hp = 5.08; // 5.08 == 0.2" (from the HP spec)
wiggle_room_width = 0.3; // so modules don't fit too tightly

hole_width = 5;
hole_diameter = 3.2;
hole_height_edge = 3; // distance from hole center to panel edge
hole_width_edge = 7.5; // distance from hole center to panel edge

outline_width = 0.4;

button_width = 10;
button_height = 6;

jack_width = 9;
jack_height = 10.5;

pot_width = 12;
pot_height = 11.35;

// increase resolution of the cylinders
$fs = 0.1;

module_name = "eduquencer";
hp = 14; // [2:16]

button_rows = 4; // [1:4]
jack_rows = 2; // [1:4]

button_cols = 4; // [2:8]
jack_cols = 4; // [1:5]

jack_start = hole_width_edge - jack_width / 2;
panel_width = hp * width_1hp;

// projection()
  group() {
    difference() {
      face_plate(hp);
      translate([0, 0, -thickness - 0.5])
        linear_extrude(height=thickness + 1, center=false)
          group() {
            translate([
              (hp * width_1hp / 2),
              panel_height - hole_height_edge
            ])
              color("yellow")
              text(
                module_name,
                font="Liberation Sans Narrow",
                size=3,
                halign="center",
                valign="center"
              );
            buttons(
                hole_width_edge,
                hp * width_1hp - hole_width_edge,
                panel_height / 2 + 12,
                panel_height - hole_height_edge - 12,
                button_cols,
                button_rows
            );
            translate([0, panel_height / 2 - 1, 0])
              group() {
                translate([
                  hole_width_edge +
                  1 * (jack_width + (
                    panel_width - 2 * hole_width_edge - 6 * jack_width
                  ) / 6),
                  0,
                  0
                ])
                  group() {
                    pot();
                    translate([0, -(pot_height / 2 + jack_height / 2 + 6), 0])
                      jack();
                  }
                translate([hp * width_1hp / 2, 0, 0])
                  group() {
                    translate([0, -(pot_height / 2 + jack_height / 2 + 6), 0])
                      jack();
                  }
                translate([
                  hole_width_edge +
                  5 * (jack_width + (
                    panel_width - 2 * hole_width_edge - 6 * jack_width
                  ) / 6),
                  0,
                  0
                ])
                  group() {
                    pot();
                    translate([0, -(pot_height / 2 + jack_height / 2 + 6), 0])
                      jack();
                  }
              }

            jacks(
              hole_width_edge - 0.5,
              panel_width - hole_width_edge - 0.5,
              hole_height_edge + 10,
              panel_height / 2 - jack_height - pot_height - 14,
              jack_cols,
              jack_rows
            );
          }
    }
  }

module buttons(x_low, x_high, y_low, y_high, cols, rows) {
  w = x_high - x_low;
  h = y_high - y_low;

  row_step = (
    rows == 1 ?
    (h - button_height) :
    (h - (rows - 1) * button_height) / (rows - 1)
  );
  col_step = (w - (cols - 1) * button_width) / (cols - 1);

  for(r=[0:rows - 1])
    for(c=[0:cols - 1]) {
      n = (r * cols + c);

      translate([
        x_low + c * (col_step + button_width),
        y_high - r * (row_step + button_height),
        0
      ])
        group() {
          rotate(n > 7 ? 45 : -45)
            button();
          translate([button_width / 2 - 3.1, button_height / 2 + 1, 0])
            color((n < 8 && n % 3 == 0) || n % 13 == 0 ? "#f9ba4d" : "#85c4a0")
            rotate(-45)
            square([3,2]);
          translate([-button_width / 2, button_height / 2, 0])
            color("yellow")
            text(
              str(1 + n % 8),
              font="Liberation Sans Narrow",
              size=3,
              halign="left"
            );
        }
    }
}

module jacks(
  x_low,
  x_high,
  y_low,
  y_high,
  cols,
  rows
) {
  w = x_high - x_low;
  h = y_high - y_low;

  row_step = (
    rows == 1 ?
    (h - jack_height) :
    (h - (rows - 1) * jack_height) / (rows - 1)
  );
  col_step = (w - (cols - 1) * jack_width) / (cols - 1);

  for(r=[0:rows - 1])
    for(c=[0:cols - 1])
      translate([
        x_low + c * (col_step + jack_width),
        y_high - r * (row_step + jack_height),
        0
      ])
        group() {
          rotate(-45)
            jack();
          translate([-jack_width / 2, jack_height / 2, 0])
            color("yellow")
            text(
              str(1 + (r * cols + c) % 8),
              font="Liberation Sans Narrow",
              size=3,
              halign="left"
            );
        }
}

_p_d_top = -6.4;
_p_d_bot = +4.75;
_p_w = 9.4;

module pot() {
  // color([0,0,0,0.2])
  // import("RD901F-40-15R1.amf");
  color("yellow")
  group() {
    circle(r=0.8);
    polygon(points=[
      [-_p_w / 2, _p_d_top],
      [-_p_w / 2, _p_d_bot],
      [+_p_w / 2, _p_d_bot],
      [+_p_w / 2, _p_d_top],

      [-_p_w / 2 + outline_width, _p_d_top + outline_width],
      [-_p_w / 2 + outline_width, _p_d_bot - outline_width],
      [+_p_w / 2 - outline_width, _p_d_bot - outline_width],
      [+_p_w / 2 - outline_width, _p_d_top + outline_width],
    ], paths=[[0,1,2,3], [4,5,6,7]]);
  }
}

module button() {
  color("yellow")
  circle(0.8);
  square([button_height, outline_width], center=true);
  translate([-button_height / 2, -button_width / 2 + 2, 0])
    group() {
      difference() {
        square([button_height, button_height]);
        translate([outline_width / 2, outline_width / 2, 0])
          square([button_height - outline_width, button_height - outline_width]);
      }
    }
  // translate([-5, 3, 0])
  //   rotate([90, 0, 0])
  //   color([0,0,0,0.2])
  //   import("CUI_DEVICES_TS04-66-73-BK-100-SMT.STL");
}

_j_d_top = -4.5;
_j_d_bot = 6;

module jack() {
  group() {
    // color([0,0,0,0.2])
    // import("WQP-PJ398SM.amf");
    color("yellow")
    union() {
      circle(r=0.8);
      polygon(points=[
        [-jack_width / 2, _j_d_top],
        [-jack_width / 2, _j_d_bot],
        [+jack_width / 2, _j_d_bot],
        [+jack_width / 2, _j_d_top],

        [-jack_width / 2 + outline_width, _j_d_top + outline_width],
        [-jack_width / 2 + outline_width, _j_d_bot - outline_width],
        [+jack_width / 2 - outline_width, _j_d_bot - outline_width],
        [+jack_width / 2 - outline_width, _j_d_top + outline_width],
      ], paths=[[0,1,2,3], [4,5,6,7]]);
      // polygon(points=[
      //   [-outline_width / 2, -jack_height / 2 - 1.3],
      //   [-outline_width / 2, +jack_height / 2 + 0.8],
      //   [+outline_width / 2, +jack_height / 2 + 0.8],
      //   [+outline_width / 2, -jack_height / 2 - 1.3],

      //   [-jack_width / 2, -outline_width / 2],
      //   [-jack_width / 2, +outline_width / 2],
      //   [+jack_width / 2, +outline_width / 2],
      //   [+jack_width / 2, -outline_width / 2],
      // ], paths=[[0,1,2,3], [4,5,6,7]]);
    }
  }
}

module face_plate(hp) {
  width = (width_1hp * hp) - wiggle_room_width;

  difference() {
    rotate([-90, 0, 0])
      translate([0, 0, 0])
        color("purple")
        cube([width, thickness, panel_height]);
    mounting_holes(width);
  }
}

module hole_in_face_plate(diameter) {
  // The -0.5 and 1.0 ensure we're
  // cutting all the way through the panel
  translate([0, 0, -0.5 - thickness])
    cylinder(d=diameter, h=thickness + 1.0);
}

module mounting_hole(diameter, width) {
  spacing = (width - diameter) / 2;
  union() {
    translate([-spacing, 0, 0])
      hole_in_face_plate(diameter);

    translate([spacing, 0, 0])
      hole_in_face_plate(diameter);

    // The -0.5 and 1.0 ensure we're
    // cutting all the way through the panel
    translate([-spacing, -diameter/2, -0.5 - thickness])
      cube([width - diameter, diameter, thickness + 1.0]);
  }
}

module rpi() {
  translate([-25, -11.5])
    color("green")
    square([50, 23]);
}

module mounting_holes (panel_width) {
  // top left
  translate([hole_width_edge, panel_height - hole_height_edge, 0]) {
    mounting_hole(hole_diameter, hole_width);
  }

  // bottom left
  translate([hole_width_edge, hole_height_edge, 0]) {
    mounting_hole(hole_diameter, hole_width);
  }

  // top right
  translate([panel_width - hole_width_edge, panel_height - hole_height_edge, 0]) {
    mounting_hole(hole_diameter, hole_width);
  }

  // bottom right
  translate([panel_width - hole_width_edge, hole_height_edge, 0 ]) {
    mounting_hole(hole_diameter, hole_width);
  }
}
