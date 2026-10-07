#!/usr/bin/env python3
"""Generate the One Step Ahead Icon Composer bundle (AppIcon.icon).

Layers (back to front):
  grid.png      flat blueprint grid, radial alpha falloff
  handle.svg    brush handle with hanging hole        (glass)
  bristles.svg  brush head below the paint line       (glass)
  paint.svg     gold paint loaded on the tip          (glass)
  ferrule.svg   metal band overlapping handle + head  (glass)

All brush geometry is designed upright in a local space centred on the
origin (negative y = toward the tip) and then rotated 45 degrees so the
head points to the top-right like the original icon.
"""
import json
import math
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter

OUT = sys.argv[1] if len(sys.argv) > 1 else "AppIcon.icon"
ASSETS = os.path.join(OUT, "Assets")
os.makedirs(ASSETS, exist_ok=True)

CANVAS = 1024
CX = CY = CANVAS / 2
ANGLE = math.radians(45)

# ---------------------------------------------------------------- colours
# Display P3 components for icon.json, sRGB hex for the SVG artwork itself.
COL = {
    "bg_top": (0.075, 0.215, 0.470),
    "bg_bottom": (0.020, 0.060, 0.190),
    "handle": (0.160, 0.600, 1.000),
    "ferrule": (0.880, 0.975, 1.000),
    "bristles": (0.000, 0.920, 1.000),
    "paint": (1.000, 0.790, 0.260),
    "grid": (0.000, 0.880, 1.000),
}


def p3(c, a=1.0):
    return "display-p3:%.5f,%.5f,%.5f,%.5f" % (c[0], c[1], c[2], a)


def hexcol(c):
    return "#%02X%02X%02X" % tuple(int(round(v * 255)) for v in c)


# ---------------------------------------------------------------- geometry
def rotate(pt):
    x, y = pt
    return (CX + x * math.cos(ANGLE) - y * math.sin(ANGLE),
            CY + x * math.sin(ANGLE) + y * math.cos(ANGLE))


def rounded_path(pts):
    """pts: list of (x, y, r) in local space -> SVG path (canvas space)."""
    n = len(pts)
    segs = []
    for i in range(n):
        x, y, r = pts[i]
        px, py, _ = pts[i - 1]
        nx, ny, _ = pts[(i + 1) % n]
        v1 = (px - x, py - y)
        v2 = (nx - x, ny - y)
        l1 = math.hypot(*v1)
        l2 = math.hypot(*v2)
        if r <= 0 or l1 == 0 or l2 == 0:
            segs.append(("pt", (x, y)))
            continue
        u1 = (v1[0] / l1, v1[1] / l1)
        u2 = (v2[0] / l2, v2[1] / l2)
        cos_t = max(-1.0, min(1.0, u1[0] * u2[0] + u1[1] * u2[1]))
        theta = math.acos(cos_t)
        if theta < 1e-6 or abs(theta - math.pi) < 1e-6:
            segs.append(("pt", (x, y)))
            continue
        t = r / math.tan(theta / 2)
        t = min(t, l1 / 2, l2 / 2)
        r_eff = t * math.tan(theta / 2)
        p_in = (x + u1[0] * t, y + u1[1] * t)
        p_out = (x + u2[0] * t, y + u2[1] * t)
        cross = u1[0] * u2[1] - u1[1] * u2[0]
        sweep = 1 if cross < 0 else 0
        segs.append(("arc", p_in, p_out, r_eff, sweep))

    d = []
    for i, s in enumerate(segs):
        if s[0] == "pt":
            X, Y = rotate(s[1])
            d.append(("M" if i == 0 else "L") + " %.2f %.2f" % (X, Y))
        else:
            _, p_in, p_out, r_eff, sweep = s
            X1, Y1 = rotate(p_in)
            X2, Y2 = rotate(p_out)
            d.append(("M" if i == 0 else "L") + " %.2f %.2f" % (X1, Y1))
            d.append("A %.2f %.2f 0 0 %d %.2f %.2f" % (r_eff, r_eff, sweep, X2, Y2))
    d.append("Z")
    return " ".join(d)


def bezier(p0, p1, p2, p3, n):
    out = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1]
        out.append((x, y))
    return out


def catmull_rom(points, per_seg=12):
    """Smooth open spline through points (endpoints duplicated)."""
    pts = [points[0]] + list(points) + [points[-1]]
    out = []
    for i in range(1, len(pts) - 2):
        p0, p1, p2, p3 = pts[i - 1], pts[i], pts[i + 1], pts[i + 2]
        for j in range(per_seg):
            t = j / per_seg
            t2, t3 = t * t, t * t * t
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
            out.append((x, y))
    out.append(points[-1])
    return out


