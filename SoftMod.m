function SoftMod(name,w,h,cw,ch)


%% File Load (DCT values)
%load(strcat('./../Video/',name,'_result/softcast_ydct_qp_0_gop_',int2str(g),'.mat'));
load(strcat('./dct/softcast_ydct','.mat'));
%% Describe simulation parameter
Resized_height = h;       % Height of video frame
Resized_width = w;        % Width of video frame
Chunk_width = cw;           % Width of one chunk
Chunk_height = ch;          % Height of one chunk
GOP_size = 1;               % GOP size

%% Decide the following process consider luminance or color component
% Now, I skipped color components
Frames = Y_DCT;

%% DCT values are divided into chunks and then calculate the variance of each chunk
l = 1;
for i = 1:GOP_size
    for j = 1:Chunk_height:Resized_height
        for k = 1:Chunk_width:Resized_width
            % Calculate the mean of each PAU 
            mean_value(l) = mean(mean(Frames(j:j+Chunk_height-1,k:k+Chunk_width-1,i)));
            % Calculate the variance of each PAU
            total = 0;
            for j1 = j:j+Chunk_height-1
                for k1 = k:k+Chunk_width-1
                    total = total + (Frames(j1,k1,i) - mean_value(l)).^2;
                end
            end
            if total~=0
                standard(l) = total / (Chunk_height*Chunk_width);
                %standard(l) = total;
            else
                standard(l) = min(standard);
            end
            % Subtract mean value from each chunk 
            Chunk(1:Chunk_height,1:Chunk_width,l) = Frames(j:j+Chunk_height-1,k:k+Chunk_width-1,i) - mean_value(l);
            l = l + 1;
        end
    end
end
save([strcat('./mod/',name,'_chunks','.mat')],'Chunk');
save([strcat('./mod/',name,'_lambda','.mat')],'standard');
save([strcat('./mod/',name,'_m','.mat')],'mean_value');


