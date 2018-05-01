clear all; clc; close all; % remove that
% Sensordata
% seqNmbr time altitude airspeed pressure temp ax ay az gx gy gz gx gy gz
% GPS data
% empty time number of sats hdop lat lon altitude
hasGPS = false;

log_time = [];     % Time of IMO sample: synch. with gyro/accel Nx[s]
log_imu_a = [];     % Accelerometer: Accels    ax, ay, az  Nx3*[g]
log_imu_g = [];     % Gyroscope, Angular rates gx, gy, gz  Nx3*[°/s]
log_temp  = [];     % Temperature?
log_press = [];     % Pressure sensor:[time[s], pressure[hPa], airspeed]
log_h     = [];     % Nx[time altituded]
log_airspeed = [];  % [airspeed]

% Open log file uncomment for different Flights.
%load('Tir_test3d2_Paths.mat');
%load('Tir_test3d1_Paths.mat');
load('18_11_18_Eric_Paths.mat');
%load('18_11_18_Greg_Paths.mat');

if hasGPS
    log_GPS_time = [];
    log_GPS_pos = [];
    log_GPS_sat = [];
end

for k = 1:size(Paths);
    
fid = fopen(Paths(k,:), 'r');
if fid == -1
   error('Cannot open file: %s', FileName);
end

% Skip first 2 lines
% Line = fgetl(fid);
% Line = fgetl(fid);

     isEOB = false;
     iData = 0;
     while ~isEOB && ~feof(fid)
