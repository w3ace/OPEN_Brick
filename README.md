# OPEN Brick

An OpenSCAD library for constructing 3D-printable, LEGO-compatible rectangular
and curved bricks. Foundation came from a brick builder written by Jorg Janssen in
2013 (CC BY-NC 3.0); curved-brick features were added by Craig Wood in 2018.

> **Fit note:** the dimensions in `_conf.scad` are useful starting points, but
> printer, material, and slicer tolerances vary. Print a small test before a
> large assembly and tune `CORRECTION`, wall thickness, or hole radii as needed.

## Quick start

Use `BrickBuilder.scad` as an example entry point, or create a small `.scad`
file alongside the library:

```scad
$fn = 0;
$fa = $preview ? 12 : 4;
$fs = $preview ? 1 : 0.4;

include <_conf.scad>;
include <RectBrickBuilder.scad>;
include <RoundBrickBuilder.scad>;

rectBrick(length=4, width=2, height=3, studstyle=1);

translate([48, 0, 0])
    roundBrick(
        outer_radius=4,
        inner_radius=2,
        reduce=0,
        height=3,
        degrees_start=0,
        degrees_end=90,
        attributes=[["window", 1], ["chamfer", 1]]
    );
```

All horizontal dimensions are based on an 8 mm stud pitch. `height` is measured
in plate units: `height=1` is a plate and `height=3` is a conventional brick.

## How the blocks are constructed

### Rectangular bricks

`rectBrick()` builds a brick in three stages:

1. **Shell:** `makeShell()` creates the outside cuboid, subtracts the lower
   cavity to leave the configured wall thickness, and opens holes beneath any
   top studs.
2. **Top connection:** `makeStuds()` places one stud at every grid position.
   Its `studstyle` selects solid, partly hollow, Technic-style, or bottom-cutting
   cylinders.
3. **Bottom connection and support:** `antistuds()` adds pins to one-stud-wide
   bricks, or hollow anti-stud tubes to wider bricks. Thin ribs connect those
   features to the walls so the underside remains printable and rigid.

```scad
rectBrick(length=4, width=2, height=3, studstyle=1);
```

| Parameter | Default | Effect |
| --- | ---: | --- |
| `length` | `4` | Brick length in stud pitches. |
| `width` | `2` | Brick width in stud pitches. |
| `height` | `3` | Height in plate units. |
| `studstyle` | `1` | `0`: no top studs; `1`: solid studs; `2`: half-depth hollow studs; `3`: through-hole/Technic studs. Style `4` is an internal cutting style used to form underside openings, not a normal top style. |

### Round and arc bricks

`roundBrick()` starts with a 2D radial cross-section and revolves it from
`degrees_start` to `degrees_end`. It then adds a hollow lower carriage and end
walls for partial arcs, places top studs on grid points that fall inside the
annulus, adds hollow anti-stud tubes below, and trims the inner/outer faces.
Finally, enabled attributes subtract openings or material; the `link` attribute
then unions a rectangular brick across the arc.

Positive `reduce` values slope inward toward a narrower top. Negative values
pull the lower outer edge inward, producing a flared profile and clipping the
underside anti-stud tubes to that reduced footprint. The `corbels`
attributes turn that flare into regularly spaced corbels by subtracting the
spaces between them.

| Parameter | Default | Effect |
| --- | ---: | --- |
| `outer_radius` | `2` | Outer radius in stud pitches. |
| `inner_radius` | `1` | Inner radius in stud pitches; use `0` for a solid center. Must be smaller than `outer_radius`. |
| `reduce` | `0` | `0` gives a vertical wall, positive values narrow the top, and negative values inset the lower outer profile. Keep its magnitude below the annulus width. |
| `height` | `3` | Height in plate units. |
| `degrees_start` | `10` | Starting angle of the arc, in degrees. Normally set this explicitly (often `0`). |
| `degrees_end` | `360` | Ending angle; arc sweep is `degrees_end - degrees_start`. |
| `attributes` | `[]` | List of `[name, value]` pairs described below. Omitted options use their disabled/default value. |

