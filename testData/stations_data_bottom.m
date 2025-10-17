reduction = 0.0;

Station(1).x	=[	1.1	1.1	1.1	1.1];
Station(1).y	=[	0	0.518	1.022	1.395];
Station(1).z	=[	0	0.25	0.5	0.683];
					
Station(2).x	=[	2.2	2.2	2.2	2.2];
Station(2).y	=[	0	0.518	1.022	1.395];
Station(2).z	=[	0	0.25	0.5	0.683];
					
Station(3).x	=[	3.3	3.3	3.3	3.3];
Station(3).y	=[	0	0.518	1.022	1.395];
Station(3).z	=[	0	0.25	0.5	0.683];
					
Station(4).x	=[	4.4	4.4	4.4	4.4];
Station(4).y	=[	0	0.518	1.022	1.395];
Station(4).z	=[	0	0.25	0.5	0.683];
					
Station(5).x	=[	5.5	5.5	5.5	5.5];
Station(5).y	=[	0	0.518	1.022	1.395];
Station(5).z	=[	0	0.25	0.5	0.683];
					
Station(6).x	=[	6.05	6.05	6.05	6.05];
Station(6).y	=[	0	0.504	1.001	1.368];
Station(6).z	=[	0	0.25	0.5	0.688];
					
Station(7).x	=[	6.6	6.6 	6.6   6.6 ];
Station(7).y	=[	0	0.482	0.963	1.337];
Station(7).z	=[	0	0.25	0.5	0.7];
					
Station(8).x	=[	7.7	7.7	7.7	7.7];
Station(8).y	=[	0	0.396	0.819	1.229];
Station(8).z	=[	0.02	0.25	0.5	0.747];

Station(9).x	=[	8.8	8.8	8.8	8.8	8.8];
Station(9).y	=[	0	0.225	0.599	0.964	1.058];
Station(9).z	=[	0.099	0.25	0.5	0.75	0.808];

Station(10).x	=[	9.9	9.9	9.9	9.9];
Station(10).y	=[	0	0.321	0.66	0.855];
Station(10).z	=[	0.27	0.5	0.75	0.892];
					
Station(11).x	=[	11	11	11	11];
Station(11).y	=[	0	0.236	0.545	0.563];
Station(11).z	=[	0.56	0.75	1	1.009];

Station(12).x	=[	11.55	11.55	11.55];
Station(12).y	=[	0	0.279	0.378];
Station(12).z	=[	0.765	1	1.089];

Station(13).x	=[	12.1	12.1];
Station(13).y	=[	0	0.199];
Station(13).z	=[	1	1.171];

Station(14).x	=[	12.65	12.65	12.65];
Station(14).y	=[	0	0.272	0.369];
Station(14).z	=[	1.278	1.5	1.645];

% This is to discretize the points to be fitted in any amount of CP's
hold on
for i=1:length(Station)
    Y_temp = Station(i).y-reduction*Station(i).y;
    Z_temp = Station(i).z-reduction*Station(i).z;
    [Y,Z] = discretize(Y_temp,Z_temp,0.005);
    X = ones(1,length(Y))*Station(i).x(1)-reduction*Station(i).x(1);
    station(i).y = Y;
    station(i).z = Z;
    station(i).x = X;
%      plot3(X,Y,Z,'.-r','markersize',5);
end

% % This loop is to see the original data
% hold on;
% for i = 1:length(Station)
%     X = Station(i).x-reduction;
%     Y = Station(i).y-reduction;
%     Z = Station(i).z-reduction;
%     plot3(X,Y,Z,'.-r','markersize',5);
% end