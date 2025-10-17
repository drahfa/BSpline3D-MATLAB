reduction = 0.0;

Station(1).x	=[	1.1	    1.1		];
Station(1).y	=[	1.395	1.508	];
Station(1).z	=[	0.683	0.683	];

Station(2).x	=[	2.2	    2.2	    ];
Station(2).y	=[	1.395	1.508   ];
Station(2).z	=[	0.683	0.683   ];

Station(3).x	=[	3.3	     3.3    ];
Station(3).y	=[	1.395	1.508   ];
Station(3).z	=[	0.683	0.683   ];

Station(4).x	=[	4.4	    4.4		];
Station(4).y	=[	1.395	1.508   ];
Station(4).z	=[	0.683	0.683	];

Station(5).x	=[	5.5	    5.5		];
Station(5).y	=[	1.395	1.508	];
Station(5).z	=[	0.683	0.683	];

Station(6).x	=[	6.05	6.05	];
Station(6).y	=[	1.368	1.485	];
Station(6).z	=[	0.688	0.688	];

Station(7).x	=[	6.6	    6.6		];
Station(7).y	=[	1.337	1.44    ];
Station(7).z	=[	0.7	    0.7		];

Station(8).x	=[	7.7	    7.7		];
Station(8).y	=[	1.229	1.323	];
Station(8).z	=[	0.747	0.747	];

Station(9).x	=[	8.8	    8.8		];
Station(9).y	=[	1.058	1.154	];
Station(9).z	=[	0.808	0.81	];

Station(10).x	=[	9.9	    9.9		];
Station(10).y	=[	0.855	0.923	];
Station(10).z	=[	0.892	0.892	];

Station(11).x	=[	11	    11		];
Station(11).y	=[	0.563	0.621	];
Station(11).z	=[	1.009	1.009	];

Station(12).x	=[	11.55	11.55	];
Station(12).y	=[	0.378	0.432	];
Station(12).z	=[	1.089	1.089	];

Station(13).x	=[	12.1	12.1	];
Station(13).y	=[	0.199	0.225	];
Station(13).z	=[	1.171	1.171	];


% Station 14 is the special case, it is a meeting point
station(14).x	=[	12.65 12.65 12.65 12.65 12.65 12.65 12.65 12.65]-reduction*[12.65 12.65 12.65 12.65 12.65 12.65 12.65 12.65];
station(14).y	=[	0.369 0.369 0.369 0.369 0.369 0.369 0.369 0.369]-reduction*[0.369 0.369 0.369 0.369 0.369 0.369 0.369 0.369];
station(14).z	=[	1.645 1.645 1.645 1.645 1.645 1.645 1.645 1.645]-reduction*[1.645 1.645 1.645 1.645 1.645 1.645 1.645 1.645];

hold on;
for i=1:length(Station)
    Y_temp = Station(i).y-reduction*Station(i).y;
    Z_temp = Station(i).z-reduction*Station(i).z;
    [Y,Z] = discretize(Y_temp,Z_temp,0.0005);
    X = ones(1,length(Y))*Station(i).x(1)-reduction*Station(i).x(1);
    station(i).y = Y;
    station(i).z = Z;
    station(i).x = X;
%      plot3(X,Y,Z,'.-b','markersize',5);
end

% % This loop is to see the original data
% hold on;
% for i = 1:length(Station)
%     X = Station(i).x-reduction;
%     Y = Station(i).y-reduction;
%     Z = Station(i).z-reduction;
%     plot3(X,Y,Z,'.-b','markersize',5);
% end
