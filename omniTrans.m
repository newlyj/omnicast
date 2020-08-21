function After_DCT = omniTrans(Y,snr,g,channel)
%% Initial
Pn = 10.^(((-1) * snr) / 10);
[m,n] = size(Y);
TransmitSignal = Y(:);

%% added
% Height_R = 2048;         % Height of raw video frame
% Width_R = 3840;          % Width of raw video frame
% Height = 1024;
% Width = 960;
% k = Height*Width/(Height_R*Width_R);

Noise = repmat(sqrt(Pn),[length(TransmitSignal),1]) .* randn(length(TransmitSignal),1);
switch channel
case 'rice'
    Channel = (v_channel/sqrt(2)) .* randn(length(TransmitSignal),1)+m_channel;
case 'awgn'
    Channel = 1;
end
Receivedsignal = Channel .* TransmitSignal + Noise;
%Receivedsignal = Channel .* TransmitSignal;
After_PAU = reshape(Receivedsignal,[m,n]);

%% demodualtion
After_DCT = After_PAU ./ g;
%After_DCT = After_PAU;

TF = isinf(After_DCT);
After_DCT(TF) = 0;
    

 end

