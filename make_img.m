g = 2
for n = 200:200
	n2 = g*(1+n)+1;
	disp(n2);
	space = (1:n2)*0.5;
	x = repmat(space, n2, 1);

	I1 = zeros (n2, n2, 3, 'double');
	I2 = zeros (n2, n2, 3, 'double');
	I3 = zeros (n2, n2, 3, 'double');
	I4 = zeros (n2, n2, 3, 'double');
	I5 = zeros (n2, n2, 3, 'double');
	I6 = zeros (n2, n2, 3, 'double');


	I1(:,:,1) = sin(1.0./(x - 50.0));
	I1(:,:,2) = exp(x)/(x*x' - 30.0);
	I1(:,:,3) = x*x';

	I2(:,:,1) = tan(x*x' - 10.0);
	I2(:,:,2) = cos(x);
	I2(:,:,3) = sin(1.0./(x*x'));
	
	I3(:,:,1) = 1.0./(sqrt(x*x' - 10.0));
	I3(:,:,2) = x*x' - 10.0;
	I3(:,:,3) = cos(x^2 - 2*x*x' + x'^2);
	
	I4(:,:,1) = (x - x')^2;
	I4(:,:,2) = x;
	I4(:,:,3) = x';
	
	I5(:,:,1) = sin(x^2 - x'^2)
	I5(:,:,2) = exp(x) + x'^2;
	I5(:,:,3) = exp(x') - x^2;
	
	I6(:,:,1) = sin(x);
	I6(:,:,2) = (sin(x) + sin(x'))./2.0;
	I6(:,:,3) = sin(x);
	

    I1 = uint8 (round ((I1+1)*127.50));
    imwrite (I1, 'image_test/zoo/1.jpg', 'Quality', 100);

    I2 = uint8 (round ((I2+1)*127.50));
    imwrite (I2, 'image_test/zoo/2.jpg', 'Quality', 100);

    I3 = uint8 (round ((I3+1)*127.50));
    imwrite (I3, 'image_test/zoo/3.jpg', 'Quality', 100);

    I4 = uint8 (round ((I4+1)*127.50));
    imwrite (I4, 'image_test/zoo/4.jpg', 'Quality', 100);

    I5 = uint8 (round ((I5+1)*127.50));
    imwrite (I5, 'image_test/zoo/5.jpg', 'Quality', 100);

    I6 = uint8 (round ((I6+1)*127.50));
    imwrite (I6, 'image_test/zoo/6.jpg', 'Quality', 100);
endfor