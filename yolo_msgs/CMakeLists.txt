cmake_minimum_required(VERSION 3.8)
project(yolo_msgs)

# -------------------------------
# Compiler options (recommended)
# -------------------------------
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# -------------------------------
# Dependencies
# -------------------------------
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(std_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)

# If you later add Image/CompressedImage fields to any msg, also enable:
# find_package(sensor_msgs REQUIRED)

# -------------------------------
# Interface generation
# -------------------------------
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/Point2D.msg"
  "msg/Vector2.msg"
  "msg/Pose2D.msg"
  "msg/BoundingBox2D.msg"
  "msg/BoundingBox3D.msg"
  "msg/Mask.msg"
  "msg/KeyPoint2D.msg"
  "msg/KeyPoint2DArray.msg"
  "msg/KeyPoint3D.msg"
  "msg/KeyPoint3DArray.msg"
  "msg/Detection.msg"
  "msg/DetectionArray.msg"
  "srv/SetClasses.srv"
  DEPENDENCIES std_msgs geometry_msgs
)

# Make downstream packages able to find the generated interfaces and dependencies
ament_export_dependencies(rosidl_default_runtime std_msgs geometry_msgs)

# -------------------------------
# Lint (optional, but recommended)
# -------------------------------
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

# ==========================================================================================
# Optional (mpox/HOST-YOLOv10-specific message extensions)
# ------------------------------------------------------------------------------------------
# If you decide to add explicit staging semantics to the message layer (recommended only if
# you want strict typing instead of embedding the stage as a string), you can add messages like:
#
#   msg/LesionStage.msg
#   msg/LesionDetection.msg
#   msg/LesionDetectionArray.msg
#
# Then include them in rosidl_generate_interfaces above AND add any extra dependencies needed
# (e.g., builtin_interfaces, sensor_msgs, etc.).
# ==========================================================================================
