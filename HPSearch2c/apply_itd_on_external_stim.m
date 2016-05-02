function data_out = apply_itd_on_external_stim( data_in, Fs, usitd, ramp_len )
%-------------------------------------------------------------------------
% Input Arguments:
%	data_in		signal duration (ms)
%	Fs			output sampling rate
%	usitd		interaural time difference in us (ignored if mono signal)
%	caldata		caldata structure (caldata.mag, caldata.freq, caldata.phase)
%					*if no calibration is desired, replace caldata with value 0
% 
    zero_padding_len = 0.15; % 150 ms
    num_zeros = round( zero_padding_len*Fs ); % number of samples used for zero padding
    
    data_in = [ zeros( 2, num_zeros ), data_in, zeros( 2, num_zeros )];
    
    % compute # of samples in stim
    stimlen = length( data_in );

    % for speed's sake, get the nearest power of 2 to the desired output length
    NFFT = 2.^( nextpow2( stimlen ));
    % length of real part of FFT
    fftbins = 1+floor(NFFT/2);

    % generate the frequency bounds for the FFT
    % this saves us from having to use a for loop to assign the values
    fft_freqs = linspace( 0, Fs/2, fftbins );
    
    % compute the phases
    itd_phases = (usitd/1e6) * 2 * pi * fft_freqs;
    
    % use quadratic hann window to fade in
    data_in = apply_fade( data_in, Fs, ramp_len );
    
    spec( 1, : ) = fft( data_in( 1, : ), NFFT );
    spec( 2, : ) = fft( data_in( 2, : ), NFFT );
    
    % decide on which side the delay has to be applied
    if( usitd < 0 ),
        chan = [ 1, 2 ];
    else
        chan = [ 2, 1 ];
    end
    
    % get independent magnitude and phase of the channel to alter
    Smag = abs( spec( chan( 1 ), 1:fftbins ));
    temp_phase = angle( spec( chan( 1 ), 1:fftbins ));
    
	Sphase = temp_phase + itd_phases;   % assign phases for left and right channels & apply the itd phase
    Sreduced = complex(Smag.*cos(Sphase), Smag.*sin(Sphase)); % Sreduced is the complex form of the spectrum
    Sfft = buildfft(Sreduced);          % build the total FFT vector
    
    % then, iFFT the signal
    Sraw = real(ifft( Sfft, NFFT ));
    S_untouched = real( ifft( spec( chan( 2 ), : ), NFFT ));
    
    % keep only points we need
    S( chan( 2 ), : ) = S_untouched( 1:stimlen );
    S( chan( 1 ), : ) = Sraw( 1:stimlen );
    
    % remove padded zeros
    S = S( :, num_zeros+1 : end-num_zeros );
    
    % again use quadratic hann window to fade in
    S = apply_fade( S, Fs, ramp_len );
    
    data_out = S;
end

function out = apply_fade( in, fs, dur )
    if( nargin < 3 ),
        dur = 5;
    end
    winlen = round( fs * ( dur /1000 ));
    win = hann( 2 * winlen )';
    win = win.*win;
    out = in;
    for kk = 1:size( in, 1 ),
        out( kk, 1:winlen ) = in( kk, 1:winlen ) .* win( 1:winlen );
        out( kk, end-winlen+1:end ) = in( kk, end-winlen+1:end ) .* win( winlen+1:end );
    end
end