%          i=i+1
        % Read new line
        Line = fgetl(fid);
        if ~ischar(Line) || strncmp(Line, 'EOB', 3)
           isEOB = true;
        else
            % Read line of logfile
            [data, num, err, ind1] = sscanf(Line, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 15);
            %sample_time = data(2); 
            %if(sample_time > 185 & sample_time < 300)
            %sample_id = char(data(2)); 
            log_time = [log_time; data(2)];
            %log_data = [log_data; data(3:end)'];
            log_h = [log_h;data(3)];
            log_airspeed = [log_airspeed; data(4)];
            log_press = [log_press; data(5)];
            log_temp = [log_temp; data(6)];
            log_imu_a = [log_imu_a; data(7) data(8) data(9)];
            log_imu_g = [log_imu_g; data(10) data(11) data(12)];     
            end
     end
%   end

fclose(fid);
end

if hasGPS
for k = 1:size(PathsGPS);
    
fid = fopen(PathsGPS(k,:), 'r');
if fid == -1
   error('Cannot open file: %s', FileName);
end

     isEOB = false;
     iData = 0;
     while ~isEOB && ~feof(fid)
        % Read new line
        Line = fgetl(fid);
        if ~ischar(Line) || strncmp(Line, 'EOB', 3)
           isEOB = true;
        else
            % Read line of logfile
            [data, num, err, ind1] = sscanf(Line, '%f %f %f %f %f %f', 6);
            %sample_time = data(2); 
            %if(sample_time > 185 & sample_time < 300)
            log_GPS_time = [log_GPS_time; data(1)];
            log_GPS_sat = [log_GPS_sat;data(2)];
            log_GPS_pos = [log_GPS_pos; data(3) data(4) data(5) data(6)];     
            end
     end

fclose(fid);
end
startTime = log_GPS_time(1);
log_GPS_time(:) = log_GPS_time(:)-startTime;
log_GPS_time(:) = log_GPS_time(:)/1000000;
end

% Adjust time vector;
startTime = log_time(1);
log_time(:) = log_time(:)-startTime;
log_time(:) = log_time(:)/1000000;


%%
plot(log_time,log_h);
hold on;
%plot(log_time,log_press);
%plot(log_GPS_time, log_GPS_pos(:,4)+22);

%% Testing

%figure('Name','Accel without/with gyro')
anglex = zeros(length(log_time),1);
angley = zeros(length(log_time),1);
anglez = zeros(length(log_time),1);


for k = 2:length(log_time)
    dT = log_time(k) - log_time(k-1);
    anglex(k) = anglex(k-1) + ((log_imu_g(k,1)-log_imu_g(k-1,1))/2)*dT;
    angley(k) = angley(k-1) + ((log_imu_g(k,2)-log_imu_g(k-1,2))/2)*dT;
    anglez(k) = anglez(k-1) + ((log_imu_g(k,3)-log_imu_g(k-1,3))/2)*dT;
end

axx = log_imu_a(:,1) .* cos(anglex*pi/180)*9.81;
axy = log_imu_a(:,1) .* cos(angley*pi/180)*9.81;
axz = log_imu_a(:,1) .* cos(anglez*pi/180)*9.81;
ayx = log_imu_a(:,2) .* cos(anglex*pi/180)*9.81;
ayy = log_imu_a(:,2) .* cos(angley*pi/180)*9.81;
ayz = log_imu_a(:,2) .* cos(anglez*pi/180)*9.81;
azx = log_imu_a(:,3) .* cos(anglex*pi/180)*9.81;
azy = log_imu_a(:,3) .* cos(angley*pi/180)*9.81;
azz = log_imu_a(:,3) .* cos(anglez*pi/180)*9.81;

figure('Name','X');
plot(log_time,log_imu_a(:,1));
hold on;
plot(log_time,log_imu_g(:,1))
plot(log_time,anglex);
plot(log_time,axx);
plot(log_time,axy);
plot(log_time,axz);
legend('ax','angle speed','angle','acceloration with angle x','acceloration with angle y','acceloration with angle z');
hold off;

figure('Name','Y');
plot(log_time,log_imu_a(:,2));
hold on;
plot(log_time,log_imu_g(:,2))
plot(log_time,angley);
plot(log_time,ayx);
plot(log_time,ayy);
plot(log_time,ayz);
legend('ay','angle speed','angle','acceloration with angle x','acceloration with angle y','acceloration with angle z');hold off;

figure('Name','Z');
plot(log_time,log_imu_a(:,3));
hold on;
plot(log_time,log_imu_g(:,3))
plot(log_time,anglez);
plot(log_time,azz);
plot(log_time,azx);
plot(log_time,azy);
plot(log_time,azz);
legend('az','angle speed','angle','acceloration with angle x','acceloration with angle y','acceloration with angle z');
hold off;


%% Find Icongnition Time und Burnduration:
%declare which acceloration vecort should be used
acc_mes = axx;

T_ico_ind = 1; %Icogntiono Time index
while acc_mes(T_ico_ind) < 20
   T_ico_ind = T_ico_ind + 1; 
end

T_ico = log_time(T_ico_ind); %Icogniotion time

T_brn_ind = T_ico_ind; %Burnout time index
while acc_mes(T_brn_ind) > 10
    T_brn_ind = T_brn_ind +1;
end

T_brn = log_time(T_brn_ind); %Burnout time


T_par_ind = T_brn_ind; % Parachute time index

while abs(acc_mes(T_par_ind)) < 15
   T_par_ind = T_par_ind + 1; 
end

T_par = log_time(T_par_ind); % Parachute time



%% Calculate Mean, Variance and Bandwith before Icognition, during Burntime and during ubpflight until parachute activation from Accelerometer:
fs = 1/(log_time(end)/length(log_time));
figure('Name','Polyfit,Autocorrelation and power density spectrum before icognition Accel');

% Mean and Variance before icognition
decayTime = 3;
a_mean = mean(acc_mes(1:T_ico_ind-decayTime));
a_var_preIco  = var(acc_mes(1:T_ico_ind-decayTime));

subplot(4,1,1);
plot(log_time(1:T_ico_ind-decayTime),acc_mes(1:T_ico_ind-decayTime),log_time(1:T_ico_ind-decayTime),ones(1,length(log_time(1:T_ico_ind-decayTime)))*a_mean);

% Bandwith
a_noise_preIco = acc_mes(1:T_ico_ind-decayTime)-a_mean;
acorr_preIco = xcorr(acc_mes(1:T_ico_ind-decayTime)-a_mean);
N = length(acorr_preIco);

subplot(4,1,2);
plot([-N/2:N/2-1],acorr_preIco);
title('Autocorrelation');

subplot(4,1,3);
if length(acorr_preIco) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(acorr_preIco),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(acc_mes(1:T_ico_ind-decayTime)-a_mean);
title('Histogram');

% fing the best polynom to recreate curve during burntime:
figure('Name','Autocorrelation and Leistungsdichtespektrum between Icognition and Burnout');
riseTime = 9;
decayTime = 3;
p_brn = polyfit(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime),2);
p_brn_curve = polyval(p_brn,log_time(T_ico_ind+riseTime:T_brn_ind-decayTime));
a_var_brn = var(acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);