# Brush dimensions (local space, points)
TIP_Y = -392          # bristle tip
TIP_HALF = 132        # half width at the tip
BASE_Y = -150         # bristle base (hidden inside ferrule)
BASE_HALF = 114
TIP_BULGE = 12        # convex tip
TIP_R = 26
FERRULE_TOP, FERRULE_BOTTOM, FERRULE_HALF, FERRULE_R = -172, -60, 118, 16
HANDLE_TOP = -80
CAP_Y, CAP_R = 314, 78
HOLE_Y, HOLE_R = 300, 26
PAINT_LEFT_Y, PAINT_RIGHT_Y = -290, -310


def side_x(y, sign):
    """x on the bristle side line at height y (sign = +1 right, -1 left)."""
    f = (BASE_Y - y) / (BASE_Y - TIP_Y)
    return sign * (BASE_HALF + (TIP_HALF - BASE_HALF) * f)


def tip_points():
    """Convex tip edge from left corner to right corner (exclusive)."""
    pts = []
    n = 10
    for i in range(1, n):
        t = i / n
        x = -TIP_HALF + 2 * TIP_HALF * t
        y = TIP_Y - TIP_BULGE * math.sin(math.pi * t)
        pts.append((x, y, 0))
    return pts


def wavy_points(shift=0.0):
    """Paint boundary from the left junction to the right junction."""
    xl = side_x(PAINT_LEFT_Y, -1)
    xr = side_x(PAINT_RIGHT_Y, +1)
    ctrl = [
        (xl, PAINT_LEFT_Y),
        (xl * 0.55, -266),
        (-4, -322),
        (xr * 0.50, -262),
        (xr, PAINT_RIGHT_Y),
    ]
    pts = catmull_rom(ctrl, per_seg=14)
    out = []
    for (x, y) in pts:
        y2 = y + shift
        out.append((x, y2, 0))
    # keep the junctions exactly on the side lines
    out[0] = (side_x(out[0][1], -1), out[0][1], 0)
    out[-1] = (side_x(out[-1][1], +1), out[-1][1], 0)
    return out


def handle_paths():
    right = bezier((60, HANDLE_TOP), (44, 20), (CAP_R, 230), (CAP_R, CAP_Y), 36)
    cap = [(CAP_R * math.cos(a), CAP_Y + CAP_R * math.sin(a))
           for a in [math.pi * i / 36 for i in range(1, 36)]]
    left = [(-x, y) for (x, y) in reversed(right)]
    pts = [(right[0][0], right[0][1], 10)]
    pts += [(x, y, 0) for (x, y) in right[1:]]
    pts += [(x, y, 0) for (x, y) in cap]
    pts += [(x, y, 0) for (x, y) in left[:-1]]
    pts.append((left[-1][0], left[-1][1], 10))
    outer = rounded_path(pts)
    # hole, counter-clockwise so it reads as a hole under either fill rule
    hole = [(HOLE_R * math.cos(-a), HOLE_Y + HOLE_R * math.sin(-a), 0)
            for a in [2 * math.pi * i / 48 for i in range(48)]]
    return outer + " " + rounded_path(hole)


def ferrule_path():
    pts = [(-FERRULE_HALF, FERRULE_TOP, FERRULE_R), (FERRULE_HALF, FERRULE_TOP, FERRULE_R),
           (FERRULE_HALF, FERRULE_BOTTOM, FERRULE_R), (-FERRULE_HALF, FERRULE_BOTTOM, FERRULE_R)]
    return rounded_path(pts)


def paint_path():
    wave = wavy_points(0.0)
    pts = [(-TIP_HALF, TIP_Y, TIP_R)] + tip_points() + [(TIP_HALF, TIP_Y, TIP_R)]
    pts += [(wave[-1][0], wave[-1][1], 6)]
    pts += list(reversed(wave[1:-1]))
    pts += [(wave[0][0], wave[0][1], 6)]
    return rounded_path(pts)


def bristles_path():
    wave = wavy_points(-2.0)  # tucked 2pt under the paint to hide the seam
    pts = [(wave[-1][0], wave[-1][1], 0)]
    pts += [(BASE_HALF, BASE_Y, 10), (-BASE_HALF, BASE_Y, 10)]
    pts += [(wave[0][0], wave[0][1], 0)]
    pts += wave[1:-1]
    return rounded_path(pts)


def write_svg(name, d, colour):
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">\n'
           '  <path d="%s" fill="%s" fill-rule="evenodd"/>\n</svg>\n' % (d, hexcol(colour)))
    with open(os.path.join(ASSETS, name), "w") as f:
        f.write(svg)


write_svg("handle.svg", handle_paths(), COL["handle"])
write_svg("ferrule.svg", ferrule_path(), COL["ferrule"])
write_svg("bristles.svg", bristles_path(), COL["bristles"])
write_svg("paint.svg", paint_path(), COL["paint"])


