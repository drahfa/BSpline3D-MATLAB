x = load('Series60Offset_x.dat');
y = load('Series60Offset_y.dat');
z = load('Series60Offset_z.dat');

figure; hold on;
for i=1:length(x)
    plot3(x(i,:),y(i,:),z(i,:),'r.-'); 
%     pause(1)
end
axis equal

figure; hold on;
j = 16;
plot(y(j,:),z(j,:),'r.-')
axis equal