## Round-brick attributes

Attributes are passed as a list. Names are case-sensitive, unknown names are
ignored, and the first occurrence of a duplicate name wins.

```scad
attributes = [
    ["flattop", 0],
    ["thinwall", 1],
    ["window", 0],
    ["chamfer", 1],
    ["archway", 0],
    ["link", 0],
    ["corbels", 1],
    ["corbel_spacing", 30],
    ["corbel_width", 12],
    ["corbel_phase", 6]
];
```

| Attribute | Values and effect |
| --- | --- |
| `flattop` | `0` (default) keeps normal top studs. Any nonzero value omits them for a smooth top. |
| `thinwall` | `0` disables it. A positive value hollows most of the upper annular body, leaving a thin printable skin and solid material near the arc ends. The current implementation treats all positive values alike. |
| `window` | `0` disables it. A positive value cuts one centered pointed/cathedral window through the radial wall. The current implementation treats all positive values alike. |
| `chamfer` | `0` disables it. A positive value clips all four vertical corners at the start and end faces. The current implementation treats all positive values alike. |
| `archway` | `0` disables it. A positive angle (typically about `15`) cuts a centered, tapered arch through the brick. The angle changes the opening width and vertical scale; values near `0` are invalid because the scale divides by this value. This feature requires `inner_radius > 1`. |
| `link` | `0` disables it. A positive integer adds a two-stud-wide rectangular brick of that many studs across the curved piece, while removing the overlap first. |
| `corbels` | `0` disables them. With `reduce < 0`, a positive value creates corbels beneath the upper wall and sets their vertical depth in plate units. |
| `corbel_spacing` | Angular distance between repeating corbels, in degrees. Defaults to `30` and must be positive. |
| `corbel_width` | Angular width of each corbel, in degrees. Defaults to `12`; it must be smaller than `corbel_spacing`. |
| `corbel_phase` | Angular start of the first space between corbels, in degrees. Defaults to `6`, allowing the pattern to be aligned with an arc. |

For example, this makes a quarter-round wall with 12-degree corbels on a
30-degree pattern:

```scad
roundBrick(
    outer_radius=7,
    inner_radius=5,
    reduce=-1,
    height=3,
    degrees_start=0,
    degrees_end=90,
    attributes=[
        ["corbels", 1],
        ["corbel_spacing", 30],
        ["corbel_width", 12]
    ]
);
```

The former `supports` argument remains available as a deprecated fallback for
`corbels`, so existing models continue to render.

Attributes affect only `roundBrick()`; rectangular bricks use `studstyle`
instead.

## Dimension and print tuning

`_conf.scad` contains the shared physical constants:

- `FLU`, `BRICK_WIDTH`, `BRICK_HEIGHT`, and `PLATE_HEIGHT` set the base scale.
- `WALL_THICKNESS`, `STUD_RADIUS`, `STUD_HEIGHT`, `ANTI_STUD_RADIUS`, and
  `PIN_RADIUS` control the mating geometry.
- `SUPPORT_THICKNESS` controls the underside ribs in rectangular bricks.
- `EDGE` forms the small lower edge detail.
- `CORRECTION` adds overlap to boolean operations and compensates for fit.

Changing these constants changes every brick generated by the library. Keep a
backup of the defaults and validate mating parts after tuning them.

## Performance

The example entry points use OpenSCAD's size-aware `$fa`/`$fs` tessellation
instead of forcing the same large `$fn` onto every curve. Preview mode uses a
coarser mesh (`$fa=12`, `$fs=1`) for interactive work; F6 render/export uses
`$fa=4`, `$fs=0.4` for smoother output. Increase `$fa` or `$fs` for a faster,
coarser export, and decrease them only when a finer surface is needed.

The round builder also resolves each named attribute once and batches the
anti-stud tube booleans, keeping its CSG tree smaller. For the fastest workflow,
preview simple geometry first, enable expensive windows/arches last, and render
only the final configuration.
