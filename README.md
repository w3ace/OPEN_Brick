# Enhanced Lego Brick Builder 

## OpenSCAD 3d object builder


## Originally written by Jorg Janssen 2013 (CC BY-NC 3.0) 
## New Features Added by Craig Wood 2018 

### New Features Implemented ()
* Cone shape inside bricks to make them printable without removeable printed supports.

### Additional Features to come
 * Customizeable support structure inside (low, med, high)
 * Different Stud Types

## Performance

`BrickBuilder.scad` now uses OpenSCAD's size-aware `$fa`/`$fs` tessellation
instead of forcing 150 facets onto every curved object. Preview mode uses a
coarser mesh (`$fa = 12`, `$fs = 1`) for interactive editing; an F6 render or
export automatically uses `$fa = 4`, `$fs = 0.4` for a smoother result.

For faster iteration in your own entry-point file, use the same pattern rather
than setting a large global `$fn`:

```scad
$fn = 0;
$fa = $preview ? 12 : 4;
$fs = $preview ? 1 : 0.4;

include <_conf.scad>;
include <RectBrickBuilder.scad>;
include <RoundBrickBuilder.scad>;
```

Increase `$fa` or `$fs` for a faster, coarser export; decrease them only when a
finer surface is required. A fixed `$fn` remains supported if you explicitly
want every cylinder and revolved surface to have the same facet count.

