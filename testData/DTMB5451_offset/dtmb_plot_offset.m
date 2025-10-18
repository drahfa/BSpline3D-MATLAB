x_bow = load('DTMB5415_bow_offset_x.dat');
y_bow = load('DTMB5415_bow_offset_y.dat');
z_bow = load('DTMB5415_bow_offset_z.dat');

x_main = load('DTMB5415_main_offset_x.dat');
y_main = load('DTMB5415_main_offset_y.dat');
z_main = load('DTMB5415_main_offset_z.dat');


figure; hold on;
for i=1:length(x_bow)
    plot3(x_bow(i,:),y_bow(i,:),z_bow(i,:),'r.-'); 
%    plot3(x_main(i,:),y_main(i,:),z_main(i,:),'b.'); 
%     pause(1)
end
axis equal

figure; hold on;
j = 17;
plot(y_bow(j,:),z_bow(j,:),'r.-')
%plot(y_main(j,:),z_main(j,:),'b.')
axis equal

data_collect = [ y_bow(j,:)' z_bow(j,:)'];
save dtmb_station_17.dat data_collect -ascii