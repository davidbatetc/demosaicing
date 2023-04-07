from typing import Tuple

import numpy as np


class SensorAlignment:
    GBRG = 0
    GRBG = 1
    BGGR = 2
    RGGB = 3


class ColorId:
    R = 0
    G = 1
    B = 2


class Method:
    BILINEAR = 0
    MALVAR2004 = 1


def mosaic(image: np.array, sensor_alignment: SensorAlignment) -> np.array:
    assert sensor_alignment == SensorAlignment.RGGB

    out_image = np.zeros(shape=(image.shape[0], image.shape[1]), dtype=image.dtype)

    out_image[0::2, 0::2] = image[0::2, 0::2, ColorId.R]
    out_image[0::2, 1::2] = image[0::2, 1::2, ColorId.G]
    out_image[1::2, 0::2] = image[1::2, 0::2, ColorId.G]
    out_image[1::2, 1::2] = image[1::2, 1::2, ColorId.B]

    return out_image


def is_within_bounds(coord: Tuple[int, int], size: Tuple[int, int]):
    return 0 <= coord[0] < size[0] and 0 <= coord[1] < size[1]


def demosaic_bilinear(image: np.array, sensor_alignment: SensorAlignment) -> np.array:
    assert sensor_alignment == SensorAlignment.RGGB

    height = image.shape[0]
    width = image.shape[1]
    out_image = np.zeros((height, width, 3), dtype=np.float32)

    for cid in range(3):
        out_image[:, :, cid] = image

    class Dirs:
        Plus = [[1, 0], [-1, 0], [0, 1], [0, -1]]
        X = [[1, 1], [-1, -1], [1, -1], [-1, 1]]
        H = [[0, 1], [0, -1]]
        V = [[1, 0], [-1, 0]]

    for r in range(height):
        for c in range(width):
            mr = r % 2
            mc = c % 2

            if mr == 0 and mc == 0:
                fillDirs = [Dirs.Plus, Dirs.X]
                fillIds = [ColorId.G, ColorId.B]
            elif mr == 1 and mc == 1:
                fillDirs = [Dirs.Plus, Dirs.X]
                fillIds = [ColorId.G, ColorId.R]
            elif mr == 0 and mc == 1:
                fillDirs = [Dirs.H, Dirs.V]
                fillIds = [ColorId.R, ColorId.B]
            else:
                fillDirs = [Dirs.V, Dirs.H]
                fillIds = [ColorId.R, ColorId.B]

            for k in range(2):
                cid = fillIds[k]
                dirs = fillDirs[k]

                out_image[r, c, cid] = 0
                n_elems = 0
                for i in range(len(dirs)):
                    d = dirs[i]

                    if is_within_bounds((r + d[0], c + d[1]), (height, width)):
                        out_image[r, c, cid] += image[r + d[0], c + d[1]]
                        n_elems += 1

                out_image[r, c, cid] /= n_elems

    return out_image.astype(dtype=image.dtype)


def demosaic(
    image: np.array, sensor_alignment: SensorAlignment, method: Method
) -> np.array:
    if method == Method.BILINEAR:
        return demosaic_bilinear(image, sensor_alignment)
    else:
        raise NotImplementedError(f"Method {method} is not implemented.")