# ---------------------------------------------------------------- grid PNG
def make_grid():
    ss = 4
    size = CANVAS * ss
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    cells = 9
    step = size / cells
    w = 3.0 * ss
    for k in range(1, cells):
        p = k * step
        draw.rectangle([p - w / 2, 0, p + w / 2, size], fill=255)
        draw.rectangle([0, p - w / 2, size, p + w / 2], fill=255)
    img = img.resize((CANVAS, CANVAS), Image.LANCZOS)
    # radial falloff: strong in the centre, faint in the corners
    falloff = Image.new("L", (CANVAS, CANVAS), 0)
    px = falloff.load()
    dmax = math.hypot(CX, CY)
    for y in range(CANVAS):
        for x in range(CANVAS):
            d = math.hypot(x - CX, y - CY) / dmax
            a = 0.34 * (1.0 - 0.78 * d ** 1.4)
            px[x, y] = int(max(0.0, a) * 255)
    alpha = Image.eval(img, lambda v: v)
    alpha = Image.composite(alpha, Image.new("L", (CANVAS, CANVAS), 0), alpha)
    # multiply line mask by falloff
    a_px = alpha.load()
    f_px = falloff.load()
    for y in range(CANVAS):
        for x in range(CANVAS):
            a_px[x, y] = (a_px[x, y] * f_px[x, y]) // 255
    rgb = tuple(int(round(v * 255)) for v in COL["grid"])
    out = Image.new("RGBA", (CANVAS, CANVAS), rgb + (0,))
    out.putalpha(alpha)
    out.save(os.path.join(ASSETS, "grid.png"))


make_grid()

# ---------------------------------------------------------------- icon.json
def layer(name, image, fill, glass=True, extra=None):
    d = {
        "fill": fill,
        "glass": glass,
        "image-name": image,
        "name": name,
        "position": {"scale": 1, "translation-in-points": [0, 0]},
    }
    if extra:
        d.update(extra)
    return d


def group(layers, shadow="neutral", translucency=True, tvalue=0.5, extra=None):
    g = {
        "layers": layers,
        "shadow": {"kind": shadow, "opacity": 0.5},
        "translucency": {"enabled": translucency, "value": tvalue},
    }
    if extra:
        g.update(extra)
    return g


icon = {
    "fill": {"linear-gradient": [p3(COL["bg_top"]), p3(COL["bg_bottom"])]},
    "groups": [
        # Icon Composer draws groups front-to-back in file order (first = top)
        group([layer("Ferrule", "ferrule.svg", {"automatic-gradient": p3(COL["ferrule"])})],
              tvalue=0.35),
        group([layer("Paint", "paint.svg", {"automatic-gradient": p3(COL["paint"])})],
              tvalue=0.3),
        group([layer("Bristles", "bristles.svg", {"automatic-gradient": p3(COL["bristles"])}),
               layer("Handle", "handle.svg", {"automatic-gradient": p3(COL["handle"])})],
              tvalue=0.45, extra={"lighting": "individual"}),
        group([layer("Grid", "grid.png", "none", glass=False)],
              shadow="none", translucency=False, extra={"specular": False}),
    ],
    "supported-platforms": {"circles": ["watchOS"], "squares": "shared"},
}

with open(os.path.join(OUT, "icon.json"), "w") as f:
    json.dump(icon, f, indent=2)
    f.write("\n")

# ---------------------------------------------------------------- flat preview
def preview(path):
    bg = Image.new("RGBA", (CANVAS, CANVAS))
    px = bg.load()
    top, bot = COL["bg_top"], COL["bg_bottom"]
    for y in range(CANVAS):
        t = y / (CANVAS - 1)
        c = tuple(int(round((top[i] * (1 - t) + bot[i] * t) * 255)) for i in range(3)) + (255,)
        for x in range(CANVAS):
            px[x, y] = c
    bg.alpha_composite(Image.open(os.path.join(ASSETS, "grid.png")).convert("RGBA"))
    for name in ["handle.svg", "bristles.svg", "paint.svg", "ferrule.svg"]:
        png = os.path.join(OUT, "..", "preview_" + name + ".png")
        subprocess.run(["rsvg-convert", "-w", str(CANVAS), "-h", str(CANVAS),
                        os.path.join(ASSETS, name), "-o", png], check=True)
        bg.alpha_composite(Image.open(png).convert("RGBA"))
        os.remove(png)
    # superellipse-ish mask so the preview looks like a home-screen icon
    mask = Image.new("L", (CANVAS * 2, CANVAS * 2), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, CANVAS * 2 - 1, CANVAS * 2 - 1],
                                           radius=int(CANVAS * 2 * 0.2237), fill=255)
    mask = mask.resize((CANVAS, CANVAS), Image.LANCZOS)
    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    out.paste(bg, mask=mask)
    out.save(path)


preview(os.path.join(os.path.dirname(os.path.abspath(OUT)), "preview_flat.png"))
print("wrote", OUT)
