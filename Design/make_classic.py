#!/usr/bin/env python3
"""Build the "Classic" Icon Composer variant from the original 2022 icon.

The original paintbrush glyph is lifted straight out of the old 1024 px PNG,
cleaned up, vectorised with potrace and split into its two natural pieces
(head and handle) so each can be a separate Liquid Glass layer. Background
and grid are shared with the Fresh variant so the comparison isolates the
brush shape.

usage: make_classic.py <old-icon.png> <fresh AppIcon.icon> <output.icon>
"""
import json
import os
import subprocess
import sys
from collections import deque

import numpy as np
import potrace
from PIL import Image, ImageDraw, ImageFilter

SRC, FRESH, OUT = sys.argv[1:4]
ASSETS = os.path.join(OUT, "Assets")
os.makedirs(ASSETS, exist_ok=True)

CANVAS = 1024
SS = 2  # trace at 2048 for smoother curves

COL = {
    "bg_top": (0.075, 0.215, 0.470),
    "bg_bottom": (0.020, 0.060, 0.190),
    "head": (0.000, 0.960, 1.000),
    "handle": (0.000, 0.800, 1.000),
}


def p3(c, a=1.0):
    return "display-p3:%.5f,%.5f,%.5f,%.5f" % (c[0], c[1], c[2], a)


def hexcol(c):
    return "#%02X%02X%02X" % tuple(int(round(v * 255)) for v in c)


# ---------------------------------------------------------------- mask
im = Image.open(SRC).convert("RGB")
r, g, b = [np.asarray(ch, dtype=np.int32) for ch in im.split()]
glyph = (g > 170) & (b > 200)
mask = Image.fromarray((glyph * 255).astype(np.uint8), "L")
mask = mask.resize((CANVAS * SS, CANVAS * SS), Image.LANCZOS)
mask = mask.filter(ImageFilter.GaussianBlur(radius=float(os.environ.get('BLUR', '2.5'))))
binary = np.asarray(mask) >= 128
H, W = binary.shape
print("foreground pixels:", int(binary.sum()))


# ---------------------------------------------------------------- components
def label_components(bin_img):
    labels = np.zeros(bin_img.shape, dtype=np.int32)
    comps = []
    nxt = 0
    ys, xs = np.nonzero(bin_img)
    for sy, sx in zip(ys, xs):
        if labels[sy, sx]:
            continue
        nxt += 1
        q = deque([(sy, sx)])
        labels[sy, sx] = nxt
        count = 0
        while q:
            y, x = q.popleft()
            count += 1
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                ny, nx = y + dy, x + dx
                if 0 <= ny < H and 0 <= nx < W and bin_img[ny, nx] and not labels[ny, nx]:
                    labels[ny, nx] = nxt
                    q.append((ny, nx))
        comps.append((nxt, count))
    return labels, comps


labels, comps = label_components(binary)
comps = sorted(comps, key=lambda c: -c[1])
print("components:", comps[:5])
big = [c for c in comps if c[1] > 0.005 * H * W]
assert len(big) == 2, "expected head + handle, got %d big components" % len(big)

# The head is the piece whose centroid is further up/right.
pieces = {}
for lab, _ in big:
    ys, xs = np.nonzero(labels == lab)
    pieces[lab] = (xs.mean() - ys.mean())
head_lab = max(pieces, key=pieces.get)
handle_lab = min(pieces, key=pieces.get)


# ---------------------------------------------------------------- potrace
def xy(p):
    return (p.x, p.y) if hasattr(p, 'x') else tuple(p)


def trace_to_path(bin_comp):
    bmp = potrace.Bitmap(~bin_comp)  # potracer traces the False/dark pixels
    path = bmp.trace(turdsize=20, alphamax=float(os.environ.get('ALPHAMAX', '1.0')), opticurve=True, opttolerance=float(os.environ.get('OPTTOL', '0.2')))
    d = []
    s = 1.0 / SS
    for curve in path:
        x0, y0 = xy(curve.start_point)
        d.append("M %.2f %.2f" % (x0 * s, y0 * s))
        for seg in curve:
            ex, ey = xy(seg.end_point)
            if seg.is_corner:
                cx, cy = xy(seg.c)
                d.append("L %.2f %.2f L %.2f %.2f" % (cx * s, cy * s, ex * s, ey * s))
            else:
                c1x, c1y = xy(seg.c1)
                c2x, c2y = xy(seg.c2)
                d.append("C %.2f %.2f %.2f %.2f %.2f %.2f" % (c1x * s, c1y * s, c2x * s, c2y * s, ex * s, ey * s))
        d.append("Z")
    return " ".join(d)


