import matlab.engine


rho = matlab.double([10, 11, 7, 4, 4, 4, 9, 9, 6, 3, 3, 2, 5, 4, 6, 4, 10])
eng = matlab.engine.start_matlab()
eng.eval("figure(1)")
eng.eval("subplot('position',[0.1 0.1 0.8 0.75])")
eng.my_polar(rho, '111', 'k', nargout=0)
input('Please Press Any Key to Exit!\n')
