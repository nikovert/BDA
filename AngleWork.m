%close all; clear all; clc;

%% Pitch angle noise capacities:
%load('Ericnoise.mat');

PitchSpeed = phidot;
PitchAngle = phi;


%%

PitchSpeedPreIco = PitchSpeed(1:T_ico_ind);
PitchSpeedBrn = PitchSpeed(T_ico_ind:T_brn_ind);
PitchSpeedPar = PitchSpeed(T_brn_ind:T_par_ind);

PitchAnglePreIco = PitchAngle(1:T_ico_ind);
PitchAngleBrn = PitchAngle(T_ico_ind:T_brn_ind);
PitchAnglePar = PitchAngle(T_brn_ind:T_par_ind);

TV_PreIco = log_time(1:T_ico_ind);
TV_Brn = log_time(T_ico_ind:T_brn_ind);
TV_Par = log_time(T_brn_ind:T_par_ind);

figure('Name','Angle speed and angle pre Icognition');
plot(TV_PreIco,PitchSpeedPreIco);
hold on;
plot(TV_PreIco,PitchAnglePreIco);
legend('Speed [°/s]','Angle [°]');

figure('Name','Angle speed and angle durnig burning');
plot(TV_Brn,PitchSpeedBrn);
hold on;
plot(TV_Brn,PitchAngleBrn);
legend('Speed [°/s]','Angle [°]');

figure('Name','Angle speed and angle after burnout');
plot(TV_Par,PitchSpeedPar);
hold on;
plot(TV_Par,PitchAnglePar);
legend('Speed [°/s]','Angle [°]');

%% Calculate Offset for better integration of the anglespeed:

PitchSpeedOffset = mean(PitchSpeedPreIco)
NewPitchSpeed = PitchSpeed - PitchSpeedOffset;

n = 10;
NewPitchSpeed = filter(1/n*ones(1,n),1,NewPitchSpeed);
% integrate new
NewPitchAngle = zeros(length(PitchAngle),1); %Start angle should be zero if rocket faces up straight.
for k = 2:length(NewPitchSpeed)
    dT = log_time(k)-log_time(k-1);
    NewPitchAngle(k) = NewPitchAngle(k-1) + NewPitchSpeed(k-1) * dT +(NewPitchSpeed(k) - NewPitchSpeed(k-1))/2 * dT;
end

figure('Name','Speed')
plot(NewPitchSpeed(1:T_par_ind));
hold on;
plot(PitchSpeed(1:T_par_ind));
legend('new','old');

figure('Name','Angle')
plot(NewPitchAngle(1:T_par_ind));
hold on;
plot(PitchAngle(1:T_par_ind));
legend('new','old');
set(gca, 'XTick', sort([T_ico_ind T_brn_ind T_par_ind, get(gca, 'XTick')]));
%xticks([T_ico_ind T_brn_ind T_par_ind])
%xticklabels({'Icognition','Burnout','Parachut ejection'})
%ax2 = copyobj(gca, gcf);                             %// Create a copy the axes
%set(ax2, 'XTick', T_ico_ind, 'label', 'Ico'); 

%% Generate the AR-Models
n = 100;

p_brn = polyfit(log_time(T_ico_ind:T_brn_ind),phi(T_ico_ind:T_brn_ind)',3);
p_upflight = polyfit(log_time(T_brn_ind:T_par_ind),phi(T_brn_ind:T_par_ind)',3);

phi_noise_brn = phi(T_ico_ind:T_brn_ind)' - polyval(p_brn,log_time(T_ico_ind:T_brn_ind));
phi_noise_upflight = phi(T_brn_ind:T_par_ind)' - polyval(p_upflight,log_time(T_brn_ind:T_par_ind));

phi_noise_brn = resample(phi_noise_brn,log_time(T_ico_ind:T_brn_ind),1000);
phi_noise_upflight = resample(phi_noise_upflight,log_time(T_brn_ind:T_par_ind),1000);

[h_brn varBrn] = aryule(phi_noise_brn,n);
[h_upflight varUpflight] = aryule(phi_noise_upflight,n);

test_noise_brn = filter(1,h_brn,randn(1,length(phi_noise_brn))*sqrt(varBrn));
test_noise_upflight = filter(1,h_upflight,randn(1,length(phi_noise_upflight))*sqrt(varUpflight));

figure(1)
plot(10*log10(pwelch(phi_noise_brn)));
hold on;
plot(10*log10(pwelch(test_noise_brn)));
legend('original','generated');
hold off;

figure(2)
plot(10*log10(pwelch(phi_noise_upflight)));
hold on;
plot(10*log10(pwelch(test_noise_upflight)));
legend('original','generated');
hold off;

