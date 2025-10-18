x_top = load('wpb_offset_top_x.dat');
y_top = load('wpb_offset_top_y.dat');
z_top = load('wpb_offset_top_z.dat');

x_mid = load('wpb_offset_mid_x.dat');
y_mid = load('wpb_offset_mid_y.dat');
z_mid = load('wpb_offset_mid_z.dat');

x_bot = load('wpb_offset_bottom_x.dat');
y_bot = load('wpb_offset_bottom_y.dat');
z_bot = load('wpb_offset_bottom_z.dat');


figure; hold on;
for i=1:length(x_top)
    plot3(x_top(i,:),y_top(i,:),z_top(i,:),'r.'); 
    plot3(x_mid(i,:),y_mid(i,:),z_mid(i,:),'b.'); 
    plot3(x_bot(i,:),y_bot(i,:),z_bot(i,:),'k.'); 
%     pause(1)
end

figure; hold on;
j = 11;
plot(y_top(j,:),z_top(j,:),'r.')
plot(y_mid(j,:),z_mid(j,:),'b.')
plot(y_bot(j,:),z_bot(j,:),'k.')
axis equal

% reduce the data of the middle offset
y_temp = [];
z_temp = [];
id = 1;
step = 2;
for k = 1:2:21
    y_temp= [y_temp y_mid(j,k)];
    z_temp= [z_temp z_mid(j,k)];
%     id = id+step;
end

figure; hold on;
j = 11;
plot(y_top(j,:),z_top(j,:),'r.')
plot(y_temp,z_temp,'b.')
plot(y_bot(j,:),z_bot(j,:),'k.')
axis equal

% collect the data to one set
data_collect1 = [y_top(j,:)' z_top(j,:)'];
data_collect2 = [y_temp' z_temp'];
data_collect3 = [y_bot(j,:)' z_bot(j,:)'];

data_collect = [flipud(data_collect1); flipud(data_collect2); flipud(data_collect3)];

%for count = 1:length(data_collect)
    plot(data_collect(:,1), data_collect(:,2),'-o')
%     pause(1)
%end

save wpb_data_station_11.dat data_collect -ascii

