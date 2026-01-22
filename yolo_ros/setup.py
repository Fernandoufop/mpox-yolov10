from setuptools import setup

package_name = "host-yolo"

setup(
    name=package_name,
    version="0.0.0",
    packages=[package_name],
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    description="YOLO for ROS 2",
    license="GPL-3.0",
    extras_require={"test": ["pytest"]},
    entry_points={
        "console_scripts": [
            "yolo_node = host-yolo.yolo_node:main",
            "debug_node = host-yolo.debug_node:main",
            "tracking_node = host-yolo.tracking_node:main",
            "detect_3d_node = host-yolo.detect_3d_node:main",
        ],
    },
)
