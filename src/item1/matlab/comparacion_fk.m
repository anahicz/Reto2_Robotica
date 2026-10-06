clc;
clear;
close all;

poses = [
17 -29 43 13 -23 -53;
-37 15 -21 -32 27 -67;
43 -12 34 27 -19 -47
];

reales = [
60.70 -68.60 406.60;
25.50 -72.20 362.30;
21.50 -78.60 416.50
];

fprintf('comparacion con el jetcobot\n');
for i = 1:size(poses, 1)
pos = fk(poses(i,:));

error_x = abs(pos(1) - reales(i,1));
error_y = abs(pos(2) - reales(i,2));
error_z = abs(pos(3) - reales(i,3));

error_promedio = (error_x + error_y + error_z) / 3;
error_euclidiano = norm(pos - reales(i,:));

if error_euclidiano <= 10
estado = 'CUMPLE';
else
estado = 'NO CUMPLE';
end

fprintf('pose %d\n', i);
fprintf('error x = %.2f mm\n', error_x);
fprintf('error y = %.2f mm\n', error_y);
fprintf('error z = %.2f mm\n', error_z);
fprintf('error promedio = %.2f mm\n', error_promedio);
fprintf('error euclidiano = %.2f mm (criterio <= 10 mm: %s)\n', ...
error_euclidiano, estado);
end

function pos = fk(q)
d1 = 134.75;
a2 = -110;
a3 = -96;
d4 = 63.4;
d5 = 75.05;
d6 = 50;

theta1 = q(1);
theta2 = q(2) - 90;
theta3 = q(3);
theta4 = q(4) - 90;
theta5 = q(5) + 90;
theta6 = q(6);

a1 = dh(theta1, d1, 0, 90);
a2_matriz = dh(theta2, 0, a2, 0);
a3_matriz = dh(theta3, 0, a3, 0);
a4 = dh(theta4, d4, 0, 90);
a5 = dh(theta5, d5, 0, -90);
a6 = dh(theta6, d6, 0, 0);

t06 = a1 * a2_matriz * a3_matriz * a4 * a5 * a6;
pos = t06(1:3, 4)';
end

function A = dh(theta, d, a, alpha)
A = [cosd(theta), -sind(theta)*cosd(alpha), sind(theta)*sind(alpha), a*cosd(theta);
sind(theta), cosd(theta)*cosd(alpha), -cosd(theta)*sind(alpha), a*sind(theta);
0, sind(alpha), cosd(alpha), d;
0, 0, 0, 1];
end
