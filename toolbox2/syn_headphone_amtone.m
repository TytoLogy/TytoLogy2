function [S, SrmsMod, SmodPhi, Smag, Sphi]  = syn_headphone_amtone( duration, Fs, freq, usitd, ModDepth, ModF, ModPhi, rad_vary, caldata )
%function [S, Srms, SrmsMod, Smag, Sphi]  = syn_headphone_amtone( duration, Fs, freq, usitd, ModDepth, ModF, ModPhi, rad_vary, caldata )
%---------------------------------------------------------------------
%	Synthesize calibrated tone for headphone output
%---------------------------------------------------------------------
%	Input Arguments:
%		duration		time of stimulus in ms
%		Fs				output sampling rate
%		freq			tone frequency
%		usitd			ITD in microseconds (+ = right ear leads, - = left ear leads)
%       ModDepth        % depth of signal modulation (pct)
%       ModF            Modulation frequency (Hz)
%       ModPhi          Modulation Phase (radians)
%		rad_vary		parameter to vary starting phase (0 = no, 1 = yes)
%		caldata         caldata structure (caldata.mag, caldata.freq, caldata.phi)
%						if no calibration is desired, replace caldata with a 
% 						single numerical value
%		
%	Output Arguments:
%		S		L & R sine data
%       SrmsMod RMS scale factor of modulated signal
%		Smag	L & R calibration magnitude
%		Sphi	L & R phase
%---------------------------------------------------------------------
%	See Also:	syn_headphone_tone, syn_headphone_amnoise
%---------------------------------------------------------------------

%---------------------------------------------------------------------
%	Felix Dollack
%	felix.dollack@googlemail.com
%
%---------------------------------------------------------------------
% Created: 
% 	16 January, 2015 (FD): adapted from syn_headphone_tone.m and
%		syn_headphone_amnoise.m
%---------------------------------------------------------------------

%% some checks on the input arguments
if nargin ~= 9
	error([mfilename ': incorrect number of input arguments']);
end
if duration <=0
	error([mfilename ': duration must be > 0'])
end

%% setup
% Sample interval
dt = 1/Fs;
% buffer size
buffer_size = ms2samples(duration, Fs);
% time vector
t = (0:buffer_size-1)*dt;
% Convert modulation depth from pct to range from 0 to 1
ModDepth = ModDepth / 100;

%% Modulation
% modulation depth factor
DMfactor = sqrt(0.3750*ModDepth^2 - ModDepth + 1);
% Modulator Phase
if isempty(ModPhi) && (ModDepth > 0)
	ModPhi = acos( (2/ModDepth) * (DMfactor - 1) + 1 );
else
	ModPhi = 0;
end

% Normalization Factor
NormF = 1 / DMfactor;
% Modulator sinusoid
modSin = 0.5 * ModDepth * cos(2*pi*ModF*t + ModPhi) - 0.5*ModDepth + 1;
% Normalized Modulator
modSin_norm = NormF * modSin;

%%
[ Stone, Smag, Sphi ] = syn_headphone_tone( duration, Fs, freq, usitd, rad_vary, caldata );

%% modulate the noise with the sinusoid
S = zeros( size( Stone ));
S(1, :) = modSin_norm .* Stone(1, :);	
S(2, :) = modSin_norm .* Stone(2, :);

%% compute rms of modulated signal
SrmsMod = rms(S');
SmodPhi = ModPhi;

% eof