thickness = 1.6;
panel_height = 128.5;
width_1hp = 5.08; // 5.08 == 0.2" (from the HP spec)
wiggle_room_width = 0.3; // so modules don't fit too tightly

hole_width = 5;
hole_diameter = 3.2;
hole_height_edge = 3; // distance from hole center to panel edge
hole_width_edge = 7.5; // distance from hole center to panel edge

button_width = 10;
button_height = 6;

jack_width = 9;
jack_height = 10.5;


// increase resolution of the cylinders
$fs = 0.1;

module_name = "eduquencer";
hp = 14; // [2:16]

button_rows = 4; // [1:4]
jack_rows = 2; // [1:4]

button_cols = 6; // [2:8]
jack_cols = 4; // [1:5]


group() {
  face_plate(hp);
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
      hole_width_edge - button_width / 2,
      hp * width_1hp - hole_width_edge + button_width / 2,
      panel_height / 2,
      panel_height - hole_height_edge - 6,
      button_cols,
      button_rows
  );
  jacks(
    hole_width_edge - button_width / 2,
    hp * width_1hp - hole_width_edge + button_width / 2,
    hole_height_edge + 6,
    panel_height / 2 - 6,
    jack_cols,
    jack_rows
  );
}

module buttons(x_low, x_high, y_low, y_high, cols, rows) {
  w = x_high - x_low;
  h = y_high - y_low;

  row_step = (
    rows == 1 ?
    (h - button_height) :
    (h - rows * button_height) / (rows - 1)
  );
  col_step = (w - cols * button_width) / (cols - 1);

  for(r=[0:rows - 1])
    for(c=[0:cols - 1])
      translate([
        x_low + button_width / 2 + c * (col_step + button_width),
        y_high - button_height / 2 - r * (row_step + button_height),
        0
      ])
        button();
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
    (h - rows * jack_height) / (rows - 1)
  );
  col_step = (w - cols * jack_width) / (cols - 1);

  for(r=[0:rows - 1])
    for(c=[0:cols - 1])
      translate([
        x_low + jack_width / 2 + c * (col_step + jack_width),
        y_high - jack_height / 2 - r * (row_step + jack_height),
        0
      ])
        jack();
}

module button() {
    translate([-5, 3, 0])
      rotate([90, 0, 0])
        color("grey")
        import("CUI_DEVICES_TS04-66-73-BK-100-SMT.STL");
}

module jack() {
  color("grey")
  import("WQP-PJ398SM.amf");
}

module face_plate(hp) {
  width = (width_1hp * hp) - wiggle_room_width;

  difference() {
    rotate([-90, 0, 0])
      translate([0, 0, 0])
        color("pink")
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
