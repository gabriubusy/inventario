"""Renders the A4 logo (three boxes in tones) into every icon the app uses."""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

GRANATE = (0x7A, 0x1F, 0x2B, 255)
CAJAS = [  # x, y, w, h, color on a 64-unit grid
    (22, 11, 20, 18, (0xE9, 0xB8, 0xBF, 255)),
    (10, 32, 20, 18, (0xFF, 0xFF, 0xFF, 255)),
    (34, 32, 20, 18, (0xF4, 0xD9, 0xDD, 255)),
]
ESCALA = 8  # supersampling for smooth edges


def logo(px, fondo_redondeado=True, margen=0.0):
    """Logo at px×px. margen shrinks the boxes toward the centre (maskable)."""
    s = px * ESCALA
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    u = s / 64
    if fondo_redondeado:
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=14 * u, fill=GRANATE)
    else:
        d.rectangle([0, 0, s, s], fill=GRANATE)
    k = 1 - margen
    c = 32 * u
    for x, y, w, h, color in CAJAS:
        x0 = c + (x * u - c) * k
        y0 = c + (y * u - c) * k
        d.rounded_rectangle(
            [x0, y0, x0 + w * u * k, y0 + h * u * k], radius=3 * u * k, fill=color
        )
    return img.resize((px, px), Image.LANCZOS)


def panel(ancho, alto, lado):
    """Granate panel with the logo's boxes centred, for the installer wizard."""
    img = Image.new("RGB", (ancho, alto), GRANATE[:3])
    marca = logo(lado)
    img.paste(marca, ((ancho - lado) // 2, (alto - lado) // 2), marca)
    return img


def main(raiz):
    raiz = Path(raiz)
    tamanos = [16, 20, 24, 32, 40, 48, 64, 128, 256]
    base = logo(256)
    base.save(
        raiz / "windows/runner/resources/app_icon.ico",
        sizes=[(t, t) for t in tamanos],
        append_images=[logo(t) for t in tamanos],
    )
    logo(32).save(raiz / "web/favicon.png")
    logo(192).save(raiz / "web/icons/Icon-192.png")
    logo(512).save(raiz / "web/icons/Icon-512.png")
    logo(192, fondo_redondeado=False, margen=0.2).save(
        raiz / "web/icons/Icon-maskable-192.png"
    )
    logo(512, fondo_redondeado=False, margen=0.2).save(
        raiz / "web/icons/Icon-maskable-512.png"
    )
    instalador = raiz / "installer"
    for factor, sufijo in ((1, ""), (2, "@2x")):
        chico = Image.new("RGB", (55 * factor, 55 * factor), (255, 255, 255))
        marca = logo(55 * factor)
        chico.paste(marca, (0, 0), marca)
        chico.save(instalador / f"asistente_pequeno{sufijo}.bmp")
        panel(164 * factor, 314 * factor, 96 * factor).save(
            instalador / f"asistente_grande{sufijo}.bmp"
        )
    logo(512).save(raiz / "installer/logo_512.png")


if __name__ == "__main__":
    main(sys.argv[1])
