x = load('TrawlerOffset_x.dat');
y = load('TrawlerOffset_y.dat');
z = load('TrawlerOffset_z.dat');

figure; hold on;
for i=1:length(x)
    plot3(x(i,:),y(i,:),z(i,:),'r-.'); 
%     pause(1)
end
axis equal

figure; hold on;
j = 4;
plot(y(j,:),z(j,:),'r.')
axis equal