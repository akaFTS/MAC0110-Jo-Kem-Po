% abrimos a imagem e enviamos para o método correto
function decompress (compressedImg, method, k, h)
        imraw = imread(compressedImg);
        imraw = double(imraw);

        tic
        if method == 1
                newImg = bilinearDecompress (imraw, k, h);
        else
                newImg = bicubicDecompress (imraw, k, h);
        end
        toc
        %escrevemos a imagem final

        imwrite(newImg, "out_test/jungle/decompressed_2-k1-3-h1.png", "Quality", 100);
end

% interpolador bilinear
function newImg = bilinearDecompress (imraw, k, h)
        n = size(imraw, 1);
        ns = n + (n-1)*k;
        newMat = zeros(ns, ns, 3);
        
        % matrizes X e Y, guardando as coordenadas dos novos pontos
        % entre 0 e h (que são as coordenadas dos pixels conhecidos)
        % em tese, as coordenadas deveriam estar entre xb + i*h e xb + (i+1)*h
        % porém, na prática, na hora de interpolar temos que substrair xb + i*h de cada ponto
        % portanto podemos ignorar desde o começo e trabalhar apenas com [0, h]
        % também já vamos realizar as operações para obter [1 x 1 x], e [1 1 y y] pois valem o mesmo para
        % todo quadrado de lado h dentro da matriz interpolada, graças a nossa abstração de [0, h]
        % o motivo desses vetores de X e Y será explicado mais abaixo
        gen = h * [0: 1/(k+1): 1]';
        um = ones(size(gen, 1), 1);
        X = [um gen um gen];
        Y = [um um gen gen]';
        
        % matriz de Hs
        H = [1 0 0 0; 1 0 h 0; 1 h 0 0; 1 h h h.^2];
        
        
        % vamos varrer cada pixel conhecido e trabalhar no quadrado
        % de lado h em que ele é o canto superior esquerdo
        % por esse mesmo motivo, os pixels da borda direita e da borda inferior
        % não serão varridos

        for i = 1:n-1
                for j = 1:n-1
                
                        % valores dos vertices
                        f00 = imraw(i, j, :);
                        f01 = imraw(i, j+1, :);
                        f10 = imraw(i+1, j, :);
                        f11 = imraw(i+1, j+1, :);
                        
                        % montamos a matriz e achamos coeficientes
                        funcs = [f00; f01; f10; f11];
                        
                        coefs(:, :, 1) = H\funcs(:, :, 1);
                        coefs(:, :, 2) = H\funcs(:, :, 2);
                        coefs(:, :, 3) = H\funcs(:, :, 3);
                        
                        % agora, a formula é p(x,y) = [1 x y xy][a0; a1; a2; a3]
                        % mas esse formato não nos permite obter valores para todas as
                        % combinações de x e y de uma vez só
                        % porém, este formato permite:
                        %
                        % [1 x 1 x]    *   | a0 0   0   0   | *  | 1 |
                        %                  | 0   a1 0   0   |    | 1 |
                        %                  | 0   0   a2 0   |    | y |
                        %                  | 0   0   0   a3 |    | y |
                        %
                        % é possivel provar que a expressão acima é equivalente à inicial,
                        % porém nela podemos adicionar mais linhas na matriz X e mais
                        % colunas na matriz Y, e no final teremos uma matriz quadrada com
                        % um elemento pra cada combinação de X por Y, ou seja, cada
                        % elemento equivale a um pixel novo.
                        
                        
                        % transformamos coefs numa matriz diagonal
                        % lembrando que isso deve ser feito 3 vezes, para R, G e B
                        diag1 = diag(coefs(:, :, 1));
                        diag2 = diag(coefs(:, :, 2));
                        diag3 = diag(coefs(:, :, 3));
                        
                        % interpolamos todos os pontos
                        V(:, :, 1) = X * diag1 * Y;
                        V(:, :, 2) = X * diag2* Y;
                        V(:, :, 3) = X * diag3 * Y;
                        
                        % adicionamos o quadrado que interpolamos no canvas newMat que
                        % formará a imagem interpolada no final
                        starti = (i-1)*(k+1) + 1;
                        startj = (j-1)*(k+1) + 1;
                        endi =  (i)*(k+1) + 1;
                        endj =  (j)*(k+1) + 1;
                        newMat(starti:endi, startj:endj, :) = V;
                        
                end
        end
        
        % convertemos nossa matriz para uma matriz de inteiros positivos 8-bits, 
        % que é o padrão pedido para imagens
        newImg = uint8(newMat);
end



