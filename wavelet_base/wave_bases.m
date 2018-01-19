%----------------------------------------------------------------------------
function [daughter,fourier_factor,coi,dofmin] = ...
	wave_bases(mother,k,scale,param);

mother = upper(mother);
n = length(k);

if (strcmp(mother,'MORLET'))  %-----------------------------------  Morlet
	if (param == -1), param = 6.;, end
	k0 = param;
	expnt = -(scale.*k - k0).^2/2.*(k > 0.);
	norm = sqrt(scale*k(2))*(pi^(-0.25))*sqrt(n);    
	daughter = norm*exp(expnt);
	daughter = daughter.*(k > 0.);    
	fourier_factor = (4*pi)/(k0 + sqrt(2 + k0^2)); 
	coi = fourier_factor/sqrt(2);                  
	dofmin = 2;                                    
else
	error('Mother must be MORLET')
end

return
