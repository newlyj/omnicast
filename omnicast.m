clc;
clear;
%% Initial parameter
Height_R = 2048;         % Height of raw video frame
Width_R = 3840;          % Width of raw video frame
Height = 1024;
Width = 960;
name = 'test';

SNR = 1:1:16;
maxUser = 10;
Result = [];

%% Load the original video
load(strcat('../../1_read/data/','test.mat'));
% prediction data for eveluation
load(strcat('../../2_prediction/predata/','real.mat'),'real');

I = img_equirect;

%% Distortion matrix in pixel domain 
w = zeros(Height_R, Width_R);
for i = 1 :Height_R
    v = i/Height_R;
    theta = (0.5-v)*pi;
    w(i,:) = cos(theta);
end

%% Partition
%  L = NPAE(1,1,I, w,[]);
%  save([strcat('./mod/',name,'_L','.mat')],'L');
load([strcat('./mod/',name,'_L','.mat')],'L')
%% Division
[m,n] = size(L);

% check the division 
Ch = 0;
for i = 1:m
    Ch = Ch + L(i,3)*L(i,4);
end
P = 2048*3840;

% divide and compute g for each chunk
Y = zeros(Height_R, Width_R);
G = zeros(Height_R, Width_R);
Y_DCT = zeros(Height_R, Width_R);
Y0 = zeros(Height_R, Width_R);
for i = 1:m
    %% Compute g
    clear chunk;
    clear Tempdct;
    clear TempY;
    clear tempG;
    chunk = I(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1);
    tempW = w(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1);
    [tempG, ~] = ComG(chunk, tempW);
    %% DCT
    [Chunk_height, Chunk_width] = size(chunk);
    chunk = double(chunk);
    Tempdct = mirt_dctn(chunk);
    %Tempdct =chunk;
     mean_value(i) = mean(mean(Tempdct));
%     standard = Tempdct- mean_value;
    Y_DCT(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1) = Tempdct;
    %% Scaling
    %TempY = (Tempdct).*tempG;
    TempY = (Tempdct-mean_value(i)).*tempG;
    %% Normalization
    k = sqrt(L(i,3) * L(i,4)./sum(TempY.^2,'all'));
    Y(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1) = TempY * k;
    G(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1) = tempG * k;
    Y0(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1) = chunk;
    %% Check the whole power
    Power = sum((TempY * sqrt(L(i,3) * L(i,4)./sum(TempY.^2,'all'))).^2,'all')/(L(i,3) * L(i,4));
end

%% Check the whole power
% TF = isnan(Y);
% Y(TF) = 0;
Power = sum(Y.^2,'all');

%% SoftTrans
Y2 = zeros(Height_R, Width_R);
for snr = SNR
    channel = 'awgn';
    Receiver = omniTrans(Y,snr,G,channel);
    %Receiver = omniTrans(x,snr,tempG,channel);
    
    %% transform into pixel domain
    for i = 1:m
        clear chunk;
        clear chunk2;
        clear Tempidct;
        chunk = Receiver(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1);
        chunk = chunk + mean_value(i);
        Tempidct = mirt_idctn(chunk);
        %Tempidct = chunk;
        chunk2 = I(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1);
        %% compute mse of each chunk
        Cmse(i) = mean(mean((double(chunk2)-Tempidct).^2));
        Y2(L(i,1) : L(i,1) + L(i,3) - 1, L(i,2) : L(i,2) + L(i,4) - 1) = Tempidct;
    end
    
    %% evaluation
    Y1 = double(img_equirect);
    WPSNR = 0;
    PSNR = 0;
    for index = 1 : maxUser
        %% load the data
        o = real(index,:);
        % hvs
        load(strcat('../../3_multicast/result/360CastWithRedundancy/','test','_user_',int2str(index),'_snr_',int2str(15),'_hvso.mat'),'hvs_O');

        X = Y1 - double(uint8(Y2));
        %% divide the viewport
        Bottom = Height_R/2-Height/2+1+o(2);
        Up = Height_R/2+Height/2+o(2);
        Left = Width_R/2-Width/2+1+o(1);
        Right = Width_R/2+Width/2+o(1);
        viewport = X(Bottom:Up,Left:Right);
        WMSE =sum(sum(((viewport).^2).* hvs_O))/sum(sum(sum(hvs_O)));
        % WPSNR in pixel domain
        WPSNR = WPSNR + 10*log10(255^2/WMSE)/maxUser;
        x = find(Cmse<1000);
        X = Cmse(x);
        PSNR = PSNR + 10*log10(255^2/(sum(X)/length(X)))/maxUser;
    end
        Result = [Result; WPSNR];
end
plot(SNR,Result);
save([strcat('../../3_multicast/result/','test','_omnicast.mat')],'Result');