def write_svg(name, d, colour):
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">\n'
           '  <path d="%s" fill="%s" fill-rule="evenodd"/>\n</svg>\n' % (d, hexcol(colour)))
    with open(os.path.join(ASSETS, name), "w") as f:
        f.write(svg)


write_svg("head.svg", trace_to_path(labels == head_lab), COL["head"])
def fit_hole_circle(comp_mask):
    """Find the enclosed hole of a component; return (filled mask, cx, cy, r) in 1024 space."""
    outside = np.zeros_like(comp_mask)
    q = deque()
    for y in range(H):
        for x in (0, W - 1):
            if not comp_mask[y, x] and not outside[y, x]:
                outside[y, x] = True
                q.append((y, x))
    for x in range(W):
        for y in (0, H - 1):
            if not comp_mask[y, x] and not outside[y, x]:
                outside[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < H and 0 <= nx < W and not comp_mask[ny, nx] and not outside[ny, nx]:
                outside[ny, nx] = True
                q.append((ny, nx))
    hole = ~comp_mask & ~outside
    ys, xs = np.nonzero(hole)
    if len(xs) == 0:
        return comp_mask, None
    cx, cy = xs.mean() / SS, ys.mean() / SS
    r = (len(xs) / np.pi) ** 0.5 / SS
    print("hole centre %.1f, %.1f radius %.1f" % (cx, cy, r))
    return comp_mask | hole, (cx, cy, r)


handle_mask, circle = fit_hole_circle(labels == handle_lab)
handle_d = trace_to_path(handle_mask)
if circle and os.environ.get("HOLE_CIRCLE", "1") == "1":
    cx, cy, r = circle
    handle_d += " M %.2f %.2f A %.2f %.2f 0 1 0 %.2f %.2f A %.2f %.2f 0 1 0 %.2f %.2f Z" % (
        cx - r, cy, r, r, cx + r, cy, r, r, cx - r, cy)
write_svg("handle.svg", handle_d, COL["handle"])

# shared grid from the Fresh variant
with open(os.path.join(FRESH, "Assets", "grid.png"), "rb") as src, open(os.path.join(ASSETS, "grid.png"), "wb") as dst:
    dst.write(src.read())


# ---------------------------------------------------------------- icon.json
def layer(name, image, fill, glass=True):
    return {
        "fill": fill,
        "glass": glass,
        "image-name": image,
        "name": name,
        "position": {"scale": 1, "translation-in-points": [0, 0]},
    }


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
        group([layer("Head", "head.svg", {"automatic-gradient": p3(COL["head"])})], tvalue=0.4),
        group([layer("Handle", "handle.svg", {"automatic-gradient": p3(COL["handle"])})], tvalue=0.45),
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
    for name in ["handle.svg", "head.svg"]:
        png = os.path.join(os.path.dirname(path), "preview_" + name + ".png")
        subprocess.run(["rsvg-convert", "-w", str(CANVAS), "-h", str(CANVAS),
                        os.path.join(ASSETS, name), "-o", png], check=True)
        bg.alpha_composite(Image.open(png).convert("RGBA"))
        os.remove(png)
    mask = Image.new("L", (CANVAS * 2, CANVAS * 2), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, CANVAS * 2 - 1, CANVAS * 2 - 1],
                                           radius=int(CANVAS * 2 * 0.2237), fill=255)
    mask = mask.resize((CANVAS, CANVAS), Image.LANCZOS)
    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    out.paste(bg, mask=mask)
    out.save(path)


preview(os.path.join(os.path.dirname(os.path.abspath(OUT)), "preview_classic.png"))
print("wrote", OUT)
