import time

poses = [
    [17, -29, 43, 13, -23, -53],
    [-37, 15, -21, -32, 27, -67],
    [43, -12, 34, 27, -19, -47]
]

for i, pose in enumerate(poses, 1):

     print(f"\npose {i}")
     print("angulos:", pose)

     mc.send_angles(pose, 10)

     time.sleep(5)

     coords = mc.get_coords()

     print("posicion del JetCobot:")
     print(f"x = {coords[0]:.2f} mm")
     print(f"y = {coords[1]:.2f} mm")
     print(f"z = {coords[2]:.2f} mm")
     print(f"[ {coords[0]:.2f} , {coords[1]:.2f} , {coords[2]:.2f} ] mm")

print("\ntodas las poses fueron llevadas a cabo")
