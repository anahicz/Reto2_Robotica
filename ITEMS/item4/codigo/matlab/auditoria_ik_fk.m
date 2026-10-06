clc;
clear;
close all;

q = [-5.09 -85.51 50.44 19.16 5.80 -45.70];

meta = [218.5 -76.3 285.7];

pos = fk(q);

error_x = abs(pos(1) - meta(1));
error_y = abs(pos(2) - meta(2));
error_z = abs(pos(3) - meta(3));
error_cartesiano = norm(pos - meta);

fprintf('q = [%.2f %.2f %.2f %.2f %.2f %.2f] grados\n', q);
fprintf('meta = [%.2f %.2f %.2f] mm\n', meta);
fprintf('fk(q) = [%.2f %.2f %.2f] mm\n', pos);
fprintf('error x = %.2f mm\n', error_x);
fprintf('error y = %.2f mm\n', error_y);
fprintf('error z = %.2f mm\n', error_z);
fprintf('error cartesiano = %.2f mm\n', error_cartesiano);

function pos = fk(q)
d1 = 134.75;
a2 = -110;
a3 = -96;
d4 = 63.4;
d5 = 75.05;
d6 = 50;

a1 = dh(q(1), d1, 0, 90);
a2_matriz = dh(q(2) - 90, 0, a2, 0);
a3_matriz = dh(q(3), 0, a3, 0);
a4 = dh(q(4) - 90, d4, 0, 90);
a5 = dh(q(5) + 90, d5, 0, -90);
a6 = dh(q(6), d6, 0, 0);

t06 = a1 * a2_matriz * a3_matriz * a4 * a5 * a6;
pos = t06(1:3, 4)';
end

function A = dh(theta, d, a, alpha)
A = [cosd(theta), -sind(theta)*cosd(alpha), ...
sind(theta)*sind(alpha), a*cosd(theta);
sind(theta), cosd(theta)*cosd(alpha), ...
-cosd(theta)*sind(alpha), a*sind(theta);
0, sind(alpha), cosd(alpha), d;
0, 0, 0, 1];
end