function newImg = bicubicDecompress(imraw, k, h)
        n = size(imraw, 1);
        ns = n + (n-1)*k;
        newMat = zeros(ns, ns, 3);
        
        % matrizes X e Y, guardando as coordenadas dos novos pontos
        % entre 0 e h (que são as coordenadas dos pixels conhecidos)
        % em tese, as coordenadas deveriam estar entre xb + i*h e xb + (i+1)*h
        % porém, na prática, na hora de interpolar temos que substrair xb + i*h de cada ponto
        % portanto podemos ignorar desde o começo e trabalhar apenas com [0, h]
        % também já vamos realizar as operações para obter [1 x x2 x3], pois é o mesmo para todo os pontos
        % e ao invés de usarmos um vetor 1x4 como na fórmula, vamos usar um kx4, pois assim obtemos
        % resultados para todos os pontos novos no intervalo ao mesmo tempo
        X = h * [0: 1/(k+1): 1]';
        X = [X.^0 X.^1 X.^2 X.^3];
        Y = X';
        
        % matriz B
        B = [1 0 0 0; 0 0 1 0; -3/(h^2) 3/(h^2) -2/h -1/h; 2/(h^3) -2/(h^3) h^(-2) h^(-2)];
        
        % fazemos uma moldura na matriz repetindo a primeira e ultima linhas/colunas duas vezes
        % como nossa derivada usa dados do ponto anterior e do próximo, exigiria tratamento
        % nas bordas da imagem. Com essa moldura, podemos agir normalmente
        framed = [imraw(1, :, :); imraw; imraw(end, :, :)];
        framed = [framed(:, 1, :) framed framed(:, end, :)];
        
        % vamos varrer cada pixel conhecido e trabalhar no quadrado
        % de lado h em que ele é o canto superior esquerdo
        % por esse mesmo motivo, os pixels da borda direita e da borda inferior
        % não serão varridos
        % lembrando que estamos numa matriz com borda de tamanho 1, por isso ir de 2:n
        % equivale a ir de 1:n-1 na matriz real
        for i = 2:n
                for j = 2:n
                
                        % valores dos vertices
                        f00 = framed(i, j, :);
                        f01 = framed(i, j+1, :);
                        f10 = framed(i+1, j, :);
                        f11 = framed(i+1, j+1, :);
                        
                        % valores auxiliares
                        fZ0 = framed(i-1, j, :);
                        f0Z = framed(i, j-1, :);
                        fZ1 = framed(i-1, j+1, :);
                        f1Z = framed(i+1, j-1, :);
                        fZZ = framed(i-1, j-1, :);
                        
                        f20 = framed(i+2, j, :);
                        f02 = framed(i, j+2, :);
                        f21 = framed(i+2, j+1, :);
                        f12 = framed(i+1, j+2, :);
                        f22 = framed(i+2, j+2, :);
                        
                        f2Z = framed(i+2, j-1, :);
                        fZ2 = framed(i-1, j+2, :);
                        
                        
                        % derivadas parciais
                        fx00 = (f10 - fZ0)/(2*h);
                        fx01 = (f11 - fZ1)/(2*h);                        
                        fx10 = (f20 - f00)/(2*h);
                        fx11 = (f21 - f01)/(2*h);
                        
                        fy00 = (f01 - f0Z)/(2*h);
                        fy01 = (f02 - f00)/(2*h);
                        fy10 = (f11 - f1Z)/(2*h);
                        fy11 = (f12 - f10)/(2*h);
                        
                        % parciais auxiliares
                        fyZ0 = (fZ1 - fZZ)/(2*h);
                        fyZ1 = (fZ2 - fZ0)/(2*h);
                        fy20 = (f21 - f2Z)/(2*h);
                        fy21 = (f22 - f20)/(2*h);
                        
                        % derivadas mistas
                        fxy00 = (fy10 - fyZ0)/(2*h);
                        fxy01 = (fy11 - fyZ1)/(2*h);
                        fxy10 = (fy20 - fy00)/(2*h);
                        fxy11 = (fy21 - fy01)/(2*h);
                        
                        % montamos a matriz e fazemos a conta
                        funcs = [f00   f01   fy00   fy01;
                                       f10   f11   fy10   fy11;
                                       fx00 fx01 fxy00 fxy01;
                                       fx10 fx11 fxy10 fxy11];
                        
                        %precisa ser multiplicado separadamente para cada camada de cor
                        coefs(:, :, 1) = B * funcs(:, :, 1) * B';
                        coefs(:, :, 2) = B * funcs(:, :, 2) * B';
                        coefs(:, :, 3) = B * funcs(:, :, 3) * B';                    
                        
                        % interpolamos todos os pontos
                        V(:, :, 1) = X * coefs(:, :, 1) * Y;
                        V(:, :, 2) = X * coefs(:, :, 2) * Y;
                        V(:, :, 3) = X * coefs(:, :, 3) * Y;
                        
                        % adicionamos o quadrado que interpolamos no canvas newMat que
                        % formará a imagem interpolada no final
                        starti = (i-2)*(k+1) + 1;
                        startj = (j-2)*(k+1) + 1;
                        endi =  (i-1)*(k+1) + 1;
                        endj =  (j-1)*(k+1) + 1;
                        newMat(starti:endi, startj:endj, :) = V;
                        
                end
        end
        
        % convertemos nossa matriz para uma matriz de inteiros positivos 8-bits, 
        % que é o padrão pedido para imagens
        newImg = uint8(newMat);
end