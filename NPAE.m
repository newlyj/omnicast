function L = NPAE(top,left,I, w, LL)
   [m , n] = size(I);
   L = [];
   %% End condition 
   if m <= 16 || n <= 16
       L = [top,left,m,n];
       return;
   end
   %% Compute gi for I
   [~, d0] = ComG(I, w);
   %% divide I in vertical direction B1|B2
   B1 = I(:,1:ceil(n/2));
   B2 = I(:,ceil(n/2)+1:end);
   
   [~, D1] = ComG(B1, w(:,1:ceil(n/2)));
   [~, D2] = ComG(B2, w(:,ceil(n/2)+1:end));
   d1 = D1 + D2;
   %% divide I in horizontal direction B3_B4
   B3 = I(1:ceil(m/2),:);
   B4 = I(ceil(m/2)+1:end,:);
   
   [~, D3] = ComG(B3, w(1:ceil(m/2),:));
   [~, D4] = ComG(B4, w(ceil(m/2)+1:end,:)); 
   d2 = D3 + D4;
   
   str=['Current Divide !!!!!!!!!(m,n) = ' num2str([m,n])];
   disp(str);
   
   A = [d0 d1 d2]; 
   ind = find(A==min(A));
   if ind == 1
       L = [LL;top,left,m,n];
       return;
   elseif ind == 2
       L1 = NPAE(top,left,B1,w(:,1:ceil(n/2)),LL);
       L2 = NPAE(top,left+ceil(n/2),B2,w(:,ceil(n/2)+1:end),LL);
       L = [LL; L1; L2];
       return;
   elseif ind == 3
       L3 = NPAE(top,left,B3,w(1:ceil(m/2),:),LL);
       L4 = NPAE(top+ceil(m/2),left,B4,w(ceil(m/2)+1:end,:),LL);
       L = [LL; L3; L4];
       return;
   end
   
end
