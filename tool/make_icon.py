"""앱 아이콘 생성 스크립트. 실행: python tool/make_icon.py
assets/icon/icon.png (1024x1024, 배경 포함) 과 assets/icon/icon_fg.png (Android adaptive 전경, 투명) 을 만든다.
디자인: 크림색 배경 위에 무지개색으로 반쯤 칠한 별 + 크레파스."""
import math
import os

from PIL import Image, ImageDraw

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
os.makedirs(OUT, exist_ok=True)

BG = (255, 243, 214)
INK = (43, 43, 43)
STRIPES = [(229, 57, 53), (251, 140, 0), (253, 216, 53), (67, 160, 71), (30, 136, 229), (142, 36, 170)]
CRAYON = (236, 64, 122)


def star_pts(cx, cy, ro, ri, n=5):
    pts = []
    for i in range(n * 2):
        r = ro if i % 2 == 0 else ri
        a = -math.pi / 2 + i * math.pi / n
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def draw_fg(s=1.0):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    cx, cy = SIZE / 2 - 30 * s, SIZE / 2 + 10 * s
    pts = star_pts(cx, cy, 380 * s, 165 * s)
    # 별 모양 마스크 안에 무지개 가로줄, 오른쪽 아래 절반은 흰색(아직 안 칠한 곳)
    mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(mask).polygon(pts, fill=255)
    color = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
    d = ImageDraw.Draw(color)
    top, bot = cy - 380 * s, cy + 310 * s
    h = (bot - top) / len(STRIPES)
    for i, c in enumerate(STRIPES):
        d.rectangle([0, top + i * h, SIZE, top + (i + 1) * h + 1], fill=c)
    d.rectangle([cx + 20 * s, 0, SIZE, SIZE], fill=(255, 255, 255))  # 오른쪽 절반은 아직 안 칠한 곳
    img.paste(color, (0, 0), mask)
    d = ImageDraw.Draw(img)
    d.line(pts + [pts[0]], fill=INK, width=int(26 * s), joint="curve")
    # 크레파스 (오른쪽 아래, 대각선)
    ang = math.radians(-40)
    L, W = 260 * s, 64 * s
    bx, by = cx + 170 * s, cy + 120 * s
    ux, uy = math.cos(ang), math.sin(ang)
    px, py = -uy, ux
    body = [(bx - px * W / 2, by - py * W / 2), (bx + px * W / 2, by + py * W / 2),
            (bx + px * W / 2 + ux * L, by + py * W / 2 + uy * L), (bx - px * W / 2 + ux * L, by - py * W / 2 + uy * L)]
    tip = [(bx - px * W / 2, by - py * W / 2), (bx + px * W / 2, by + py * W / 2), (bx - ux * 90 * s, by - uy * 90 * s)]
    d.polygon(body, fill=CRAYON, outline=INK)
    d.polygon(tip, fill=(250, 200, 215), outline=INK)
    d.line(body + [body[0]], fill=INK, width=int(14 * s), joint="curve")
    d.line(tip + [tip[0]], fill=INK, width=int(14 * s), joint="curve")
    return img


bg = Image.new("RGBA", (SIZE, SIZE), BG + (255,))
Image.alpha_composite(bg, draw_fg()).convert("RGB").save(os.path.join(OUT, "icon.png"))
fg = draw_fg().resize((int(SIZE * 0.66),) * 2, Image.LANCZOS)
canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
off = (SIZE - fg.width) // 2
canvas.paste(fg, (off, off), fg)
canvas.save(os.path.join(OUT, "icon_fg.png"))
print("done")