subplot(4,1,1);
plot(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime),log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),p_brn_curve);

% Bandwith
a_noise_brn = acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve;
acorr_brn = xcorr(acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);
N = length(acorr_brn);

subplot(4,1,2);
stem([-N/2:N/2-1],acorr_brn);
title('Autocorrelation');

subplot(4,1,3);
if length(acorr_brn) < 2048
    N = 2048;
end
stem([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(acorr_brn),N))));
ylabel('Energy in [dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(acc_mes(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);
title('Histogram');

% fing the best polynom to recreate curve during upflight:
figure('Name','Autocorrelation and Leistungsdichtespektrum after Burnout');
riseTime = 20;
decayTime = 12;
p_upflight = polyfit(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime),2);
p_upflight_curve =polyval(p_upflight,log_time(T_brn_ind+riseTime:T_par_ind-decayTime));
a_var_upflight = var(acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve)

subplot(4,1,1);
plot(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime),log_time(T_brn_ind+riseTime:T_par_ind-decayTime),p_upflight_curve);

% Bandwith
a_noise_upflight = acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve;
acorr_upflight = xcorr(acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);
N = length(acorr_upflight);
subplot(4,1,2);
stem([-N/2:N/2-1],acorr_upflight);
title('Autocorrelation');

subplot(4,1,3);
if length(acorr_upflight) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(acorr_upflight),N))));
ylabel('Energy in [dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(acc_mes(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);
title('Histogram');

%% Same for Barometer pressure:

figure('Name','Polyfit,Autocorrelation and power density spectrum before icognition Pressure');

decayTime = 3;
p_mean = mean(log_press(1:T_ico_ind-decayTime));
p_var_preIco = var(log_press(1:T_ico_ind-decayTime));

subplot(4,1,1);
plot(log_time(1:T_ico_ind-decayTime),log_press(1:T_ico_ind-decayTime),log_time(1:T_ico_ind-decayTime),ones(T_ico_ind-decayTime,1).*p_mean);
title('mean vs real');

% Bandwith
p_noise_preIco = log_press(1:T_ico_ind-decayTime)-p_mean
pcorr_preIco = xcorr(p_noise_preIco);
N = length(pcorr_preIco);

subplot(4,1,2);
plot([-N/2:N/2-1],pcorr_preIco);
title('Autocorrelation');

subplot(4,1,3);
if length(pcorr_preIco) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(pcorr_preIco),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_press(1:T_ico_ind-decayTime)-p_mean);
title('Histogram');

figure('Name','Autocorrelation and power density spectrum between Icognition and Burnout Pressure');
%find the best polynom to recreate curve during burntime:
riseTime = 6;
decayTime = 3;
p_brn = polyfit(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),log_press(T_ico_ind+riseTime:T_brn_ind-decayTime),2);
p_brn_curve = polyval(p_brn,log_time(T_ico_ind+riseTime:T_brn_ind-decayTime));
p_var_brn = var(log_press(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);

%For checking purpose:
subplot(4,1,1);
plot(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),log_press(T_ico_ind+riseTime:T_brn_ind-decayTime),log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),p_brn_curve);
title('Poly vs real');

