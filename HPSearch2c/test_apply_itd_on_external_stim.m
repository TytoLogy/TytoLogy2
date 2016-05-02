close all
clear
clc

millis = 1e3;
if( false ),
    itd_max = 1000;
    itd = itd_max;
else
    itd = 1000;
end
% read test file
[ temp, fs ] = wavread( '750Hz.wav' );

% generate time vector in milliseconds
t = [ 0:length( temp )-1]./fs * millis;

data = zeros( 2, length( temp ));
data( 1, : ) = temp;
data( 2, : ) = temp;

ramp_len = 5; % in milliseconds

shifted = apply_itd_on_external_stim( data, fs, itd, ramp_len );

figure;
plot( t, temp );
hold all;
plot( t, shifted', '--' );
% legend( 'Original', 'Untouched', 'Shifted' );
% xlim([ 0, 250 ]);

% err( :, 1 ) = shifted( 1, : ) - temp';
% err( :, 2 ) = shifted( 1, : ) - temp';
% 
% figure;
% plot( t, abs( err ).^2 );
% xlim([ 0, 10 ]);
% title( 'quadratic error' )
% xlabel( 'time [ms]' )
% soundsc( shifted', fs )
% soundsc( temp, fs )
% eof