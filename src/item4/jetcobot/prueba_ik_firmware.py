import time

meta = [218.5, -76.3, 285.7]
objetivo = meta

x, y, z = objetivo

coords = mc.get_coords()
rx, ry, rz = coords[3], coords[4], coords[5]

mc.send_coords([x, y, z, rx, ry, rz], 15, 1)

time.sleep(8)

q = mc.get_angles()

print("meta:", objetivo)
print("angulos:", q)