% Bandwith
p_noise_brn = log_press(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve;
pcorr_brn = xcorr(p_noise_brn);
N = length(pcorr_brn);

subplot(4,1,2);
plot([-N/2:N/2-1],pcorr_brn);
title('Autocorrelation');

subplot(4,1,3);
if length(pcorr_brn) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(pcorr_preIco),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_press(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);
title('Histogram');

figure('Name','Autocorrelation and power density spectrum after Burnout Pressure');
%find the best polynom to recreate curve during upflight:
riseTime = 3;
decayTime = 20;
p_upflight = polyfit(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),log_press(T_brn_ind+riseTime:T_par_ind-decayTime),2);
p_upflight_curve =polyval(p_upflight,log_time(T_brn_ind+riseTime:T_par_ind-decayTime));
p_var_upflight = var(log_press(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);

%For checking purpose:
subplot(4,1,1);
plot(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),log_press(T_brn_ind+riseTime:T_par_ind-decayTime),log_time(T_brn_ind+riseTime:T_par_ind-decayTime),p_upflight_curve);
title('Poly vs real');

% Bandwith
p_noise_upflight = log_press(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve;
pcorr_upflight = xcorr(p_noise_upflight);
N = length(pcorr_upflight);
subplot(4,1,2);
plot([-N/2:N/2-1],pcorr_upflight);
title('Autocorrelation');

subplot(4,1,3);
if length(pcorr_upflight) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(pcorr_preIco),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_press(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);
title('Histogram');
%% Same for Barometer Temperature:

figure('Name','Polyfit,Autocorrelation and power density spectrum before icognition Temperatur');
decayTime = 3;
T_mean = mean(log_temp(1:T_ico_ind-decayTime));
T_var_preIco  = var(log_temp(1:T_ico_ind-decayTime));

subplot(4,1,1);
plot(log_time(1:T_ico_ind-decayTime),log_temp(1:T_ico_ind-decayTime),log_time(1:T_ico_ind-decayTime),ones(T_ico_ind-decayTime,1)*T_mean);

% Bandwith
T_noise_preIco = log_temp(1:T_ico_ind-decayTime)-T_mean;
Tcorr_preIco = xcorr(T_noise_preIco);
N = length(Tcorr_preIco);

subplot(4,1,2);
plot([-N/2:N/2-1],Tcorr_preIco);
title('Autocorrelation');

subplot(4,1,3);
if length(Tcorr_preIco) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(Tcorr_preIco),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_temp(1:T_ico_ind-decayTime)-T_mean);
title('Histogram');

figure('Name','Autocorrelation and power density spectrum between Icognition and Burnout Temperatur');
%find the best polynom to recreate curve during burntime:
riseTime = 6;
decayTime = 3;
p_brn = polyfit(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),log_temp(T_ico_ind+riseTime:T_brn_ind-decayTime),2);
p_brn_curve = polyval(p_brn,log_time(T_ico_ind+riseTime:T_brn_ind-decayTime));
T_var_brn = var(log_temp(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);

%For checking purpose:
subplot(4,1,1);
plot(log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),log_temp(T_ico_ind+riseTime:T_brn_ind-decayTime),log_time(T_ico_ind+riseTime:T_brn_ind-decayTime),p_brn_curve);

% Bandwith
T_noise_brn = log_temp(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve;
Tcorr_brn = xcorr(T_noise_brn);
N = length(Tcorr_brn);

subplot(4,1,2);
plot([-N/2:N/2-1],Tcorr_brn);
title('Autocorrelation');

subplot(4,1,3);
if length(Tcorr_brn) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(Tcorr_brn),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_temp(T_ico_ind+riseTime:T_brn_ind-decayTime)-p_brn_curve);
title('Histogram');

