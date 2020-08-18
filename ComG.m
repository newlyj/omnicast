function [g, D] = ComG(chunk, w)
    %% Generate DCT basis matrix
    [Chunk_height, Chunk_width] = size(chunk);
    Cdct = mirt_dctn(chunk);
    chunk = double(chunk);
    F = chunk./max(max(chunk));
    Wf = w.* F.^2;
    %Wf = w;
    %% DCT transform 
    %% Compute lambda of the current chunk
    standard = zeros([Chunk_height, Chunk_width], 'double');
    mean_value = mean(mean(Cdct));
    for i = 1 : Chunk_height
        for j = 1 : Chunk_width
            %standard(i,j) = (Cdct(i,j)- mean_value).^2/(Chunk_height * Chunk_width);
            standard(i,j) = (Cdct(i,j)- mean_value).^2;
        end
    end
    
    g = sqrt(sqrt(Wf./standard));
    
    %% find inf in g;
%     TF = isinf(g);
%     g(TF) = 0;
    
    D = sum(sum(sqrt(Wf.*(Cdct).^2)))^2;
end