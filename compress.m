function compress (originalImg, k)    % ler imagem e calcular o tamanho dela    img = imread(originalImg);    p = size(img, 1);        % pegar só as linhas e colunas i tais que i = 1 mod (k+1)    newImg = img(1:(k+1):p, 1:(k+1):p, :);        % construir a imagem comprimida    imwrite(newImg, "compressed.png");    end