figure('Name','Autocorrelation and power density spectrum after Burnout Temperatur');

%find the best polynom to recreate curve during upflight:
riseTime = 3;
decayTime = 2;
p_upflight = polyfit(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),log_temp(T_brn_ind+riseTime:T_par_ind-decayTime),2);
p_upflight_curve =polyval(p_upflight,log_time(T_brn_ind+riseTime:T_par_ind-decayTime));
T_var_upflight = var(log_temp(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);

%For checking purpose:
subplot(4,1,1);
plot(log_time(T_brn_ind+riseTime:T_par_ind-decayTime),log_temp(T_brn_ind+riseTime:T_par_ind-decayTime),log_time(T_brn_ind+riseTime:T_par_ind-decayTime),p_upflight_curve);

% Bandwith
T_noise_upflight = log_temp(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve;
Tcorr_upflight = xcorr(T_noise_upflight);
N = length(Tcorr_upflight);

subplot(4,1,2);
plot([-N/2:N/2-1],Tcorr_upflight);
title('Autocorrelation');

subplot(4,1,3);
if length(Tcorr_upflight) < 2048
    N = 2048;
end
plot([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(Tcorr_upflight),N))));
ylabel('[dB]'), xlabel('Frequency in [Hz]');
title('power density spectrum');

subplot(4,1,4);
histogram(log_temp(T_brn_ind+riseTime:T_par_ind-decayTime)-p_upflight_curve);
title('Histogram');

%% Get Bandwith of the different Noises

% fs = 1/(log_time(end)/length(log_time));
% % Acceleration
% %plot(log_time(1:T_ico_ind-decayTime),az(1:T_ico_ind-decayTime));
% 
% %plot([-1:2/2048:1-2/2048],abs(fftshift(fft((az(1:T_ico_ind-decayTime)-a_mean).^2,2048))));
% 
% figure('Name','Autocorrelation and Leistungsdichtespektrum vor Start');
% decayTime = 3;
% acorr = xcorr(azz(1:T_ico_ind-decayTime)-a_mean);
% N = length(acorr);
% subplot(2,1,1);
% stem([-N/2:N/2-1],acorr);
% subplot(2,1,2);
% stem([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(acorr),N))));
% ylabel('Energy in [dB]'), xlabel('Frequency in [Hz]');


% figure('Name','Autocorrelation and Leistungsdichtespektrum Icognition bis Burnout');
% 
% riseTime = 6;
% decayTime = 3;
% acorr = xcorr(az(T_ico_ind+riseTime:T_brn_ind-decayTime)-);
% N = length(acorr);
% subplot(2,1,1);
% stem([-N/2:N/2-1],acorr);
% subplot(2,1,2);
% stem([-fs:(2*fs)/N:fs-2*fs/N],10*log10(fftshift(fft(abs(acorr),N))));
% ylabel('Energy in [dB]'), xlabel('Frequency in [Hz]');

% Gyrometer

% Barometer



%% Path generation
%clear all;
%hasGPS = true;
%PathsGPS(1,:) = '../SensorData/EPFLData/24.02.2018.1 - Tir_test3D/gps_data_004_1519469099934';
%PathsGPS(2,:) = '../SensorData/EPFLData/24.02.2018.2-Tir_test3D_fix/gps_data_001_1519479278350';
% PathsGPS(3,:) = '../SensorData/EPFLData/18.11.2017.2 - Greg/telemetry_data_3_1511012347617';
% PathsGPS(4,:) = '../SensorData/EPFLData/18.11.2017.2 - Greg/telemetry_data_4_1511012369307';
% PathsGPS(5,:) = '../SensorData/EPFLData/18.11.2017.2 - Greg/telemetry_data_5_1511012401268';

