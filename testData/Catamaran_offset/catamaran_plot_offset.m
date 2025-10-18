x_hull_in = load('catamaran_offset_x_hull_in.dat');
y_hull_in = load('catamaran_offset_y_hull_in.dat');
z_hull_in = load('catamaran_offset_z_hull_in.dat');

x_hull_out = load('catamaran_offset_x_hull_out.dat');
y_hull_out = load('catamaran_offset_y_hull_out.dat');
z_hull_out = load('catamaran_offset_z_hull_out.dat');

x_top_in = load('catamaran_offset_x_top_in.dat');
y_top_in = load('catamaran_offset_y_top_in.dat');
z_top_in = load('catamaran_offset_z_top_in.dat');

x_top_out = load('catamaran_offset_x_top_out.dat');
y_top_out = load('catamaran_offset_y_top_out.dat');
z_top_out = load('catamaran_offset_z_top_out.dat');


figure; hold on;
for i=1:length(x_top)
    plot3(x_hull_in(i,:),y_hull_in(i,:),z_hull_in(i,:),'r.-'); 
    plot3(x_hull_out(i,:),y_hull_out(i,:),z_hull_out(i,:),'b.-'); 
    plot3(x_top_in(i,:),y_top_in(i,:),z_top_in(i,:),'k.-'); 
    plot3(x_top_out(i,:),y_top_out(i,:),z_top_out(i,:),'m.-'); 
%     pause(1)
end
axis equal

figure; hold on;
j = 11;
plot(y_hull_in(j,:),z_hull_in(j,:),'r.-')
plot(y_hull_out(j,:),z_hull_out(j,:),'b.-')
plot(y_top_in(j,:),z_top_in(j,:),'k.-')
plot(y_top_out(j,:),z_top_out(j,:),'m.-')
axis equal