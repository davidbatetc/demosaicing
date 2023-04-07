import cv2 as cv
import numpy as np
import pathlib
import matplotlib.pyplot as plt
import demosaic


def load_image(path: pathlib.Path) -> np.array:
    return cv.imread(
        str(path),
    )[:, :, ::-1]


def main() -> None:
    data_path = pathlib.Path("data")
    image = load_image(data_path / "kodak" / "kodim23.png")

    mos_image = demosaic.mosaic(image, demosaic.SensorAlignment.RGGB)
    dem_image = demosaic.demosaic(
        mos_image, demosaic.SensorAlignment.RGGB, demosaic.Method.BILINEAR
    )

    _, axes = plt.subplots(1, 2)
    axes[0].imshow(mos_image, cmap="gray", vmin=0, vmax=255)
    axes[1].imshow(dem_image)

    plt.show()


if __name__ == "__main__":
    main()
