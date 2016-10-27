g = 2
for n = 200:200
	out = strcat('imgs_sintetica/',int2str (n), '.jpg');
	n2 = g*(1+n)+1;
	disp(n2);
	space = (1:n2)*0.5;
	x = repmat(space, n2, 1);
	I = zeros (n2, n2, 3, 'double');

	I(:,:,1) = sin(x);
	I(:,:,3) = sin(x);
	I(:,:,2) = (sin(x)+sin(x'))/2.0;

    I = uint8 (round ((I+1)*127.50));
    imwrite (I, out, 'Quality', 100);
endfor